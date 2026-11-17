-- SAMS initial schema (MySQL 8.x)
-- Run this script once in MySQL Workbench or another MySQL client.
-- It creates the sams database, 19 tables, and deferred foreign keys.
-- Database credentials are intentionally not included.

CREATE DATABASE IF NOT EXISTS sams CHARACTER SET utf8mb4;
USE sams;

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

-- Add foreign keys whose referenced tables are created later.

ALTER TABLE teachers
ADD CONSTRAINT fk_teachers_department
FOREIGN KEY (department_id)
REFERENCES departments(id)
ON DELETE RESTRICT
ON UPDATE CASCADE;

ALTER TABLE registration_requests
ADD CONSTRAINT fk_registration_course
FOREIGN KEY (requested_course_id)
REFERENCES courses(id)
ON DELETE RESTRICT
ON UPDATE CASCADE;

ALTER TABLE registration_requests
ADD CONSTRAINT fk_registration_term
FOREIGN KEY (requested_term_id)
REFERENCES academic_terms(id)
ON DELETE RESTRICT
ON UPDATE CASCADE;

-- Verify the schema:
SHOW TABLES;

SELECT COUNT(*) AS total_tables
FROM INFORMATION_SCHEMA.TABLES
WHERE TABLE_SCHEMA = 'sams'
  AND TABLE_TYPE = 'BASE TABLE';
