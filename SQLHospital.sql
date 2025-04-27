CREATE DATABASE Hospital; -- Створення бази даних Лікарня
GO
USE Hospital; -- Використання бази даних Лікарня
GO
CREATE TABLE Departments -- Таблиця Відділення
(
Id INT IDENTITY PRIMARY KEY NOT NULL,
Building INT NOT NULL CHECK (Building BETWEEN 1 AND 5),
Financing MONEY NOT NULL CHECK (Financing >= 0) DEFAULT 0,
Name NVARCHAR(100) NOT NULL UNIQUE CHECK (LEN(Name)>0)
);
CREATE TABLE Diseases  -- Таблиця Захворювання
(
Id INT IDENTITY PRIMARY KEY NOT NULL,
Name NVARCHAR(100) NOT NULL UNIQUE CHECK (LEN(Name) > 0),
Severity INT NOT NULL CHECK (Severity >= 1) DEFAULT 1
);
CREATE TABLE Doctors  -- Таблиця Докторів
(
Id INT IDENTITY PRIMARY KEY NOT NULL,
Name NVARCHAR(100) NOT NULL UNIQUE CHECK (LEN(Name) > 0),
Phone CHAR(20)NULL,
Salary MONEY NOT NULL CHECK (Salary > 0),
Surname NVARCHAR(MAX) NOT NULL CHECK (LEN(Surname) > 0)
);
CREATE TABLE Examinations -- Таблиця Обстеження 
(
Id INT IDENTITY PRIMARY KEY NOT NULL,
DayOfWeek INT NOT NULL CHECK (DayOfWeek BETWEEN 1 AND 7),
EndTime TIME NOT NULL,
Name NVARCHAR(100) NOT NULL UNIQUE CHECK (LEN(Name) > 0),
StartTime TIME NOT NULL CHECK (StartTime >= '06:00' and StartTime <= '20:00'),
CHECK (EndTime > StartTime)
);
CREATE TABLE Wards -- Таблиця Палати
(
Id INT IDENTITY PRIMARY KEY NOT NULL,
Building INT NOT NULL CHECK (Building BETWEEN 1 AND 5),
Floor INT NOT NULL CHECK (Floor > 1),
Name NVARCHAR(100) NOT NULL UNIQUE CHECK (LEN(Name) > 0)
);
SELECT * FROM Wards; -- 1

SELECT Surname, Phone FROM Doctors; -- 2

SELECT DISTINCT Floor FROM Wards; -- 3

SELECT Name AS [Name of Disease], Severity AS [Severity of Disease] FROM Diseases; -- 4  

SELECT D.Name AS DoctorName, DP.Name AS DepartmentName, W.Name AS WardName FROM Doctors D, Departments DP, Wards W; -- 5

SELECT Name FROM Departments WHERE Building = 5 AND Financing < 30000; -- 6

SELECT Name FROM Departments WHERE Building = 3 AND Financing BETWEEN 12000 AND 15000; -- 7

SELECT Name FROM Wards WHERE Floor = 1 AND Building IN (4, 5); -- 8

SELECT Name, Building, Financing -- 9
FROM Departments 
WHERE Building IN (3, 6) AND (Financing < 11000 OR Financing > 25000);

SELECT Surname  -- 10
FROM Doctors 
WHERE Salary + 500 > 1500;

SELECT Surname  -- 11
FROM Doctors 
WHERE Salary / 2 > 3 * 300;

SELECT DISTINCT Name  -- 12
FROM Examinations 
WHERE DayOfWeek BETWEEN 1 AND 3 AND StartTime >= '13:00' AND EndTime <= '14:00';

SELECT Name, Building  -- 13
FROM Departments 
WHERE Building IN (1, 3, 8, 10);

SELECT Name  -- 14
FROM Diseases 
WHERE Severity NOT IN (1, 2);

SELECT Name  --15
FROM Departments 
WHERE Building NOT IN (1, 3);

SELECT Name  --16
FROM Departments 
WHERE Building IN (1, 3);

SELECT Surname  -- 17
FROM Doctors 
WHERE Surname LIKE 'N%';