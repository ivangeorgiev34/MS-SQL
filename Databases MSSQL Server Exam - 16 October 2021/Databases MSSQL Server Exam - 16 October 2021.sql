--Section 1. DDL 

CREATE DATABASE CigarShop

USE CigarShop

--01. Database Design
CREATE TABLE Sizes(
Id INT IDENTITY(1,1) PRIMARY KEY
,[Length] INT NOT NULL
,RingRange DECIMAL(3,2) NOT NULL
,CHECK ([Length] >= 10 AND [Length] <= 25)
,CHECK (RingRange >= 1.5 AND RingRange <= 7.5)
)

CREATE TABLE Tastes(
Id INT IDENTITY(1,1) PRIMARY KEY
,TasteType VARCHAR(20) NOT NULL
,TasteStrength VARCHAR(15) NOT NULL
,ImageURL NVARCHAR(100) NOT NULL
)

CREATE TABLE Brands(
Id INT IDENTITY(1,1) PRIMARY KEY
,BrandName VARCHAR(30) UNIQUE NOT NULL
,BrandDescription VARCHAR(MAX)
)

--CHECK FOR MULTIPLE PKs
CREATE TABLE Cigars(
Id INT IDENTITY(1,1) PRIMARY KEY
,CigarName VARCHAR(80) NOT NULL
,BrandId INT NOT NULL
,TastId INT NOT NULL
,SizeId INT NOT NULL
,PriceForSingleCigar MONEY NOT NULL
,ImageURL NVARCHAR(100) NOT NULL
--,PRIMARY KEY(Id,SizeId)
,FOREIGN KEY(BrandId) REFERENCES Brands(Id)
,FOREIGN KEY(TastId) REFERENCES Tastes(Id)
,FOREIGN KEY(SizeId) REFERENCES Sizes(Id)
)

CREATE TABLE Addresses(
Id INT IDENTITY(1,1) PRIMARY KEY
,Town VARCHAR(30) NOT NULL
,Country NVARCHAR(30) NOT NULL
,Streat NVARCHAR(100) NOT NULL
,ZIP VARCHAR(20) NOT NULL
)

CREATE TABLE Clients(
Id INT IDENTITY(1,1) PRIMARY KEY
,FirstName NVARCHAR(30) NOT NULL
,LastName NVARCHAR(30) NOT NULL
,Email NVARCHAR(50) NOT NULL
,AddressId INT NOT NULL
,FOREIGN KEY(AddressId) REFERENCES Addresses(Id)
)

CREATE TABLE ClientsCigars(
ClientId INT NOT NULL
,CigarId INT NOT NULL
,PRIMARY KEY (ClientId,CigarId)
,FOREIGN KEY(ClientId) REFERENCES Clients(Id)
,FOREIGN KEY(CigarId) REFERENCES Cigars(Id)
)

--Section 2. DML 

--02. Insert
INSERT INTO Cigars(CigarName,BrandId,TastId,SizeId,PriceForSingleCigar,ImageURL)
VALUES
('COHIBA ROBUSTO',9,1,5,15.50,'cohiba-robusto-stick_18.jpg')
,('COHIBA SIGLO I',9,1,10,410.00,'cohiba-siglo-i-stick_12.jpg')
,('HOYO DE MONTERREY LE HOYO DU MAIRE',14,5,11,7.50,'hoyo-du-maire-stick_17.jpg')
,('HOYO DE MONTERREY LE HOYO DE SAN JUAN',14,4,15,32.00,'hoyo-de-san-juan-stick_20.jpg')
,('TRINIDAD COLONIALES',2,3,8,85.21,'trinidad-coloniales-stick_30.jpg')

INSERT INTO Addresses(Town,Country,Streat,ZIP)
VALUES
('Sofia','Bulgaria','18 Bul. Vasil levski','1000')
,('Athens','Greece','4342 McDonald Avenue','10435')
,('Zagreb','Croatia','4333 Lauren Drive','10000')

--03. Update
UPDATE Cigars
SET PriceForSingleCigar = PriceForSingleCigar * 1.20
WHERE TastId = 1

UPDATE Brands
SET BrandDescription = 'New description'
WHERE BrandDescription IS NULL

--04. Delete
DELETE FROM ClientsCigars
WHERE ClientId IN((SELECT Id FROM Clients WHERE Id IN(SELECT Id FROM Addresses WHERE Country LIKE 'C%')))

DELETE FROM Clients
WHERE Id IN (SELECT Id FROM Addresses WHERE Country LIKE 'C%')

DELETE FROM Addresses 
WHERE Country LIKE 'C%'

--Section 3. Querying

--05. Cigars by Price
SELECT 
c.CigarName
,c.PriceForSingleCigar
,c.ImageURL
FROM Cigars AS c
ORDER BY c.PriceForSingleCigar ASC,c.CigarName DESC

--06. Cigars by Taste
SELECT
c.Id
,c.CigarName
,c.PriceForSingleCigar
,t.TasteType
,t.TasteStrength
FROM Cigars AS c
JOIN Tastes AS t ON
t.Id = c.TastId
WHERE t.TasteType = 'Earthy' OR t.TasteType = 'Woody'
ORDER BY c.PriceForSingleCigar DESC

--07. Clients without Cigars
SELECT 
cl.Id
,CONCAT(cl.FirstName,' ',cl.LastName) AS ClientName
,cl.Email
FROM Clients AS cl
LEFT JOIN ClientsCigars AS clc ON
clc.ClientId  = cl.Id
WHERE clc.ClientId IS NULL
ORDER BY ClientName ASC

--08. First 5 Cigars
SELECT TOP 5
c.CigarName
,c.PriceForSingleCigar
,c.ImageURL
FROM Cigars AS c
JOIN Sizes AS s ON
c.SizeId = s.Id
WHERE (s.[Length] >= 12 AND (c.CigarName LIKE '%CI%'
OR c.PriceForSingleCigar > 50 )AND s.RingRange > 2.55)
ORDER BY c.CigarName ASC,c.PriceForSingleCigar DESC

--09. Clients with ZIP Codes
SELECT
CONCAT(cl.FirstName,' ',cl.LastName) AS FullName
,a.Country
,a.ZIP
,CONCAT('$',MAX(ci.PriceForSingleCigar)) AS CigarPrice
FROM Clients AS cl
JOIN Addresses AS a ON
a.Id = cl.AddressId
JOIN ClientsCigars AS cc ON
cl.Id = cc.ClientId
JOIN Cigars AS ci ON
ci.Id = cc.CigarId
WHERE ISNUMERIC(a.ZIP) = 1
GROUP BY CONCAT(cl.FirstName,' ',cl.LastName),a.Country,a.ZIP
ORDER BY FullName ASC

--10. Cigars by Size
SELECT
cl.LastName
,AVG(s.[Length]) AS CiagrLength
,CEILING(AVG(s.RingRange)) AS CiagrRingRange
FROM Clients AS cl
JOIN ClientsCigars AS cc ON
cc.ClientId = cl.Id
JOIN Cigars AS ci ON
ci.Id = cc.CigarId
JOIN Sizes AS s ON
s.Id = ci.SizeId
GROUP BY cl.LastName
ORDER BY AVG(s.[Length]) DESC

--Section 4. Programmability

--11. Client with Cigars
CREATE FUNCTION udf_ClientWithCigars(@name NVARCHAR(30))
RETURNS INT
AS 
BEGIN

RETURN(
SELECT
COUNT(*)
FROM Clients AS cl
JOIN ClientsCigars AS cc ON
cc.ClientId = cl.Id
JOIN Cigars AS ci ON
ci.Id = cc.CigarId
WHERE cl.FirstName = @name
)

END

--12. Search for Cigar with Specific Taste
CREATE PROCEDURE usp_SearchByTaste(@taste VARCHAR(20))
AS
SELECT 
ci.CigarName
,CONCAT('$',ci.PriceForSingleCigar) AS Price
,t.TasteType
,b.BrandName
,CONCAT(s.[Length],' cm') AS CigarLength 
,CONCAT(s.RingRange,' cm') AS CigarRingRange
FROM Cigars AS ci
JOIN Tastes AS t ON
t.Id = ci.TastId
JOIN Brands AS b ON
b.Id = ci.BrandId
JOIN Sizes AS s ON
s.Id = ci.SizeId
WHERE t.TasteType = @taste
ORDER BY CigarLength ASC,CigarRingRange DESC

EXEC usp_SearchByTaste 'Woody'





