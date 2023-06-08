USE TestDB

--Problem 1
CREATE TABLE [Persons](
PersonID INT  IDENTITY(1,1)
,FirstName NVARCHAR(30)
,Salary DECIMAL(7,2)
,PassportID INT
)

CREATE TABLE [Passports](
PassportID INT IDENTITY(101,1)
,PassportNumber NVARCHAR(50)
)

INSERT INTO Passports(PassportNumber)
VALUES
('N34FG21B')
,('K65LO4R7')
,('ZE657QP2')

INSERT INTO Persons(FirstName,Salary,PassportID)
VALUES 
('Roberto',43300.00,102)
,('Tom',56100.00,103)
,('Yana',60200.00,101)

ALTER TABLE Persons
ADD CONSTRAINT PK_Persons_PersonID PRIMARY KEY(PersonID)

ALTER TABLE Passports
ADD CONSTRAINT PK_Passports_PassportID PRIMARY KEY(PassportID)

ALTER TABLE Persons
ADD CONSTRAINT FK_PassportID_PassportID FOREIGN KEY(PassportID) REFERENCES Passports(PassportID)

--Problem 2
CREATE TABLE Models(
ModelID INT IDENTITY(101,1)
,[Name] NVARCHAR(20)
,ManufacturerID INT
)

CREATE TABLE Manufacturers(
ManufacturerID INT IDENTITY(1,1)
,[Name] NVARCHAR(20)
,EstablishedOn DATETIME2
)

INSERT INTO Models([Name],ManufacturerID)
VALUES
('X1',1)
,('i6',1)
,('Model S',2)
,('Model X',2)
,('Model 3',2)
,('Nova',3)

--check for errors in the dates
INSERT INTO Manufacturers([Name],[EstablishedOn])
VALUES 
('BMW','1916-03-07')
,('Tesla','2003-01-01')
,('Lada','1966-05-01')

ALTER TABLE Models
ADD CONSTRAINT PK_Models_ModelID PRIMARY KEY(ModelID)

ALTER TABLE Manufacturers
ADD CONSTRAINT PK_Manufacturers_ManufacturerID PRIMARY KEY(ManufacturerID)

ALTER TABLE Models
ADD CONSTRAINT FK_Models_ManufacturerID_Manufacturers_ManufacturerID FOREIGN KEY(ManufacturerID) REFERENCES Manufacturers(ManufacturerID)

--Problem 3
CREATE TABLE Students(
StudentID INT IDENTITY(1,1)
,[Name] NVARCHAR(30)
)

CREATE TABLE Exams(
ExamID INT IDENTITY(101,1)
,[Name] NVARCHAR(30)
)

CREATE TABLE StudentsExams(
StudentID INT NOT NULL
,ExamID INT NOT NULL 
)

INSERT INTO Students([Name])
VALUES
('Mila')
,('Toni')
,('Ron')

INSERT INTO Exams([Name])
VALUES
('SpringMVC')
,('Neo4j')
,('Oracle 11g')

INSERT INTO StudentsExams(StudentID,ExamID)
VALUES
(1,101)
,(1,102)
,(2,101)
,(3,103)
,(2,102)
,(2,103)

ALTER TABLE Students
ADD CONSTRAINT PK_Students_StudentID PRIMARY KEY(StudentID)

ALTER TABLE Exams
ADD CONSTRAINT PK_Exams_ExamID PRIMARY KEY(ExamID)

ALTER TABLE StudentsExams
ADD CONSTRAINT PK_StudentsExams_StudentID_ExamID PRIMARY KEY(StudentID,ExamID)

ALTER TABLE StudentsExams
ADD CONSTRAINT FK_StudentsExams_StudentID FOREIGN KEY(StudentID) REFERENCES Students(StudentID)

ALTER TABLE StudentsExams 
ADD CONSTRAINT FK_StudentsExams_ExamID FOREIGN KEY(ExamID) REFERENCES Exams(ExamID)

--Problem 4
CREATE TABLE Teachers(
TeacherID INT IDENTITY(101,1)
,[Name] NVARCHAR(30)
,ManagerID INT
)

INSERT INTO Teachers([Name],[ManagerID])
VALUES
('John',NULL)
,('Maya',106)
,('Silvia',106)
,('Ted',105)
,('Mark',101)
,('Greta',101)

ALTER TABLE Teachers
ADD CONSTRAINT PK_Teachers_TeacherID PRIMARY KEY(TeacherID)

ALTER TABLE Teachers
ADD CONSTRAINT FK_Teachers_ManagerID_Teachers_TeacherID FOREIGN KEY(ManagerID) REFERENCES Teachers(TeacherID)

--Problem 5
CREATE DATABASE OnlineStore

USE OnlineStore

CREATE TABLE OrderItems(
OrderID INT NOT NULL
,ItemID INT NOT NULL
)

ALTER TABLE OrderItems
ADD CONSTRAINT PK_OrderItems_OrderID_ItemID PRIMARY KEY(OrderID,ItemID)

CREATE TABLE Items(
ItemID INT PRIMARY KEY 
,[Name] VARCHAR(50)
,ItemTypeID INT
)

ALTER TABLE OrderItems
ADD CONSTRAINT FK_Items_ItemID_OrderItems_ItemID FOREIGN KEY(ItemID) REFERENCES Items(ItemID)

CREATE TABLE ItemTypes(
ItemTypeID INT PRIMARY KEY
,[Name] VARCHAR(50)
)

ALTER TABLE Items
ADD CONSTRAINT FK_Items_ItemTypeID_ItemTypes_ItemTypeID FOREIGN KEY(ItemTypeID) REFERENCES ItemTypes(ItemTypeID)

CREATE TABLE Orders(
OrderID INT PRIMARY KEY
,CustomerID INT
)

ALTER TABLE OrderItems
ADD CONSTRAINT FK_OrderItems_OrderID_Orders_OrderID FOREIGN KEY(OrderID) REFERENCES Orders(OrderID)

CREATE TABLE Customers(
CustomerID INT PRIMARY KEY
,[Name] VARCHAR(50)
,Birthday DATE
,CityID INT
)

ALTER TABLE Orders
ADD CONSTRAINT FK_Orders_CustomerID_Customers_CustomerID FOREIGN KEY(CustomerID) REFERENCES Customers(CustomerID)

CREATE TABLE Cities(
CityID INT PRIMARY KEY
,[Name] VARCHAR(50)
)

ALTER TABLE Customers
ADD CONSTRAINT FK_Customers_CityID_Cities_CityID FOREIGN KEY(CityID) REFERENCES Cities(CityID)

--Problem 6
CREATE DATABASE University

USE University

CREATE TABLE Agenda(
StudentID INT NOT NULL
,SubjectID INT NOT NULL
)

ALTER TABLE Agenda
ADD CONSTRAINT PK_Agenda_StudentID_SubjectID PRIMARY KEY(StudentID,SubjectID)

CREATE TABLE Subjects(
SubjectID INT PRIMARY KEY
,SubjectName VARCHAR(50)
)

ALTER TABLE Agenda
ADD CONSTRAINT FK_Agenda_SubjectID_Subjects_SubjectID FOREIGN KEY(SubjectID) REFERENCES Subjects(SubjectID)

CREATE TABLE Students(
StudentID INT PRIMARY KEY
,StudentNumber INT
,StudentName VARCHAR(50)
,MajorID INT
)

ALTER TABLE Agenda
ADD CONSTRAINT FK_Agenda_StudentID_Students_StudentID FOREIGN KEY(StudentID) REFERENCES Students(StudentID)

CREATE TABLE Majors(
MajorID INT PRIMARY KEY
,[Name] VARCHAR(50)
)

ALTER TABLE Students
ADD CONSTRAINT FK_Students_MajorID_Majors_MajorID FOREIGN KEY(MajorID) REFERENCES Majors(MajorID)

CREATE TABLE Payments(
PaymentID INT PRIMARY KEY
,PaymentDate DATE
,PaymentAmount INT
,StudentID INT
)

ALTER TABLE Payments
ADD CONSTRAINT FK_Payments_StudentID_Students_StudentID FOREIGN KEY(StudentID) REFERENCES Students(StudentID)

--Problem 9
USE [Geography]

SELECT m.MountainRange
,p.PeakName
,p.Elevation
FROM Mountains AS m
JOIN Peaks AS p ON
m.MountainRange = 'Rila'
AND p.MountainId = m.Id
ORDER BY p.Elevation DESC


