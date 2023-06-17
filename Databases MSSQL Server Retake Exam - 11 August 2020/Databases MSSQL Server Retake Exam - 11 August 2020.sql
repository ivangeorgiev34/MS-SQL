--Section 1. DDL 
CREATE DATABASE Bakery

USE Bakery

--01. DDL

CREATE TABLE Countries(
Id INT IDENTITY(1,1) PRIMARY KEY
,[Name] NVARCHAR(50) UNIQUE NOT NULL
)

CREATE TABLE Customers(
Id INT IDENTITY(1,1) PRIMARY KEY
,FirstName NVARCHAR(25) NOT NULL
,LastName NVARCHAR(25) NOT NULL
,Gender CHAR(1) NOT NULL
,Age INT NOT NULL
,PhoneNumber VARCHAR(10) NOT NULL
,CountryId INT NOT NULL
,CHECK (Gender IN ('M','F'))
,CHECK (LEN(PhoneNumber) = 10)
,FOREIGN KEY(CountryId) REFERENCES Countries(Id)
)

CREATE TABLE Products(
Id INT IDENTITY(1,1) PRIMARY KEY
,[Name] NVARCHAR(25) UNIQUE NOT NULL
,[Description] NVARCHAR(250) NOT NULL
,Recipe NVARCHAR(MAX) NOT NULL
,Price MONEY NOT NULL
,CHECK (Price > 0)
)

CREATE TABLE Feedbacks(
Id INT IDENTITY(1,1) PRIMARY KEY
,[Description] NVARCHAR(255) 
,Rate DECIMAL(3,2) NOT NULL
,ProductId INT NOT NULL
,CustomerId INT NOT NULL
,CHECK (Rate >= 0 AND Rate <= 10)
,FOREIGN KEY(ProductId) REFERENCES Products(Id)
,FOREIGN KEY(CustomerId) REFERENCES Customers(Id)
)

CREATE TABLE Distributors(
Id INT IDENTITY(1,1) PRIMARY KEY
,[Name] NVARCHAR(25) UNIQUE NOT NULL
,AddressText NVARCHAR(30) NOT NULL
,Summary NVARCHAR(200) NOT NULL
,CountryId INT NOT NULL
,FOREIGN KEY(CountryId) REFERENCES Countries(Id)
)

CREATE TABLE Ingredients(
Id INT IDENTITY(1,1) PRIMARY KEY
,[Name] NVARCHAR(30)  NOT NULL
,[Description] NVARCHAR(200) NOT NULL
,OriginCountryId INT NOT NULL
,DistributorId INT NOT NULL
,FOREIGN KEY(OriginCountryId) REFERENCES Countries(Id)
,FOREIGN KEY(DistributorId) REFERENCES Distributors(Id)
)

CREATE TABLE ProductsIngredients(
ProductId INT NOT NULL
,IngredientId INT NOT NULL
,PRIMARY KEY(ProductId,IngredientId)
,FOREIGN KEY(ProductId) REFERENCES Products(Id)
,FOREIGN KEY(IngredientId) REFERENCES Ingredients(Id)
)

--Section 2. DML 
INSERT INTO Distributors([Name],CountryId,AddressText,Summary)
VALUES
('Deloitte & Touche',2,'6 Arch St #9757','Customizable neutral traveling')
,('Congress Title',13,'58 Hancock St','Customer loyalty')
,('Kitchen People',1,'3 E 31st St #77','Triple-buffered stable delivery')
,('General Color Co Inc',21,'6185 Bohn St #72','Focus group')
,('Beck Corporation',23,'21 E 64th Ave','Quality-focused 4th generation hardware')

INSERT INTO Customers(FirstName,LastName,Age,Gender,PhoneNumber,CountryId)
VALUES
('Francoise','Rautenstrauch',15,'M','0195698399',5)
,('Kendra','Loud',22,'F','0063631526',11)
,('Lourdes','Bauswell',50,'M','0139037043',8)
,('Hannah','Edmison',18,'F','0043343686',1)
,('Tom','Loeza',31,'M','0144876096',23)
,('Queenie','Kramarczyk',30,'F','0064215793',29)
,('Hiu','Portaro',25,'M','0068277755',16)
,('Josefa','Opitz',43,'F','0197887645',17)

--03. Update
UPDATE Ingredients
SET DistributorId = 35
WHERE [Name] IN( 'Bay Leaf','Paprika','Poppy')

UPDATE Ingredients
SET OriginCountryId = 14
WHERE OriginCountryId = 8

--04. Delete
DELETE FROM Feedbacks
WHERE CustomerId = 14 OR ProductId = 5

--Section 3. Querying 

--05. Products By Price
SELECT
p.[Name]
,p.Price
,p.[Description]
FROM Products AS p
ORDER BY p.Price DESC,p.[Name] ASC

--06. Negative Feedback
SELECT
f.ProductId
,f.Rate
,f.[Description]
,f.CustomerId
,c.Age
,c.Gender
FROM Feedbacks AS f
JOIN Customers AS c ON
c.Id = f.CustomerId
WHERE f.Rate < 5
ORDER BY ProductId DESC,Rate ASC

--07. Customers without Feedback
SELECT
CONCAT(c.FirstName,' ',c.LastName)
,c.PhoneNumber
,c.Gender
FROM Customers AS c 
LEFT JOIN Feedbacks AS f ON
f.CustomerId = c.Id
WHERE f.CustomerId IS NULL
ORDER BY c.Id ASC

--08. Customers by Criteria
SELECT
cu.FirstName
,cu.Age
,cu.PhoneNumber
FROM Customers AS cu
JOIN Countries AS co ON
co.Id = cu.CountryId
WHERE (cu.Age >= 21 AND cu.FirstName LIKE '%an%')
OR (cu.PhoneNumber LIKE'________38' AND co.[Name] != 'Greece')
ORDER BY cu.FirstName ASC,cu.Age DESC

--09. Middle Range Distributors
--	Select all distributors which distribute ingredients used in the making process of all products 
--	having average rate between 5 and 8 (inclusive). 
--	Order by distributor name, ingredient name and product name all ascending.

SELECT
d.[Name]
,i.[Name]
,p.[Name]
,AVG(f.Rate)
FROM ProductsIngredients AS pri
JOIN Products AS p ON
p.Id = pri.ProductId
JOIN Ingredients AS i ON
i.Id = pri.IngredientId
JOIN Distributors AS d ON 
d.Id = i.DistributorId
JOIN Feedbacks AS f ON
f.ProductId = p.Id
GROUP BY d.[Name],i.[Name],p.[Name]
HAVING AVG(f.Rate) >= 5 AND AVG(f.Rate) <= 8
ORDER BY d.[Name] ASC,i.[Name] ASC, p.[Name] ASC

--10. Country Representative
SELECT
CountryName
,DistributorName
FROM (SELECT
c.[Name] AS CountryName
,d.[Name] AS DistributorName
,COUNT(i.Id) AS CountOfIngredients
,DENSE_RANK() OVER (PARTITION BY c.[Name] ORDER BY COUNT(i.Id) DESC) AS Ranked
FROM Countries AS c
JOIN Distributors AS d ON 
c.Id = d.CountryId
LEFT JOIN Ingredients AS i ON
d.Id = i.DistributorId
GROUP BY c.[Name],d.[Name]) AS temp
WHERE Ranked = 1
ORDER BY CountryName,DistributorName

--Section 4. Programmability 

--11. Customers with Countries
CREATE VIEW v_UserWithCountries AS
SELECT
CONCAT(cu.FirstName,' ',cu.LastName) AS CustomerName
,cu.Age
,cu.Gender
,co.[Name]
FROM Customers AS cu
JOIN Countries AS co ON
co.Id = cu.CountryId

--12. Delete Products
--Create a trigger that deletes all of the relations of a product upon its deletion. 
CREATE TRIGGER tr_DeleteRelations
ON Products
INSTEAD OF DELETE
AS
BEGIN

DELETE FROM ProductsIngredients
WHERE ProductId = (SELECT Id FROM deleted)

DELETE FROM Feedbacks
WHERE ProductId = (SELECT Id FROM deleted)

END







