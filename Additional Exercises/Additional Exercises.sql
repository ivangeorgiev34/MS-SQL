--Problem 1
USE Diablo

SELECT
SUBSTRING(u.Email,CHARINDEX('@',u.Email,1)+1,LEN(u.Email) - CHARINDEX('@',u.Email,1)) AS [Email Provider]
,COUNT(*) AS [Number Of Users]
FROM Users AS u
GROUP BY SUBSTRING(u.Email,CHARINDEX('@',u.Email,1)+1,LEN(u.Email) - CHARINDEX('@',u.Email,1))
ORDER BY 
COUNT(*) DESC
,[Email Provider] ASC

--Problem 2
SELECT
g.[Name] AS [Game]
,gt.[Name] AS [Game Type]
,u.Username AS [Username]
,ug.[Level] AS [Level]
,ug.Cash AS [Cash]
,c.[Name] AS [Character]
FROM Users AS u 
JOIN UsersGames AS ug ON
u.Id = ug.UserId
JOIN Games AS g ON
g.Id = ug.GameId
JOIN GameTypes AS gt ON
gt.Id = g.GameTypeId
JOIN Characters AS c ON
c.Id = ug.CharacterId
ORDER BY 
ug.[Level] DESC
,u.Username ASC
,g.[Name] ASC


--Problem 3
SELECT 
u.Username AS [Username]
,g.[Name] AS [Game]
,COUNT(i.[Name]) AS [Items Count]
,SUM(i.Price) AS [Items Price]
FROM UsersGames AS ug
JOIN Users AS u ON
u.Id = ug.UserId
JOIN Games  AS g ON
g.Id = ug.GameId
JOIN GameTypes AS gt ON 
g.GameTypeId = gt.id
JOIN Characters AS c ON 
ug.CharacterId = c.Id
JOIN UserGameItems AS ugt ON 
ug.Id = ugt.UserGameId
JOIN Items AS i ON 
ugt.ItemId = i.Id
GROUP BY U.Username,g.[Name]
HAVING COUNT(*) >= 10
ORDER BY 
COUNT(*) DESC
,SUM(i.Price) DESC
,u.Username ASC

--Problem 4
SELECT us.Username AS [Username], 
ga.[Name] AS [Game], 
MAX(cha.[Name]) AS [Character], 
SUM(sta.Strength) + MAX(gtst.Strength) 
+ MAX(chst.Strength) AS [Strength], 
SUM(sta.Defence) + MAX(gtst.Defence) 
+ MAX(chst.Defence) AS [Defence], 
SUM(sta.Speed) + MAX(gtst.Speed) 
+ MAX(chst.Speed) AS [Speed], 
SUM(sta.Mind) + MAX(gtst.Mind) 
+ MAX(chst.Mind) AS [Mind], 
SUM(sta.Luck) + MAX(gtst.Luck) 
+ MAX(chst.Luck) AS [Luck] 
FROM   Users AS us 
JOIN UsersGames AS ug 
ON us.Id = ug.UserId 
JOIN Games AS ga 
ON ug.GameId = ga.Id 
JOIN Characters AS cha 
ON ug.CharacterId = cha.Id 
JOIN UserGameItems AS ugi 
ON ug.Id = ugi.UserGameId 
JOIN Items AS itms 
ON ugi.ItemId = itms.Id 
JOIN [Statistics] AS sta 
ON itms.StatisticId = sta.Id 
JOIN GameTypes AS gt 
ON ga.GameTypeId = gt.Id 
JOIN [Statistics] AS chst 
ON cha.StatisticId = chst.Id 
JOIN [Statistics] AS gtst 
ON gt.BonusStatsId = gtst.Id 
GROUP  BY us.Username, ga.[Name] 
ORDER  BY Strength DESC, Defence DESC, Speed DESC, Mind DESC, Luck DESC 

--Problem 5
USE Diablo

SELECT
i.[Name]
,i.Price
,i.MinLevel
,s.Strength
,s.Defence
,s.Speed
,s.Luck
,s.Mind
FROM Items AS i
JOIN [Statistics] AS s ON
s.Id = i.StatisticId
GROUP BY i.[Name],i.Price,i.MinLevel,s.Strength,s.Defence,s.Speed,s.Luck,s.Mind
HAVING  s.Mind > (SELECT AVG(Mind) FROM [Statistics])
AND s.Luck > (SELECT AVG(Luck) FROM [Statistics])
AND s.Speed > (SELECT AVG(Speed) FROM [Statistics])
ORDER BY i.[Name] ASC

--Problem 6
SELECT
i.[Name] AS Item
,i.Price
,i.MinLevel
,gt.[Name] AS [Forbidden Game Type]
FROM GameTypes AS gt 
FULL JOIN GameTypeForbiddenItems AS gtfi ON
gt.Id = gtfi.GameTypeId
FULL JOIN Items AS i ON
i.Id = gtfi.ItemId
ORDER BY gt.[Name] DESC,i.[Name] ASC

--Problem 7
DECLARE @AlexUserGameId INT = (SELECT Id 
   FROM   UsersGames AS ug 
   WHERE  ug.GameId = (SELECT Id 
                       FROM   Games 
                       WHERE  Name = 'Edinburgh') 
          AND ug.UserId = (SELECT Id 
                           FROM   Users 
                           WHERE  Username = 'Alex')) 
DECLARE @AlexItemsPrice MONEY = (SELECT SUM(Price) 
   FROM   Items 
   WHERE  Name IN ( 'Blackguard', 'Bottomless Potion of Amplification', 
                            'Eye of Etlich (Diablo III)' 
                                    , 'Gem of Efficacious Toxin', 
                    'Golden Gorget of Leoric', 'Hellfire Amulet' )) 
DECLARE @GameID INT = (SELECT GameId 
   FROM   UsersGames 
   WHERE  Id = @AlexUserGameId) 

INSERT UserGameItems 
SELECT it.Id, 
       @AlexUserGameId 
FROM   Items AS it 
WHERE  it.Name IN ( 'Blackguard', 'Bottomless Potion of Amplification', 
                           'Eye of Etlich (Diablo III)' 
                                      , 'Gem of Efficacious Toxin', 
                    'Golden Gorget of Leoric', 'Hellfire Amulet' ) 

UPDATE UsersGames 
SET    Cash = Cash - @AlexItemsPrice 
WHERE  Id = @AlexUserGameId 

SELECT us.Username, 
       ga.[Name], 
       ug.Cash, 
       its.[Name] AS [Item Name] 
FROM   Users AS us 
       INNER JOIN UsersGames AS ug 
               ON ug.UserId = us.Id 
       INNER JOIN Games AS ga 
               ON ga.Id = ug.GameId 
       INNER JOIN UserGameItems AS ugi 
               ON ugi.UserGameId = ug.Id 
       INNER JOIN Items AS its 
               ON its.Id = ugi.ItemId 
WHERE  ug.GameId = @GameID 
ORDER  BY [Item Name] 

--Problem 8
USE [Geography]

SELECT
p.PeakName
,m.MountainRange
,p.Elevation
FROM Mountains AS m 
JOIN Peaks AS p ON
p.MountainId = m.Id
ORDER BY p.Elevation DESC,p.PeakName ASC

--Problem 9
SELECT
p.PeakName
,m.MountainRange
,cou.CountryName
,con.ContinentName
FROM Countries AS cou 
JOIN MountainsCountries AS mc ON
mc.CountryCode = cou.CountryCode
JOIN Mountains AS m ON
m.Id = mc.MountainId
JOIN Peaks AS p ON
p.MountainId = m.Id
JOIN Continents AS con ON
con.ContinentCode = cou.ContinentCode
ORDER BY p.PeakName ASC,cou.CountryName ASC

--Problem 10
SELECT
cou.CountryName
,con.ContinentName
,ISNULL(COUNT(r.RiverName),0)
,ISNULL(SUM(r.[Length]),0)
FROM Countries AS cou
LEFT JOIN Continents AS con ON
con.ContinentCode = cou.ContinentCode
LEFT JOIN CountriesRivers AS cr ON 
cr.CountryCode = cou.CountryCode
LEFT JOIN Rivers AS r ON
r.Id = cr.RiverId
GROUP BY cou.CountryName,con.ContinentName
ORDER BY COUNT(r.RiverName) DESC,SUM(r.[Length]) DESC,cou.CountryName ASC

--Problem 11
SELECT
cur.CurrencyCode AS CurrencyCode
,cur.[Description] AS Currency
,COUNT(cou.CountryCode) AS NumberOfCountries
FROM Currencies AS cur
LEFT JOIN Countries AS cou ON
cur.CurrencyCode = cou.CurrencyCode
GROUP BY cur.CurrencyCode,cur.[Description]
ORDER BY NumberOfCountries DESC,cur.[Description] ASC

--Problem 12
SELECT
con.ContinentName AS ContinentName
,SUM(CAST(cou.AreaInSqKm AS bigint)) AS CountriesArea
,SUM(CAST(cou.[Population] AS bigint)) AS CountriesPopulation
FROM Continents AS con
JOIN Countries AS cou ON
cou.ContinentCode = con.ContinentCode
GROUP BY con.ContinentName
ORDER BY CountriesPopulation DESC

--Problem 13
CREATE TABLE Monasteries(
Id INT IDENTITY(1,1) PRIMARY KEY
,[Name] VARCHAR(MAX) NOT NULL
,CountryCode CHAR(2) NOT NULL
,FOREIGN KEY(CountryCode) REFERENCES Countries(CountryCode)
)

INSERT INTO Monasteries(Name, CountryCode) VALUES
('Rila Monastery “St. Ivan of Rila”', 'BG'), 
('Bachkovo Monastery “Virgin Mary”', 'BG'),
('Troyan Monastery “Holy Mother''s Assumption”', 'BG'),
('Kopan Monastery', 'NP'),
('Thrangu Tashi Yangtse Monastery', 'NP'),
('Shechen Tennyi Dargyeling Monastery', 'NP'),
('Benchen Monastery', 'NP'),
('Southern Shaolin Monastery', 'CN'),
('Dabei Monastery', 'CN'),
('Wa Sau Toi', 'CN'),
('Lhunshigyia Monastery', 'CN'),
('Rakya Monastery', 'CN'),
('Monasteries of Meteora', 'GR'),
('The Holy Monastery of Stavronikita', 'GR'),
('Taung Kalat Monastery', 'MM'),
('Pa-Auk Forest Monastery', 'MM'),
('Taktsang Palphug Monastery', 'BT'),
('Sümela Monastery', 'TR')

ALTER TABLE Countries
ADD IsDeleted BIT DEFAULT 0 NOT NULL

UPDATE Countries 
SET IsDeleted = 1
WHERE CountryCode IN(
SELECT
cou.CountryCode
FROM Countries AS cou
JOIN CountriesRivers AS cr ON
cr.CountryCode = cou.CountryCode
JOIN Rivers AS r ON
r.Id = cr.RiverId
GROUP BY cou.CountryCode
HAVING COUNT(r.Id) > 3
)

SELECT
m.[Name]
,c.CountryName
FROM Monasteries AS m 
JOIN Countries AS c ON 
c.CountryCode = m.CountryCode
WHERE c.IsDeleted = 0
ORDER BY m.[Name]


--Problem 14
UPDATE Countries 
SET CountryName = 'Burma'
WHERE CountryName = 'Myanmar'

INSERT INTO Monasteries([Name],CountryCode)
VALUES
('Hanga Abbey',(SELECT cou.CountryCode FROM Countries AS cou WHERE CountryName = 'Tanzania'))

INSERT INTO Monasteries([Name],CountryCode)
VALUES
('Myin-Tin-Daik',(SELECT cou.CountryCode FROM Countries AS cou WHERE CountryName = 'Myanmar'))

SELECT
con.ContinentName AS ContinentName
,cou.CountryName AS CountryName
,COUNT(m.Id) AS MonasteriesCount
FROM Countries AS cou
LEFT JOIN Monasteries AS m ON
cou.CountryCode = m.CountryCode
LEFT JOIN Continents AS con ON
con.ContinentCode = cou.ContinentCode
WHERE cou.IsDeleted = 0
GROUP BY con.ContinentName,cou.CountryName
ORDER BY COUNT(m.Id) DESC,cou.CountryName ASC










