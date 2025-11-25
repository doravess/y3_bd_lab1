USE [y3_db_lab1(2)];
GO

-- ============================
-- 1) Departments
-- ============================
INSERT INTO Department (Name) VALUES
('IT'), ('Sales'), ('Logistics'), ('HR');
GO

-- ============================
-- 2) Roles
-- ============================
INSERT INTO Role (Name) VALUES
('Manager'), ('Staff'), ('Admin');
GO

-- ============================
-- 3) Employees
-- ============================
INSERT INTO Employee (FirstName, LastName, DepartmentId, RoleId, HireDate)
VALUES
('Alice','Smith', 1, 1, '2023-01-15'),
('Bob','Johnson', 2, 2, '2023-02-01'),
('Charlie','Brown', 3, 2, '2023-03-20');
GO

-- ============================
-- 4) Suppliers
-- ============================
INSERT INTO Supplier (Name, Phone, Email, Address)
VALUES
('Supplier A', '111-111', 'a@supplier.com', 'Street 1'),
('Supplier B', '222-222', 'b@supplier.com', 'Street 2');
GO

-- ============================
-- 5) Categories
-- ============================
INSERT INTO Category (Name)
VALUES ('Electronics'), ('Books'), ('Furniture');
GO

-- ============================
-- 6) Products
-- ============================
DECLARE @NewProductId INT;

EXEC AddProduct @Name='Laptop', @CategoryId=1, @SupplierId=1, @BasePrice=1200, @NewProductId=@NewProductId OUTPUT;
EXEC AddProduct @Name='Chair', @CategoryId=3, @SupplierId=2, @BasePrice=150, @NewProductId=@NewProductId OUTPUT;
EXEC AddProduct @Name='Book: SQL Guide', @CategoryId=2, @SupplierId=NULL, @BasePrice=30, @NewProductId=@NewProductId OUTPUT;
GO

-- ============================
-- 7) Inventory
-- ============================
EXEC AddInventory @ProductId=1, @Quantity=10;
EXEC AddInventory @ProductId=2, @Quantity=20;
EXEC AddInventory @ProductId=3, @Quantity=50;
GO

-- ============================
-- 8) Customers
-- ============================
INSERT INTO Customer (FirstName, LastName, Phone)
VALUES
('Daniel','Lee','555-1010'),
('Eva','White','555-2020');
GO

-- ============================
-- 9) UserAccounts
-- ============================
-- Створюємо користувача із заданим UserId
DECLARE @NewUserId INT;

INSERT INTO UserAccount (Username, PasswordHash, EmployeeId)
OUTPUT INSERTED.Id INTO @NewUserId
VALUES ('alice','hash123',1);

INSERT INTO UserAccount (Username, PasswordHash, EmployeeId)
VALUES ('bob','hash456',2);
GO

-- ============================
-- 10) Test Stored Procedures
-- ============================

-- A) UpdateProductPrice
EXEC UpdateProductPrice @ProductId=1, @NewPrice=1250;
EXEC UpdateProductPrice @ProductId=2, @NewPrice=160;

-- B) CreateShipment
DECLARE @ShipmentId INT;
EXEC CreateShipment @SupplierId=1, @ShipmentDate='2025-11-23', @ProductId=1, @Quantity=5, @PricePerUnit=1200, @ShipmentId=@ShipmentId OUTPUT;

-- C) MakeOrder
DECLARE @OrderId INT;
EXEC MakeOrder @CustomerId=1, @OrderDate='2025-11-23', @ProductId=1, @Quantity=2, @Price=1250, @OrderId=@OrderId OUTPUT;

-- D) AddReturn
DECLARE @ReturnId INT;
EXEC AddReturn @OrderId=@OrderId, @ReturnDate='2025-11-24', @Reason='Defective', @ReturnId=@ReturnId OUTPUT;

-- E) SoftDeleteProduct / RestoreProduct
EXEC SoftDeleteProduct @ProductId=3;
EXEC RestoreProduct @ProductId=3;

-- ============================
-- 11) Test Queries / Views
-- ============================
SELECT * FROM vw_AvailableProducts;
SELECT * FROM vw_CurrentPrices;
SELECT * FROM vw_PriceHistory;
SELECT * FROM vw_OrderSummary;

-- ============================
-- 12) GetPriceHistory
-- ============================
EXEC GetPriceHistory @ProductId=1;

-- ============================
-- 13) GetOrderDetails
-- ============================
EXEC GetOrderDetails @OrderId=@OrderId;

-- ============================
-- 14) Search / Filter
-- ============================
EXEC SearchProducts @Term='Laptop';
EXEC GetProductsByCategory @CategoryId=1;

GO
