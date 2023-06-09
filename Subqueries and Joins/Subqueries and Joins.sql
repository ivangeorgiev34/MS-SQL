--Problem 1
USE SoftUni

SELECT TOP 5
e.EmployeeID
,e.JobTitle
,e.AddressID
,a.AddressText
FROM Employees AS e
JOIN Addresses AS a ON
e.AddressID = a.AddressID
ORDER BY e.AddressID ASC

--Problem 2
SELECT TOP 50
e.FirstName
,e.LastName
,t.[Name]
,a.AddressText
FROM Employees AS e
JOIN Addresses AS a ON
e.AddressID = a.AddressID
JOIN Towns AS t ON
a.TownID = t.TownID
ORDER BY 
e.FirstName
,e.LastName

--Problem 3
SELECT
e.EmployeeID
,e.FirstName
,e.LastName
,d.[Name] AS DepartmentName
FROM Employees AS e
JOIN Departments AS d ON
e.DepartmentID = d.DepartmentID
AND d.[Name] = 'Sales'
ORDER BY e.EmployeeID ASC

--Problem 4
SELECT TOP 5
e.EmployeeID
,e.FirstName
,e.Salary
,d.[Name]
FROM Employees AS e
JOIN Departments AS d ON 
d.DepartmentID = e.DepartmentID
AND e.Salary > 15000
ORDER BY e.DepartmentID ASC

--Problem 5
SELECT TOP 3
e.EmployeeID
,e.FirstName
FROM Employees AS e
LEFT JOIN EmployeesProjects AS p ON
e.EmployeeID = p.EmployeeID
WHERE p.ProjectID IS NULL
ORDER BY e.EmployeeID ASC

--Problem 6
SELECT 
e.FirstName
,e.LastName
,e.HireDate
,d.[Name] AS DeptName
FROM Employees AS e
JOIN Departments AS d ON
e.DepartmentID = d.DepartmentID
WHERE d.[Name] IN(
'Finance'
,'Sales'
)
AND e.HireDate > '1999-01-01'
ORDER BY e.HireDate ASC

--Problem 7
SELECT TOP 5
e.EmployeeID
,e.FirstName
,P.[Name]
FROM Employees AS e
JOIN EmployeesProjects AS ep ON
ep.EmployeeID = e.EmployeeID
JOIN Projects AS p ON
p.ProjectID = ep.ProjectID
WHERE p.StartDate > '2002-08-13'
AND p.EndDate IS NULL
ORDER BY e.EmployeeID ASC

--Problem 8
SELECT
e.EmployeeID
,e.FirstName
,CASE
WHEN DATEPART(YEAR,p.StartDate) >= 2005 THEN NULL
ELSE p.[Name]
END
FROM Employees AS e
JOIN EmployeesProjects AS ep ON
ep.EmployeeID = e.EmployeeID
JOIN Projects AS p ON
p.ProjectID = ep.ProjectID
WHERE e.EmployeeID = 24

--Problem 9
SELECT
e.EmployeeID
,e.FirstName
,e.ManagerID
,m.FirstName AS ManagerName
FROM Employees AS e 
JOIN Employees AS m ON
e.ManagerID = m.EmployeeID
WHERE m.EmployeeID = 3
OR m.EmployeeID = 7
ORDER BY e.EmployeeID ASC

--Problem 10
SELECT TOP 50
e.EmployeeID
,CONCAT(e.FirstName,' ',e.LastName) AS EmployeeName
,CONCAT(m.FirstName,' ',m.LastName) AS ManagerName
,d.[Name] AS DepartmentName
FROM Employees AS e
JOIN Employees AS m ON
e.ManagerID = m.EmployeeID
JOIN Departments AS d ON
d.DepartmentID = e.DepartmentID
ORDER BY e.EmployeeID ASC

--Problem 11
SELECT 
MIN(av.AverageSalary) AS MinAverageSalary
FROM
(
SELECT AVG(em.Salary) AS AverageSalary 
FROM Employees AS em 
GROUP BY em.DepartmentID
) AS av

--Problem 12
USE [Geography]

SELECT 
c.CountryCode
,m.MountainRange
,p.PeakName
,p.Elevation
FROM Peaks AS p
JOIN Mountains AS m ON
m.Id = p.MountainId
JOIN MountainsCountries AS mc ON
mc.MountainId = m.Id
JOIN Countries AS c ON
c.CountryCode = mc.CountryCode
AND c.CountryName = 'Bulgaria'
WHERE p.Elevation > 2835
ORDER BY p.Elevation DESC

--Problem 13
SELECT
mc.CountryCode
,COUNT(m.MountainRange) AS MountainRanges
FROM Mountains AS m
JOIN MountainsCountries AS mc ON
mc.MountainId = m.Id
WHERE mc.CountryCode = 'BG'
OR mc.CountryCode = 'US'
OR mc.CountryCode = 'RU'
GROUP BY mc.CountryCode

--Problem 14
SELECT TOP 5
c.CountryName
,r.RiverName
FROM Rivers AS r
FULL JOIN CountriesRivers AS cr ON
r.Id = cr.RiverId
FULL JOIN Countries AS c ON
c.CountryCode = cr.CountryCode
WHERE c.ContinentCode = 'AF'
ORDER BY c.CountryName ASC

--Problem 15
SELECT 
TempResult.ContinentCode,
TempResult.CurrencyCode,
TempResult.Total AS CurrencyUsage
FROM
(
SELECT ContinentCode, CurrencyCode, COUNT(CurrencyCode) AS Total,
DENSE_RANK() OVER(PARTITION BY ContinentCode ORDER BY COUNT(CurrencyCode) DESC) AS Ranked
FROM Countries
GROUP BY ContinentCode, CurrencyCode
) AS TempResult
WHERE Ranked = 1 AND Total > 1
ORDER BY ContinentCode

--Problem 16
SELECT 
COUNT(c.ContinentCode) AS [Count]
FROM Countries AS c
LEFT JOIN MountainsCountries AS mc ON
mc.CountryCode = c.CountryCode
LEFT JOIN Mountains AS m ON
m.Id = mc.MountainId
WHERE m.Id IS NULL

--Problem 17
SELECT TOP 5
c.CountryName
,MAX(p.Elevation) AS HighestPeakElevation
,MAX(r.[Length]) AS LongestRiverLength
FROM Countries AS c
JOIN MountainsCountries AS mc ON
mc.CountryCode = c.CountryCode
JOIN Mountains AS m ON
m.Id = mc.MountainId
JOIN Peaks AS p ON
p.MountainId = m.Id
JOIN CountriesRivers AS cr ON
cr.CountryCode = c.CountryCode
JOIN Rivers AS r ON
r.Id = cr.RiverId
GROUP BY(c.CountryName)
ORDER BY 
HighestPeakElevation DESC
,LongestRiverLength DESC
,c.CountryName

