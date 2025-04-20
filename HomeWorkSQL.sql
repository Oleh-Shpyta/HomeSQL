CREATE DATABASE StudentGrades; -- Створення бази даних
GO
USE StudentGrades; -- Використання створеної бази данних
GO
--Створюємо таблицю для зберігання даних.
CREATE TABLE StudentGrades(
StudentID int IDENTITY(1,1) Primary key,
FullName  NVARCHAR(50),
City  NVARCHAR(50),
Country  NVARCHAR(50),
BirthDate DATE,
Email NVARCHAR(50),
Phone NVARCHAR(20),
GroupName NVARCHAR(50),
AverageYearGrade Float,
MinSubject NVARCHAR(100),
MaxSubject NVARCHAR(100)
);
GO
--Встановлення даних
INSERT INTO StudentGrades(FullName, City, Country, BirthDate, Email, Phone, GroupName, AverageYearGrade, MinSubject, MaxSubject)
VALUES
(N'Masha Ivanova', N'Kyiv', N'UK', '2001-05-02', 'Masha_Ivanova@example.com', '8522147',N'A-1', 85.5, N'Math', N'History'),
(N'Dasha Danilovma', N'New York', N'USA', '2001-05-02','Dasha_Danilovma@gmail.com', '879841',N'A-5', 84.1, N'Physics', N'Sport'),
(N'Oleh Shpyta', N'Wrocław', N'PL', '2001-05-02','Oleh_Shpyta@gmail.com', '965647',N'B1-1', 98.5, N'Biology', N'Art');
GO
SELECT * FROM StudentGrades; -- відображає всю інформацію таблиці.
SELECT Fullname FROM StudentGrades; --Відображає ПІБ студентів
SELECT AverageYearGrade FROM StudentGrades; -- Відображення середніх оцінок

SELECT FullName -- Показати ПІБ усіх студентів з мінімальною оцінкою, більшою
FROM StudentGrades
WHERE AverageYearGrade > 95;
-- Показати країни студентів. Назви країн мають бути унікальними.
SELECT DISTINCT Country FROM StudentGrades;
--Показати міста студентів. Назви міст мають бути унікальними.
SELECT DISTINCT City FROM StudentGrades;
-- Показати назви груп. Назви груп мають бути унікальними.
SELECT DISTINCT GroupName FROM StudentGrades;
--Назви предметів мають бути унікальними.
SELECT DISTINCT MinSubject AS Subject FROM StudentGrades
UNION
SELECT DISTINCT MaxSubject AS Subject FROM StudentGrades;