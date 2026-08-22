# Exam Cheating Detection System — Oracle SQL

A relational database project built with **Oracle SQL / SQL\*Plus** to store, track, and report exam cheating incidents.

The system organizes student, exam, room, instructor, invigilator, cheating-type, violation, and penalty data in a structured relational schema.

## Project Objectives

The database is designed to:

- Store student information
- Store exam information
- Record cheating incidents
- Track different types of cheating
- Monitor repeated violations
- Manage exam invigilators
- Store penalties
- Generate reports about cheating cases

## Database Tables

| Table | Purpose |
| --- | --- |
| `Students` | Stores student information |
| `Instructors` | Stores instructor information |
| `Exam_Rooms` | Stores exam room information |
| `Exams` | Stores exam details and room assignment |
| `Invigilators` | Connects instructors with exams they supervise |
| `Cheating_Types` | Stores categories of cheating |
| `Cheating_Incidents` | Records individual cheating cases |
| `Violations` | Tracks violation counts for students |
| `Penalties` | Stores penalties associated with violations |

## Main Relationships

The schema uses primary and foreign keys to connect the main entities.

Examples:

```text
Exam_Rooms  1 ---- * Exams
Instructors 1 ---- * Invigilators
Exams       1 ---- * Invigilators
Students    1 ---- * Cheating_Incidents
Exams       1 ---- * Cheating_Incidents
Cheating_Types 1 - * Cheating_Incidents
Students    1 ---- * Violations
Cheating_Incidents 1 - * Violations
Violations  1 ---- * Penalties
```

## Automatic Violation Tracking

The project includes an Oracle sequence:

```sql
Violations_seq
```

and a row-level trigger:

```sql
trg_violation_auto
```

When a new cheating incident is inserted, the trigger checks whether the student already has a violation record.

- If no violation exists, a new record is created.
- If a violation already exists, the student's `Violation_Count` is increased.

## Sample Report Query

The SQL script includes a query that combines students, exams, cheating types, and incidents:

```sql
SELECT
    s.Student_Name,
    e.Course_Name,
    c.Type_Name,
    ci.Description
FROM Students s
JOIN Cheating_Incidents ci
    ON s.Student_ID = ci.Student_ID
JOIN Exams e
    ON ci.Exam_ID = e.Exam_ID
JOIN Cheating_Types c
    ON ci.Type_ID = c.Type_ID;
```

## Repository Structure

```text
Exam-Cheating-Detection-Oracle-SQL/
├── README.md
├── exam_cheating_detection.sql
├── .gitignore
└── docs/
    ├── Doc_SQL.pdf
    ├── Doc_SQL.docx
    └── sqlplus-session-log.txt
```

## Requirements

- Oracle Database
- Oracle SQL\*Plus or Oracle SQL Developer

The project was developed using Oracle Database 21c Express Edition.

## Run with SQL*Plus

Connect to your Oracle database, then run:

```sql
@exam_cheating_detection.sql
```

The script creates the schema, inserts sample records, creates the sequence and trigger, and runs a sample report query.

> Run the script in a clean schema. Running it repeatedly without dropping existing objects will produce "already exists" errors.

## Sample Data

The project includes example records for:

- Students from multiple IT-related majors
- Database and Networks exams
- Exam rooms
- Instructors and invigilators
- Cheating types such as phone use, talking, and copying
- Violations and penalties

## Documentation

The original project documentation is included in both PDF and Word formats under [`docs/`](docs/).

The original SQL\*Plus development session is also preserved as `sqlplus-session-log.txt`. It shows the commands, outputs, trigger debugging, and the final successful trigger creation.

## Technologies Used

- Oracle Database
- SQL
- SQL\*Plus
- PL/SQL
- Relational Database Design
- Primary Keys and Foreign Keys
- Sequences
- Triggers
- SQL Joins

## Learning Objectives

This project demonstrates:

- Designing a normalized relational database
- Creating tables with PK/FK constraints
- Inserting and querying relational data
- Joining multiple tables for reports
- Using Oracle sequences
- Creating PL/SQL triggers
- Tracking repeated events automatically
- Modeling a real-world academic monitoring system

---

Database project for an **Exam Cheating Detection System** using Oracle SQL and PL/SQL.
