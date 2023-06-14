--Section 1. DDL
CREATE DATABASE [Service]

USE [Service]
--01.Table Design
CREATE TABLE Users(
Id INT IDENTITY(1,1) PRIMARY KEY
,Username VARCHAR(30) UNIQUE NOT NULL
,[Password] VARCHAR(50)	NOT NULL
,[Name] VARCHAR(50)
,Birthdate DATETIME
,Age INT
,Email VARCHAR(50) NOT NULL
,CHECK (Age >= 14 AND Age <= 110)
)

CREATE TABLE Departments(
Id INT IDENTITY(1,1) PRIMARY KEY
,[Name] VARCHAR(50) NOT NULL
)

CREATE TABLE Employees(
Id INT IDENTITY(1,1) PRIMARY KEY
,FirstName VARCHAR(25)
,LastName VARCHAR(25)
,Birthdate DATETIME
,Age INT 
,DepartmentId INT
,CHECK (Age >= 18 AND Age <= 110)
,FOREIGN KEY(DepartmentId) REFERENCES Departments(Id)
)

CREATE TABLE Categories(
Id INT IDENTITY(1,1) PRIMARY KEY
,[Name] VARCHAR(50) NOT NULL
,DepartmentId INT NOT NULL
,FOREIGN KEY(DepartmentId) REFERENCES Departments(Id)
)

CREATE TABLE [Status](
Id INT IDENTITY(1,1) PRIMARY KEY
,[Label] VARCHAR(30) NOT NULL
)

CREATE TABLE Reports(
Id INT IDENTITY(1,1) PRIMARY KEY
,CategoryId INT NOT NULL
,StatusId INT NOT NULL
,OpenDate DATETIME NOT NULL
,CloseDate DATETIME
,[Description] VARCHAR(200) NOT NULL
,UserId INT NOT NULL
,EmployeeId INT
,FOREIGN KEY(CategoryId) REFERENCES Categories(Id)
,FOREIGN KEY(StatusId) REFERENCES [Status](Id)
,FOREIGN KEY(UserId) REFERENCES Users(Id)
,FOREIGN KEY(EmployeeId) REFERENCES Employees(Id)
)

--Section 2. DML

--02. Insert

INSERT INTO Employees(FirstName,LastName,Birthdate,DepartmentId)
VALUES
('Marlo','O''Malley','1958-9-21',1)
,('Niki','Stanaghan','1969-11-26',4)
,('Ayrton','Senna','1960-03-21',9)
,('Ronnie','Peterson','1944-02-14',9)
,('Giovanna','Amati','1959-07-20',5)

INSERT INTO Reports(CategoryId,StatusId,OpenDate,CloseDate,[Description],UserId,EmployeeId)
VALUES
(1,1,'2017-04-13',NULL,'Stuck Road on Str.133',6,2)
,(6,3,'2015-09-05','2015-12-06','Charity trail running',3,5)
,(14,2,'2015-09-07',NULL,'Falling bricks on Str.58',5,2)
,(4,3,'2017-07-03','2017-07-06','Cut off streetlight on Str.11',1,1)

--03. Update
UPDATE Reports
SET CloseDate = GETDATE()
WHERE CloseDate IS NULL

--04. Delete
DELETE FROM Reports
WHERE StatusId = 4

--Section 3. Querying 

--05. Unassigned Reports
SELECT
r.[Description]
,FORMAT(r.OpenDate,'dd-MM-yyyy')
FROM Reports AS r
WHERE r.EmployeeId IS NULL
ORDER BY r.OpenDate ASC,r.[Description] ASC

--06. Reports & Categories
SELECT
r.[Description]
,c.[Name] AS CategoryName
FROM Reports AS r
JOIN Categories AS c ON
c.Id = r.CategoryId
ORDER BY r.[Description] ASC,c.[Name] ASC

--07. Most Reported Category
SELECT TOP 5
c.[Name] AS CategoryName
,COUNT(r.CategoryId) AS ReportsNumber
FROM Categories AS c
JOIN Reports AS r ON
r.CategoryId = c.Id
GROUP BY c.[Name]
ORDER BY COUNT(r.CategoryId) DESC,c.[Name] ASC

--08. Birthday Report
SELECT
u.Username
,c.[Name] AS CategoryName
FROM Users AS u
JOIN Reports AS r ON
r.UserId = u.Id
JOIN Categories AS c ON
r.CategoryId =c.Id
WHERE DATEPART(DAY,u.Birthdate) = DATEPART(DAY,r.OpenDate)
AND DATEPART(MONTH,u.Birthdate) = DATEPART(MONTH,r.OpenDate)
ORDER BY u.Username ASC,c.[Name] ASC


--09. Users per Employee
SELECT
CONCAT(e.FirstName,' ',e.LastName) AS FullName
,COUNT(u.Id)
FROM Employees AS e
LEFT JOIN Reports AS r ON
r.EmployeeId = e.Id
LEFT JOIN Users AS u ON
u.Id = r.UserId
GROUP BY CONCAT(e.FirstName,' ',e.LastName)
ORDER BY COUNT(u.Id) DESC,FullName ASC


--10. Full Info
SELECT
CONCAT(e.FirstName,' ',e.LastName) AS Employee
,d.[Name] AS Department
,c.[Name] AS Category
,r.[Description] 
,FORMAT(r.OpenDate,'dd.MM.yyyy') AS OpenDate
,s.[Label] AS [Status]
,u.[Name] AS [User]
FROM Reports AS r
JOIN Employees AS e ON
e.Id = r.EmployeeId
JOIN Departments AS d ON 
d.Id = e.DepartmentId
JOIN Categories AS c ON
c.Id = r.CategoryId
JOIN [Status] AS s ON
s.Id = r.StatusId
JOIN Users AS u ON
u.Id = r.UserId
ORDER BY e.FirstName DESC,e.LastName DESC,d.[Name] ASC,c.[Name] ASC
,r.[Description] ASC,r.OpenDate ASC,s.[Label] ASC,u.[Name] ASC

--Section 4. Programmability 

--11. Hours to Complete
CREATE FUNCTION udf_HoursToComplete(@StartDate DATETIME, @EndDate DATETIME)
RETURNS INT
AS 
BEGIN

IF(@StartDate IS NULL OR @EndDate IS NULL)
BEGIN 
RETURN 0
END

RETURN
DATEDIFF(HOUR,@StartDate,@EndDate)
END

--12. Assign Employee
CREATE OR ALTER PROCEDURE usp_AssignEmployeeToReport(@EmployeeId INT, @ReportId INT)
AS

IF((SELECT DepartmentId FROM Employees WHERE @EmployeeId = Id) IN 
(SELECT DepartmentId FROM Categories WHERE Id IN (SELECT
CategoryId
FROM Reports AS r
WHERE @ReportId = Id)))
BEGIN
UPDATE Reports
SET EmployeeId = @EmployeeId
WHERE @ReportId = Id
END
ELSE
BEGIN 
RAISERROR('Employee doesn''t belong to the appropriate department!', 16, 1)
END

EXEC usp_AssignEmployeeToReport 30, 1




