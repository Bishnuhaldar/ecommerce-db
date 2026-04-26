-- ================================================
-- PRODUCT TABLE
-- ================================================
ALTER TABLE products
    ADD COLUMN price_category VARCHAR(20) GENERATED ALWAYS AS (
        CASE
            WHEN price < 1000 THEN 'cheap'
            WHEN price BETWEEN 1000 AND 5000 THEN 'midrange'
            WHEN price > 5000 THEN 'expensive'
        END
    ) STORED,
    ADD COLUMN rating DECIMAL(2,1) NOT NULL DEFAULT 0.0;

-- ================================================
-- STORED PROCEDURES
-- ================================================
DELIMITER $$

-- 1. Create Product
DROP PROCEDURE IF EXISTS sp_CreateProduct;
CREATE PROCEDURE sp_CreateProduct(
    IN p_sku VARCHAR(100),
    IN p_name VARCHAR(255),
    IN p_category VARCHAR(100),
    IN p_brand VARCHAR(100),
    IN p_price DECIMAL(10,2),
    IN p_stock INT,
    IN p_rating DECIMAL(2,1)
)
BEGIN
    INSERT INTO products (sku, name, category, brand, price, stock, rating)
    VALUES (p_sku, p_name, p_category, p_brand, p_price, p_stock, p_rating);
    SELECT LAST_INSERT_ID() AS new_product_id;
END $$

-- 2. Get Product by ID
DROP PROCEDURE IF EXISTS sp_GetProduct;
CREATE PROCEDURE sp_GetProduct(IN p_product_id INT)
BEGIN
    SELECT * FROM products WHERE product_id = p_product_id;
END $$

-- 3. List All Active Products
DROP PROCEDURE IF EXISTS sp_ListProducts;
CREATE PROCEDURE sp_ListProducts()
BEGIN
    SELECT product_id, sku, name, category, brand, price, stock, price_category, rating
    FROM products WHERE is_active = 1 ORDER BY created_at DESC;
END $$

-- 4. Update Product
DROP PROCEDURE IF EXISTS sp_UpdateProduct;
CREATE PROCEDURE sp_UpdateProduct(
    IN p_product_id INT,
    IN p_name VARCHAR(255),
    IN p_price DECIMAL(10,2),
    IN p_stock INT,
    IN p_rating DECIMAL(2,1)
)
BEGIN
    UPDATE products
    SET name = p_name, price = p_price, stock = p_stock, rating = p_rating
    WHERE product_id = p_product_id;
END $$

-- 7. Search Products
DROP PROCEDURE IF EXISTS sp_SearchProducts;
CREATE PROCEDURE sp_SearchProducts(IN p_keyword VARCHAR(100))
BEGIN
    SELECT product_id, sku, name, brand, price, stock, price_category, rating
    FROM products
    WHERE is_active = 1 AND (name LIKE CONCAT('%', p_keyword, '%') OR brand LIKE CONCAT('%', p_keyword, '%'));
END $$

DELIMITER ;
