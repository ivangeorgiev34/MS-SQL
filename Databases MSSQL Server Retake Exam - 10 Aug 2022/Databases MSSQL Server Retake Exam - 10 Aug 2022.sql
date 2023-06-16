CREATE DATABASE NationalTouristSitesOfBulgaria

USE NationalTouristSitesOfBulgaria

--01. DDL
CREATE TABLE Categories(
Id INT PRIMARY KEY IDENTITY(1,1)
,[Name] VARCHAR(50) NOT NULL
) 

CREATE TABLE Locations(
Id INT PRIMARY KEY IDENTITY(1,1)
,[Name] VARCHAR(50) NOT NULL
,Municipality VARCHAR(50)
,Province VARCHAR(50)
)

CREATE TABLE Sites(
Id INT PRIMARY KEY IDENTITY(1,1)
,[Name] VARCHAR(100) NOT NULL
,LocationId INT NOT NULL
,CategoryId INT NOT NULL
,Establishment VARCHAR(15)
,FOREIGN KEY(LocationId) REFERENCES Locations(Id)
,FOREIGN KEY(CategoryId) REFERENCES Categories(Id)
)

CREATE TABLE Tourists(
Id INT PRIMARY KEY IDENTITY(1,1)
,[Name] VARCHAR(50) NOT NULL
,Age INT NOT NULL
,PhoneNumber VARCHAR(20) NOT NULL
,Nationality VARCHAR(30) NOT NULL
,Reward VARCHAR(20)
,CHECK (Age>=0 AND Age<=120)
)

CREATE TABLE SitesTourists(
TouristId INT NOT NULL
,SiteId INT NOT NULL
,PRIMARY KEY (TouristId,SiteId)
,FOREIGN KEY(TouristId) REFERENCES Tourists(Id)
,FOREIGN KEY(SiteId) REFERENCES Sites(Id)
)

CREATE TABLE BonusPrizes(
Id INT PRIMARY KEY IDENTITY(1,1)
,[Name] VARCHAR(50) NOT NULL
)

CREATE TABLE TouristsBonusPrizes(
TouristId INT NOT NULL
,BonusPrizeId INT NOT NULL
,PRIMARY KEY(TouristId,BonusPrizeId)
,FOREIGN KEY(TouristId) REFERENCES Tourists(Id)
,FOREIGN KEY(BonusPrizeId) REFERENCES BonusPrizes(Id)
)

--02. Insert
INSERT INTO Tourists([Name],Age,PhoneNumber,Nationality,Reward)
VALUES
('Borislava Kazakova',52,'+359896354244','Bulgaria',NULL)
,('Peter Bosh',48,'+447911844141','UK',NULL)
,('Martin Smith',29,'+353863818592','Ireland','Bronze badge')
,('Svilen Dobrev',49,'+359986584786','Bulgaria','Silver badge')
,('Kremena Popova',38,'+359893298604','Bulgaria',NULL)

INSERT INTO Sites([Name],LocationId,CategoryId,Establishment)
VALUES
('Ustra fortress',90,7,'X')
,('Karlanovo Pyramids',65,7,NULL)
,('The Tomb of Tsar Sevt',63,8,'V BC')
,('Sinite Kamani Natural Park',17,1,NULL)
,('St. Petka of Bulgaria – Rupite',92,6,'1994')

--03. Update
UPDATE Sites
SET Establishment = '(not defined)'
WHERE Establishment IS NULL

--04. Delete 
DELETE FROM TouristsBonusPrizes
WHERE BonusPrizeId IN (
SELECT Id 
FROM BonusPrizes 
WHERE [Name] = 'Sleeping bag')

DELETE FROM BonusPrizes
WHERE [Name] = 'Sleeping bag'

--05. Tourists 
SELECT
t.[Name]
,t.Age
,t.PhoneNumber
,t.Nationality
FROM Tourists AS t
ORDER BY t.Nationality ASC
,t.Age DESC
,t.[Name] ASC

--06. Sites with Their Location and Category 
SELECT
s.[Name]
,l.[Name]
,s.Establishment
,c.[Name]
FROM Sites AS s
JOIN Locations AS l ON
l.Id = s.LocationId
JOIN Categories AS c ON
c.Id = s.CategoryId
ORDER BY c.[Name] DESC
,l.[Name] ASC
,s.[Name] ASC

--07. Count of Sites in Sofia Province 
SELECT
l.Province
,l.Municipality
,l.[Name]
,COUNT(s.[Name])
FROM Locations AS l
JOIN Sites AS s ON
s.LocationId = l.Id
WHERE l.Province = 'Sofia'
GROUP BY l.[Name]
,l.Province
,l.Municipality
ORDER BY COUNT(s.[Name]) DESC
,l.[Name] ASC

--08. Tourist Sites established BC 
SELECT
s.[Name]
,l.[Name]
,l.Municipality
,l.Province
,s.Establishment
FROM Sites AS s
JOIN Locations AS l ON
l.Id = s.LocationId
WHERE (l.[Name] NOT LIKE 'B%'
AND l.[Name] NOT LIKE 'M%'
AND l.[Name] NOT LIKE 'D%')
AND s.Establishment LIKE '%BC'
ORDER BY s.[Name] ASC

--09. Tourists with their Bonus Prizes 
SELECT
t.[Name]
,t.Age
,t.PhoneNumber
,t.Nationality
,CASE
WHEN bp.[Name] IS NULL THEN '(no bonus prize)'
WHEN bp.[Name] IS NOT NULL THEN bp.[Name]
END
FROM Tourists AS t
LEFT JOIN TouristsBonusPrizes AS tbp ON
t.Id = tbp.TouristId
LEFT JOIN BonusPrizes AS bp ON
bp.Id = tbp.BonusPrizeId
ORDER BY t.[Name] ASC

--10. Tourists visiting History & Archaeology sites 
SELECT
RTRIM(SUBSTRING(t.[Name],CHARINDEX(' ',t.[Name]),LEN(t.[Name]) - CHARINDEX(' ',t.[Name])+1)) AS LastName --FIDEL CASTRO
,t.Nationality
,t.Age
,t.PhoneNumber
FROM Tourists AS t
JOIN SitesTourists AS st ON
st.TouristId = t.Id
JOIN Sites AS s ON
s.Id = st.SiteId
JOIN Categories AS c ON
c.Id = s.CategoryId
WHERE c.[Name] = 'History and archaeology'
GROUP BY RTRIM(SUBSTRING(t.[Name],CHARINDEX(' ',t.[Name]),LEN(t.[Name]) - CHARINDEX(' ',t.[Name])+1))
,t.Nationality
,t.Age
,t.PhoneNumber
ORDER BY LastName ASC

--11. Tourists Count on a Tourist Site 
CREATE FUNCTION udf_GetTouristsCountOnATouristSite(@Site VARCHAR(100))
RETURNS INT
AS
BEGIN
RETURN (SELECT
COUNT(t.[Name])
FROM Sites AS s
JOIN SitesTourists AS st ON
st.SiteId = s.Id
JOIN Tourists AS t ON
t.Id = st.TouristId
WHERE s.[Name] = @Site
GROUP BY s.[Name])
END

--12. Annual Reward Lottery 
CREATE OR ALTER PROCEDURE usp_AnnualRewardLottery(@TouristName VARCHAR(50))
AS
DECLARE @SitesVisited INT,
@Badge VARCHAR(20)
BEGIN
SET @SitesVisited = (SELECT
COUNT(s.[Name])
FROM Tourists AS t 
JOIN SitesTourists AS st ON
st.TouristId = t.Id
JOIN Sites AS s ON
s.Id = st.SiteId
WHERE t.[Name] = @TouristName)

IF(@SitesVisited >= 100)
BEGIN
SET @Badge = 'Gold badge'
END
ELSE IF(@SitesVisited >= 50)
BEGIN 
SET @Badge = 'Silver badge'
END
ELSE IF(@SitesVisited >= 25)
BEGIN 
SET @Badge = 'Bronze badge'
END

UPDATE Tourists
SET Reward = @Badge
WHERE [Name] = @TouristName

SELECT
t.[Name]
,t.Reward
FROM Tourists AS t
WHERE t.[Name] = @TouristName

END








