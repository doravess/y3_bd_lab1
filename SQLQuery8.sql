-- Видалити стару процедуру
DROP PROCEDURE IF EXISTS GetAllProducts
GO

-- Створити нову правильну процедуру
CREATE PROCEDURE GetAllProducts
AS
BEGIN
    SELECT 
        Id, 
        Name, 
        BasePrice, 
        CategoryId, 
        SupplierId, 
        IsDeleted, 
        UpdatedAt, 
        UpdatedBy, 
        Details
    FROM dbo.Product
    WHERE IsDeleted = 0
END
GO

-- Перевірити, що працює
EXEC GetAllProducts
GO

-- =============================================
-- Видалити ВСІ старі Product процедури
-- =============================================
DROP PROCEDURE IF EXISTS GetAllProducts
GO
DROP PROCEDURE IF EXISTS GetProductById
GO
DROP PROCEDURE IF EXISTS AddProduct
GO
DROP PROCEDURE IF EXISTS UpdateProduct
GO
DROP PROCEDURE IF EXISTS DeleteProduct
GO

-- =============================================
-- Створити НОВІ процедури з правильними полями
-- =============================================

-- GetAllProducts
CREATE PROCEDURE GetAllProducts
AS
BEGIN
    SELECT 
        Id, 
        Name, 
        BasePrice, 
        CategoryId, 
        SupplierId, 
        IsDeleted, 
        UpdatedAt, 
        UpdatedBy, 
        Details
    FROM dbo.Product
    WHERE IsDeleted = 0
END
GO

-- GetProductById
CREATE PROCEDURE GetProductById
    @Id INT
AS
BEGIN
    SELECT 
        Id, 
        Name, 
        BasePrice, 
        CategoryId, 
        SupplierId, 
        IsDeleted, 
        UpdatedAt, 
        UpdatedBy, 
        Details
    FROM dbo.Product
    WHERE Id = @Id AND IsDeleted = 0
END
GO

-- AddProduct
CREATE PROCEDURE AddProduct
    @Name NVARCHAR(150),
    @BasePrice DECIMAL(10,2),
    @CategoryId INT = NULL,
    @SupplierId INT = NULL,
    @Details NVARCHAR(400) = NULL
AS
BEGIN
    INSERT INTO dbo.Product (Name, BasePrice, CategoryId, SupplierId, IsDeleted, UpdatedAt, Details)
    VALUES (@Name, @BasePrice, @CategoryId, @SupplierId, 0, GETDATE(), @Details)
END
GO

-- UpdateProduct
CREATE PROCEDURE UpdateProduct
    @Id INT,
    @Name NVARCHAR(150),
    @BasePrice DECIMAL(10,2),
    @CategoryId INT = NULL,
    @SupplierId INT = NULL,
    @Details NVARCHAR(400) = NULL
AS
BEGIN
    UPDATE dbo.Product
    SET 
        Name = @Name, 
        BasePrice = @BasePrice, 
        CategoryId = @CategoryId,
        SupplierId = @SupplierId,
        UpdatedAt = GETDATE(),
        Details = @Details
    WHERE Id = @Id
END
GO

-- DeleteProduct (soft delete)
CREATE PROCEDURE DeleteProduct
    @Id INT
AS
BEGIN
    UPDATE dbo.Product
    SET IsDeleted = 1, UpdatedAt = GETDATE()
    WHERE Id = @Id
END
GO

-- =============================================
-- ТЕСТИ
-- =============================================
PRINT '=== Testing GetAllProducts ==='
EXEC GetAllProducts
GO

PRINT '=== All procedures created successfully! ==='
SELECT name, create_date FROM sys.procedures WHERE name LIKE '%Product%'
GO