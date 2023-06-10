--Section 1. DDL 
CREATE DATABASE Bitbucket

USE Bitbucket

--01. DDL
CREATE TABLE Users(
Id INT IDENTITY(1,1) PRIMARY KEY
,Username VARCHAR(30) NOT NULL
,[Password] VARCHAR(30) NOT NULL
,Email VARCHAR(50) NOT NULL
)

CREATE TABLE Repositories(
Id INT IDENTITY(1,1) PRIMARY KEY
,[Name] VARCHAR(50) NOT NULL
)

CREATE TABLE RepositoriesContributors(
RepositoryId INT NOT NULL
,ContributorId INT NOT NULL
,PRIMARY KEY(RepositoryId,ContributorId)
,FOREIGN KEY(RepositoryId) REFERENCES Repositories(Id)
,FOREIGN KEY(ContributorId) REFERENCES Users(Id)
)

CREATE TABLE Issues(
Id INT IDENTITY(1,1) PRIMARY KEY
,Title VARCHAR(255) NOT NULL
,IssueStatus VARCHAR(6) NOT NULL
,RepositoryId INT NOT NULL
,AssigneeId	INT NOT NULL
,FOREIGN KEY(RepositoryId) REFERENCES Repositories(Id)
,FOREIGN KEY(AssigneeId) REFERENCES Users(Id)
)

CREATE TABLE Commits(
Id INT IDENTITY(1,1) PRIMARY KEY
,[Message] VARCHAR(255) NOT NULL
,IssueId INT
,RepositoryId INT NOT NULL
,ContributorId INT NOT NULL
,FOREIGN KEY(IssueId) REFERENCES Issues(Id)
,FOREIGN KEY(RepositoryId) REFERENCES Repositories(Id)
,FOREIGN KEY(ContributorId) REFERENCES Users(Id)
)

CREATE TABLE Files(
Id INT IDENTITY(1,1) PRIMARY KEY
,[Name] VARCHAR(100) NOT NULL
,Size DECIMAL(7,2) NOT NULL
,ParentId INT
,CommitId INT NOT NULL
,FOREIGN KEY(ParentId) REFERENCES Files(Id)
,FOREIGN KEY(CommitId) REFERENCES Commits(Id)
)

--Section 2. DML (10 pts)

--02. Insert
INSERT INTO Files([Name],Size,ParentId,CommitId)
VALUES 
('Trade.idk',2598.0,1,1)
,('menu.net',9238.31,2,2)
,('Administrate.soshy',1246.93,3,3)
,('Controller.php',7353.15,4,4)
,('Find.java',9957.86,5,5)
,('Controller.json',14034.87,3,6)
,('Operate.xix',7662.92,7,7)

INSERT INTO Issues(Title,IssueStatus,RepositoryId,AssigneeId)
VALUES 
('Critical Problem with HomeController.cs file','open',1,4)
,('Typo fix in Judge.html','open',4,3)
,('Implement documentation for UsersService.cs','closed',8,2)
,('Unreachable code in Index.cs','open',9,8)

--03. Update
UPDATE Issues
SET IssueStatus = 'closed'
WHERE AssigneeId = 6

--04. Delete
DELETE FROM RepositoriesContributors
WHERE RepositoryId IN (SELECT Id FROM Repositories WHERE [Name] = 'Softuni-Teamwork')

DELETE FROM Issues
WHERE RepositoryId IN (SELECT Id FROM Repositories WHERE [Name] = 'Softuni-Teamwork')

--Section 3. Querying 

--05. Commits
SELECT
c.Id
,c.[Message]
,c.RepositoryId
,c.ContributorId
FROM Commits AS c
ORDER BY c.Id ASC,c.[Message] ASC,c.RepositoryId ASC,c.ContributorId ASC

--06. Front-end
SELECT
f.Id
,f.[Name]
,f.Size
FROM Files AS f
WHERE f.Size > 1000
AND f.[Name] LIKE '%html%'
ORDER BY f.Size DESC,f.Id ASC,f.[Name] ASC

--07. Issue Assignment
SELECT
I.Id
,CONCAT(u.Username,' : ',i.Title)
FROM Issues AS i
JOIN Users AS u ON
u.Id = i.AssigneeId
ORDER BY i.Id DESC,i.AssigneeId ASC

--08. Single Files
SELECT f1.Id, f1.[Name], CONCAT(f1.Size, 'KB') AS Size
FROM Files AS f1
LEFT JOIN Files AS f2 ON f2.ParentId = f1.Id
WHERE f2.Id IS NULL
ORDER BY f1.Id, f1.[Name], Size DESC

--09. Commits in Repositories
SELECT TOP(5) r.Id, r.[Name], COUNT(r.Id) AS Commits
FROM RepositoriesContributors AS rc
JOIN Repositories AS r ON r.Id = rc.RepositoryId
JOIN Commits AS c ON c.RepositoryId = r.Id
GROUP BY r.Id, r.[Name]
ORDER BY Commits DESC, r.Id, r.[Name]

--10. Average Size
SELECT
u.Username
,AVG(f.Size)
FROM RepositoriesContributors AS rc
JOIN Users AS u ON
u.Id = rc.ContributorId
JOIN Commits AS c ON
c.ContributorId = u.Id
JOIN Files AS f ON
f.CommitId = c.Id
GROUP BY  u.Username
ORDER BY AVG(f.Size) DESC,u.Username ASC

--Section 4. Programmability 

--11. All User Commits
CREATE FUNCTION udf_AllUserCommits(@username VARCHAR(30))
RETURNS INT
AS 
BEGIN
RETURN(
SELECT
COUNT(c.Id)
FROM Users AS u
JOIN Commits AS c ON
c.ContributorId = u.Id
WHERE u.Username = @username
)
END

--12. Search for Files
CREATE PROCEDURE usp_SearchForFiles(@fileExtension VARCHAR(10))
AS
SELECT
f.Id
,f.[Name]
,CONCAT(f.Size,'KB') AS Size
FROM Files AS f
WHERE f.[Name] LIKE CONCAT('%.',@fileExtension,'%')
ORDER BY f.Id ASC,f.[Name] ASC,f.Size DESC

EXEC usp_SearchForFiles 'txt'







