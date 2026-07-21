-- Database Programming Practice Script
-- Course: DPR400210 - Database Programming

-- 1. Create a sample table for Student Records
CREATE TABLE Students (
    StudentID INT PRIMARY KEY AUTO_INCREMENT,
    FirstName VARCHAR(50) NOT NULL,
    LastName VARCHAR(50) NOT NULL,
    Course VARCHAR(100) DEFAULT 'Database Programming',
    EnrollmentDate DATE
);

-- 2. Insert sample records
INSERT INTO Students (FirstName, LastName, EnrollmentDate)
VALUES 
('Izihirwe', 'Majibu', '2026-07-21'),
('Eric', 'Maniraguha', '2026-07-21');

-- 3. Query the data
SELECT * FROM Students WHERE Course = 'Database Programming';
