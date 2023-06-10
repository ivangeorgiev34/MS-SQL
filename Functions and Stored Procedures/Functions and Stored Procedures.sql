--Problem 1	
USE SoftUni 

CREATE PROCEDURE usp_GetEmployeesSalaryAbove35000
AS 
SELECT 
e.FirstName
,e.LastName
FROM Employees AS e
WHERE e.Salary > 35000

--Problem 2
CREATE PROCEDURE usp_GetEmployeesSalaryAboveNumber @SalaryBorder DECIMAL(18,4)
AS 
SELECT 
e.FirstName
,e.LastName
FROM Employees AS e
WHERE e.Salary >= @SalaryBorder

EXEC usp_GetEmployeesSalaryAboveNumber 48100

--Problem 3
CREATE PROCEDURE usp_GetTownsStartingWith @TownStartingChar VARCHAR(30)
AS 
SELECT 
t.[Name]
FROM Towns AS t 
WHERE t.[Name] LIKE CONCAT(@TownStartingChar,'%')

EXEC usp_GetTownsStartingWith sa

--Problem 4
CREATE PROCEDURE usp_GetEmployeesFromTown(@TownName VARCHAR(50))
AS 
SELECT
e.FirstName
,e.LastName
FROM Employees AS e
JOIN Addresses AS a ON
a.AddressID = e.AddressID
JOIN Towns AS t ON
t.TownID = a.TownID
WHERE @TownName = t.[Name]

EXEC usp_GetEmployeesFromTown 'Sofia'

--Problem 5
CREATE FUNCTION ufn_GetSalaryLevel(@salary DECIMAL(18,4))
RETURNS VARCHAR(10) 
AS 
BEGIN

DECLARE @Result VARCHAR(10) 

	IF(@salary < 30000)
BEGIN
	SET @Result = 'Low'
END

	ELSE IF(@salary >= 30000 AND @salary <= 50000)
BEGIN 
	SET @Result = 'Average'
END

	ELSE
BEGIN
	SET @Result = 'High'
END
RETURN @Result
END

--Problem 6
CREATE PROCEDURE usp_EmployeesBySalaryLevel(@LevelOfSalary VARCHAR(10))
AS 
SELECT
e.FirstName AS [First Name]
,e.LastName AS [Last Name]
FROM Employees AS e
WHERE @LevelOfSalary = dbo.ufn_GetSalaryLevel(e.Salary)

--Problem 7
CREATE FUNCTION ufn_IsWordComprised(@setOfLetters NVARCHAR(10), @word NVARCHAR(10)) 
RETURNS BIT
AS 
BEGIN 
DECLARE @Output BIT
SET @Output = 1
DECLARE @I INT
SET @I = 0
WHILE(@I < LEN(@setOfLetters))
BEGIN
SET @I += 1
IF(@setOfLetters LIKE '%' + SUBSTRING(@word,@I,1) + '%')
CONTINUE
ELSE
SET @Output = 0
BREAK
END
RETURN @Output
END

--Problem 8

CREATE PROC usp_DeleteEmployeesFromDepartment (@departmentId INT)
AS

DECLARE @empIDsToBeDeleted TABLE
(
	Id int
)

INSERT INTO @empIDsToBeDeleted
SELECT e.EmployeeID
FROM Employees AS e
WHERE e.DepartmentID = @departmentId

ALTER TABLE Departments
ALTER COLUMN ManagerID int NULL

DELETE FROM EmployeesProjects
WHERE EmployeeID IN (SELECT Id FROM @empIDsToBeDeleted)

UPDATE Employees
SET ManagerID = NULL
WHERE ManagerID IN (SELECT Id FROM @empIDsToBeDeleted)

UPDATE Departments
SET ManagerID = NULL
WHERE ManagerID IN (SELECT Id FROM @empIDsToBeDeleted)

DELETE FROM Employees
WHERE EmployeeID IN (SELECT Id FROM @empIDsToBeDeleted)

DELETE FROM Departments
WHERE DepartmentID = @departmentId 

SELECT COUNT(*) AS [Employees Count] FROM Employees AS e
JOIN Departments AS d
ON d.DepartmentID = e.DepartmentID
WHERE e.DepartmentID = @departmentId

--Problem 9
USE Bank

CREATE PROCEDURE usp_GetHoldersFullName
AS 
SELECT 
CONCAT(a.FirstName,' ',a.LastName) AS [Full Name]
FROM AccountHolders AS a

--Problem 10
CREATE PROCEDURE usp_GetHoldersWithBalanceHigherThan(@Balance MONEY)
AS 
SELECT
ah.FirstName AS [First Name]
,ah.LastName AS [Last Name]
FROM AccountHolders AS ah
JOIN Accounts AS a ON
a.AccountHolderId = ah.Id
GROUP BY ah.FirstName,ah.LastName
HAVING SUM(a.Balance) > @Balance
ORDER BY 
ah.FirstName
,ah.LastName

--Problem 11
CREATE OR ALTER FUNCTION ufn_CalculateFutureValue(@Sum DECIMAL(8,4),@YearlyInterestRate FLOAT,@NumberOfYears INT)
RETURNS DECIMAL(8,4)
AS 
BEGIN
DECLARE @Result DECIMAL(8,4)
SET @Result = @Sum * (POWER(1+@YearlyInterestRate,@NumberOfYears))
RETURN @Result 
END

SELECT dbo.ufn_CalculateFutureValue(123.12,0.1,5)

--Problem 12
CREATE OR ALTER PROCEDURE usp_CalculateFutureValueForAccount(@AccountId INT,@YearlyInterestRate FLOAT)
AS 
BEGIN
SELECT
ah.Id AS [Account Id]
,ah.FirstName AS [First Name]
,ah.LastName AS [Last Name]
,a.Balance AS [Current Balance]
,dbo.ufn_CalculateFutureValue(a.Balance,@YearlyInterestRate,5) AS [Balance in 5 Years]
FROM AccountHolders AS ah
JOIN Accounts AS a ON
a.AccountHolderId = ah.Id
WHERE @AccountId = a.Id
END

--Problem 13
USE Diablo

CREATE FUNCTION ufn_CashInUsersGames (@gameName NVARCHAR(50))
RETURNS TABLE 
AS 
RETURN SELECT
(
SELECT SUM(Cash) AS SumCash
FROM (
SELECT 
g.[Name],
ug.Cash,
ROW_NUMBER() OVER(PARTITION BY g.[Name] ORDER BY ug.Cash DESC) AS RowNumber
FROM UsersGames AS ug
INNER JOIN Games AS g
ON ug.GameId = g.Id
WHERE g.[Name] = @gameName
) AS RowNumberSubquery
WHERE RowNumber % 2 != 0
) AS SumCash

--Problem 14
USE Bank

CREATE TABLE Logs (
  LogId INT PRIMARY KEY IDENTITY,
  AccountId INT,
  OldSum MONEY,
  NewSum MONEY
)

CREATE TRIGGER tr_InsertNewEntryIntoLogs
ON Accounts
AFTER UPDATE
AS
INSERT INTO Logs VALUES
(
(SELECT Id
FROM inserted),
(SELECT Balance
FROM deleted),
(SELECT Balance
FROM inserted)
)

--Problem 15
CREATE TABLE NotificationEmails(
Id INT IDENTITY(1,1) PRIMARY KEY
,Recipient INT
,[Subject] NVARCHAR(100)
,Body NVARCHAR(100)
)

CREATE TRIGGER tr_CreateNewEmailWhenRecordIsInsertedInLogs
ON Logs
AFTER INSERT
AS
BEGIN
INSERT INTO NotificationEmails
VALUES
(
(
SELECT AccountId
FROM inserted
)
,(
CONCAT('Balance change for account: ' ,(SELECT AccountId FROM inserted))
)
,(
CONCAT('On ' ,GETDATE(),'your balance was changed from ',(SELECT OldSum FROM inserted),' to ',(SELECT NewSum FROM inserted),'.')
)
)
END

--Problem 16
CREATE PROCEDURE usp_DepositMoney(@AccountId INT, @MoneyAmount MONEY) 
AS
BEGIN
UPDATE Accounts
SET Balance = Balance + ROUND(@MoneyAmount,4)
WHERE Id = @AccountId
END

--Problem 17
CREATE PROCEDURE usp_WithdrawMoney(@AccountId INT, @MoneyAmount MONEY) 
AS 
BEGIN
UPDATE Accounts 
SET Balance = Balance - ROUND(@MoneyAmount,4)
WHERE Id = @AccountId
END

--Problem 18
CREATE PROCEDURE usp_TransferMoney(@SenderId INT,@ReceiverId INT,@Amount MONEY)
AS 
BEGIN
EXEC usp_WithdrawMoney @SenderId, @Amount
EXEC usp_DepositMoney @ReceiverId, @Amount
END

--Problem 20
USE Diablo

DECLARE @gameName NVARCHAR(50) = 'Safflower'
DECLARE @username NVARCHAR(50) = 'Stamat'

DECLARE @userGameId INT = (
  SELECT ug.Id
  FROM UsersGames AS ug
    JOIN Users AS u
      ON ug.UserId = u.Id
    JOIN Games AS g
      ON ug.GameId = g.Id
  WHERE u.Username = @username AND g.Name = @gameName)

DECLARE @userGameLevel INT = (SELECT Level
                              FROM UsersGames
                              WHERE Id = @userGameId)
DECLARE @itemsCost MONEY, @availableCash MONEY, @minLevel INT, @maxLevel INT

SET @minLevel = 11
SET @maxLevel = 12
SET @availableCash = (SELECT Cash
                      FROM UsersGames
                      WHERE Id = @userGameId)
SET @itemsCost = (SELECT SUM(Price)
                  FROM Items
                  WHERE MinLevel BETWEEN @minLevel AND @maxLevel)

IF (@availableCash >= @itemsCost AND @userGameLevel >= @maxLevel)

  BEGIN
    BEGIN TRANSACTION
    UPDATE UsersGames
    SET Cash -= @itemsCost
    WHERE Id = @userGameId
    IF (@@ROWCOUNT <> 1)
      BEGIN
        ROLLBACK
        RAISERROR ('Could not make payment', 16, 1)
      END
    ELSE
      BEGIN
        INSERT INTO UserGameItems (ItemId, UserGameId)
          (SELECT
             Id,
             @userGameId
           FROM Items
           WHERE MinLevel BETWEEN @minLevel AND @maxLevel)

        IF ((SELECT COUNT(*)
             FROM Items
             WHERE MinLevel BETWEEN @minLevel AND @maxLevel) <> @@ROWCOUNT)
          BEGIN
            ROLLBACK;
            RAISERROR ('Could not buy items', 16, 1)
          END
        ELSE COMMIT;
      END
  END

SET @minLevel = 19
SET @maxLevel = 21
SET @availableCash = (SELECT Cash
                      FROM UsersGames
                      WHERE Id = @userGameId)
SET @itemsCost = (SELECT SUM(Price)
                  FROM Items
                  WHERE MinLevel BETWEEN @minLevel AND @maxLevel)

IF (@availableCash >= @itemsCost AND @userGameLevel >= @maxLevel)

  BEGIN
    BEGIN TRANSACTION
    UPDATE UsersGames
    SET Cash -= @itemsCost
    WHERE Id = @userGameId

    IF (@@ROWCOUNT <> 1)
      BEGIN
        ROLLBACK
        RAISERROR ('Could not make payment', 16, 1)
      END
    ELSE
      BEGIN
        INSERT INTO UserGameItems (ItemId, UserGameId)
          (SELECT
             Id,
             @userGameId
           FROM Items
           WHERE MinLevel BETWEEN @minLevel AND @maxLevel)

        IF ((SELECT COUNT(*)
             FROM Items
             WHERE MinLevel BETWEEN @minLevel AND @maxLevel) <> @@ROWCOUNT)
          BEGIN
            ROLLBACK
            RAISERROR ('Could not buy items', 16, 1)
          END
        ELSE COMMIT;
      END
  END

SELECT i.Name AS [Item Name]
FROM UserGameItems AS ugi
  JOIN Items AS i
    ON i.Id = ugi.ItemId
  JOIN UsersGames AS ug
    ON ug.Id = ugi.UserGameId
  JOIN Games AS g
    ON g.Id = ug.GameId
WHERE g.Name = @gameName
ORDER BY [Item Name]


--Problem 21
USE SoftUni

CREATE OR ALTER PROCEDURE usp_AssignProject(@emloyeeId INT, @projectID INT)
AS 
BEGIN
BEGIN TRANSACTION
INSERT INTO EmployeesProjects
VALUES
(@emloyeeId,@projectID)

DECLARE @CountOfProjects INT

SET @CountOfProjects = 
(SELECT COUNT(*) 
FROM EmployeesProjects AS ep
WHERE ep.EmployeeID = @emloyeeId
GROUP BY(ep.EmployeeID))

IF(@CountOfProjects > 3)
BEGIN
RAISERROR ('The employee has too many projects!', 16, 1)
ROLLBACK
RETURN
END

COMMIT
END

--Problem 22
CREATE TABLE Deleted_Employees(
EmployeeId INT IDENTITY(1,1) PRIMARY KEY
,FirstName NVARCHAR(30)
,LastName NVARCHAR(30)
,MiddleName NVARCHAR(30)
,JobTitle NVARCHAR(30)
,DepartmentId INT
,Salary DECIMAL(15, 2)
)

CREATE OR ALTER TRIGGER tr_InsertFiredEmployees
ON Employees
AFTER DELETE
AS
BEGIN
INSERT INTO Deleted_Employees
SELECT
d.FirstName
,d.LastName
,d.MiddleName
,d.JobTitle 
,d.DepartmentId 
,d.Salary
FROM deleted AS d
END



