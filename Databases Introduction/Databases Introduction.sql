--Problem 1
CREATE DATABASE [Minions]

USE [Minions]

--Problem 2
CREATE TABLE [Minions]
(
[Id] INT PRIMARY KEY
, [Name] NVARCHAR(50)
,[Age] INT
)

CREATE TABLE [Towns]
(
[Id] INT PRIMARY KEY
, [Name] NVARCHAR(50)
)

--Problem 3
ALTER TABLE [Minions]
ADD [TownId] INT

ALTER TABLE [Minions]
ADD CONSTRAINT FK_MinionsTownId 
FOREIGN KEY ([TownId]) REFERENCES [Towns](Id)

--Problem 4
INSERT INTO [Towns]([Id],[Name])
VALUES
(1,'Sofia')
,(2,'Plovdiv')
,(3,'Varna')

INSERT INTO [Minions]([Id],[Name],[Age],[TownId])
VALUES
(1,'Kevin',22,1)
,(2,'Bob',15,3)
,(3,'Steward',NULL,2)

--Problem 5
TRUNCATE TABLE [Minions]

--Problem 6
DROP TABLE [Minions]

DROP TABLE [Towns]

--Problem 7
CREATE TABLE People(
[Id] INT PRIMARY KEY IDENTITY(1,1)
,[Name] NVARCHAR(200) NOT NULL
,[Picture] VARBINARY(MAX)
,[Height] DECIMAL(3,2)
,[Weight] DECIMAL(5,2)
,[Gender] CHAR(1) NOT NULL
CHECK([Gender] = 'm' OR [Gender] = 'f') 
,[Birthdate] DATETIME2 NOT NULL
,[Biography] NVARCHAR(MAX)
)

INSERT INTO [People]([Name],[Gender],[Birthdate])
VALUES
('Anton','m','2000-05-05')
,('Teodor','m','2010-11-05')
,('Boris','m','2000-12-10')
,('Mario','m','2000-10-10')
,('Plamen','m','2000-09-06')

--Problem 8
CREATE TABLE [Users](
[Id] INT PRIMARY KEY IDENTITY(1,1)
,[Username] VARCHAR(30) UNIQUE NOT NULL
,[Password] VARCHAR(26) NOT NULL
,[ProfilePicture] VARBINARY(MAX)
,[LastLoginTime] DATETIME2
,[IsDeleted] BIT
CHECK ([IsDeleted] = 0 OR [IsDeleted] = 1)
)

INSERT INTO [Users]([Username],[Password])
VALUES
('Vasil','gkrj')
,('Georgi','gkrj')
,('Ivan','weekea')
,('Mario','ewowf')
,('Plamen','abcd')

--Problem 9
ALTER TABLE [Users]
DROP CONSTRAINT PK__Users__3214EC07060EE048

ALTER TABLE [Users]
ADD PRIMARY KEY([Id],[Username])

--Problem 10
ALTER TABLE [Users]
ADD CONSTRAINT CH_PasswordLength CHECK (LEN([Password]) >= 5)

--Problem 11
ALTER TABLE [Users]
ADD CONSTRAINT DF_LastLoginTime DEFAULT '09:50:57' FOR [LastLoginTime]

--Problem 12
ALTER TABLE [Users]
DROP CONSTRAINT PK__Users__7722245980FC4770

ALTER TABLE [Users]
ADD CONSTRAINT PK_Id PRIMARY KEY([Id])

ALTER TABLE [Users]
ADD CONSTRAINT UQ_Username UNIQUE([Username])

ALTER TABLE [Users]
ADD CONSTRAINT CH_UsernameLenght CHECK(LEN([Username]) >= 3)

--Problem 13
CREATE DATABASE [Movies]

USE [Movies]

CREATE TABLE [Directors](
[Id] INT PRIMARY KEY IDENTITY(1,1)
,[DirectorName] NVARCHAR(100) NOT NULL
,[Notes] NVARCHAR(MAX) 
)

INSERT INTO [Directors]([DirectorName],[Notes])
VALUES
('Ognqn','erjgkewlsdk')
,('Denis','gewegwregwr')
,('Kalin','djjkglewlew')
,('Valentin','krgmemgwele')
,('Petur','gewegrrwewee')

CREATE TABLE [Genres](
[Id] INT PRIMARY KEY IDENTITY(1,1)
,[GenreName] NVARCHAR(100) NOT NULL
,[Notes] NVARCHAR(MAX) 
)

INSERT INTO [Genres]
VALUES
('Horror','kwegkkekk')
,('Action','pegkegelge')
,('Adventure','egmrlqwmwl')
,('Mystery','gglgkwejgwekj')
,('Romantical','lalalalwkfewfw')

CREATE TABLE [Categories](
[Id] INT PRIMARY KEY IDENTITY(1,1)
,[CategoryName] NVARCHAR(100) NOT NULL
,[Notes] NVARCHAR(MAX) 
)

INSERT INTO [Categories]
VALUES
('Comedy','rdhrehre')
,('Thriller','sfxbdfhrs')
,('Drama','pwqowkwmqw')
,('Science fiction','lwrlkrwqkwqn')
,('Fantasy','laljefjwgegje')

CREATE TABLE [Movies](
[Id] INT PRIMARY KEY IDENTITY(1,1)
,[Title] NVARCHAR(100) NOT NULL
,[DirectorId] INT NOT NULL
,[CopyrightYear] INT 
,[Length] TIME NOT NULL
,[GenreId] INT NOT NULL
,[CategoryId] INT NOT NULL
,[Rating] DECIMAL(3,2)
,[Notes] NVARCHAR(MAX) 
)

INSERT INTO [Movies]([Title],[DirectorId],[CopyrightYear],[Length],[GenreId],[CategoryId],[Rating],[Notes])
VALUES
('Anabelle',1,2000,'01:38:10',1,1,4.29,'egwwwegew')
,('Home Alone',2,2010,'02:18:19',1,2,4.84,'kegkgkkwewe')
,('Scarface',2,1997,'01:40:35',3,3,4.19,'jgrwejgkwegk')
,('Maze Runner',3,2018,'02:20:45',3,2,4.91,'efbresdgegwegw')
,('Minions',4,2014,'02:04:54',2,2,4.64,'rgrwhgrgrwgrw')

--Problem 14
CREATE DATABASE [CarRental]

USE [CarRental]

CREATE TABLE [Categories](
[Id] INT PRIMARY KEY IDENTITY(1,1)
,[CategoryName] NVARCHAR(50) NOT NULL
,[DailyRate] DECIMAL(4,2)
,[WeeklyRate] DECIMAL(4,2)
,[MonthlyRate] DECIMAL(5,2)
,[WeekendRate] DECIMAL(5,2)
)

INSERT INTO [Categories]([CategoryName],[DailyRate],[WeeklyRate],[MonthlyRate],[WeekendRate])
VALUES
('Sport',30.82,70.61,100.92,150.25)
,('Drag',20.42,40.91,102.31,158.15)
,('Normal',10.52,45.13,105.12,138.59)

CREATE TABLE [Cars](
[Id] INT PRIMARY KEY IDENTITY(1,1)
,[PlateNumber] NVARCHAR(50) NOT NULL
,[Manufacturer] NVARCHAR(50) NOT NULL
,[Model] NVARCHAR(50) NOT NULL
,[CarYear] INT NOT NULL
,[CategoryId] INT NOT NULL
,[Doors] INT NOT NULL
,[Picture] VARBINARY(MAX) 
,[Condition] NVARCHAR(100)
,[Available] BIT NOT NULL
)

INSERT INTO [Cars]([PlateNumber],[Manufacturer],[Model],[CarYear],[CategoryId],[Doors],[Condition],[Available])
VALUES
('3JWE','Audi','RS4',2007,1,4,'bad',0)
,('57ME','BMW','M5',2010,2,4,'great',1)
,('57ME','Mercedes-Benz','CLS 63 AMG',2017,1,4,'very good',1)

CREATE TABLE [Employees](
[Id] INT PRIMARY KEY IDENTITY(1,1)
,[FirstName] NVARCHAR(50) NOT NULL
,[LastName] NVARCHAR(50) NOT NULL
,[Title] NVARCHAR(50)
,[Notes] NVARCHAR(MAX)
)

INSERT INTO [Employees]([FirstName],[LastName],[Title],[Notes])
VALUES
('Deyan','Petrov','rgrh','kwegewgkew')
,('Petur','Stoyanov','gewew','rehewweewwenfd')
,('Stoyan','Vladimirov','mfbmnfd','adllgddsgk')

CREATE TABLE [Customers](
[Id] INT PRIMARY KEY IDENTITY(1,1)
,[DriverLicenceNumber] NVARCHAR(50) NOT NULL
,[FullName] NVARCHAR(100) NOT NULL
,[Address] NVARCHAR(150) NOT NULL
,[City] NVARCHAR(100) NOT NULL
,[ZIPCode] INT NOT NULL
,[Notes] NVARCHAR(MAX)
)

INSERT INTO [Customers]([DriverLicenceNumber],[FullName],[Address],[City],[ZIPCode],[Notes])
VALUES
('JAE8','Krasimir Petkov','Graf Ignatiev 12','Sofia',1000,'kejgekewe')
,('PM41','Anton Georgiev','Vasil Levski 2','Pleven',3400,'mwegnkweew')
,('PM41','Kiril Ivanov','Hristo Botev 15','Vidin',2900,'jewgjewkgek')

CREATE TABLE [RentalOrders](
[Id] INT PRIMARY KEY IDENTITY(1,1)
,[DriverLicenceNumber] NVARCHAR(50) NOT NULL
,[EmployeeId] INT NOT NULL
,[CustomerId] INT NOT NULL
,[CarId] INT NOT NULL
,[TankLevel] INT
,[KilometrageStart] INT
,[KilometrageEnd] INT
,[TotalKilometrage] INT
,[StartDate] DATETIME2 NOT NULL
,[EndDate] DATETIME2 NOT NULL
,[TotalDays] INT NOT NULL
,[RateApplied] DECIMAL(4,2) NOT NULL
,[TaxRate] DECIMAL(4,2) NOT NULL
,[OrderStatus] BIT NOT NULL
,[Notes] NVARCHAR(MAX)
)

INSERT INTO [RentalOrders]([DriverLicenceNumber],[EmployeeId],[CustomerId],[CarId],[TankLevel],[KilometrageStart],[KilometrageEnd],[TotalKilometrage],[StartDate],[EndDate],[TotalDays],[RateApplied],[TaxRate],[OrderStatus],[Notes])
VALUES
('KRM2',1,2,2,68,120,30,200,'2022-11-11','2022-11-12',1,22.24,10.13,1,'gehweregerwee')
,('4NFM',2,2,3,20,190,10,400,'2022-05-11','2022-05-14',3,24.48,22.91,0,'rgjnwegmwfhew')
,('LM1W',3,1,2,90,200,40,190,'2022-01-21','2022-01-25',4,29.98,18.01,1,'wegjewgklew')

--Problem 15
CREATE DATABASE [Hotel]

USE [Hotel]

CREATE TABLE [Employees](
[Id] INT PRIMARY KEY IDENTITY(1,1)
,[FirstName] NVARCHAR(50) NOT NULL
,[LastName] NVARCHAR(50) NOT NULL
,[Title] NVARCHAR(50)
,[Notes] NVARCHAR(MAX)
)

INSERT INTO [Employees]([FirstName],[LastName],[Title],[Notes])
VALUES
('Petur','Slavkov','kwgekwe','fewgewwegew')
,('Martin','Petrov','rehgerher','ngfrdryr')
,('Daniel','Zlatkov','erwewrq','utrulte')

CREATE TABLE [Customers](
[AccountNumber] INT PRIMARY KEY IDENTITY(1,1)
,[FirstName] NVARCHAR(50) NOT NULL
,[LastName] NVARCHAR(50) NOT NULL
,[PhoneNumber] NVARCHAR(30) NOT NULL
,[EmergencyName] NVARCHAR(50) NOT NULL
,[EmergencyNumber] NVARCHAR(30) NOT NULL
,[Notes] NVARCHAR(MAX)
)

INSERT INTO [Customers]([FirstName],[LastName],[PhoneNumber],[EmergencyName],[EmergencyNumber],[Notes])
VALUES
('Georgi','Zlatkov','0898394911','rhewweh','0892303928','lgrkrwlwegwe')
,('Zlatin','Georgiev','087865253','hrehehwer','089857362','jgewgweqw')
,('Simeon','Georgiev','0878628273','rehthtweaw','0878615237','kgnweknqwk')

CREATE TABLE [RoomStatus](
[RoomStatus] INT PRIMARY KEY IDENTITY(1,1)
,[Notes] NVARCHAR(MAX)
)

INSERT INTO [RoomStatus]([Notes])
VALUES
('hwrhr')
,('bfnfdjwe')
,('asewgwen')

CREATE TABLE [RoomTypes](
[RoomType] NVARCHAR(50) PRIMARY KEY
,[Notes] NVARCHAR(MAX)
)

INSERT INTO [RoomTypes]([RoomType],[Notes])
VALUES
('Apartment','rbnrehw')
,('Studio','lwetmwlwl')
,('Flat','wqrehrewq')

CREATE TABLE [BedTypes](
[BedType] NVARCHAR(50) PRIMARY KEY
,[Notes] NVARCHAR(MAX)
)

INSERT INTO [BedTypes]([BedType],[Notes])
VALUES
('Normal','rehrehrwq')
,('Water','lwmeowjwq')
,('Special','aoejpwrmf')

CREATE TABLE [Rooms](
[RoomNumber] INT PRIMARY KEY IDENTITY(1,1)
,[RoomType] NVARCHAR(50) NOT NULL
,[BedType] NVARCHAR(50) NOT NULL
,[Rate] DECIMAL(4,2) NOT NULL
,[RoomStatus] INT NOT NULL
,[Notes] NVARCHAR(MAX)
)

INSERT INTO [Rooms]([RoomType],[BedType],[Rate],[RoomStatus],[Notes])
VALUES
('Apartment','Special',12.24,1,'kwegmnrwq')
,('Studio','Water',21.94,3,'rhewqefdn')
,('Flat','Normal',14.30,2,'kbwmehgqkmm')

CREATE TABLE [Payments](
[Id] INT PRIMARY KEY IDENTITY(1,1)
,[EmployeeId] INT NOT NULL
,[PaymentDate] DATETIME2 NOT NULL
,[AccountNumber] NVARCHAR(50) NOT NULL
,[FirstDateOccupied] DATETIME2 NOT NULL
,[LastDateOccupied] DATETIME2 NOT NULL
,[TotalDays] INT NOT NULL
,[AmountCharged] DECIMAL(5,2)  NOT NULL
,[TaxRate] DECIMAL(4,2) NOT NULL
,[TaxAmount] DECIMAL(5,2) NOT NULL
,[PaymentTotal] INT NOT NULL
,[Notes] NVARCHAR(MAX)
) 

INSERT INTO [Payments]([EmployeeId],[PaymentDate],[AccountNumber],[FirstDateOccupied],[LastDateOccupied],[TotalDays],[AmountCharged],[TaxRate],[TaxAmount],[PaymentTotal],[Notes])
VALUES
(1,'2022-11-11','28739','2022-10-11','2022-10-12',1,452.64,10.29,100.42,500,'rgregrrer')
,(2,'2022-01-11','28739','2022-01-22','2022-01-24',2,491.94,29.59,110.72,670,'lewgkengwkrek')
,(3,'2022-12-11','28739','2022-12-25','2022-12-27',2,411.04,15.08,190.02,770,'egergrbfrehw')

CREATE TABLE [Occupancies](
[Id] INT PRIMARY KEY IDENTITY(1,1)
,[EmployeeId] INT NOT NULL
,[DateOccupied] DATETIME2 NOT NULL
,[AccountNumber] NVARCHAR(50) NOT NULL
,[RoomNumber] INT NOT NULL
,[RateApplied] DECIMAL(4,2) NOT NULL
,[PhoneCharge] INT NOT NULL
,[Notes] NVARCHAR(MAX)
) 

INSERT INTO [Occupancies]([EmployeeId],[DateOccupied],[AccountNumber],[RoomNumber],[RateApplied],[PhoneCharge],[Notes])
VALUES
(1,'2022-01-01','92182',2,20.21,83,'erhrenefd')
,(2,'2022-11-01','82817',4,30.10,61,'ewgrefbrehwr')
,(3,'2022-11-21','928114',1,33.90,95,'ldmwdwqojge')

--Problem 16
CREATE DATABASE [SoftUni]

USE [SoftUni]

CREATE TABLE [Towns](
[Id] INT PRIMARY KEY IDENTITY(1,1)
,[Name] NVARCHAR(50) NOT NULL
)

CREATE TABLE [Addresses](
[Id] INT PRIMARY KEY IDENTITY(1,1)
,[AddressText] NVARCHAR(100) NOT NULL
,[TownId] INT NOT NULL
)

ALTER TABLE [Addresses]
ADD CONSTRAINT FK_TownId FOREIGN KEY([TownId]) REFERENCES [Towns]([Id])

CREATE TABLE [Departments](
[Id] INT PRIMARY KEY IDENTITY(1,1)
,[Name] NVARCHAR(50) NOT NULL
)

CREATE TABLE [Employees](
[Id] INT PRIMARY KEY IDENTITY(1,1)
,[FirstName] NVARCHAR(50) NOT NULL
,[MiddleName] NVARCHAR(50) NOT NULL
,[LastName] NVARCHAR(50) NOT NULL
,[JobTitle] NVARCHAR(50) NOT NULL
,[DepartmentId] INT NOT NULL
,[HireDate] DATETIME2 NOT NULL
,[Salary] DECIMAL(6,2) NOT NULL
,[AddressId] INT NOT NULL
)

ALTER TABLE [Employees]
ALTER COLUMN [AddressId] INT

ALTER TABLE [Employees]
ADD CONSTRAINT FK_DepartmentId FOREIGN KEY([DepartmentId]) REFERENCES [Departments]([Id])

ALTER TABLE [Employees]
ADD CONSTRAINT FK_AddressId FOREIGN KEY([AddressId]) REFERENCES [Addresses]([Id])

--Problem 18
INSERT INTO [Towns]([Name])
VALUES 
('Sofia')
,('Plovdiv')
,('Varna')
,('Burgas')

INSERT INTO [Departments]([Name])
VALUES
('Engineering')
,('Sales')
,('Marketing')
,('Software Development')
,('Quality Assurance')

INSERT INTO [Employees]([FirstName],[MiddleName],[LastName],[JobTitle],[DepartmentId],[HireDate],[Salary])
VALUES
('Ivan','Ivanov','Ivanov','.NET Developer',4,'2013-02-01',3500.00)
,('Petar','Petrov','Petrov','Senior Engineer',1,'2004-03-02',4000.00)
,('Maria','Petrova','Ivanova','Intern',5,'2016-08-28',525.25)
,('Georgi','Terziev','Ivanov','CEO',2,'2007-12-09',3000.00)
,('Peter','Pan','Pan','Intern',3,'2016-08-28',599.88)

--Problem 19
SELECT * FROM [Towns]

SELECT * FROM [Departments]

SELECT * FROM [Employees]

--Problem 20
SELECT * 
FROM [Towns]
ORDER BY [Name] ASC

SELECT *
FROM [Departments]
ORDER BY [Name] ASC

SELECT *
FROM [Employees]
ORDER BY [Salary] DESC

--Problem 21
SELECT [Name]
FROM [Towns]
ORDER BY [Name] ASC

SELECT [Name]
FROM [Departments]
ORDER BY [Name] ASC

SELECT [FirstName],[LastName],[JobTitle],[Salary]
FROM [Employees]
ORDER BY [Salary] DESC

--Problem 22
UPDATE [Employees]
SET
[Salary] = [Salary] * 1.10
WHERE [Salary] IS NOT NULL

SELECT [Salary]
FROM [Employees]

--Problem 23
USE Hotel

UPDATE [Payments]
SET
[TaxRate] = [TaxRate] - ([TaxRate] * 0.03)

SELECT [TaxRate]
FROM [Payments]

--Problem 24
USE Hotel

TRUNCATE TABLE [Occupancies]