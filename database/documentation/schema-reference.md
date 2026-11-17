# SAMS Database Schema Reference

Since your database is named `sams`, all the following SQL will use that database.

We will create the 19 tables in dependency order, so that foreign keys can be established correctly.

**Database conventions**

- Database: `sams`
- DBMS: MySQL 8.x
- Storage engine: InnoDB
- Character set: `utf8mb4`
- Primary keys: `BIGINT UNSIGNED AUTO_INCREMENT`
- Timestamps: `DATETIME(3)`, stored in UTC
- Status fields: `VARCHAR`, so statuses can be extended without changing the table definition.
- Historical attendance data should not be deleted when a student, teacher or other account becomes inactive.

Run the SQL in MySQL Workbench, DBeaver, phpMyAdmin or your MySQL terminal.

```
USE sams;
```

## **1. User and identity management**

These tables manage login accounts and the information associated with students and teachers.

### 1. users

**Purpose:** Stores the login account for every system user. Students, teachers and administrators all have a user account.

| Column           | Description                            |
| ---------------- | -------------------------------------- |
| `id`             | Unique user ID                         |
| `full_name`      | User's full name                       |
| `email`          | Unique email address                   |
| `password_hash`  | Hashed password                        |
| `role`           | ADMIN, TEACHER or STUDENT              |
| `status`         | PENDING, ACTIVE, SUSPENDED or INACTIVE |
| `email_verified` | Whether the email is verified          |
| `last_login_at`  | Last successful login                  |
| `created_at`     | Account creation time                  |
| `updated_at`     | Last update time                       |

```
CREATE TABLE users (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    full_name VARCHAR(150) NOT NULL,
    email VARCHAR(255) NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    role VARCHAR(20) NOT NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'PENDING',
    email_verified BOOLEAN NOT NULL DEFAULT FALSE,
    last_login_at DATETIME(3) NULL,
    created_at DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
    updated_at DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3)
        ON UPDATE CURRENT_TIMESTAMP(3),

    CONSTRAINT uq_users_email UNIQUE (email),
    CONSTRAINT chk_users_role
        CHECK (role IN ('ADMIN', 'TEACHER', 'STUDENT')),
    CONSTRAINT chk_users_status
        CHECK (status IN ('PENDING', 'ACTIVE', 'SUSPENDED', 'INACTIVE'))
) ENGINE=InnoDB;
```

### 2. students

**Purpose:** Stores student-specific information. Login credentials remain in `users`; this table stores academic and personal student information.

| Column                | Description                    |
| --------------------- | ------------------------------ |
| `id`                  | Unique student ID              |
| `user_id`             | Corresponding user account     |
| `roll_number`         | College roll number            |
| `registration_number` | University registration number |
| `date_of_birth`       | Date of birth                  |
| `phone_number`        | Contact number                 |
| `gender`              | Gender, if collected           |
| `address`             | Residential address            |
| `created_at`          | Record creation time           |
| `updated_at`          | Last update time               |

```
CREATE TABLE students (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    user_id BIGINT UNSIGNED NOT NULL,
    roll_number VARCHAR(50) NOT NULL,
    registration_number VARCHAR(100) NULL,
    date_of_birth DATE NULL,
    phone_number VARCHAR(20) NULL,
    gender VARCHAR(30) NULL,
    address TEXT NULL,
    created_at DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
    updated_at DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3)
        ON UPDATE CURRENT_TIMESTAMP(3),

    CONSTRAINT uq_students_user UNIQUE (user_id),

    CONSTRAINT fk_students_user
        FOREIGN KEY (user_id) REFERENCES users(id)
        ON DELETE RESTRICT ON UPDATE CASCADE,

    INDEX idx_students_roll_number (roll_number),
    INDEX idx_students_registration_number (registration_number)
) ENGINE=InnoDB;
```

**Design note:** `roll_number` is not globally unique here because we have not confirmed whether the college reuses roll numbers across courses or batches. We can add the appropriate unique constraint once that rule is confirmed.

### 3. teachers

**Purpose:** Stores teacher-specific information.

| Column          | Description                       |
| --------------- | --------------------------------- |
| `id`            | Unique teacher ID                 |
| `user_id`       | Corresponding user account        |
| `employee_id`   | College employee ID               |
| `phone_number`  | Contact number                    |
| `designation`   | Teacher's designation             |
| `department_id` | Department the teacher belongs to |
| `created_at`    | Record creation time              |
| `updated_at`    | Last update time                  |

```
CREATE TABLE teachers (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    user_id BIGINT UNSIGNED NOT NULL,
    employee_id VARCHAR(50) NOT NULL,
    phone_number VARCHAR(20) NULL,
    designation VARCHAR(100) NULL,
    department_id BIGINT UNSIGNED NULL,
    created_at DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
    updated_at DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3)
        ON UPDATE CURRENT_TIMESTAMP(3),

    CONSTRAINT uq_teachers_user UNIQUE (user_id),
    CONSTRAINT uq_teachers_employee_id UNIQUE (employee_id),

    CONSTRAINT fk_teachers_user
        FOREIGN KEY (user_id) REFERENCES users(id)
        ON DELETE RESTRICT ON UPDATE CASCADE,

    INDEX idx_teachers_department (department_id)
) ENGINE=InnoDB;
```

The `department_id` foreign key will be added after creating the `departments` table.

### 4. registration_requests

**Purpose:** Stores student registration requests awaiting administrator approval.

| Column                  | Description                              |
| ----------------------- | ---------------------------------------- |
| `id`                    | Unique request ID                        |
| `user_id`               | User account associated with the request |
| `requested_course_id`   | Course the student wants to join         |
| `requested_term_id`     | Optional requested academic term         |
| `requested_roll_number` | Roll number supplied by student          |
| `message`               | Additional information                   |
| `status`                | PENDING, APPROVED or REJECTED            |
| `reviewed_by`           | Administrator who reviewed it            |
| `reviewed_at`           | Review timestamp                         |
| `created_at`            | Request creation time                    |

```
CREATE TABLE registration_requests (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    user_id BIGINT UNSIGNED NOT NULL,
    requested_course_id BIGINT UNSIGNED NOT NULL,
    requested_term_id BIGINT UNSIGNED NULL,
    requested_roll_number VARCHAR(50) NULL,
    message TEXT NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'PENDING',
    reviewed_by BIGINT UNSIGNED NULL,
    reviewed_at DATETIME(3) NULL,
    created_at DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),

    CONSTRAINT fk_registration_user
        FOREIGN KEY (user_id) REFERENCES users(id)
        ON DELETE RESTRICT ON UPDATE CASCADE,

    CONSTRAINT fk_registration_reviewer
        FOREIGN KEY (reviewed_by) REFERENCES users(id)
        ON DELETE SET NULL ON UPDATE CASCADE,

    CONSTRAINT chk_registration_status
        CHECK (status IN ('PENDING', 'APPROVED', 'REJECTED')),

    INDEX idx_registration_status (status),
    INDEX idx_registration_user (user_id)
) ENGINE=InnoDB;
```

The course and term foreign keys will be added after their tables are created.

## **2. Academic management**

These tables describe the college's academic structure.

### 5. departments

**Purpose:** Stores departments such as Computer Science, Commerce and Management.

| Column            | Description            |
| ----------------- | ---------------------- |
| `id`              | Unique department ID   |
| `department_name` | Department name        |
| `department_code` | Short department code  |
| `description`     | Department description |
| `status`          | ACTIVE or INACTIVE     |
| `created_at`      | Creation time          |

```
CREATE TABLE departments (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    department_name VARCHAR(150) NOT NULL,
    department_code VARCHAR(30) NOT NULL,
    description TEXT NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'ACTIVE',
    created_at DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),

    CONSTRAINT uq_departments_name UNIQUE (department_name),
    CONSTRAINT uq_departments_code UNIQUE (department_code),

    CONSTRAINT chk_departments_status
        CHECK (status IN ('ACTIVE', 'INACTIVE'))
) ENGINE=InnoDB;
```

### 6. courses

**Purpose:** Stores academic courses such as BCA, BBA and B.Sc.

| Column           | Description           |
| ---------------- | --------------------- |
| `id`             | Unique course ID      |
| `department_id`  | Associated department |
| `course_name`    | Course name           |
| `course_code`    | Course code           |
| `duration_years` | Course duration       |
| `description`    | Course description    |
| `status`         | ACTIVE or INACTIVE    |
| `created_at`     | Creation time         |

```
CREATE TABLE courses (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    department_id BIGINT UNSIGNED NOT NULL,
    course_name VARCHAR(150) NOT NULL,
    course_code VARCHAR(30) NOT NULL,
    duration_years DECIMAL(3,1) NOT NULL,
    description TEXT NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'ACTIVE',
    created_at DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),

    CONSTRAINT uq_courses_code UNIQUE (course_code),

    CONSTRAINT fk_courses_department
        FOREIGN KEY (department_id) REFERENCES departments(id)
        ON DELETE RESTRICT ON UPDATE CASCADE,

    CONSTRAINT chk_courses_duration
        CHECK (duration_years > 0),

    CONSTRAINT chk_courses_status
        CHECK (status IN ('ACTIVE', 'INACTIVE')),

    INDEX idx_courses_department (department_id)
) ENGINE=InnoDB;
```

### 7. academic_terms

**Purpose:** Represents an academic period. It supports semesters, academic years, trimesters and custom terms.

| Column        | Description                         |
| ------------- | ----------------------------------- |
| `id`          | Unique term ID                      |
| `course_id`   | Associated course                   |
| `term_name`   | Example: Semester 1                 |
| `term_type`   | SEMESTER, YEAR, TRIMESTER or CUSTOM |
| `term_number` | Term number                         |
| `start_date`  | Term starting date                  |
| `end_date`    | Term ending date                    |
| `status`      | PLANNED, ACTIVE or COMPLETED        |

```
CREATE TABLE academic_terms (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    course_id BIGINT UNSIGNED NOT NULL,
    term_name VARCHAR(100) NOT NULL,
    term_type VARCHAR(20) NOT NULL,
    term_number INT UNSIGNED NULL,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'PLANNED',
    created_at DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),

    CONSTRAINT fk_terms_course
        FOREIGN KEY (course_id) REFERENCES courses(id)
        ON DELETE RESTRICT ON UPDATE CASCADE,

    CONSTRAINT chk_terms_type
        CHECK (term_type IN ('SEMESTER', 'YEAR', 'TRIMESTER', 'CUSTOM')),

    CONSTRAINT chk_terms_status
        CHECK (status IN ('PLANNED', 'ACTIVE', 'COMPLETED')),

    CONSTRAINT chk_terms_dates
        CHECK (end_date >= start_date),

    INDEX idx_terms_course (course_id)
) ENGINE=InnoDB;
```

### 8. class_sections

**Purpose:** Represents a particular class, batch or section under a course and academic term.

Example: BCA, Semester 3, Section A.

| Column         | Description              |
| -------------- | ------------------------ |
| `id`           | Unique section ID        |
| `course_id`    | Associated course        |
| `term_id`      | Associated academic term |
| `section_name` | Section name             |
| `capacity`     | Maximum student capacity |
| `status`       | ACTIVE or INACTIVE       |

```
CREATE TABLE class_sections (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    course_id BIGINT UNSIGNED NOT NULL,
    term_id BIGINT UNSIGNED NOT NULL,
    section_name VARCHAR(50) NOT NULL,
    capacity INT UNSIGNED NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'ACTIVE',
    created_at DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),

    CONSTRAINT uq_sections_term_name
        UNIQUE (term_id, section_name),

    CONSTRAINT fk_sections_course
        FOREIGN KEY (course_id) REFERENCES courses(id)
        ON DELETE RESTRICT ON UPDATE CASCADE,

    CONSTRAINT fk_sections_term
        FOREIGN KEY (term_id) REFERENCES academic_terms(id)
        ON DELETE RESTRICT ON UPDATE CASCADE,

    CONSTRAINT chk_sections_status
        CHECK (status IN ('ACTIVE', 'INACTIVE')),

    INDEX idx_sections_course (course_id),
    INDEX idx_sections_term (term_id)
) ENGINE=InnoDB;
```

**Important:** The application must ensure that the selected `term_id` belongs to the selected `course_id`. A simple pair of independent foreign keys does not enforce that relationship.

### 9. subjects

**Purpose:** Stores subjects offered under a particular course and academic term.

| Column         | Description        |
| -------------- | ------------------ |
| `id`           | Unique subject ID  |
| `course_id`    | Associated course  |
| `term_id`      | Associated term    |
| `subject_name` | Subject name       |
| `subject_code` | Subject code       |
| `credits`      | Subject credits    |
| `status`       | ACTIVE or INACTIVE |

```
CREATE TABLE subjects (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    course_id BIGINT UNSIGNED NOT NULL,
    term_id BIGINT UNSIGNED NOT NULL,
    subject_name VARCHAR(150) NOT NULL,
    subject_code VARCHAR(50) NOT NULL,
    credits DECIMAL(4,1) NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'ACTIVE',
    created_at DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),

    CONSTRAINT uq_subject_code_term
        UNIQUE (term_id, subject_code),

    CONSTRAINT fk_subjects_course
        FOREIGN KEY (course_id) REFERENCES courses(id)
        ON DELETE RESTRICT ON UPDATE CASCADE,

    CONSTRAINT fk_subjects_term
        FOREIGN KEY (term_id) REFERENCES academic_terms(id)
        ON DELETE RESTRICT ON UPDATE CASCADE,

    CONSTRAINT chk_subjects_status
        CHECK (status IN ('ACTIVE', 'INACTIVE')),

    INDEX idx_subjects_course (course_id),
    INDEX idx_subjects_term (term_id)
) ENGINE=InnoDB;
```

### 10. enrollments

**Purpose:** Connects students to their class sections. It also keeps track of enrollment history.

| Column            | Description                               |
| ----------------- | ----------------------------------------- |
| `id`              | Unique enrollment ID                      |
| `student_id`      | Enrolled student                          |
| `section_id`      | Assigned section                          |
| `enrollment_date` | Enrollment date                           |
| `status`          | ACTIVE, COMPLETED, WITHDRAWN or SUSPENDED |
| `created_at`      | Record creation time                      |

```
CREATE TABLE enrollments (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    student_id BIGINT UNSIGNED NOT NULL,
    section_id BIGINT UNSIGNED NOT NULL,
    enrollment_date DATE NOT NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'ACTIVE',
    created_at DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),

    CONSTRAINT uq_enrollment_student_section
        UNIQUE (student_id, section_id),

    CONSTRAINT fk_enrollments_student
        FOREIGN KEY (student_id) REFERENCES students(id)
        ON DELETE RESTRICT ON UPDATE CASCADE,

    CONSTRAINT fk_enrollments_section
        FOREIGN KEY (section_id) REFERENCES class_sections(id)
        ON DELETE RESTRICT ON UPDATE CASCADE,

    CONSTRAINT chk_enrollments_status
        CHECK (status IN ('ACTIVE', 'COMPLETED', 'WITHDRAWN', 'SUSPENDED')),

    INDEX idx_enrollments_section (section_id)
) ENGINE=InnoDB;
```

### 11. teacher_assignments

**Purpose:** Assigns teachers to subjects and sections.

| Column        | Description          |
| ------------- | -------------------- |
| `id`          | Unique assignment ID |
| `teacher_id`  | Assigned teacher     |
| `subject_id`  | Assigned subject     |
| `section_id`  | Assigned section     |
| `assigned_at` | Assignment date      |
| `status`      | ACTIVE or INACTIVE   |

```
CREATE TABLE teacher_assignments (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    teacher_id BIGINT UNSIGNED NOT NULL,
    subject_id BIGINT UNSIGNED NOT NULL,
    section_id BIGINT UNSIGNED NOT NULL,
    assigned_at DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
    status VARCHAR(20) NOT NULL DEFAULT 'ACTIVE',

    CONSTRAINT uq_teacher_subject_section
        UNIQUE (teacher_id, subject_id, section_id),

    CONSTRAINT fk_assignments_teacher
        FOREIGN KEY (teacher_id) REFERENCES teachers(id)
        ON DELETE RESTRICT ON UPDATE CASCADE,

    CONSTRAINT fk_assignments_subject
        FOREIGN KEY (subject_id) REFERENCES subjects(id)
        ON DELETE RESTRICT ON UPDATE CASCADE,

    CONSTRAINT fk_assignments_section
        FOREIGN KEY (section_id) REFERENCES class_sections(id)
        ON DELETE RESTRICT ON UPDATE CASCADE,

    CONSTRAINT chk_assignments_status
        CHECK (status IN ('ACTIVE', 'INACTIVE')),

    INDEX idx_assignments_subject (subject_id),
    INDEX idx_assignments_section (section_id)
) ENGINE=InnoDB;
```

The application must validate that the assigned subject and section belong to the same academic course and term.

## **3. Attendance management**

These tables handle attendance policies, individual attendance sessions, QR codes, attendance records, daily summaries and leave approvals.

### 12. attendance_policies

**Purpose:** Stores configurable attendance rules. A policy can define the grace period for late attendance and QR token rotation interval.

| Column                    | Description                        |
| ------------------------- | ---------------------------------- |
| `id`                      | Unique policy ID                   |
| `policy_name`             | Policy name                        |
| `grace_period_minutes`    | Allowed late-entry grace period    |
| `qr_rotation_seconds`     | QR token rotation interval         |
| `late_attendance_enabled` | Whether late attendance is allowed |
| `is_default`              | Whether this is the default policy |
| `status`                  | ACTIVE or INACTIVE                 |
| `created_at`              | Creation time                      |
| `updated_at`              | Last update time                   |

```
CREATE TABLE attendance_policies (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    policy_name VARCHAR(100) NOT NULL,
    grace_period_minutes INT UNSIGNED NOT NULL DEFAULT 5,
    qr_rotation_seconds INT UNSIGNED NOT NULL DEFAULT 60,
    late_attendance_enabled BOOLEAN NOT NULL DEFAULT TRUE,
    is_default BOOLEAN NOT NULL DEFAULT FALSE,
    status VARCHAR(20) NOT NULL DEFAULT 'ACTIVE',
    created_at DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
    updated_at DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3)
        ON UPDATE CURRENT_TIMESTAMP(3),

    CONSTRAINT uq_attendance_policy_name UNIQUE (policy_name),

    CONSTRAINT chk_policy_status
        CHECK (status IN ('ACTIVE', 'INACTIVE')),

    CONSTRAINT chk_policy_rotation
        CHECK (qr_rotation_seconds > 0)
) ENGINE=InnoDB;
```

### 13. attendance_sessions

**Purpose:** Represents an attendance-taking session conducted by a teacher for a particular subject and section.

For example, a teacher starts a BCA Semester 3 DBMS class at 10:00 AM. That class gets one attendance session.

| Column                  | Description                          |
| ----------------------- | ------------------------------------ |
| `id`                    | Unique session ID                    |
| `teacher_assignment_id` | Teacher's subject/section assignment |
| `policy_id`             | Attendance policy used               |
| `session_date`          | Date of the class                    |
| `start_time`            | Session start time                   |
| `end_time`              | Session end time                     |
| `grace_period_snapshot` | Grace period copied from policy      |
| `qr_rotation_snapshot`  | QR rotation copied from policy       |
| `status`                | SCHEDULED, OPEN, CLOSED or CANCELLED |
| `opened_by`             | User who opened the session          |
| `closed_at`             | Session closing timestamp            |
| `created_at`            | Creation time                        |

```
CREATE TABLE attendance_sessions (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    teacher_assignment_id BIGINT UNSIGNED NOT NULL,
    policy_id BIGINT UNSIGNED NOT NULL,
    session_date DATE NOT NULL,
    start_time DATETIME(3) NOT NULL,
    end_time DATETIME(3) NULL,
    grace_period_snapshot INT UNSIGNED NOT NULL,
    qr_rotation_snapshot INT UNSIGNED NOT NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'SCHEDULED',
    opened_by BIGINT UNSIGNED NULL,
    closed_at DATETIME(3) NULL,
    created_at DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),

    CONSTRAINT fk_sessions_assignment
        FOREIGN KEY (teacher_assignment_id)
        REFERENCES teacher_assignments(id)
        ON DELETE RESTRICT ON UPDATE CASCADE,

    CONSTRAINT fk_sessions_policy
        FOREIGN KEY (policy_id) REFERENCES attendance_policies(id)
        ON DELETE RESTRICT ON UPDATE CASCADE,

    CONSTRAINT fk_sessions_opened_by
        FOREIGN KEY (opened_by) REFERENCES users(id)
        ON DELETE SET NULL ON UPDATE CASCADE,

    CONSTRAINT chk_sessions_status
        CHECK (status IN ('SCHEDULED', 'OPEN', 'CLOSED', 'CANCELLED')),

    CONSTRAINT chk_sessions_time
        CHECK (end_time IS NULL OR end_time >= start_time),

    INDEX idx_sessions_date (session_date),
    INDEX idx_sessions_status (status),
    INDEX idx_sessions_assignment (teacher_assignment_id)
) ENGINE=InnoDB;
```

**Why store policy snapshots?**

Suppose the college changes the grace period from 5 minutes to 10 minutes. An old attendance session should still use the original 5-minute rule. The snapshot columns preserve that historical information.

### 14. qr_tokens

**Purpose:** Stores hashes of temporary QR tokens generated for an attendance session.

The QR token rotates every 60 seconds according to the configured policy.

| Column       | Description                   |
| ------------ | ----------------------------- |
| `id`         | Unique token ID               |
| `session_id` | Associated attendance session |
| `token_hash` | SHA-256 hash of the token     |
| `issued_at`  | Token generation time         |
| `expires_at` | Token expiry time             |
| `revoked_at` | Optional revocation time      |

```
CREATE TABLE qr_tokens (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    session_id BIGINT UNSIGNED NOT NULL,
    token_hash CHAR(64) NOT NULL,
    issued_at DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
    expires_at DATETIME(3) NOT NULL,
    revoked_at DATETIME(3) NULL,

    CONSTRAINT uq_qr_token_hash UNIQUE (token_hash),

    CONSTRAINT fk_qr_tokens_session
        FOREIGN KEY (session_id) REFERENCES attendance_sessions(id)
        ON DELETE RESTRICT ON UPDATE CASCADE,

    CONSTRAINT chk_qr_token_expiry
        CHECK (expires_at > issued_at),

    INDEX idx_qr_tokens_session (session_id),
    INDEX idx_qr_tokens_expiry (expires_at)
) ENGINE=InnoDB;
```

**Security rule:** Never store the original QR token in the database. Generate a random token, hash it with SHA-256, and store only the hash. The QR code itself should contain the token or a secure reference to it, not the stored hash.

### 15. attendance_records

**Purpose:** Stores individual attendance results for each student in each attendance session.

| Column       | Description                      |
| ------------ | -------------------------------- |
| `id`         | Unique attendance record ID      |
| `session_id` | Attendance session               |
| `student_id` | Student                          |
| `status`     | PRESENT, LATE, ABSENT or EXCUSED |
| `marked_at`  | Attendance marking time          |
| `marked_by`  | User who marked the attendance   |
| `source`     | QR, MANUAL or SYSTEM             |
| `remarks`    | Additional information           |
| `created_at` | Creation time                    |
| `updated_at` | Last update time                 |

```
CREATE TABLE attendance_records (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    session_id BIGINT UNSIGNED NOT NULL,
    student_id BIGINT UNSIGNED NOT NULL,
    status VARCHAR(20) NOT NULL,
    marked_at DATETIME(3) NULL,
    marked_by BIGINT UNSIGNED NULL,
    source VARCHAR(20) NOT NULL DEFAULT 'QR',
    remarks TEXT NULL,
    created_at DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
    updated_at DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3)
        ON UPDATE CURRENT_TIMESTAMP(3),

    CONSTRAINT uq_attendance_session_student
        UNIQUE (session_id, student_id),

    CONSTRAINT fk_attendance_session
        FOREIGN KEY (session_id) REFERENCES attendance_sessions(id)
        ON DELETE RESTRICT ON UPDATE CASCADE,

    CONSTRAINT fk_attendance_student
        FOREIGN KEY (student_id) REFERENCES students(id)
        ON DELETE RESTRICT ON UPDATE CASCADE,

    CONSTRAINT fk_attendance_marked_by
        FOREIGN KEY (marked_by) REFERENCES users(id)
        ON DELETE SET NULL ON UPDATE CASCADE,

    CONSTRAINT chk_attendance_status
        CHECK (status IN ('PRESENT', 'LATE', 'ABSENT', 'EXCUSED')),

    CONSTRAINT chk_attendance_source
        CHECK (source IN ('QR', 'MANUAL', 'SYSTEM')),

    INDEX idx_attendance_student (student_id),
    INDEX idx_attendance_status (status)
) ENGINE=InnoDB;
```

**Important:** The unique constraint ensures that a student cannot have two attendance records for the same session.

### 16. daily_attendance

**Purpose:** Stores calculated daily attendance summaries for each student and subject.

For example, a student may have three DBMS sessions on a particular date. This table stores the combined daily result.

| Column                  | Description                      |
| ----------------------- | -------------------------------- |
| `id`                    | Unique summary ID                |
| `student_id`            | Student                          |
| `subject_id`            | Subject                          |
| `attendance_date`       | Attendance date                  |
| `total_sessions`        | Number of qualifying sessions    |
| `present_count`         | Present sessions                 |
| `late_count`            | Late sessions                    |
| `absent_count`          | Absent sessions                  |
| `excused_count`         | Excused sessions                 |
| `attendance_percentage` | Calculated percentage            |
| `status`                | PRESENT, LATE, ABSENT or EXCUSED |
| `finalized_at`          | Summary finalization time        |

```
CREATE TABLE daily_attendance (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    student_id BIGINT UNSIGNED NOT NULL,
    subject_id BIGINT UNSIGNED NOT NULL,
    attendance_date DATE NOT NULL,
    total_sessions INT UNSIGNED NOT NULL DEFAULT 0,
    present_count INT UNSIGNED NOT NULL DEFAULT 0,
    late_count INT UNSIGNED NOT NULL DEFAULT 0,
    absent_count INT UNSIGNED NOT NULL DEFAULT 0,
    excused_count INT UNSIGNED NOT NULL DEFAULT 0,
    attendance_percentage DECIMAL(5,2) NULL,
    status VARCHAR(20) NOT NULL,
    finalized_at DATETIME(3) NULL,
    created_at DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
    updated_at DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3)
        ON UPDATE CURRENT_TIMESTAMP(3),

    CONSTRAINT uq_daily_student_subject_date
        UNIQUE (student_id, subject_id, attendance_date),

    CONSTRAINT fk_daily_attendance_student
        FOREIGN KEY (student_id) REFERENCES students(id)
        ON DELETE RESTRICT ON UPDATE CASCADE,

    CONSTRAINT fk_daily_attendance_subject
        FOREIGN KEY (subject_id) REFERENCES subjects(id)
        ON DELETE RESTRICT ON UPDATE CASCADE,

    CONSTRAINT chk_daily_attendance_status
        CHECK (status IN ('PRESENT', 'LATE', 'ABSENT', 'EXCUSED')),

    CONSTRAINT chk_daily_attendance_percentage
        CHECK (
            attendance_percentage IS NULL
            OR attendance_percentage BETWEEN 0 AND 100
        ),

    INDEX idx_daily_attendance_date (attendance_date),
    INDEX idx_daily_attendance_student (student_id)
) ENGINE=InnoDB;
```

**Attendance percentage formula:**

\\[ \text{Attendance \\%} = \frac{\text{Present}+\text{Late}} {\text{Present}+\text{Late}+\text{Absent}} \times 100 \\]

Excused sessions are excluded from the denominator.

If every session is excused, the daily status becomes `EXCUSED` and the percentage is `NULL`. If there are no qualifying sessions, no daily summary should be created.

### 17. approved_leaves

**Purpose:** Stores student leave applications and their approval status.

| Column        | Description                   |
| ------------- | ----------------------------- |
| `id`          | Unique leave ID               |
| `student_id`  | Student requesting leave      |
| `start_date`  | Leave starting date           |
| `end_date`    | Leave ending date             |
| `reason`      | Leave reason                  |
| `status`      | PENDING, APPROVED or REJECTED |
| `reviewed_by` | Administrator who reviewed it |
| `reviewed_at` | Review timestamp              |
| `created_at`  | Application creation time     |

```
CREATE TABLE approved_leaves (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    student_id BIGINT UNSIGNED NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    reason TEXT NOT NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'PENDING',
    reviewed_by BIGINT UNSIGNED NULL,
    reviewed_at DATETIME(3) NULL,
    created_at DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),

    CONSTRAINT fk_leaves_student
        FOREIGN KEY (student_id) REFERENCES students(id)
        ON DELETE RESTRICT ON UPDATE CASCADE,

    CONSTRAINT fk_leaves_reviewer
        FOREIGN KEY (reviewed_by) REFERENCES users(id)
        ON DELETE SET NULL ON UPDATE CASCADE,

    CONSTRAINT chk_leaves_status
        CHECK (status IN ('PENDING', 'APPROVED', 'REJECTED')),

    CONSTRAINT chk_leaves_dates
        CHECK (end_date >= start_date),

    INDEX idx_leaves_student (student_id),
    INDEX idx_leaves_dates (start_date, end_date),
    INDEX idx_leaves_status (status)
) ENGINE=InnoDB;
```

An approved leave should cause the relevant attendance records to be marked `EXCUSED` according to the institution's leave policy. Do not automatically mark every session in a date range excused without checking that the leave applies to the student's enrolled section and subject.

## **4. System management**

### 18. audit_logs

**Purpose:** Records important actions performed by users. This helps administrators investigate changes and maintain accountability.

Examples:

- Administrator approved a registration.
- Teacher manually changed attendance.
- Administrator changed an attendance policy.
- User account was suspended.

| Column        | Description                   |
| ------------- | ----------------------------- |
| `id`          | Unique log ID                 |
| `actor_id`    | User who performed the action |
| `action`      | Action performed              |
| `entity_type` | Type of affected record       |
| `entity_id`   | ID of affected record         |
| `details`     | Additional JSON information   |
| `ip_address`  | User's IP address             |
| `created_at`  | Action timestamp              |

```
CREATE TABLE audit_logs (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    actor_id BIGINT UNSIGNED NULL,
    action VARCHAR(100) NOT NULL,
    entity_type VARCHAR(100) NOT NULL,
    entity_id BIGINT UNSIGNED NULL,
    details JSON NULL,
    ip_address VARCHAR(45) NULL,
    created_at DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),

    CONSTRAINT fk_audit_actor
        FOREIGN KEY (actor_id) REFERENCES users(id)
        ON DELETE SET NULL ON UPDATE CASCADE,

    INDEX idx_audit_actor (actor_id),
    INDEX idx_audit_action (action),
    INDEX idx_audit_entity (entity_type, entity_id),
    INDEX idx_audit_created_at (created_at)
) ENGINE=InnoDB;
```

### 19. processing_jobs

**Purpose:** Tracks background jobs handled by the system. This can later be used for attendance calculations, report generation, email notifications and other asynchronous tasks.

| Column         | Description                              |
| -------------- | ---------------------------------------- |
| `id`           | Unique job ID                            |
| `job_type`     | Type of job                              |
| `payload`      | Job data in JSON format                  |
| `status`       | PENDING, PROCESSING, COMPLETED or FAILED |
| `attempts`     | Number of processing attempts            |
| `available_at` | Earliest processing time                 |
| `started_at`   | Processing start time                    |
| `completed_at` | Processing completion time               |
| `last_error`   | Error information                        |
| `created_at`   | Job creation time                        |

```
CREATE TABLE processing_jobs (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    job_type VARCHAR(100) NOT NULL,
    payload JSON NOT NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'PENDING',
    attempts INT UNSIGNED NOT NULL DEFAULT 0,
    available_at DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
    started_at DATETIME(3) NULL,
    completed_at DATETIME(3) NULL,
    last_error TEXT NULL,
    created_at DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),

    CONSTRAINT chk_jobs_status
        CHECK (status IN ('PENDING', 'PROCESSING', 'COMPLETED', 'FAILED')),

    INDEX idx_jobs_status_available (status, available_at),
    INDEX idx_jobs_created_at (created_at)
) ENGINE=InnoDB;
```

## **5. Add the remaining foreign keys**

Some tables were created before their referenced tables. Now that all 19 tables exist, add the remaining foreign keys.

```
-- Connect teachers to departments
ALTER TABLE teachers
ADD CONSTRAINT fk_teachers_department
FOREIGN KEY (department_id)
REFERENCES departments(id)
ON DELETE RESTRICT
ON UPDATE CASCADE;


-- Connect registration requests to courses
ALTER TABLE registration_requests
ADD CONSTRAINT fk_registration_course
FOREIGN KEY (requested_course_id)
REFERENCES courses(id)
ON DELETE RESTRICT
ON UPDATE CASCADE;


-- Connect registration requests to academic terms
ALTER TABLE registration_requests
ADD CONSTRAINT fk_registration_term
FOREIGN KEY (requested_term_id)
REFERENCES academic_terms(id)
ON DELETE RESTRICT
ON UPDATE CASCADE;
```

## **6. Verify your database**

After executing all the SQL statements, run these commands.

**Check whether all 19 tables exist:**

```
USE sams;

SHOW TABLES;
```

**Check a particular table's structure:**

```
DESCRIBE users;
DESCRIBE students;
DESCRIBE attendance_records;
```

**Check foreign-key relationships:**

```
SELECT
    TABLE_NAME,
    COLUMN_NAME,
    CONSTRAINT_NAME,
    REFERENCED_TABLE_NAME,
    REFERENCED_COLUMN_NAME
FROM INFORMATION_SCHEMA.KEY_COLUMN_USAGE
WHERE TABLE_SCHEMA = 'sams'
  AND REFERENCED_TABLE_NAME IS NOT NULL
ORDER BY TABLE_NAME;
```

**Check the table count:**

```
SELECT COUNT(*) AS total_tables
FROM INFORMATION_SCHEMA.TABLES
WHERE TABLE_SCHEMA = 'sams'
  AND TABLE_TYPE = 'BASE TABLE';
```

Expected result: 19 tables

## **7. Important design considerations before proceeding**

There are a few relationships that require additional validation in your Spring Boot service:

1. A section's `course_id` must match the course associated with its `term_id`.
2. A subject's course and term must match.
3. A teacher assignment's subject and section must belong to the same course and term.
4. A student must be enrolled in the section associated with an attendance session before attendance can be recorded.
5. An approved leave must be checked against the student's enrollment before applying `EXCUSED`.
6. A daily attendance summary should only be calculated from finalized, non-cancelled sessions.

These are cross-table business rules. The current foreign keys alone do not enforce all of them.

Also, the 5-minute grace period is a provisional default. You can change it according to your college's attendance policy.

## Documentation note

This document records the 19-table MySQL schema, its creation order, constraints, foreign-key additions, and verification queries. The database is named `sams`; the DDL below is the schema reference supplied for Phase 2. Verify it against the live database after applying the SQL.

