CREATE DATABASE Boardgames

USE Boardgames

--01. DDL
CREATE TABLE Categories(
Id INT PRIMARY KEY IDENTITY(1,1)
,[Name] VARCHAR(50) NOT NULL
)

CREATE TABLE Addresses(
Id INT PRIMARY KEY IDENTITY(1,1)
,StreetName  NVARCHAR(100) NOT NULL
,StreetNumber INT NOT NULL
,Town VARCHAR(30) NOT NULL 
,Country VARCHAR(50) NOT NULL
,ZIP INT NOT NULL
)

CREATE TABLE Publishers(
Id INT PRIMARY KEY IDENTITY(1,1)
,[Name] VARCHAR(30) UNIQUE NOT NULL
,AddressId INT NOT NULL
,Website NVARCHAR(40)
,Phone NVARCHAR(20)
,FOREIGN KEY(AddressId) REFERENCES Addresses(Id)
)

CREATE TABLE PlayersRanges(
Id INT PRIMARY KEY IDENTITY(1,1)
,PlayersMin INT NOT NULL
,PlayersMax INT NOT NULL
)

CREATE TABLE Boardgames(
Id INT PRIMARY KEY IDENTITY(1,1)
,[Name] NVARCHAR(30) NOT NULL
,YearPublished INT NOT NULL
,Rating DECIMAL(18,2) NOT NULL
,CategoryId INT NOT NULL
,PublisherId INT NOT NULL
,PlayersRangeId INT NOT NULL
,FOREIGN KEY(CategoryId) REFERENCES Categories(Id)
,FOREIGN KEY(PublisherId) REFERENCES Publishers(Id)
,FOREIGN KEY(PlayersRangeId) REFERENCES PlayersRanges(Id)
)

CREATE TABLE Creators(
Id INT PRIMARY KEY IDENTITY(1,1)
,FirstName NVARCHAR(30) NOT NULL
,LastName NVARCHAR(30) NOT NULL
,Email NVARCHAR(30) NOT NULL
)

CREATE TABLE CreatorsBoardgames(
CreatorId INT NOT NULL
,BoardgameId INT NOT NULL
,PRIMARY KEY(CreatorId,BoardgameId)
,FOREIGN KEY(CreatorId) REFERENCES Creators(Id)
,FOREIGN KEY(BoardgameId) REFERENCES Boardgames(Id)
)

--02. Insert
INSERT INTO Boardgames([Name],YearPublished,Rating,CategoryId,PublisherId,PlayersRangeId)
VALUES
('Deep Blue',2019,5.67,1,15,7)
,('Paris',2016,9.78,7,1,5)
,('Catan: Starfarers',2021,9.87,7,13,6)
,('Bleeding Kansas',2020,3.25,3,7,4)
,('One Small Step',2019,5.75,5,9,2)

INSERT INTO Publishers([Name],AddressId,Website,Phone)
VALUES
('Agman Games',5,'www.agmangames.com','+16546135542')
,('Amethyst Games',7,'www.amethystgames.com','+15558889992')
,('BattleBooks',13,'www.battlebooks.com','+12345678907')

--03. Update
UPDATE PlayersRanges
SET PlayersMax = PlayersMax+1
WHERE PlayersMax = 2 AND PlayersMin = 2

UPDATE Boardgames
SET [Name] = CONCAT([Name],'V2')
WHERE YearPublished >= 2020
--We've decided to increase the maximum count of players for the boardgames with 1. 
--Update the table PlayersRanges and increase the maximum players of the boardgames, which have a range of players [2,2].
--Also, you have to change the name of the boardgames that were issued after 2020 inclusive. You have to add "V2" to the end of their names.

--04. Delete
--In table Addresses, delete every country, which has a Town, starting with the letter 'L'. 
--Keep in mind that there could be foreign key constraint conflicts.

DELETE FROM CreatorsBoardgames
WHERE BoardgameId  IN (SELECT Id FROM Boardgames WHERE PublisherId IN (SELECT Id FROM Publishers WHERE AddressId IN (SELECT Id FROM Addresses WHERE Town LIKE 'L%')))

DELETE FROM Boardgames
WHERE PublisherId IN (SELECT Id FROM Publishers WHERE AddressId IN (SELECT Id FROM Addresses WHERE Town LIKE 'L%'))

DELETE FROM Publishers
WHERE AddressId IN (SELECT Id FROM Addresses WHERE Town LIKE 'L%')

DELETE FROM Addresses
WHERE Town LIKE 'L%'

--05. Boardgames by Year of Publication
SELECT
bg.[Name]
,bg.Rating
FROM BoardGames AS bg
ORDER BY bg.YearPublished ASC
,bg.[Name] DESC

--06. Boardgames by Category
SELECT
bg.Id
,bg.[Name]
,bg.YearPublished
,c.[Name]
FROM Boardgames AS bg
JOIN Categories AS c ON 
c.Id = bg.CategoryId
WHERE c.[Name] IN ('Strategy Games','Wargames')
ORDER BY bg.YearPublished DESC

--07. Creators without Boardgames
SELECT
c.Id
,CONCAT(c.FirstName,' ',c.LastName)
,c.Email
FROM Creators AS c
WHERE c.Id NOT IN (SELECT CreatorId FROM CreatorsBoardgames) 
ORDER BY CONCAT(c.FirstName,' ',c.LastName) ASC

--08. First 5 Boardgames
SELECT TOP 5
bg.[Name]
,bg.Rating
,c.[Name]
FROM Boardgames AS bg
JOIN Categories AS c ON
bg.CategoryId = c.Id
JOIN PlayersRanges AS pr ON
pr.Id = bg.PlayersRangeId
WHERE (bg.Rating > 7.00 AND bg.[Name] LIKE '%a%') 
OR (bg.Rating > 7.50 AND (pr.PlayersMin = 2 AND pr.PlayersMax = 5)) 
ORDER BY bg.[Name] ASC
,bg.Rating DESC

--09. Creators with Emails
SELECT
CONCAT(c.FirstName,' ',c.LastName)
,c.Email
,MAX(bg.Rating)
FROM Creators AS c
JOIN CreatorsBoardgames AS cbg ON
cbg.CreatorId = c.Id
JOIN Boardgames AS bg ON
bg.Id = cbg.BoardgameId
WHERE c.Email LIKE '%.com'
GROUP BY CONCAT(c.FirstName,' ',c.LastName)
,c.Email
ORDER BY CONCAT(c.FirstName,' ',c.LastName) ASC

--10. Creators by Rating
SELECT
c.LastName
,CEILING(AVG(bg.Rating))
,p.[Name]
FROM Creators AS c
JOIN CreatorsBoardgames AS cbg ON
cbg.CreatorId = c.Id
JOIN Boardgames AS bg ON
bg.Id = cbg.BoardgameId
JOIN Publishers AS p ON
p.Id = bg.PublisherId
WHERE p.[Name] = 'Stonemaier Games'
GROUP BY c.LastName,p.[Name]
ORDER BY AVG(bg.Rating) DESC

--11. Creator with Boardgames
CREATE FUNCTION udf_CreatorWithBoardgames(@FirstName NVARCHAR(30))
RETURNS INT
AS 
BEGIN 
RETURN(
SELECT
COUNT(cbg.BoardgameId)
FROM Creators AS c
JOIN CreatorsBoardgames AS cbg ON
cbg.CreatorId = c.Id
WHERE c.FirstName = @FirstName
)
END

--12. Search for Boardgame with Specific Category
CREATE PROCEDURE usp_SearchByCategory(@Category VARCHAR(50))
AS
BEGIN
SELECT
bg.[Name]
,bg.YearPublished
,bg.Rating
,c.[Name]
,p.[Name]
,CONCAT(pr.PlayersMin,' people')
,CONCAT(pr.PlayersMax,' people')
FROM Categories AS c 
JOIN Boardgames AS bg ON
bg.CategoryId = c.Id
JOIN PlayersRanges AS pr ON
pr.Id = bg.PlayersRangeId
JOIN Publishers AS p ON
p.Id = bg.PublisherId
WHERE c.[Name] = @Category
ORDER BY p.[Name] ASC
,bg.YearPublished DESC
END

EXEC usp_SearchByCategory 'Wargames'






