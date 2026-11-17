# SAMS – Smart Attendance Management System

SAMS (Smart Attendance Management System) is a QR code-based attendance management platform designed to digitize and simplify academic attendance tracking. It aims to provide a centralized system for managing students, faculty, academic semesters, courses, and attendance records.

The system uses time-based rotating QR codes to make attendance verification more reliable while providing automated attendance percentage calculations and attendance monitoring.

## Features

- **Student Management:** Register and manage student information.
- **Faculty Management:** Manage faculty members and their assigned courses.
- **QR Code Attendance:** Mark attendance using dynamically rotating QR codes.
- **Time-Based QR Rotation:** QR codes refresh every 60 seconds to reduce unauthorized attendance attempts.
- **Attendance Tracking:** Maintain daily attendance records for individual students.
- **Attendance Percentage:** Automatically calculate attendance percentages.
- **Semester Management:** Support flexible academic semester configurations.
- **Leave Management:** Allow students to submit leave requests and treat approved leave as excused.
- **Attendance Monitoring:** View and monitor attendance records.
- **Role-Based Access:** Provide appropriate access based on user roles.

## Project Objectives

- Replace traditional manual attendance procedures with a digital system.
- Reduce attendance-related administrative work.
- Improve attendance accuracy and transparency.
- Minimize proxy attendance through time-based QR verification.
- Provide reliable attendance records and percentage calculations.
- Simplify academic attendance management for students and faculty.

## Technology Stack

The project is being designed around the following technologies:

- **Frontend:** To be finalized
- **Backend:** To be finalized
- **Database:** MySQL
- **Authentication:** To be finalized
- **QR Code:** Dynamic QR code generation and verification

## System Modules

| Module         | Description                                       |
| -------------- | ------------------------------------------------- |
| Authentication | User authentication and access management         |
| Student        | Student registration and profile management       |
| Faculty        | Faculty information and management                |
| Academic       | Course, semester, and academic session management |
| Attendance     | QR-based attendance marking and record management |
| Leave          | Leave application and approval management         |
| Reports        | Attendance records and percentage calculations    |

## Attendance Mechanism

1. An authorized faculty member initiates an attendance session.
2. The system generates a time-sensitive QR code.
3. The QR code rotates every 60 seconds.
4. Students scan the currently valid QR code to submit attendance.
5. The backend validates the QR code and attendance session.
6. A valid submission is recorded in the attendance database.
7. Attendance percentages are calculated automatically.

## Database

SAMS uses MySQL as its relational database management system.

The database is designed to maintain relationships between students, faculty, courses, semesters, attendance sessions, attendance records, and leave applications.

## Local Development Setup

Start MySQL, the Spring Boot backend, the FastAPI service, and the React frontend in separate terminals.

### 1. Prepare MySQL

Start your local MySQL server and create the SAMS database:

```sql
CREATE DATABASE IF NOT EXISTS sams;
```

The backend is currently configured for `localhost:3306`, database `sams`, username `root`, and password `root` in `backend/src/main/resources/application.properties`.

### 2. Start the Spring Boot backend

From the repository root, open a terminal and run:

```powershell
cd backend
.\mvnw.cmd spring-boot:run
```

The backend health endpoint is [http://localhost:8080/api/v1/health](http://localhost:8080/api/v1/health).

### 3. Start the FastAPI service

From a second terminal:

```powershell
cd python-service
.\.venv\Scripts\Activate.ps1
python -m uvicorn app.main:app --reload --port 8000
```

The FastAPI health endpoint is [http://localhost:8000/health](http://localhost:8000/health).

### 4. Start the React frontend

From a third terminal:

```powershell
cd frontend
npm install
npm run dev
```

Open the local URL printed by Vite, usually [http://localhost:5173](http://localhost:5173). The frontend calls `/api/v1/health`; Vite forwards that request to Spring Boot on port 8080. `frontend/.env.example` contains the API base URL used by the frontend.

## Project Timeline

- **Starting Date:** 17 November 2026
- **Status:** Under Development

SAMS is currently in the planning and database design phase. Development will proceed incrementally through structured implementation phases.

## Security

Security is an important consideration because the system handles student information and academic attendance records.

For information about supported versions and vulnerability reporting, see [SECURITY.md](SECURITY.md).

## Contributing

Contributions, suggestions, and bug reports are welcome.

If you would like to contribute:

1. Fork the repository.
2. Create a new branch.
3. Make your changes.
4. Commit your changes.
5. Open a Pull Request.

Please ensure that your contributions follow the project's coding standards.

## License

The licensing terms for this project will be specified in the repository.

---

**SAMS – Smart Attendance Management System**

_Making academic attendance management smarter, simpler, and more reliable._
