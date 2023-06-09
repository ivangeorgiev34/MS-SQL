CREATE DATABASE TripService

USE TripService

--01. DDL
CREATE TABLE Cities(
Id INT PRIMARY KEY IDENTITY(1,1)
,[Name] NVARCHAR(20) NOT NULL
,CountryCode CHAR(2) NOT NULL
)

CREATE TABLE Hotels(
Id INT PRIMARY KEY IDENTITY(1,1)
,[Name] NVARCHAR(20) NOT NULL
,CityId INT NOT NULL
,EmployeeCount INT NOT NULL
,BaseRate DECIMAL(18,2)
,FOREIGN KEY(CityId) REFERENCES Cities(Id)
)

CREATE TABLE Rooms(
Id INT PRIMARY KEY IDENTITY(1,1)
,Price DECIMAL(18,2) NOT NULL
,[Type] NVARCHAR(20) NOT NULL
,Beds INT NOT NULL
,HotelId INT NOT NULL
,FOREIGN KEY(HotelId) REFERENCES Hotels(Id)
)

CREATE TABLE Trips(
Id INT PRIMARY KEY IDENTITY(1,1)
,RoomId INT NOT NULL
,BookDate DATE NOT NULL
,ArrivalDate DATE NOT NULL
,ReturnDate DATE NOT NULL
,CancelDate DATE 
,CHECK(BookDate < ArrivalDate)
,CHECK(ArrivalDate < ReturnDate)
,FOREIGN KEY(RoomId) REFERENCES Rooms(Id)
)

CREATE TABLE Accounts(
Id INT PRIMARY KEY IDENTITY(1,1)
,FirstName NVARCHAR(50) NOT NULL
,MiddleName NVARCHAR(20)
,LastName NVARCHAR(50) NOT NULL
,CityId INT NOT NULL
,BirthDate DATE NOT NULL
,Email VARCHAR(100) UNIQUE NOT NULL
,FOREIGN KEY(CityId) REFERENCES Cities(Id)
)

CREATE TABLE AccountsTrips(
AccountId INT NOT NULL
,TripId INT NOT NULL
,Luggage INT NOT NULL
,CHECK(Luggage >= 0)
,PRIMARY KEY(AccountId,TripId)
,FOREIGN KEY(AccountId) REFERENCES Accounts(Id)
,FOREIGN KEY(TripId) REFERENCES Trips(Id)
)

--02. Insert
INSERT INTO Accounts(FirstName,MiddleName,LastName,CityId,BirthDate,Email)
VALUES
('John','Smith','Smith',34,'1975-07-21','j_smith@gmail.com')
,('Gosho',NULL,'Petrov',11,'1978-05-16','g_petrov@gmail.com')
,('Ivan','Petrovich','Pavlov',59,'1849-09-26','i_pavlov@softuni.bg')
,('Friedrich','Wilhelm','Nietzsche',2,'1844-10-15','f_nietzsche@softuni.bg')

INSERT INTO Trips(RoomId,BookDate,ArrivalDate,ReturnDate,CancelDate)
VALUES
(101,'2015-04-12','2015-04-14','2015-04-20','2015-02-02')
,(102,'2015-07-07','2015-07-15','2015-07-22','2015-04-29')
,(103,'2013-07-17','2013-07-23','2013-07-24',NULL)
,(104,'2012-03-17','2012-03-31','2012-04-01','2012-01-10')
,(109,'2017-08-07','2017-08-28','2017-08-29',NULL)

--03. Update
UPDATE Rooms
SET Price = Price * 1.14
WHERE HotelId IN (5,7,9)

--04. Delete
DELETE FROM AccountsTrips
WHERE AccountId = 47

--05. EEE-Mails
SELECT
a.FirstName
,a.LastName
,FORMAT(a.BirthDate,'MM-dd-yyyy') AS Hometown
,c.[Name]
,a.Email
FROM Accounts AS a
JOIN Cities AS c ON
c.Id = a.CityId
WHERE a.Email LIKE 'e%'
ORDER BY c.[Name] ASC

--06. City Statistics
SELECT
c.[Name]
,COUNT(*) AS Hotels
FROM Cities AS c 
JOIN Hotels AS h ON
h.CityId = c.Id
GROUP BY c.[Name]
HAVING COUNT(*) > 0
ORDER BY COUNT(*) DESC
,c.[Name] ASC

--07. Longest and Shortest Trips
SELECT
a.Id
,CONCAT(a.FirstName,' ',a.LastName)
,MAX(DATEDIFF(DAY,t.ArrivalDate,t.ReturnDate))
,MIN(DATEDIFF(DAY,t.ArrivalDate,t.ReturnDate))
FROM Accounts AS a 
JOIN AccountsTrips AS atr ON
atr.AccountId = a.Id
JOIN Trips AS t ON
t.Id = atr.TripId
WHERE a.MiddleName IS NULL
AND t.CancelDate IS NULL
GROUP BY a.Id,CONCAT(a.FirstName,' ',a.LastName)
ORDER BY MAX(DATEDIFF(DAY,t.ArrivalDate,t.ReturnDate)) DESC
,MIN(DATEDIFF(DAY,t.ArrivalDate,t.ReturnDate)) ASC

--08. Metropolis
SELECT TOP 10
c.Id
,c.[Name]
,c.CountryCode
,COUNT(*)
FROM Cities AS c 
JOIN Accounts AS a ON
a.CityId = c.Id
GROUP BY c.Id
,c.[Name]
,c.CountryCode
ORDER BY COUNT(*) DESC

--09. Romantic Getaways
SELECT
a.Id
,a.Email
,c.[Name]
,COUNT(t.Id) AS Trips
FROM Accounts AS a
JOIN Cities AS c ON
c.Id = a.CityId
JOIN Hotels AS h ON
h.CityId = c.Id
JOIN AccountsTrips AS atr ON
atr.AccountId = a.Id
JOIN Trips AS t ON
t.Id = atr.TripId
WHERE a.CityId = h.CityId
GROUP BY a.Id
,a.Email
,c.[Name]
HAVING COUNT(t.Id) > 0
ORDER BY COUNT(t.Id) DESC
,a.Id ASC

--10. GDPR Violation
SELECT
t.Id
,CONCAT(a.FirstName,' ',a.MiddleName,' ',a.LastName) AS FullName
,(SELECT c.[Name] FROM  Cities WHERE c.Id = a.CityId)
,(SELECT c.[Name] FROM  Cities WHERE c.Id = h.CityId)
,CASE
WHEN t.CancelDate IS NOT NULL THEN 'Canceled'
ELSE CONCAT(CONVERT(VARCHAR(MAX),DATEDIFF(DAY,t.ArrivalDate,t.ReturnDate)),' days')
END
FROM Hotels AS h 
JOIN Cities AS c ON
c.Id = h.CityId
JOIN Accounts AS a ON
a.CityId = c.Id 
JOIN AccountsTrips AS atr ON
atr.AccountId = a.Id
JOIN Trips AS t ON
t.Id = atr.TripId
--FROM Trips AS t 
--JOIN AccountsTrips AS atr ON
--atr.TripId = t.Id
--JOIN Accounts AS a ON
--a.Id = atr.AccountId
--JOIN Cities AS c ON
--c.Id = a.CityId
--JOIN Hotels AS h ON
--h.CityId = c.Id
ORDER BY FullName ASC
,t.Id ASC

