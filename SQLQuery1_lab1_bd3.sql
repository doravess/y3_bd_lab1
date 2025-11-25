USE [y3_db_lab1(2)];
GO

-- =============================
--      ТАБЛИЦІ
-- =============================

-- 1. Department
IF OBJECT_ID('Department','U') IS NULL
BEGIN
CREATE TABLE Department (
    Id INT IDENTITY PRIMARY KEY,
    Name VARCHAR(100) NOT NULL,
    IsDeleted BIT NOT NULL DEFAULT 0,
    UpdatedAt DATETIME NULL,
    UpdatedBy INT NULL
);
END
GO

-- 2. Role
IF OBJECT_ID('Role','U') IS NULL
BEGIN
CREATE TABLE Role (
    Id INT IDENTITY PRIMARY KEY,
    Name VARCHAR(50) NOT NULL
);
END
GO

-- 3. Employee
IF OBJECT_ID('Employee','U') IS NULL
BEGIN
CREATE TABLE Employee (
    Id INT IDENTITY PRIMARY KEY,
    FirstName VARCHAR(100) NOT NULL,
    LastName VARCHAR(100) NOT NULL,
    DepartmentId INT NOT NULL,
    RoleId INT NOT NULL,
    HireDate DATE NOT NULL,
    IsDeleted BIT NOT NULL DEFAULT 0,
    UpdatedAt DATETIME NULL,
    UpdatedBy INT NULL,
    CONSTRAINT FK_Employee_Department FOREIGN KEY (DepartmentId) REFERENCES Department(Id),
    CONSTRAINT FK_Employee_Role FOREIGN KEY (RoleId) REFERENCES Role(Id)
);
END
GO

-- 4. Supplier
IF OBJECT_ID('Supplier','U') IS NULL
BEGIN
CREATE TABLE Supplier (
    Id INT IDENTITY PRIMARY KEY,
    Name VARCHAR(150) NOT NULL,
    Phone VARCHAR(50),
    Email VARCHAR(100),
    Address VARCHAR(200),
    IsDeleted BIT NOT NULL DEFAULT 0
);
END
GO

-- 5. Category
IF OBJECT_ID('Category','U') IS NULL
BEGIN
CREATE TABLE Category (
    Id INT IDENTITY PRIMARY KEY,
    Name VARCHAR(100) NOT NULL
);
END
GO

-- 6. Product
IF OBJECT_ID('Product','U') IS NULL
BEGIN
CREATE TABLE Product (
    Id INT IDENTITY PRIMARY KEY,
    Name VARCHAR(150) NOT NULL,
    CategoryId INT NOT NULL,
    SupplierId INT NULL,
    BasePrice DECIMAL(10,2) NOT NULL,
    IsDeleted BIT NOT NULL DEFAULT 0,
    UpdatedAt DATETIME NULL,
    UpdatedBy INT NULL,
    CONSTRAINT FK_Product_Category FOREIGN KEY (CategoryId) REFERENCES Category(Id),
    CONSTRAINT FK_Product_Supplier FOREIGN KEY (SupplierId) REFERENCES Supplier(Id)
);
END
GO

-- 7. Inventory
IF OBJECT_ID('Inventory','U') IS NULL
BEGIN
CREATE TABLE Inventory (
    Id INT IDENTITY PRIMARY KEY,
    ProductId INT NOT NULL,
    Quantity INT NOT NULL DEFAULT 0,
    LastRestock DATETIME NULL,
    CONSTRAINT FK_Inventory_Product FOREIGN KEY (ProductId) REFERENCES Product(Id)
);
END
GO

-- 8. Shipment
IF OBJECT_ID('Shipment','U') IS NULL
BEGIN
CREATE TABLE Shipment (
    Id INT IDENTITY PRIMARY KEY,
    SupplierId INT NOT NULL,
    ShipmentDate DATETIME NOT NULL,
    CONSTRAINT FK_Shipment_Supplier FOREIGN KEY (SupplierId) REFERENCES Supplier(Id)
);
END
GO

-- 9. ShipmentItem
IF OBJECT_ID('ShipmentItem','U') IS NULL
BEGIN
CREATE TABLE ShipmentItem (
    Id INT IDENTITY PRIMARY KEY,
    ShipmentId INT NOT NULL,
    ProductId INT NOT NULL,
    Quantity INT NOT NULL,
    PricePerUnit DECIMAL(10,2) NOT NULL,
    CONSTRAINT FK_ShipmentItem_Shipment FOREIGN KEY (ShipmentId) REFERENCES Shipment(Id),
    CONSTRAINT FK_ShipmentItem_Product FOREIGN KEY (ProductId) REFERENCES Product(Id)
);
END
GO

-- 10. Customer
IF OBJECT_ID('Customer','U') IS NULL
BEGIN
CREATE TABLE Customer (
    Id INT IDENTITY PRIMARY KEY,
    FirstName VARCHAR(100) NOT NULL,
    LastName VARCHAR(100) NOT NULL,
    Phone VARCHAR(50)
);
END
GO

-- 11. Order
IF OBJECT_ID('[Order]','U') IS NULL
BEGIN
CREATE TABLE [Order] (
    Id INT IDENTITY PRIMARY KEY,
    CustomerId INT NOT NULL,
    OrderDate DATETIME NOT NULL,
    Total DECIMAL(10,2) NOT NULL,
    CONSTRAINT FK_Order_Customer FOREIGN KEY (CustomerId) REFERENCES Customer(Id)
);
END
GO

-- 12. OrderItem
IF OBJECT_ID('OrderItem','U') IS NULL
BEGIN
CREATE TABLE OrderItem (
    Id INT IDENTITY PRIMARY KEY,
    OrderId INT NOT NULL,
    ProductId INT NOT NULL,
    Quantity INT NOT NULL,
    Price DECIMAL(10,2) NOT NULL,
    CONSTRAINT FK_OrderItem_Order FOREIGN KEY (OrderId) REFERENCES [Order](Id),
    CONSTRAINT FK_OrderItem_Product FOREIGN KEY (ProductId) REFERENCES Product(Id)
);
END
GO

-- 13. Return
IF OBJECT_ID('[Return]','U') IS NULL
BEGIN
CREATE TABLE [Return] (
    Id INT IDENTITY PRIMARY KEY,
    OrderId INT NOT NULL,
    ReturnDate DATETIME NOT NULL,
    Reason VARCHAR(200),
    CONSTRAINT FK_Return_Order FOREIGN KEY (OrderId) REFERENCES [Order](Id)
);
END
GO

-- 14. PriceHistory
IF OBJECT_ID('PriceHistory','U') IS NULL
BEGIN
CREATE TABLE PriceHistory (
    Id INT IDENTITY PRIMARY KEY,
    ProductId INT NOT NULL,
    OldPrice DECIMAL(10,2) NOT NULL,
    NewPrice DECIMAL(10,2) NOT NULL,
    ChangeDate DATETIME NOT NULL,
    ChangedBy INT NULL,
    CONSTRAINT FK_PriceHistory_Product FOREIGN KEY (ProductId) REFERENCES Product(Id)
);
END
GO

-- 15. UserAccount
IF OBJECT_ID('UserAccount','U') IS NULL
BEGIN
CREATE TABLE UserAccount (
    Id INT IDENTITY PRIMARY KEY,
    Username VARCHAR(50) NOT NULL UNIQUE,
    PasswordHash VARCHAR(200) NOT NULL,
    EmployeeId INT NOT NULL,
    CONSTRAINT FK_UserAccount_Employee FOREIGN KEY (EmployeeId) REFERENCES Employee(Id)
);
END
GO

-- 16. AuditLog
IF OBJECT_ID('AuditLog','U') IS NULL
BEGIN
CREATE TABLE AuditLog (
    Id INT IDENTITY PRIMARY KEY,
    TableName VARCHAR(100) NOT NULL,
    RecordId INT NOT NULL,
    Action VARCHAR(50) NOT NULL,
    ChangeDate DATETIME NOT NULL DEFAULT GETDATE(),
    UserId INT NULL,
    Details NVARCHAR(400) NULL,
    CONSTRAINT FK_AuditLog_User FOREIGN KEY (UserId) REFERENCES UserAccount(Id)
);
END
GO

-- ============================
-- Додаємо колонку Details якщо відсутня
-- ============================

IF COL_LENGTH('Product','Details') IS NULL
    ALTER TABLE Product ADD Details NVARCHAR(400) NULL;
IF COL_LENGTH('OrderItem','Details') IS NULL
    ALTER TABLE OrderItem ADD Details NVARCHAR(400) NULL;
IF COL_LENGTH('Shipment','Details') IS NULL
    ALTER TABLE Shipment ADD Details NVARCHAR(400) NULL;
IF COL_LENGTH('[Return]','Details') IS NULL
    ALTER TABLE [Return] ADD Details NVARCHAR(400) NULL;
IF COL_LENGTH('Inventory','Details') IS NULL
    ALTER TABLE Inventory ADD Details NVARCHAR(400) NULL;
IF COL_LENGTH('[Order]','Details') IS NULL
    ALTER TABLE [Order] ADD Details NVARCHAR(400) NULL;
GO

-- ============================
-- ІНДЕКСИ з перевіркою
-- ============================

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name='IX_Product_Name' AND object_id=OBJECT_ID('Product'))
    CREATE NONCLUSTERED INDEX IX_Product_Name ON Product (Name)
    INCLUDE (CategoryId, BasePrice, IsDeleted);
GO

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name='IX_Inventory_ProductId' AND object_id=OBJECT_ID('Inventory'))
    CREATE NONCLUSTERED INDEX IX_Inventory_ProductId ON Inventory (ProductId);
GO

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name='IX_Product_Active' AND object_id=OBJECT_ID('Product'))
    CREATE NONCLUSTERED INDEX IX_Product_Active ON Product (CategoryId) WHERE IsDeleted = 0;
GO

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name='IX_UserAccount_Username' AND object_id=OBJECT_ID('UserAccount'))
    CREATE NONCLUSTERED INDEX IX_UserAccount_Username ON UserAccount (Username);
GO


-- ============================
-- 3) Функції
-- ============================

IF OBJECT_ID('fn_GetSessionUserId','FN') IS NOT NULL
    DROP FUNCTION fn_GetSessionUserId;
GO

CREATE FUNCTION fn_GetSessionUserId()
RETURNS INT
AS
BEGIN
    DECLARE @uid INT = NULL;
    SELECT @uid = CONVERT(INT, SESSION_CONTEXT(N'UserId'));
    RETURN @uid;
END;
GO

-- ============================
-- 4) Views
-- ============================

-- A) Доступні продукти
IF OBJECT_ID('vw_AvailableProducts','V') IS NOT NULL
    DROP VIEW vw_AvailableProducts;
GO

CREATE VIEW vw_AvailableProducts AS
SELECT p.Id, p.Name, p.BasePrice, c.Name AS Category, ISNULL(i.Quantity,0) AS Quantity
FROM Product p
LEFT JOIN Category c ON p.CategoryId = c.Id
LEFT JOIN Inventory i ON p.Id = i.ProductId
WHERE p.IsDeleted = 0;
GO

-- B) Поточні ціни
IF OBJECT_ID('vw_CurrentPrices','V') IS NOT NULL
    DROP VIEW vw_CurrentPrices;
GO

CREATE VIEW vw_CurrentPrices AS
SELECT p.Id, p.Name, p.BasePrice AS CurrentPrice, ph.LastChangeDate
FROM Product p
OUTER APPLY (
    SELECT MAX(ChangeDate) AS LastChangeDate
    FROM PriceHistory ph
    WHERE ph.ProductId = p.Id
) ph
WHERE p.IsDeleted = 0;
GO

-- C) Історія цін
IF OBJECT_ID('vw_PriceHistory','V') IS NOT NULL
    DROP VIEW vw_PriceHistory;
GO

CREATE VIEW vw_PriceHistory AS
SELECT ph.Id, ph.ProductId, p.Name AS ProductName, ph.OldPrice, ph.NewPrice, ph.ChangeDate, ua.Username AS ChangedBy
FROM PriceHistory ph
LEFT JOIN Product p ON ph.ProductId = p.Id
LEFT JOIN UserAccount ua ON ph.ChangedBy = ua.Id;
GO

-- D) Замовлення з позиціями
IF OBJECT_ID('vw_OrderSummary','V') IS NOT NULL
    DROP VIEW vw_OrderSummary;
GO

CREATE VIEW vw_OrderSummary AS
SELECT o.Id AS OrderId, o.CustomerId, c.FirstName + ' ' + c.LastName AS CustomerName, o.OrderDate,
       o.Total, COUNT(oi.Id) AS ItemCount
FROM [Order] o
LEFT JOIN Customer c ON o.CustomerId = c.Id
LEFT JOIN OrderItem oi ON o.Id = oi.OrderId
GROUP BY o.Id, o.CustomerId, c.FirstName, c.LastName, o.OrderDate, o.Total;
GO

-- ============================
-- 5) Stored Procedures (12)
-- ============================

-- 1) AddProduct
IF OBJECT_ID('AddProduct','P') IS NOT NULL DROP PROCEDURE AddProduct;
GO
CREATE PROCEDURE AddProduct
    @Name VARCHAR(150),
    @CategoryId INT,
    @SupplierId INT = NULL,
    @BasePrice DECIMAL(10,2),
    @NewProductId INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @uid INT = dbo.fn_GetSessionUserId();
    BEGIN TRAN;
    BEGIN TRY
        INSERT INTO Product (Name, CategoryId, SupplierId, BasePrice, IsDeleted, UpdatedAt, UpdatedBy)
        VALUES (@Name, @CategoryId, @SupplierId, @BasePrice, 0, GETDATE(), @uid);

        SET @NewProductId = SCOPE_IDENTITY();

        INSERT INTO PriceHistory (ProductId, OldPrice, NewPrice, ChangeDate, ChangedBy)
        VALUES (@NewProductId, @BasePrice, @BasePrice, GETDATE(), @uid);

        INSERT INTO AuditLog (TableName, RecordId, Action, ChangeDate, UserId, Details)
        VALUES ('Product', @NewProductId, 'Insert', GETDATE(), @uid, CONCAT('Name=', @Name));

        COMMIT;
    END TRY
    BEGIN CATCH
        ROLLBACK;
        THROW;
    END CATCH
END;
GO

-- 2) UpdateProductPrice
IF OBJECT_ID('UpdateProductPrice','P') IS NOT NULL DROP PROCEDURE UpdateProductPrice;
GO
CREATE PROCEDURE UpdateProductPrice
    @ProductId INT,
    @NewPrice DECIMAL(10,2)
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @uid INT = dbo.fn_GetSessionUserId();
    DECLARE @oldPrice DECIMAL(10,2);

    BEGIN TRAN;
    BEGIN TRY
        SELECT @oldPrice = BasePrice FROM Product WHERE Id = @ProductId;
        IF @oldPrice IS NULL THROW 50000, 'Product not found', 1;

        UPDATE Product
        SET BasePrice = @NewPrice, UpdatedAt = GETDATE(), UpdatedBy = @uid
        WHERE Id = @ProductId;

        INSERT INTO PriceHistory (ProductId, OldPrice, NewPrice, ChangeDate, ChangedBy)
        VALUES (@ProductId, @oldPrice, @NewPrice, GETDATE(), @uid);

        INSERT INTO AuditLog (TableName, RecordId, Action, ChangeDate, UserId, Details)
        VALUES ('Product', @ProductId, 'UpdatePrice', GETDATE(), @uid, CONCAT('Old=', @oldPrice,';New=', @NewPrice));

        COMMIT;
    END TRY
    BEGIN CATCH
        ROLLBACK;
        THROW;
    END CATCH
END;
GO

-- 3) AddInventory
IF OBJECT_ID('AddInventory','P') IS NOT NULL DROP PROCEDURE AddInventory;
GO
CREATE PROCEDURE AddInventory
    @ProductId INT,
    @Quantity INT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @uid INT = dbo.fn_GetSessionUserId();
    BEGIN TRAN;
    BEGIN TRY
        IF EXISTS (SELECT 1 FROM Inventory WHERE ProductId = @ProductId)
        BEGIN
            UPDATE Inventory
            SET Quantity = Quantity + @Quantity, LastRestock = GETDATE()
            WHERE ProductId = @ProductId;
        END
        ELSE
        BEGIN
            INSERT INTO Inventory (ProductId, Quantity, LastRestock)
            VALUES (@ProductId, @Quantity, GETDATE());
        END

        INSERT INTO AuditLog (TableName, RecordId, Action, ChangeDate, UserId, Details)
        VALUES ('Inventory', @ProductId, 'AddStock', GETDATE(), @uid, CONCAT('Qty=', @Quantity));

        COMMIT;
    END TRY
    BEGIN CATCH
        ROLLBACK;
        THROW;
    END CATCH
END;
GO

-- 4) CreateShipment
IF OBJECT_ID('CreateShipment','P') IS NOT NULL DROP PROCEDURE CreateShipment;
GO
CREATE PROCEDURE CreateShipment
    @SupplierId INT,
    @ShipmentDate DATETIME,
    @ProductId INT,
    @Quantity INT,
    @PricePerUnit DECIMAL(10,2),
    @ShipmentId INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @uid INT = dbo.fn_GetSessionUserId();
    BEGIN TRAN;
    BEGIN TRY
        INSERT INTO Shipment (SupplierId, ShipmentDate)
        VALUES (@SupplierId, @ShipmentDate);

        SET @ShipmentId = SCOPE_IDENTITY();

        INSERT INTO ShipmentItem (ShipmentId, ProductId, Quantity, PricePerUnit)
        VALUES (@ShipmentId, @ProductId, @Quantity, @PricePerUnit);

        EXEC AddInventory @ProductId = @ProductId, @Quantity = @Quantity;

        INSERT INTO AuditLog (TableName, RecordId, Action, ChangeDate, UserId, Details)
        VALUES ('Shipment', @ShipmentId, 'Create', GETDATE(), @uid, CONCAT('Pid=',@ProductId,';Qty=',@Quantity));

        COMMIT;
    END TRY
    BEGIN CATCH
        ROLLBACK;
        THROW;
    END CATCH
END;
GO

-- 5) MakeOrder
IF OBJECT_ID('MakeOrder','P') IS NOT NULL DROP PROCEDURE MakeOrder;
GO
CREATE PROCEDURE MakeOrder
    @CustomerId INT,
    @OrderDate DATETIME,
    @ProductId INT,
    @Quantity INT,
    @Price DECIMAL(10,2),
    @OrderId INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @uid INT = dbo.fn_GetSessionUserId();
    BEGIN TRAN;
    BEGIN TRY
        INSERT INTO [Order] (CustomerId, OrderDate, Total)
        VALUES (@CustomerId, @OrderDate, @Quantity*@Price);

        SET @OrderId = SCOPE_IDENTITY();

        INSERT INTO OrderItem (OrderId, ProductId, Quantity, Price)
        VALUES (@OrderId, @ProductId, @Quantity, @Price);

        UPDATE Inventory
        SET Quantity = Quantity - @Quantity
        WHERE ProductId = @ProductId;

        IF EXISTS (SELECT 1 FROM Inventory WHERE ProductId=@ProductId AND Quantity < 0)
            THROW 50001, 'Not enough stock', 1;

        INSERT INTO AuditLog (TableName, RecordId, Action, ChangeDate, UserId, Details)
        VALUES ('Order', @OrderId, 'Create', GETDATE(), @uid, CONCAT('Pid=',@ProductId,';Qty=',@Quantity));

        COMMIT;
    END TRY
    BEGIN CATCH
        ROLLBACK;
        THROW;
    END CATCH
END;
GO

-- 6) AddReturn
IF OBJECT_ID('AddReturn','P') IS NOT NULL DROP PROCEDURE AddReturn;
GO
CREATE PROCEDURE AddReturn
    @OrderId INT,
    @ReturnDate DATETIME,
    @Reason VARCHAR(200),
    @ReturnId INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @uid INT = dbo.fn_GetSessionUserId();
    BEGIN TRAN;
    BEGIN TRY
        INSERT INTO [Return] (OrderId, ReturnDate, Reason)
        VALUES (@OrderId, @ReturnDate, @Reason);

        SET @ReturnId = SCOPE_IDENTITY();

        UPDATE i
        SET i.Quantity = i.Quantity + oi.Quantity
        FROM Inventory i
        JOIN OrderItem oi ON i.ProductId = oi.ProductId
        WHERE oi.OrderId = @OrderId;

        INSERT INTO AuditLog (TableName, RecordId, Action, ChangeDate, UserId, Details)
        VALUES ('Return', @ReturnId, 'Create', GETDATE(), @uid, CONCAT('OrderId=', @OrderId));

        COMMIT;
    END TRY
    BEGIN CATCH
        ROLLBACK;
        THROW;
    END CATCH
END;
GO

-- 7) GetProductsByCategory
IF OBJECT_ID('GetProductsByCategory','P') IS NOT NULL DROP PROCEDURE GetProductsByCategory;
GO
CREATE PROCEDURE GetProductsByCategory
    @CategoryId INT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT p.Id, p.Name, p.BasePrice, c.Name AS Category, s.Name AS Supplier, ISNULL(i.Quantity,0) AS Quantity
    FROM Product p
    LEFT JOIN Category c ON p.CategoryId = c.Id
    LEFT JOIN Supplier s ON p.SupplierId = s.Id
    LEFT JOIN Inventory i ON p.Id = i.ProductId
    WHERE p.CategoryId=@CategoryId AND p.IsDeleted=0;
END;
GO

-- 8) SearchProducts
IF OBJECT_ID('SearchProducts','P') IS NOT NULL DROP PROCEDURE SearchProducts;
GO
CREATE PROCEDURE SearchProducts
    @Term VARCHAR(200)
AS
BEGIN
    SET NOCOUNT ON;
    SELECT p.Id, p.Name, p.BasePrice, ISNULL(i.Quantity,0) AS Quantity
    FROM Product p
    LEFT JOIN Inventory i ON p.Id=i.ProductId
    WHERE p.Name LIKE '%'+@Term+'%' AND p.IsDeleted=0;
END;
GO

-- 9) SoftDeleteProduct
IF OBJECT_ID('SoftDeleteProduct','P') IS NOT NULL DROP PROCEDURE SoftDeleteProduct;
GO
CREATE PROCEDURE SoftDeleteProduct
    @ProductId INT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @uid INT = dbo.fn_GetSessionUserId();
    BEGIN TRAN;
    BEGIN TRY
        UPDATE Product
        SET IsDeleted=1, UpdatedAt=GETDATE(), UpdatedBy=@uid
        WHERE Id=@ProductId;

        INSERT INTO AuditLog (TableName, RecordId, Action, ChangeDate, UserId, Details)
        VALUES ('Product', @ProductId, 'SoftDelete', GETDATE(), @uid, NULL);

        COMMIT;
    END TRY
    BEGIN CATCH
        ROLLBACK;
        THROW;
    END CATCH
END;
GO

-- 10) RestoreProduct
IF OBJECT_ID('RestoreProduct','P') IS NOT NULL DROP PROCEDURE RestoreProduct;
GO
CREATE PROCEDURE RestoreProduct
    @ProductId INT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @uid INT = dbo.fn_GetSessionUserId();
    UPDATE Product
    SET IsDeleted=0, UpdatedAt=GETDATE(), UpdatedBy=@uid
    WHERE Id=@ProductId;

    INSERT INTO AuditLog (TableName, RecordId, Action, ChangeDate, UserId, Details)
    VALUES ('Product', @ProductId, 'Restore', GETDATE(), @uid, NULL);
END;
GO

-- 11) GetPriceHistory
IF OBJECT_ID('GetPriceHistory','P') IS NOT NULL DROP PROCEDURE GetPriceHistory;
GO
CREATE PROCEDURE GetPriceHistory
    @ProductId INT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT ph.Id, ph.OldPrice, ph.NewPrice, ph.ChangeDate, ua.Username AS ChangedByUser
    FROM PriceHistory ph
    LEFT JOIN UserAccount ua ON ph.ChangedBy = ua.Id
    WHERE ph.ProductId=@ProductId
    ORDER BY ph.ChangeDate DESC;
END;
GO

-- 12) GetOrderDetails
IF OBJECT_ID('GetOrderDetails','P') IS NOT NULL DROP PROCEDURE GetOrderDetails;
GO
CREATE PROCEDURE GetOrderDetails
    @OrderId INT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT o.Id AS OrderId, o.OrderDate, o.Total, c.FirstName, c.LastName,
           oi.ProductId, p.Name AS ProductName, oi.Quantity, oi.Price
    FROM [Order] o
    LEFT JOIN Customer c ON o.CustomerId=c.Id
    LEFT JOIN OrderItem oi ON o.Id=oi.OrderId
    LEFT JOIN Product p ON oi.ProductId=p.Id
    WHERE o.Id=@OrderId;
END;
GO

-- ============================
-- 6) Triggers
-- ============================

-- 1) trg_Product_InsteadOfDelete
IF OBJECT_ID('trg_Product_InsteadOfDelete','TR') IS NOT NULL
    DROP TRIGGER trg_Product_InsteadOfDelete;
GO

CREATE TRIGGER trg_Product_InsteadOfDelete
ON Product
INSTEAD OF DELETE
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @uid INT = dbo.fn_GetSessionUserId();
    UPDATE p
    SET IsDeleted = 1,
        UpdatedAt = GETDATE(),
        UpdatedBy = @uid
    FROM Product p
    JOIN deleted d ON p.Id = d.Id;

    INSERT INTO AuditLog (TableName, RecordId, Action, ChangeDate, UserId, Details)
    SELECT 'Product', d.Id, 'SoftDelete', GETDATE(), @uid, NULL
    FROM deleted d;
END;
GO

-- 2) trg_Employee_AfterUpdate
IF OBJECT_ID('trg_Employee_AfterUpdate','TR') IS NOT NULL
    DROP TRIGGER trg_Employee_AfterUpdate;
GO

CREATE TRIGGER trg_Employee_AfterUpdate
ON Employee
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @uid INT = dbo.fn_GetSessionUserId();
    UPDATE e
    SET UpdatedAt = GETDATE(),
        UpdatedBy = @uid
    FROM Employee e
    JOIN inserted i ON e.Id = i.Id;

    INSERT INTO AuditLog (TableName, RecordId, Action, ChangeDate, UserId, Details)
    SELECT 'Employee', i.Id, 'Update', GETDATE(), @uid, NULL
    FROM inserted i;
END;
GO

-- 3) trg_Order_Audit
IF OBJECT_ID('trg_Order_Audit','TR') IS NOT NULL
    DROP TRIGGER trg_Order_Audit;
GO

CREATE TRIGGER trg_Order_Audit
ON [Order]
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @uid INT = dbo.fn_GetSessionUserId();

    -- INSERT
    INSERT INTO AuditLog (TableName, RecordId, Action, ChangeDate, UserId, Details)
    SELECT 'Order', i.Id, 'Insert', GETDATE(), @uid, NULL
    FROM inserted i
    WHERE NOT EXISTS (SELECT 1 FROM deleted d WHERE d.Id = i.Id);

    -- UPDATE
    INSERT INTO AuditLog (TableName, RecordId, Action, ChangeDate, UserId, Details)
    SELECT 'Order', i.Id, 'Update', GETDATE(), @uid, NULL
    FROM inserted i
    JOIN deleted d ON i.Id = d.Id;

    -- DELETE
    INSERT INTO AuditLog (TableName, RecordId, Action, ChangeDate, UserId, Details)
    SELECT 'Order', d.Id, 'Delete', GETDATE(), @uid, NULL
    FROM deleted d
    WHERE NOT EXISTS (SELECT 1 FROM inserted i WHERE i.Id = d.Id);
END;
GO