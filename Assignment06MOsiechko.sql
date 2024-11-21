--*************************************************************************--
-- Title: Assignment06
-- Author: MOsiechko
-- Desc: This file demonstrates how to use Views
-- Change Log: When,Who,What
-- 2024-11-17,MOsiechko,Created File
--**************************************************************************--
BEGIN TRY
	USE Master;
	IF EXISTS(SELECT Name FROM SysDatabases WHERE Name = 'Assignment06DB_MOsiechko')
	 BEGIN 
	  ALTER DATABASE [Assignment06DB_MOsiechko] SET Single_user WITH ROLLBACK IMMEDIATE;
	  DROP DATABASE Assignment06DB_MOsiechko;
	 END
	CREATE DATABASE Assignment06DB_MOsiechko;
END TRY
BEGIN CATCH
	PRINT Error_Number();
END CATCH
GO
USE Assignment06DB_MOsiechko;

-- Create Tables (Module 01)-- 
CREATE TABLE Categories
([CategoryID] [int] IDENTITY(1,1) NOT NULL 
,[CategoryName] [nvarchar](100) NOT NULL
);
GO

CREATE TABLE Products
([ProductID] [int] IDENTITY(1,1) NOT NULL 
,[ProductName] [nvarchar](100) NOT NULL 
,[CategoryID] [int] NULL  
,[UnitPrice] [mOney] NOT NULL
);
GO

CREATE TABLE Employees -- New Table
([EmployeeID] [int] IDENTITY(1,1) NOT NULL 
,[EmployeeFirstName] [nvarchar](100) NOT NULL
,[EmployeeLastName] [nvarchar](100) NOT NULL 
,[ManagerID] [int] NULL  
);
GO

CREATE TABLE Inventories
([InventoryID] [int] IDENTITY(1,1) NOT NULL
,[InventoryDate] [Date] NOT NULL
,[EmployeeID] [int] NOT NULL -- New Column
,[ProductID] [int] NOT NULL
,[Count] [int] NOT NULL
);
GO

-- Add Constraints (Module 02) -- 
BEGIN  -- Categories
	ALTER TABLE Categories 
	 ADD CONSTRAINT pkCategories 
	  PRIMARY KEY (CategoryId);

	ALTER TABLE Categories 
	 ADD CONSTRAINT ukCategories 
	  UNIQUE (CategoryName);
END
GO 

BEGIN -- Products
	ALTER TABLE Products 
	 ADD CONSTRAINT pkProducts 
	  PRIMARY KEY (ProductId);

	ALTER TABLE Products 
	 ADD CONSTRAINT ukProducts 
	  UNIQUE (ProductName);

	ALTER TABLE Products 
	 ADD CONSTRAINT fkProductsToCategories 
	  FOREIGN KEY (CategoryId) REFERENCES Categories(CategoryId);

	ALTER TABLE Products 
	 ADD CONSTRAINT ckProductUnitPriceZeroOrHigher 
	  CHECK (UnitPrice >= 0);
END
GO

BEGIN -- Employees
	ALTER TABLE Employees
	 ADD CONSTRAINT pkEmployees 
	  PRIMARY KEY (EmployeeId);

	ALTER TABLE Employees 
	 ADD CONSTRAINT fkEmployeesToEmployeesManager 
	  FOREIGN KEY (ManagerId) REFERENCES Employees(EmployeeId);
END
GO

BEGIN -- Inventories
	ALTER TABLE Inventories 
	 ADD CONSTRAINT pkInventories 
	  PRIMARY KEY (InventoryId);

	ALTER TABLE Inventories
	 ADD CONSTRAINT dfInventoryDate
	  DEFAULT GetDate() FOR InventoryDate;

	ALTER TABLE Inventories
	 ADD CONSTRAINT fkInventoriesToProducts
	  FOREIGN KEY (ProductId) REFERENCES Products(ProductId);

	ALTER TABLE Inventories 
	 ADD CONSTRAINT ckInventoryCountZeroOrHigher 
	  CHECK ([Count] >= 0);

	ALTER TABLE Inventories
	 ADD CONSTRAINT fkInventoriesToEmployees
	  FOREIGN KEY (EmployeeId) REFERENCES Employees(EmployeeId);
END 
GO

-- Adding Data (Module 04) -- 
INSERT INTO Categories 
(CategoryName)
SELECT CategoryName 
 FROM Northwind.dbo.Categories
 ORDER BY CategoryID;
GO

INSERT INTO Products
(ProductName, CategoryID, UnitPrice)
SELECT ProductName,CategoryID, UnitPrice 
 FROM Northwind.dbo.Products
  ORDER BY ProductID;
GO

INSERT INTO Employees
(EmployeeFirstName, EmployeeLastName, ManagerID)
SELECT E.FirstName, E.LastName, IsNull(E.ReportsTo, E.EmployeeID) 
 FROM Northwind.dbo.Employees AS E
  ORDER BY E.EmployeeID;
GO

INSERT INTO Inventories
(InventoryDate, EmployeeID, ProductID, [Count])
SELECT '20170101' AS InventoryDate, 5 AS EmployeeID, ProductID, UnitsInStock
FROM Northwind.dbo.Products
UNION
SELECT '20170201' AS InventoryDate, 7 AS EmployeeID, ProductID, UnitsInStock + 10 -- Using this is to create a made up value
FROM Northwind.dbo.Products
UNION
SELECT '20170301' AS InventoryDate, 9 AS EmployeeID, ProductID, UnitsInStock + 20 -- Using this is to create a made up value
FROM Northwind.dbo.Products
ORDER BY 1, 2
GO

-- Show the Current data in the Categories, Products, and Inventories Tables
SELECT * FROM Categories;
GO
SELECT * FROM Products;
GO
SELECT * FROM Employees;
GO
SELECT * FROM Inventories;
GO

/********************************* Questions and Answers *********************************/
Print
'NOTES------------------------------------------------------------------------------------ 
 1) You can use any name you like for your views, but be descriptive and consistent
 2) You can use your working code from assignment 5 for much of this assignment
 3) You must use the BASIC views for each table after they are created in Question 1
------------------------------------------------------------------------------------------'

-- Question 1 (5% pts): How can you create BACIC views to show data from each table in the database.
-- NOTES: 1) Do not use a *, list out each column!
--        2) Create one view per table!
--		  3) Use SchemaBinding to protect the views from being orphaned!
GO
CREATE VIEW vCategories
WITH SCHEMABINDING   -- this requires to use the tables's 2-part name
AS
SELECT CategoryID, CategoryName
FROM dbo.Categories;   -- this is the 2-part name (dbo.name)
GO

CREATE VIEW vProducts
WITH SCHEMABINDING   -- this requires to use the tables's 2-part name
AS
SELECT ProductID, ProductName, CategoryID, UnitPrice
FROM dbo.Products;
GO

CREATE VIEW vEmployees
WITH SCHEMABINDING   -- this requires to use the tables's 2-part name
AS
SELECT EmployeeID, EmployeeFirstName, EmployeeLastName, ManagerID
FROM dbo.Employees;
GO

CREATE VIEW vInventories
WITH SCHEMABINDING   -- this requires to use the tables's 2-part name
AS
SELECT InventoryID, InventoryDate, EmployeeID, ProductID, [Count]
FROM dbo.Inventories;
GO

-- Question 2 (5% pts): How can you set permissions, so that the public group CANNOT select data 
-- from each table, but can select data from each view?
GO
DENY SELECT ON dbo.Categories To Public;
GRANT SELECT ON vCategories To Public;
GO

DENY SELECT ON dbo.Products To Public;
GRANT SELECT ON vProducts To Public;
GO

DENY SELECT ON dbo.Employees To Public;
GRANT SELECT ON vEmployees To Public;
GO

DENY SELECT ON dbo.Inventories To Public;
GRANT SELECT ON vInventories To Public;
GO

-- Question 3 (10% pts): How can you create a view to show a list of Category and Product names, 
-- and the price of each product?
-- Order the result by the Category and Product!
GO
CREATE VIEW vProductsByCategories
AS
SELECT TOP 1000000 
  C.CategoryName
 ,P.ProductName
 ,P.UnitPrice
FROM vCategories AS C INNER JOIN vProducts AS P
ON C.CategoryID = P.CategoryID
ORDER BY 1,2,3;
GO

-- Question 4 (10% pts): How can you create a view to show a list of Product names 
-- and Inventory Counts on each Inventory Date?
-- Order the results by the Product, Date, and Count!
GO
CREATE VIEW vInventoriesByProductsByDates
AS 
SELECT TOP 1000000 
  P.ProductName
 ,I.InventoryDate
 ,I.[Count]
FROM vProducts AS P INNER JOIN vInventories AS I
ON P.ProductID = I.ProductID
ORDER BY 1,2,3;
GO

-- Question 5 (10% pts): How can you create a view to show a list of Inventory Dates 
-- and the Employee that took the count?
-- Order the results by the Date and return only one row per date!

-- Here is are the rows selected from the view:

-- InventoryDate	EmployeeName
-- 2017-01-01	    Steven Buchanan
-- 2017-02-01	    Robert King
-- 2017-03-01	    Anne Dodsworth

GO
CREATE VIEW vInventoriesByEmployeesByDates
AS
SELECT DISTINCT TOP 1000000 
  I.InventoryDate
 ,E.EmployeeFirstName +' '+ E.EmployeeLastName AS EmployeeName
FROM vEmployees AS E INNER JOIN vInventories AS I
ON E.EmployeeID = I.EmployeeID
ORDER BY InventoryDate;
GO

-- Question 6 (10% pts): How can you create a view show a list of Categories, Products, 
-- and the Inventory Date and Count of each product?
-- Order the results by the Category, Product, Date, and Count!
GO
CREATE VIEW vInventoriesByProductsByCategories 
AS
SELECT TOP 1000000 
  C.CategoryName
 ,P.ProductName
 ,I.InventoryDate
 ,I.[Count]
FROM vCategories AS C 
INNER JOIN vProducts AS P
ON C.CategoryID = P.CategoryID
INNER JOIN vInventories AS I 
ON P.ProductID = I.ProductID
ORDER BY 1,2,3,4;
GO

-- Question 7 (10% pts): How can you create a view to show a list of Categories, Products, 
-- the Inventory Date and Count of each product, and the EMPLOYEE who took the count?
-- Order the results by the Inventory Date, Category, Product and Employee!
GO
CREATE VIEW vInventoriesByProductsByEmployees
AS 
SELECT TOP 1000000 
 C.CategoryName
,P.ProductName
,I.InventoryDate
,I.[Count]
,E.EmployeeFirstName +' '+ E.EmployeeLastName AS EmployeeName
FROM vCategories AS C 
INNER JOIN vProducts AS P
ON C.CategoryID = P.CategoryID
INNER JOIN vInventories AS I 
ON P.ProductID = I.ProductID
INNER JOIN vEmployees AS E
ON I.EmployeeID = E.EmployeeID
ORDER BY 3,1,2,5;
GO

-- Question 8 (10% pts): How can you create a view to show a list of Categories, Products, 
-- the Inventory Date and Count of each product, and the Employee who took the count
-- for the Products 'Chai' and 'Chang'? 
GO
CREATE VIEW vInventoriesForChaiAndChangByEmployees
AS 
SELECT TOP 1000000 
 C.CategoryName
,P.ProductName
,I.InventoryDate
,I.[Count]
,E.EmployeeFirstName +' '+ E.EmployeeLastName AS EmployeeName
FROM vCategories AS C 
INNER JOIN vProducts AS P
ON C.CategoryID = P.CategoryID
INNER JOIN vInventories AS I 
ON P.ProductID = I.ProductID
INNER JOIN vEmployees AS E
ON I.EmployeeID = E.EmployeeID
WHERE P.ProductID IN (SELECT ProductID FROM vProducts WHERE ProductName IN 'Chai', 'Chang'))
ORDER BY 3,1,2,5;
GO

-- Question 9 (10% pts): How can you create a view to show a list of Employees and the Manager who manages them?
-- Order the results by the Manager's name!
GO
CREATE VIEW vEmployeesByManager
AS 
SELECT TOP 1000000  
 M.EmployeeFirstName +' '+ M.EmployeeLastName AS Manager
,E.EmployeeFirstName +' '+ E.EmployeeLastName AS Employee
FROM vEmployees AS E 
INNER JOIN vEmployees AS M
ON E.ManagerID = M.EmployeeID
ORDER BY Manager, Employee;
GO

-- Question 10 (20% pts): How can you create one view to show all the data from all four 
-- BASIC Views? Also show the Employee's Manager Name and order the data by 
-- Category, Product, InventoryID, and Employee.
GO
CREATE VIEW vInventoriesByProductsByCategoriesByEmployees
AS 
SELECT TOP 1000000 
 C.CategoryID
,C.CategoryName
,P.ProductID
,P.ProductName
,P.UnitPrice
,I.InventoryID
,I.InventoryDate
,I.[Count]
,E.EmployeeID
,E.EmployeeFirstName + ' ' + E.EmployeeLastName AS Employee
,M.EmployeeFirstName + ' ' + M.EmployeeLastName AS Manager
FROM vCategories AS C
INNER JOIN vProducts AS P
ON C.CategoryID = P.CategoryID
INNER JOIN vInventories AS I
ON P.ProductID = I.ProductID
INNER JOIN vEmployees AS E
ON I.EmployeeID = E.EmployeeID
INNER JOIN vEmployees AS M
ON E.ManagerID = M.EmployeeID
ORDER BY 1,3,6,10;
GO

-- Test your Views (NOTE: You must change the view names to match what I have below!)
Print 'Note: You will get an error until the views are created!'
SELECT * FROM [dbo].[vCategories]
SELECT * FROM [dbo].[vProducts]
SELECT * FROM [dbo].[vInventories]
SELECT * FROM [dbo].[vEmployees]

SELECT * FROM [dbo].[vProductsByCategories]
SELECT * FROM [dbo].[vInventoriesByProductsByDates]
SELECT * FROM [dbo].[vInventoriesByEmployeesByDates]
SELECT * FROM [dbo].[vInventoriesByProductsByCategories]
SELECT * FROM [dbo].[vInventoriesByProductsByEmployees]
SELECT * FROM [dbo].[vInventoriesForChaiAndChangByEmployees]
SELECT * FROM [dbo].[vEmployeesByManager]
SELECT * FROM [dbo].[vInventoriesByProductsByCategoriesByEmployees]

/***************************************************************************************/