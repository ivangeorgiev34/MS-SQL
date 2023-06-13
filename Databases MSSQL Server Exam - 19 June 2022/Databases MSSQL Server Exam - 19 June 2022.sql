--Section 1
CREATE DATABASE Zoo

USE Zoo

--01. Database Design
CREATE TABLE Owners(
Id INT IDENTITY(1,1) PRIMARY KEY
,[Name] VARCHAR(50) NOT NULL
,PhoneNumber VARCHAR(15) NOT NULL
,[Address] VARCHAR(50)
)

CREATE TABLE AnimalTypes(
Id INT IDENTITY(1,1) PRIMARY KEY
,AnimalType VARCHAR(30) NOT NULL
)

CREATE TABLE Cages(
Id INT IDENTITY(1,1) PRIMARY KEY
,AnimalTypeId INT NOT NULL
,FOREIGN KEY(AnimalTypeId) REFERENCES AnimalTypes(Id)
)

CREATE TABLE Animals(
Id INT IDENTITY(1,1) PRIMARY KEY
,[Name] VARCHAR(30) NOT NULL
,BirthDate DATE NOT NULL
,OwnerId INT 
,AnimalTypeId INT NOT NULL
,FOREIGN KEY(OwnerId) REFERENCES Owners(Id)
,FOREIGN KEY(AnimalTypeId) REFERENCES AnimalTypes(Id)
)

CREATE TABLE AnimalsCages(
CageId INT 
,AnimalId INT 
,PRIMARY KEY(CageId,AnimalId)
,FOREIGN KEY (CageId) REFERENCES Cages(Id)
,FOREIGN KEY (AnimalId) REFERENCES Animals(Id)
)

CREATE TABLE VolunteersDepartments(
Id INT IDENTITY(1,1) PRIMARY KEY
,DepartmentName VARCHAR(30) NOT NULL
)

CREATE TABLE Volunteers(
Id INT IDENTITY(1,1) PRIMARY KEY
,[Name] VARCHAR(50) NOT NULL
,PhoneNumber VARCHAR(15) NOT NULL
,[Address] VARCHAR(50)
,AnimalId INT 
,DepartmentId INT NOT NULL
,FOREIGN KEY (AnimalId) REFERENCES Animals(Id)
,FOREIGN KEY (DepartmentId) REFERENCES VolunteersDepartments(Id)
)

--Section 2

--02. Insert
INSERT INTO Volunteers([Name],PhoneNumber,[Address],AnimalId,DepartmentId)
VALUES 
('Anita Kostova','0896365412','Sofia, 5 Rosa str.',15,1)
,('Dimitur Stoev','0877564223',NULL,42,4)
,('Kalina Evtimova','0896321112','Silistra, 21 Breza str.',9,7)
,('Stoyan Tomov','0898564100','Montana, 1 Bor str.',18,8)
,('Boryana Mileva','0888112233',NULL,31,5)

INSERT INTO Animals([Name],BirthDate,OwnerId,AnimalTypeId)
VALUES
('Giraffe','2018-09-21',21,1)
,('Harpy Eagle','2015-04-17',15,3)
,('Hamadryas Baboon','2017-11-02',NULL,1)
,('Tuatara','2021-06-30',2,4)

--03. Update
UPDATE Animals
SET OwnerId = (SELECT Id FROM Owners WHERE [Name] = 'Kaloqn Stoqnov')
WHERE OwnerId IS NULL

--04. Delete
DELETE FROM Volunteers
WHERE DepartmentId = (SELECT Id FROM VolunteersDepartments
WHERE DepartmentName = 'Education program assistant')

DELETE FROM VolunteersDepartments
WHERE Id = (SELECT Id FROM VolunteersDepartments
WHERE DepartmentName = 'Education program assistant')

--Section 3

--05. Volunteers
SELECT
v.[Name]
,v.PhoneNumber
,v.[Address]
,v.AnimalId
,v.DepartmentId
FROM Volunteers AS v
ORDER BY 
v.[Name] ASC
,v.AnimalId ASC
,v.DepartmentId ASC

--06. Animals data
SELECT
a.[Name]
,(
		SELECT AnimalType FROM AnimalTypes
		WHERE Id = a.AnimalTypeId
)
,FORMAT(a.BirthDate,'dd.MM.yyyy')
FROM Animals AS a
ORDER BY a.[Name] ASC

--07. Owners and Their Animals

SELECT TOP 5
o.[Name] AS [Owner]
,COUNT(a.OwnerId) AS CountOfAnimals
FROM Owners AS o
JOIN Animals AS a ON
a.OwnerId = o.Id
GROUP BY o.[Name]
ORDER BY COUNT(a.OwnerId) DESC,o.[Name] ASC

--08. Owners, Animals and Cages

SELECT
CONCAT(o.[Name],'-',a.[Name]) AS OwnersAnimals
,o.PhoneNumber
,ac.CageId
FROM Owners AS o
JOIN Animals AS a ON
a.OwnerId = o.Id
JOIN AnimalTypes AS aty ON
aty.Id = a.AnimalTypeId
JOIN AnimalsCages AS ac ON 
ac.AnimalId = a.Id
WHERE aty.AnimalType = 'Mammals'
ORDER BY o.[Name] ASC,a.[Name] DESC

--09. Volunteers in Sofia
SELECT
v.[Name]
,v.PhoneNumber
,LTRIM(SUBSTRING(v.[Address],CHARINDEX(',',v.[Address],1)+1,LEN(v.[Address])))
FROM Volunteers AS v
JOIN VolunteersDepartments AS vd ON
vd.Id = v.DepartmentId
WHERE vd.DepartmentName = 'Education program assistant'
AND LTRIM(SUBSTRING(v.[Address],1,CHARINDEX(',',v.[Address],1)-1)) = 'Sofia'
ORDER BY v.[Name]

--10. Animals for Adoption
SELECT 
a.[Name]
,DATEPART(YEAR,a.BirthDate) AS BirthYear
,aty.AnimalType
FROM Animals AS a
JOIN AnimalTypes AS aty ON
aty.Id = a.AnimalTypeId
WHERE a.OwnerId IS NULL
AND aty.AnimalType <> 'Birds'
AND DATEDIFF(YEAR,a.BirthDate,'01/01/2022') < 5
ORDER BY a.[Name]

--11. All Volunteers in a Department
CREATE FUNCTION udf_GetVolunteersCountFromADepartment (@VolunteersDepartment VARCHAR(30))
RETURNS INT
AS 
BEGIN
DECLARE @CountOfVolunteers INT

SET @CountOfVolunteers = 
(SELECT
COUNT(*)
FROM Volunteers AS v
JOIN VolunteersDepartments AS vd ON
vd.Id = v.DepartmentId
WHERE vd.DepartmentName = @VolunteersDepartment)

RETURN @CountOfVolunteers
END

--12. Animals with Owner or Not
CREATE OR ALTER PROCEDURE usp_AnimalsWithOwnersOrNot(@AnimalName VARCHAR(30))
AS

DECLARE @TableResults TABLE ([Name] VARCHAR(30),Owners VARCHAR(50))

IF((SELECT
a.[Name]
FROM Animals AS a
JOIN Owners AS o ON
o.Id = a.OwnerId
WHERE a.[Name] = @AnimalName) IS NULL
AND (SELECT
o.[Name] AS OwnersName
FROM Animals AS a
JOIN Owners AS o ON
o.Id = a.OwnerId
WHERE a.[Name] = @AnimalName) IS NULL)
BEGIN
(SELECT
@AnimalName AS [Name]
,'For adoption' AS OwnersName)
RETURN 
END

(SELECT
a.[Name]
,o.[Name] AS OwnersName
FROM Animals AS a
JOIN Owners AS o ON
o.Id = a.OwnerId
WHERE a.[Name] = @AnimalName)








