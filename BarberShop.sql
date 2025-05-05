CREATE DATABASE Barbershop;
GO
USE Barbershop;
GO

CREATE TABLE Barbers (  --інформації про барберів
    BarberID INT PRIMARY KEY IDENTITY,
    FullName NVARCHAR(100) NOT NULL,
    Gender NVARCHAR(10),
    Phone NVARCHAR(20),
    Email NVARCHAR(100),
    BirthDate DATE,
    HireDate DATE,
    Position NVARCHAR(50) CHECK (Position IN ('Chief', 'Senior', 'Junior'))
);
GO

CREATE TABLE Services ( --Таблиця для збереження списку послуг
    ServiceID INT PRIMARY KEY IDENTITY,
    ServiceName NVARCHAR(100) NOT NULL,
    Price DECIMAL(10, 2),
    DurationMinutes INT
);
GO

CREATE TABLE BarberServices ( -- Послуги барберів
    BarberID INT,
    ServiceID INT,
    PRIMARY KEY (BarberID, ServiceID),
    FOREIGN KEY (BarberID) REFERENCES Barbers(BarberID) ON DELETE CASCADE,
    FOREIGN KEY (ServiceID) REFERENCES Services(ServiceID) ON DELETE CASCADE
);
GO

CREATE TABLE Clients ( -- Клієнти
    ClientID INT PRIMARY KEY IDENTITY,
    FullName NVARCHAR(100) NOT NULL,
    Phone NVARCHAR(20),
    Email NVARCHAR(100)
);
GO

CREATE TABLE Schedules ( --Таблиця розкладу барберів
    ScheduleID INT PRIMARY KEY IDENTITY,
    BarberID INT,
    AvailableDate DATE,
    AvailableTime TIME,
    FOREIGN KEY (BarberID) REFERENCES Barbers(BarberID) ON DELETE CASCADE
);
GO

CREATE TABLE Appointments ( -- Записи клієнтів
    AppointmentID INT PRIMARY KEY IDENTITY,
    ClientID INT,
    BarberID INT,
    ServiceID INT,
    AppointmentDate DATE,
    AppointmentTime TIME,
    FOREIGN KEY (ClientID) REFERENCES Clients(ClientID),
    FOREIGN KEY (BarberID) REFERENCES Barbers(BarberID),
    FOREIGN KEY (ServiceID) REFERENCES Services(ServiceID)
);
GO

CREATE TABLE Feedbacks ( -- Таблиця для збереження відгуків клієнтів
    FeedbackID INT PRIMARY KEY IDENTITY,
    ClientID INT,
    BarberID INT,
    Rating NVARCHAR(20) CHECK (Rating IN ('Very Bad', 'Bad', 'Normal', 'Good', 'Excellent')),
    Comment NVARCHAR(500),
    FOREIGN KEY (ClientID) REFERENCES Clients(ClientID),
    FOREIGN KEY (BarberID) REFERENCES Barbers(BarberID)
);
GO

CREATE TABLE VisitHistory ( -- Історія відвідувань
    VisitID INT PRIMARY KEY IDENTITY,
    ClientID INT,
    BarberID INT,
    ServiceID INT,
    VisitDate DATE,
    TotalCost DECIMAL(10, 2),
    Rating NVARCHAR(20),
    Feedback NVARCHAR(500),
    FOREIGN KEY (ClientID) REFERENCES Clients(ClientID),
    FOREIGN KEY (BarberID) REFERENCES Barbers(BarberID),
    FOREIGN KEY (ServiceID) REFERENCES Services(ServiceID)
);
GO

CREATE PROCEDURE GetAllBarbers --Повернути ПІБ всіх барберів салону. 
AS
BEGIN
    SELECT FullName FROM Barbers;
END;
GO

CREATE PROCEDURE GetSeniorBarbers --Повернути інформацію про всіх синьйор-барберів. 
AS
BEGIN
    SELECT * FROM Barbers WHERE Position = 'Senior';
END;
GO

CREATE PROCEDURE GetBarbersWhoShave -- Повернути інформацію про всіх барберів, які можуть надати послугу традиційного гоління бороди. 
AS
BEGIN
    SELECT B.*
    FROM Barbers B
    JOIN BarberServices BS ON B.BarberID = BS.BarberID
    JOIN Services S ON BS.ServiceID = S.ServiceID
    WHERE S.ServiceName = 'Traditional Beard Shaving';
END;
GO

CREATE PROCEDURE GetBarbersByService --Повернути інформацію про всіх барберів, які можуть надати конкретну послугу. Інформація про потрібну послугу надається як параметр.
    @ServiceName NVARCHAR(100)
AS
BEGIN
    SELECT B.*
    FROM Barbers B
    JOIN BarberServices BS ON B.BarberID = BS.BarberID
    JOIN Services S ON BS.ServiceID = S.ServiceID
    WHERE S.ServiceName = @ServiceName;
END;
GO

CREATE PROCEDURE GetBarbersWithExperience --Повернути інформацію про всіх барберів, які працюють понад зазначену кількість років. Кількість років передається як параметр.
    @Years INT
AS
BEGIN
    SELECT * FROM Barbers
    WHERE DATEDIFF(YEAR, HireDate, GETDATE()) >= @Years;
END;
GO

CREATE PROCEDURE CountSeniorAndJuniorBarbers --Повернути кількість синьйор-барберів та кількість джуніор-барберів. 
AS
BEGIN
    SELECT 
        SUM(CASE WHEN Position = 'Senior Barber' THEN 1 ELSE 0 END) AS SeniorBarberCount,
        SUM(CASE WHEN Position = 'Junior Barber' THEN 1 ELSE 0 END) AS JuniorBarberCount
    FROM Barbers;
END;
GO

CREATE PROCEDURE GetLoyalClients -- Повернути інформацію про постійних клієнтів. Критерій постійного клієнта: був у салоні задану кількість разів. Кількість передається як параметр. 
    @VisitCount INT
AS
BEGIN
    SELECT C.*
    FROM Clients C
    JOIN (
        SELECT ClientID
        FROM VisitHistory
        GROUP BY ClientID
        HAVING COUNT(*) >= @VisitCount
    ) AS FrequentClients ON C.ClientID = FrequentClients.ClientID;
END;
GO

CREATE TRIGGER trg_PreventChiefBarberDeletion -- Заборонити можливість видалення інформації про чиф-барбер, якщо не додано другий чиф-барбер. 
ON Barbers
INSTEAD OF DELETE
AS
BEGIN
    IF EXISTS (
        SELECT 1
        FROM deleted
        WHERE Position = 'Chief Barber'
    )
    BEGIN
        DECLARE @ChiefCount INT;
        SELECT @ChiefCount = COUNT(*) FROM Barbers WHERE Position = 'Chief Barber';

        IF @ChiefCount <= 1
        BEGIN
            RAISERROR('Cannot delete the only Chief Barber.', 16, 1);
            RETURN;
        END
    END

    DELETE FROM Barbers WHERE BarberID IN (SELECT BarberID FROM deleted);
END;
GO

CREATE TRIGGER trg_PreventUnderageBarbers -- Заборонити додавати барберів молодше 21 року
ON Barbers
INSTEAD OF INSERT
AS
BEGIN
    IF EXISTS (
        SELECT 1 FROM inserted
        WHERE DATEDIFF(YEAR, BirthDate, GETDATE()) < 21
    )
    BEGIN
        RAISERROR('Cannot add barbers younger than 21 years old.', 16, 1);
        RETURN;
    END

    INSERT INTO Barbers(FullName, Gender, Phone, Email, BirthDate, HireDate, Position)
    SELECT FullName, Gender, Phone, Email, BirthDate, HireDate, Position FROM inserted;
END;
GO
-- Функції користувача
CREATE FUNCTION SayHello(@Name NVARCHAR(100))
RETURNS NVARCHAR(200)
AS
BEGIN
    RETURN 'Hello, ' + @Name + '!';
END;
GO

CREATE FUNCTION GetCurrentMinute()
RETURNS INT
AS
BEGIN
    RETURN DATEPART(MINUTE, GETDATE());
END;
GO

CREATE FUNCTION GetCurrentYear()
RETURNS INT
AS
BEGIN
    RETURN YEAR(GETDATE());
END;
GO

CREATE FUNCTION IsYearEvenOrOdd()
RETURNS NVARCHAR(10)
AS
BEGIN
    IF (YEAR(GETDATE()) % 2 = 0)
        RETURN 'Even';
    ELSE
        RETURN 'Odd';
END;
GO

CREATE FUNCTION IsPrime(@Number INT)
RETURNS NVARCHAR(10)
AS
BEGIN
    DECLARE @i INT = 2;
    IF @Number < 2 RETURN 'No';
    WHILE @i <= SQRT(@Number)
    BEGIN
        IF @Number % @i = 0 RETURN 'No';
        SET @i = @i + 1;
    END
    RETURN 'Yes';
END;
GO

CREATE FUNCTION SumMinMax(@a INT, @b INT, @c INT, @d INT, @e INT)
RETURNS INT
AS
BEGIN
    DECLARE @min INT, @max INT;
    SELECT @min = MIN(v), @max = MAX(v)
    FROM (VALUES (@a), (@b), (@c), (@d), (@e)) AS value(v);
    RETURN @min + @max;
END;
GO

CREATE FUNCTION ShowNumbers(@start INT, @end INT, @type NVARCHAR(10))
RETURNS NVARCHAR(MAX)
AS
BEGIN
    DECLARE @result NVARCHAR(MAX) = '';
    DECLARE @i INT = @start;
    WHILE @i <= @end
    BEGIN
        IF (@type = 'Even' AND @i % 2 = 0) OR (@type = 'Odd' AND @i % 2 = 1)
            SET @result = @result + CAST(@i AS NVARCHAR) + ' ';
        SET @i = @i + 1;
    END
    RETURN @result;
END;
GO

-- Збережені процедури

CREATE PROCEDURE HelloWorld
AS
BEGIN
    PRINT 'Hello, world!';
END;
GO

CREATE PROCEDURE GetCurrentTime
AS
BEGIN
    SELECT GETDATE() AS CurrentTime;
END;
GO

CREATE PROCEDURE GetCurrentDate
AS
BEGIN
    SELECT CAST(GETDATE() AS DATE) AS CurrentDate;
END;
GO

CREATE PROCEDURE SumThreeNumbers (@a INT, @b INT, @c INT)
AS
BEGIN
    SELECT (@a + @b + @c) AS Sum;
END;
GO

CREATE PROCEDURE AverageThreeNumbers (@a INT, @b INT, @c INT)
AS
BEGIN
    SELECT (@a + @b + @c) / 3.0 AS Average;
END;
GO

CREATE PROCEDURE MaxOfThree (@a INT, @b INT, @c INT)
AS
BEGIN
    SELECT MAX(v) AS MaxValue
    FROM (VALUES (@a), (@b), (@c)) AS value(v);
END;
GO

CREATE PROCEDURE MinOfThree (@a INT, @b INT, @c INT)
AS
BEGIN
    SELECT MIN(v) AS MinValue
    FROM (VALUES (@a), (@b), (@c)) AS value(v);
END;
GO

CREATE PROCEDURE DrawLine (@length INT, @symbol NVARCHAR(5))
AS
BEGIN
    DECLARE @line NVARCHAR(MAX) = REPLICATE(@symbol, @length);
    PRINT @line;
END;
GO

CREATE PROCEDURE CalculateFactorial (@n INT)
AS
BEGIN
    DECLARE @result BIGINT = 1;
    DECLARE @i INT = 1;
    WHILE @i <= @n
    BEGIN
        SET @result = @result * @i;
        SET @i = @i + 1;
    END
    SELECT @result AS Factorial;
END;
GO

CREATE PROCEDURE PowerOfNumber (@number FLOAT, @power INT)
AS
BEGIN
    SELECT POWER(@number, @power) AS Result;
END;
GO