--Problem 1 
USE SoftUni

SELECT 
e.FirstName
,e.LastName
FROM Employees AS e
WHERE e.FirstName LIKE 'Sa%'

--Problem 2
SELECT 
e.FirstName
,e.LastName
FROM Employees AS e
WHERE e.LastName LIKE '%ei%'

--Problem 3
SELECT 
e.FirstName
FROM Employees AS e
WHERE 
e.DepartmentID = 3
OR e.DepartmentID = 10
AND YEAR(e.HireDate) > 1995
AND YEAR(e.HireDate) < 2005

--Problem 4
SELECT
e.FirstName
,e.LastName
FROM Employees AS e
WHERE e.JobTitle NOT LIKE '%engineer%'

--Problem 5
SELECT 
t.[Name]
FROM Towns AS t
WHERE LEN(t.[Name]) = 5
OR LEN(t.[Name]) = 6
ORDER BY t.[Name] ASC

--Problem 6
SELECT
t.TownID
,t.[Name]
FROM Towns AS t
WHERE LEFT(t.[Name], 1) IN
(
'M'
,'K'
,'B'
,'E'
)
ORDER BY t.[Name] ASC

--Problem 7
SELECT 
t.[TownID]
,t.[Name]
FROM Towns AS t
WHERE LEFT(t.[Name],1) NOT IN
(
'R'
,'B'
,'D'
)
ORDER BY t.[Name] ASC

--Problem 8
CREATE VIEW	V_EmployeesHiredAfter2000 AS
SELECT 
e.FirstName
,e.LastName
FROM Employees AS e
WHERE YEAR(e.HireDate) > 2000

--Problem 9
SELECT 
e.FirstName
,e.LastName
FROM Employees AS e
WHERE LEN(e.LastName) = 5

--Problem 10
SELECT 
e.EmployeeID
,e.FirstName
,e.LastName
,e.Salary
,DENSE_RANK() OVER (PARTITION BY e.Salary ORDER BY e.EmployeeID) AS [Rank]
FROM Employees AS e
WHERE 
e.Salary >= 10000 
AND e.Salary <= 50000 
ORDER BY e.Salary DESC


--Problem 11
SELECT * FROM (SELECT 
e.EmployeeID
,e.FirstName
,e.LastName
,e.Salary
,DENSE_RANK() OVER (PARTITION BY e.Salary ORDER BY e.EmployeeID) AS [Rank]
FROM Employees AS e
WHERE 
e.Salary >= 10000 
AND e.Salary <= 50000) AS temp
WHERE temp.[Rank] = 2
ORDER BY temp.Salary DESC

--Problem 12
USE [Geography]

SELECT 
c.CountryName AS [Country Name]
,c.IsoCode AS [ISO Code]
FROM Countries AS c
WHERE LEN(c.CountryName) - LEN(REPLACE(c.CountryName,'a','')) >= 3
ORDER BY c.IsoCode ASC

--Problem 13
SELECT 
p.PeakName
,r.RiverName
,LOWER(CONCAT(LEFT(p.PeakName, LEN(p.PeakName) - 1), r.RiverName)) AS [Mix]
FROM Rivers AS r,Peaks as p
WHERE RIGHT(p.PeakName,1) = LEFT(r.RiverName,1)
ORDER BY [Mix]

--Problem 14
USE Diablo

SELECT TOP(50) 
[Name]
,FORMAT([Start], 'yyyy-MM-dd') AS [Start]
FROM Games
WHERE DATEPART(YEAR, [Start]) BETWEEN 2011 AND 2012
ORDER BY 
[Start]
,[Name]

--Problem 15
SELECT 
u.Username
,SUBSTRING(u.Email
,CHARINDEX('@',u.Email)+1
,LEN(u.Email) - CHARINDEX('@',u.Email)) AS [Email Provider]
FROM Users AS u
ORDER BY 
[Email Provider]
,u.Username

--Problem 16
SELECT 
u.Username AS [Username]
,u.IpAddress AS [IP Address]
FROM Users AS u
WHERE u.IpAddress LIKE '___.1%.%.___'
ORDER BY u.Username ASC

--Problem 17
	SELECT 
	g.[Name] 
	,CASE 
	WHEN DATEPART(HOUR,g.[Start]) >= 0 AND DATEPART(HOUR,g.[Start]) < 12 THEN 'Morning'
	WHEN DATEPART(HOUR,g.[Start]) >= 12 AND  DATEPART(HOUR,g.[Start]) < 18 THEN 'Afternoon'
	WHEN DATEPART(HOUR,g.[Start])>= 18 AND  DATEPART(HOUR,g.[Start]) < 24 THEN 'Evening'
	END
	AS [Part of the Day]
	,CASE
	WHEN Duration <= 3 THEN 'Extra Short'
	WHEN Duration >=4 AND Duration <= 6 THEN 'Short'
	WHEN Duration > 6 THEN 'Long'
	WHEN Duration IS NULL THEN 'Extra Long'
	END
	AS [Duration]
	FROM Games AS g
	ORDER BY 
	g.[Name] ASC
	,[Duration] ASC
	,[Part of the Day] ASC
 
 --Problem 18
USE Orders

SELECT 
o.ProductName
,o.OrderDate
,DATEADD(DAY,3,o.OrderDate) AS [Pay Due]
,DATEADD(MONTH,1,O.OrderDate) AS [Delivery Due]
FROM Orders AS o

--Problem 19
USE TestDB

CREATE TABLE People(
Id INT PRIMARY KEY IDENTITY(1,1)
,[Name] NVARCHAR(30) NOT NULL
,Birthdate DATETIME NOT NULL
)

INSERT INTO People([Name],Birthdate)
VALUES
('Victor','2000-12-07 00:00:00.000')
,('Steven','1992-09-10 00:00:00.000')
,('Stephen','1910-09-19 00:00:00.000')
,('John','2010-01-06 00:00:00.000')

SELECT 
p.[Name]
,DATEDIFF(YEAR,p.Birthdate,GETDATE()) AS [Age in Years]
,DATEDIFF(MONTH,p.Birthdate,GETDATE()) AS [Age in Months]
,DATEDIFF(DAY,p.Birthdate,GETDATE()) AS [Age in Days]
,DATEDIFF(MINUTE,p.Birthdate,GETDATE()) AS [Age in Minutes]
FROM People AS p



