--Problem 1
USE Gringotts

SELECT 
COUNT(*) AS [Count] 
FROM WizzardDeposits 

--Problem 2
SELECT 
MAX(w.MagicWandSize) AS LongestMagicWand
FROM WizzardDeposits AS w

--Problem 3
SELECT
w.DepositGroup 
,MAX(w.MagicWandSize) AS LongestMagicWand
FROM WizzardDeposits AS w
GROUP BY(w.DepositGroup)

--Problem 4
SELECT TOP 2
w.DepositGroup
FROM WizzardDeposits AS w
GROUP BY(w.DepositGroup)
ORDER BY AVG(MagicWandSize)

--Problem 5
SELECT
w.DepositGroup
,SUM(w.DepositAmount) AS TotalSum
FROM WizzardDeposits AS w
GROUP BY(w.DepositGroup)

--Problem 6
SELECT
w.DepositGroup
,SUM(w.DepositAmount) AS TotalSum
FROM WizzardDeposits AS w
WHERE w.MagicWandCreator = 'Ollivander family'
GROUP BY(w.DepositGroup)

--Problem 7
SELECT
w.DepositGroup
,SUM(w.DepositAmount) AS TotalSum
FROM WizzardDeposits AS w
WHERE w.MagicWandCreator = 'Ollivander family'
GROUP BY(w.DepositGroup)
HAVING SUM(w.DepositAmount) < 150000
ORDER BY SUM(w.DepositAmount) DESC

--Problem 8
SELECT 
w.DepositGroup
,w.MagicWandCreator
,MIN(w.DepositCharge) AS MinDepostiCharge
FROM WizzardDeposits AS w
GROUP BY 
w.DepositGroup
,w.MagicWandCreator
ORDER BY
w.MagicWandCreator ASC
,w.DepositGroup ASC

--Problem 9
SELECT
temp.AgeGroup,COUNT(*) AS WizardCount
FROM
(SELECT
CASE
WHEN Age BETWEEN 0 AND 10 THEN '[0-10]'
WHEN Age BETWEEN 11 AND 20 THEN '[11-20]'
WHEN Age BETWEEN 21 AND 30 THEN '[21-30]'
WHEN Age BETWEEN 31 AND 40 THEN '[31-40]'
WHEN Age BETWEEN 41 AND 50 THEN '[41-50]'
WHEN Age BETWEEN 51 AND 60 THEN '[51-60]'
WHEN Age >= 61 THEN '[61+]'
END AS AgeGroup
FROM WizzardDeposits) AS temp
GROUP BY(temp.AgeGroup)

--Problem 10
SELECT
SUBSTRING(w.FirstName,1,1) AS FirstLetter
FROM WizzardDeposits AS w
WHERE w.DepositGroup  = 'Troll Chest'
GROUP BY SUBSTRING(w.FirstName,1,1)
ORDER BY FirstLetter ASC

--Problem 11
SELECT
w.DepositGroup
,w.IsDepositExpired
,AVG(w.DepositInterest) AS AverageInterest
FROM WizzardDeposits AS w
WHERE w.DepositStartDate > '1985-01-01'
GROUP BY w.DepositGroup,w.IsDepositExpired
ORDER BY 
w.DepositGroup DESC
,w.IsDepositExpired ASC

--Problem 12
SELECT
ABS(SUM(f.DepositAmount - s.DepositAmount)) AS SumDifference
FROM WizzardDeposits AS f
JOIN WizzardDeposits AS s ON
f.Id = s.Id + 1 

--Problem 13
USE SoftUni

SELECT
e.DepartmentID
,SUM(e.Salary) AS TotalSalary
FROM Employees AS e
GROUP BY e.DepartmentID
ORDER BY e.DepartmentID

--Problem 14
SELECT
e.DepartmentID
,MIN(e.Salary) AS MinimumSalary
FROM Employees AS e
GROUP BY e.DepartmentID
HAVING e.DepartmentID IN (
2
,5
,7
)

--Problem 15
SELECT *
INTO Temp
FROM Employees AS e
WHERE e.Salary > 30000

DELETE FROM Temp
WHERE ManagerID = 42

UPDATE Temp 
SET Salary = Salary + 5000
WHERE DepartmentID = 1

SELECT
t.DepartmentID
,AVG(t.Salary) AS AverageSalary
FROM Temp AS t
GROUP BY t.DepartmentID

--Problem 16
SELECT
e.DepartmentID
,MAX(e.Salary) AS MaxSalary
FROM Employees AS e
GROUP BY e.DepartmentID
HAVING MAX(e.Salary) NOT BETWEEN 30000 AND 70000

--Problem 17
SELECT
COUNT(*) AS [Count]
FROM Employees AS e
WHERE e.ManagerID IS NULL

--Problem 18
SELECT
e.DepartmentID
,MAX(e.Salary) SKIP 2
FROM Employees AS e
GROUP BY e.DepartmentID






SELECT * FROM Employees







SELECT * FROM WizzardDeposits

