-- Exam Cheating Detection System
-- Oracle SQL / SQL*Plus
-- Clean executable script derived from the project's SQL*Plus session.

-- =========================================================
-- 1. TABLES
-- =========================================================

CREATE TABLE Students (
    Student_ID NUMBER PRIMARY KEY,
    Student_Name VARCHAR2(100) NOT NULL,
    Major VARCHAR2(50),
    Year_Level NUMBER
);

CREATE TABLE Instructors (
    Instructor_ID NUMBER PRIMARY KEY,
    Instructor_Name VARCHAR2(100) NOT NULL,
    Department VARCHAR2(50)
);

CREATE TABLE Exam_Rooms (
    Room_ID NUMBER PRIMARY KEY,
    Room_Name VARCHAR2(50),
    Capacity NUMBER
);

CREATE TABLE Exams (
    Exam_ID NUMBER PRIMARY KEY,
    Course_Name VARCHAR2(100),
    Exam_Date DATE,
    Room_ID NUMBER,
    CONSTRAINT fk_exams_room
        FOREIGN KEY (Room_ID) REFERENCES Exam_Rooms(Room_ID)
);

CREATE TABLE Invigilators (
    Invigilator_ID NUMBER PRIMARY KEY,
    Instructor_ID NUMBER,
    Exam_ID NUMBER,
    CONSTRAINT fk_invigilators_instructor
        FOREIGN KEY (Instructor_ID) REFERENCES Instructors(Instructor_ID),
    CONSTRAINT fk_invigilators_exam
        FOREIGN KEY (Exam_ID) REFERENCES Exams(Exam_ID)
);

CREATE TABLE Cheating_Types (
    Type_ID NUMBER PRIMARY KEY,
    Type_Name VARCHAR2(100)
);

CREATE TABLE Cheating_Incidents (
    Incident_ID NUMBER PRIMARY KEY,
    Student_ID NUMBER,
    Exam_ID NUMBER,
    Type_ID NUMBER,
    Incident_Date DATE,
    Description VARCHAR2(255),
    CONSTRAINT fk_incidents_student
        FOREIGN KEY (Student_ID) REFERENCES Students(Student_ID),
    CONSTRAINT fk_incidents_exam
        FOREIGN KEY (Exam_ID) REFERENCES Exams(Exam_ID),
    CONSTRAINT fk_incidents_type
        FOREIGN KEY (Type_ID) REFERENCES Cheating_Types(Type_ID)
);

CREATE TABLE Violations (
    Violation_ID NUMBER PRIMARY KEY,
    Student_ID NUMBER,
    Incident_ID NUMBER,
    Violation_Count NUMBER,
    CONSTRAINT fk_violations_student
        FOREIGN KEY (Student_ID) REFERENCES Students(Student_ID),
    CONSTRAINT fk_violations_incident
        FOREIGN KEY (Incident_ID) REFERENCES Cheating_Incidents(Incident_ID)
);

CREATE TABLE Penalties (
    Penalty_ID NUMBER PRIMARY KEY,
    Violation_ID NUMBER,
    Penalty_Type VARCHAR2(100),
    Penalty_Date DATE,
    CONSTRAINT fk_penalties_violation
        FOREIGN KEY (Violation_ID) REFERENCES Violations(Violation_ID)
);

-- =========================================================
-- 2. SAMPLE DATA
-- =========================================================

INSERT INTO Students VALUES (1, 'Ahmad Ali', 'Computer Science', 3);
INSERT INTO Students VALUES (2, 'Sara Khaled', 'Information Systems', 2);
INSERT INTO Students VALUES (3, 'Omar Hassan', 'Cyber Security', 4);
INSERT INTO Students VALUES (4, 'Lina Mohammad', 'Software Engineering', 1);

INSERT INTO Instructors VALUES (1, 'Dr. Moath', 'IT');
INSERT INTO Instructors VALUES (2, 'Dr. Ablah', 'CS');

INSERT INTO Exam_Rooms VALUES (1, 'Room 35B', 30);
INSERT INTO Exam_Rooms VALUES (2, 'Room 36B', 25);

INSERT INTO Exams VALUES (
    1, 'Database', TO_DATE('2026-04-10', 'YYYY-MM-DD'), 1
);
INSERT INTO Exams VALUES (
    2, 'Networks', TO_DATE('2026-04-12', 'YYYY-MM-DD'), 2
);

INSERT INTO Invigilators VALUES (1, 1, 1);
INSERT INTO Invigilators VALUES (2, 2, 2);

INSERT INTO Cheating_Types VALUES (1, 'Using Phone');
INSERT INTO Cheating_Types VALUES (2, 'Talking');
INSERT INTO Cheating_Types VALUES (3, 'Copying');

INSERT INTO Cheating_Incidents VALUES (
    1, 1, 1, 1, SYSDATE, 'Used mobile phone'
);
INSERT INTO Cheating_Incidents VALUES (
    2, 2, 1, 2, SYSDATE, 'Talking during exam'
);
INSERT INTO Cheating_Incidents VALUES (
    3, 1, 2, 3, SYSDATE, 'Copied answers'
);

INSERT INTO Violations VALUES (1, 1, 1, 1);
INSERT INTO Violations VALUES (2, 2, 2, 1);
INSERT INTO Violations VALUES (3, 1, 3, 2);

INSERT INTO Penalties VALUES (1, 1, 'Warning', SYSDATE);
INSERT INTO Penalties VALUES (2, 2, 'Mark Deduction', SYSDATE);
INSERT INTO Penalties VALUES (3, 3, 'Exam Fail', SYSDATE);

COMMIT;

-- =========================================================
-- 3. SEQUENCE AND TRIGGER
-- =========================================================

CREATE SEQUENCE Violations_seq
    START WITH 100
    INCREMENT BY 1;

CREATE OR REPLACE TRIGGER trg_violation_auto
AFTER INSERT ON Cheating_Incidents
FOR EACH ROW
DECLARE
    v_count NUMBER;
BEGIN
    SELECT COUNT(*)
    INTO v_count
    FROM Violations
    WHERE Student_ID = :NEW.Student_ID;

    IF v_count = 0 THEN
        INSERT INTO Violations (
            Violation_ID,
            Student_ID,
            Incident_ID,
            Violation_Count
        ) VALUES (
            Violations_seq.NEXTVAL,
            :NEW.Student_ID,
            :NEW.Incident_ID,
            1
        );
    ELSE
        UPDATE Violations
        SET Violation_Count = Violation_Count + 1
        WHERE Student_ID = :NEW.Student_ID;
    END IF;
END;
/

-- =========================================================
-- 4. SAMPLE REPORT QUERY
-- =========================================================

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
    ON ci.Type_ID = c.Type_ID
ORDER BY s.Student_Name, e.Course_Name;

COMMIT;
