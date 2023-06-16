--Section 1. DDL 

--01. Database design
CREATE DATABASE Airport

USE Airport

CREATE TABLE Passengers(
Id INT IDENTITY(1,1) PRIMARY KEY
,FullName VARCHAR(100) NOT NULL
,Email VARCHAR(50) NOT NULL
)

CREATE TABLE Pilots(
Id INT IDENTITY(1,1) PRIMARY KEY
,FirstName VARCHAR(30) UNIQUE NOT NULL
,LastName VARCHAR(30) UNIQUE NOT NULL
,Age TINYINT NOT NULL
,Rating FLOAT
,CHECK (Age >= 21 AND Age <= 62)
,CHECK (Rating >= 0.0 AND Rating <= 10.0)
)

CREATE TABLE AircraftTypes(
Id INT IDENTITY(1,1) PRIMARY KEY
,TypeName VARCHAR(30) UNIQUE NOT NULL
)

CREATE TABLE Aircraft(
Id INT IDENTITY(1,1) PRIMARY KEY
,Manufacturer VARCHAR(25) NOT NULL
,Model VARCHAR(30) NOT NULL
,[Year] INT NOT NULL
,FlightHours INT 
,Condition CHAR(1) NOT NULL
,TypeId INT	FOREIGN KEY(TypeId) REFERENCES AircraftTypes(Id) NOT NULL
)

CREATE TABLE PilotsAircraft(
AircraftId INT NOT NULL
,PilotId INT NOT NULL
,PRIMARY KEY(AircraftId,PilotId)
,FOREIGN KEY(AircraftId) REFERENCES Aircraft(Id)
,FOREIGN KEY(PilotId) REFERENCES Pilots(Id)
)

CREATE TABLE Airports(
Id INT IDENTITY(1,1) PRIMARY KEY
,AirportName VARCHAR(70) UNIQUE NOT NULL
,Country VARCHAR(100) UNIQUE NOT NULL
)

CREATE TABLE FlightDestinations(
Id INT IDENTITY(1,1) PRIMARY KEY
,AirportId INT NOT NULL 
,[Start] DATETIME NOT NULL
,AircraftId INT NOT NULL
,PassengerId INT NOT NULL
,TicketPrice DECIMAL(18,2) DEFAULT(15) NOT NULL
,FOREIGN KEY(AirportId) REFERENCES Airports(Id)
,FOREIGN KEY(AircraftId) REFERENCES Aircraft(Id)
,FOREIGN KEY(PassengerId) REFERENCES Passengers(Id)
)

--Section 2. DML

--02. Insert
INSERT INTO Passengers(FullName,Email)
VALUES
((SELECT CONCAT(FirstName,' ',LastName) FROM Pilots WHERE Id = 5),(SELECT CONCAT(FirstName,LastName,'@gmail.com') FROM Pilots WHERE Id = 5))
,((SELECT CONCAT(FirstName,' ',LastName) FROM Pilots WHERE Id = 6),(SELECT CONCAT(FirstName,LastName,'@gmail.com') FROM Pilots WHERE Id = 6))
,((SELECT CONCAT(FirstName,' ',LastName) FROM Pilots WHERE Id = 7),(SELECT CONCAT(FirstName,LastName,'@gmail.com') FROM Pilots WHERE Id = 7))
,((SELECT CONCAT(FirstName,' ',LastName) FROM Pilots WHERE Id = 8),(SELECT CONCAT(FirstName,LastName,'@gmail.com') FROM Pilots WHERE Id = 8))
,((SELECT CONCAT(FirstName,' ',LastName) FROM Pilots WHERE Id = 9),(SELECT CONCAT(FirstName,LastName,'@gmail.com') FROM Pilots WHERE Id = 9))
,((SELECT CONCAT(FirstName,' ',LastName) FROM Pilots WHERE Id = 10),(SELECT CONCAT(FirstName,LastName,'@gmail.com') FROM Pilots WHERE Id = 10))
,((SELECT CONCAT(FirstName,' ',LastName) FROM Pilots WHERE Id = 11),(SELECT CONCAT(FirstName,LastName,'@gmail.com') FROM Pilots WHERE Id = 11))
,((SELECT CONCAT(FirstName,' ',LastName) FROM Pilots WHERE Id = 12),(SELECT CONCAT(FirstName,LastName,'@gmail.com') FROM Pilots WHERE Id = 12))
,((SELECT CONCAT(FirstName,' ',LastName) FROM Pilots WHERE Id = 13),(SELECT CONCAT(FirstName,LastName,'@gmail.com') FROM Pilots WHERE Id = 13))
,((SELECT CONCAT(FirstName,' ',LastName) FROM Pilots WHERE Id = 14),(SELECT CONCAT(FirstName,LastName,'@gmail.com') FROM Pilots WHERE Id = 14))
,((SELECT CONCAT(FirstName,' ',LastName) FROM Pilots WHERE Id = 15),(SELECT CONCAT(FirstName,LastName,'@gmail.com') FROM Pilots WHERE Id = 15))

--03. Update
UPDATE Aircraft 
SET Condition = 'A'
WHERE Condition IN ('B','C')
AND (FlightHours IS NULL OR FlightHours <= 100)
AND [Year] >= 2013


--04. Delete
DELETE FROM Passengers
WHERE LEN(FullName) <= 10

--Section 3. Querying 

--05. Aircraft
SELECT
a.Manufacturer
,a.Model
,a.FlightHours
,a.Condition
FROM Aircraft AS a
ORDER BY FlightHours DESC

--06. Pilots and Aircraft
SELECT
p.FirstName
,p.LastName
,a.Manufacturer
,a.Model
,a.FlightHours
FROM PilotsAircraft AS pa
JOIN Aircraft AS a ON
a.Id = pa.AircraftId
JOIN Pilots AS p ON
p.Id = pa.PilotId
WHERE a.FlightHours IS NOT NULL
AND a.FlightHours <= 304
ORDER BY a.FlightHours DESC,p.FirstName ASC

--07. Top 20 Flight Destinations
SELECT TOP 20
fd.Id AS DestinationId
,fd.[Start]
,p.FullName
,a.AirportName
,fd.TicketPrice
FROM FlightDestinations AS fd
JOIN Passengers AS p ON
p.Id = fd.PassengerId
JOIN Airports AS a ON
a.Id = fd.AirportId
WHERE DATEPART(DAY,fd.[Start]) % 2 = 0
ORDER BY fd.TicketPrice DESC,a.AirportName ASC

--08. Number of Flights for Each Aircraft
SELECT
fd.AircraftId
,ac.Manufacturer
,ac.FlightHours
,COUNT(*) AS FlightDestinationsCount
,ROUND(AVG(fd.TicketPrice),2) AS AvgPrice
--*
FROM Aircraft AS ac
JOIN FlightDestinations AS fd ON
fd.AircraftId = ac.Id
GROUP BY fd.AircraftId,ac.Manufacturer,ac.FlightHours
HAVING COUNT(*) >= 2
ORDER BY FlightDestinationsCount DESC,fd.AircraftId ASC

--09. Regular Passengers
SELECT
p.FullName
,COUNT(a.Id)
,SUM(fd.TicketPrice)
FROM FlightDestinations AS fd
JOIN Passengers AS p ON
fd.PassengerId = p.Id
JOIN Aircraft AS a ON
a.Id = fd.AircraftId
GROUP BY p.FullName
HAVING p.FullName LIKE '_a%'
AND COUNT(a.Id) > 1
ORDER BY p.FullName ASC

--10. Full Info for Flight Destinations
SELECT
ap.AirportName
,fd.[Start]
,fd.TicketPrice
,p.FullName
,ac.Manufacturer
,ac.Model
FROM FlightDestinations AS fd
JOIN Airports AS ap ON
ap.Id = fd.AirportId
JOIN Passengers AS p ON
p.Id = FD.PassengerId
JOIN Aircraft AS ac ON
ac.Id = fd.AircraftId
WHERE (DATEPART(HOUR,fd.[Start]) >= 6 
AND DATEPART(HOUR,fd.[Start]) <= 20)
AND fd.TicketPrice > 2500
ORDER BY ac.Model ASC

--Section 4. Programmability 

--11. Find all Destinations by Email Address
CREATE FUNCTION udf_FlightDestinationsByEmail(@email VARCHAR(50))
RETURNS INT
AS 
BEGIN

DECLARE @CountOfFlightDestinations INT

SET @CountOfFlightDestinations=
(SELECT
COUNT(*)
FROM Passengers AS p
JOIN FlightDestinations AS fd ON
fd.PassengerId = p.Id
WHERE p.Email = @email)

RETURN @CountOfFlightDestinations
END

--12. Full Info for Airports
CREATE OR ALTER PROCEDURE usp_SearchByAirportName(@airportName VARCHAR(70))
AS

SELECT
ap.AirportName
,p.FullName
,(CASE
WHEN fd.TicketPrice <= 400 THEN 'Low'
WHEN fd.TicketPrice >= 401 AND fd.TicketPrice <= 1500 THEN 'Medium'
WHEN fd.TicketPrice > 1501 THEN 'High'
END) AS LevelOfTickerPrice 
,ac.Manufacturer
,ac.Condition
,aty.TypeName
FROM Airports AS ap
JOIN FlightDestinations AS fd ON
fd.AirportId = ap.Id
JOIN Passengers AS p ON
p.Id = fd.PassengerId
JOIN Aircraft AS ac ON
ac.Id = fd.AircraftId
JOIN AircraftTypes AS aty ON
aty.Id = ac.TypeId
WHERE ap.AirportName = @airportName
ORDER BY ac.Manufacturer ASC,p.FullName ASC









