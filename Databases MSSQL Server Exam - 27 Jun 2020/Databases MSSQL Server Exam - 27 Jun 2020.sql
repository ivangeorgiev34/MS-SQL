--Section 1. DDL 
CREATE DATABASE WMS

USE WMS

--01. Database design
CREATE TABLE Clients(
ClientId INT IDENTITY(1,1) PRIMARY KEY
,FirstName NVARCHAR(50) NOT NULL
,LastName NVARCHAR(50) NOT NULL
,Phone NVARCHAR(12) NOT NULL
,CHECK (LEN(Phone) = 12)
)

CREATE TABLE Mechanics(
MechanicId INT IDENTITY(1,1) PRIMARY KEY
,FirstName NVARCHAR(50) NOT NULL
,LastName NVARCHAR(50) NOT NULL
,[Address] NVARCHAR(255) NOT NULL
)

CREATE TABLE Models(
ModelId INT IDENTITY(1,1) PRIMARY KEY
,[Name] NVARCHAR(50) UNIQUE NOT NULL
)

CREATE TABLE Jobs(
JobId INT IDENTITY(1,1) PRIMARY KEY
,ModelId INT NOT NULL
,[Status] NVARCHAR(11) DEFAULT 'Pending' NOT NULL
,ClientId INT NOT NULL
,MechanicId INT 
,IssueDate DATE NOT NULL
,FinishDate DATE
,CHECK ([Status] = 'Pending' OR [Status] = 'In Progress' OR [Status] = 'Finished')
,FOREIGN KEY (ModelId) REFERENCES Models(ModelId)
,FOREIGN KEY (ClientId) REFERENCES Clients(ClientId)
,FOREIGN KEY (MechanicId) REFERENCES Mechanics(MechanicId)
)

CREATE TABLE Orders(
OrderId INT IDENTITY(1,1) PRIMARY KEY
,JobId INT NOT NULL
,IssueDate DATE
,Delivered BIT DEFAULT 0 NOT NULL
,FOREIGN KEY (JobId) REFERENCES Jobs(JobId)
)

CREATE TABLE Vendors(
VendorId INT IDENTITY(1,1) PRIMARY KEY
,[Name] NVARCHAR(50) UNIQUE NOT NULL
)

CREATE TABLE Parts(
PartId INT IDENTITY(1,1) PRIMARY KEY
,SerialNumber NVARCHAR(50) UNIQUE NOT NULL
,[Description] NVARCHAR(255) 
,Price MONEY NOT NULL
,VendorId INT NOT NULL
,StockQty INT DEFAULT 0 NOT NULL
,CHECK (Price > 0)
,CHECK (StockQty >= 0)
,FOREIGN KEY (VendorId) REFERENCES Vendors(VendorId)
)

CREATE TABLE OrderParts(
OrderId INT NOT NULL
,PartId INT NOT NULL
,Quantity INT DEFAULT 1 NOT NULL
,CHECK (Quantity > 0)
,PRIMARY KEY(OrderId,PartId)
,FOREIGN KEY (OrderId) REFERENCES Orders(OrderId)
,FOREIGN KEY (PartId) REFERENCES Parts(PartId)
)

CREATE TABLE PartsNeeded(
JobId INT NOT NULL
,PartId INT NOT NULL
,Quantity INT DEFAULT 1 NOT NULL
,CHECK (Quantity > 0)
,PRIMARY KEY(JobId,PartId)
,FOREIGN KEY (JobId) REFERENCES Jobs(JobId)
,FOREIGN KEY (PartId) REFERENCES Parts(PartId)
)

--Section 2. DML

--02. Insert
INSERT INTO Clients(FirstName,LastName,Phone)
VALUES 
('Teri','Ennaco','570-889-5187')
,('Merlyn','Lawler','201-588-7810')
,('Georgene','Montezuma','925-615-5185')
,('Jettie','Mconnell','908-802-3564')
,('Lemuel','Latzke','631-748-6479')
,('Melodie','Knipp','805-690-1682')
,('Candida','Corbley','908-275-8357')

INSERT INTO Parts(SerialNumber,[Description],Price,VendorId)
VALUES
('WP8182119','Door Boot Seal',117.86,2)
,('W10780048','Suspension Rod',42.81,1)
,('W10841140','Silicone Adhesive ',6.77,4)
,('WPY055980','High Temperature Adhesive',13.94,3)

--03. Update
UPDATE Jobs
SET [Status] = 'In Progress'
,MechanicId = 3
WHERE [Status] = 'Pending'

--04. Delete

DELETE FROM OrderParts
WHERE OrderId = 19

DELETE FROM Orders
WHERE OrderId = 19

--Section 3. Querying 

--05. Mechanic Assignments
SELECT
CONCAT(m.FirstName,' ',m.LastName)
,j.[Status]
,j.IssueDate
FROM Mechanics AS m
JOIN Jobs AS j ON
j.MechanicId = m.MechanicId
ORDER BY m.MechanicId ASC,j.IssueDate ASC,j.JobId ASC

--06. Current Clients
SELECT
CONCAT(c.FirstName,' ',c.LastName)
,DATEDIFF(DAY,j.IssueDate,'2017-04-24') AS [Days going]
,j.[Status]
FROM Clients AS c
JOIN Jobs AS j ON
j.ClientId = c.ClientId
WHERE j.[Status] != 'Finished'
ORDER BY [Days going] DESC,c.ClientId ASC

--07. Mechanic Performance
SELECT
CONCAT(m.FirstName,' ',m.LastName)
,AVG(DATEDIFF(DAY,j.IssueDate,j.FinishDate))
FROM Mechanics AS m
JOIN Jobs AS j ON
j.MechanicId = m.MechanicId
GROUP BY CONCAT(m.FirstName,' ',m.LastName),m.MechanicId
ORDER BY m.MechanicId ASC

--08. Available Mechanics
SELECT (m.FirstName + ' ' + m.LastName) AS Available
	FROM Mechanics AS m
	LEFT JOIN Jobs AS j ON j.MechanicId = m.MechanicId
	WHERE (j.[Status] = 'Finished' OR j.JobId IS NULL) 
		AND m.MechanicId NOT IN(SELECT ms.MechanicId FROM Mechanics AS ms
										JOIN Jobs AS js ON js.MechanicId = ms.MechanicId
										WHERE js.[Status] != 'Finished'
										GROUP BY ms.MechanicId)
	GROUP BY m.MechanicId, m.FirstName, m.LastName
ORDER BY m.MechanicId ASC

--09. Past Expenses
SELECT
j.JobId
,SUM(p.Price) AS Total
FROM Jobs AS j
JOIN PartsNeeded AS pn ON
pn.JobId = j.JobId
JOIN Parts AS p ON
p.PartId = pn.PartId
WHERE j.[Status] = 'Finished'
GROUP BY j.JobId
ORDER BY SUM(p.Price) DESC, j.JobId ASC

--10. Missing Parts
SELECT tmp.PartId, tmp.[Description], tmp.[Required], tmp.[In Stock], tmp.Delivered AS Ordered
FROM (SELECT p.PartId, p.[Description], pn.Quantity AS [Required] 
			,p.StockQty AS [In Stock]
			,IIF((SELECT Delivered FROM Orders AS o WHERE j.JobId = o.JobId) IS NULL, 0, 1) AS Delivered
	FROM Jobs AS j
	LEFT JOIN PartsNeeded AS pn ON pn.JobId = j.JobId
	LEFT JOIN Parts AS p ON p.PartId = pn.PartId
	LEFT JOIN OrderParts AS op ON op.OrderId = p.PartId
	WHERE (j.Status != 'Finished') 
			AND (pn.Quantity > p.StockQty) 
			AND (SELECT Delivered FROM Orders AS o WHERE j.JobId = o.JobId) IS NULL
	) AS tmp
GROUP BY tmp.PartId, tmp.[Description], tmp.[Required], tmp.[In Stock], tmp.Delivered








