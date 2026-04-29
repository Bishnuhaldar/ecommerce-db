-- ================================================
-- PRODUCT TABLE
-- ================================================
CREATE TABLE IF NOT EXISTS products (
    product_id     INT AUTO_INCREMENT PRIMARY KEY,
    sku            VARCHAR(100)  NOT NULL UNIQUE,
    name           VARCHAR(255)  NOT NULL,
    category       VARCHAR(100),
    brand          VARCHAR(100),
    price          DECIMAL(10,2) NOT NULL,
    stock          INT           NOT NULL DEFAULT 0,
    is_active      TINYINT(1)    NOT NULL DEFAULT 1,
    price_category VARCHAR(20)   GENERATED ALWAYS AS (
        CASE 
            WHEN price < 1000 THEN 'cheap'
            WHEN price > 5000 THEN 'expensive'
            ELSE 'midrange'
        END
    ) STORED,
    rating         DECIMAL(2,1)  DEFAULT NULL,
    created_at     DATETIME      DEFAULT CURRENT_TIMESTAMP
);

-- ================================================
-- STORED PROCEDURES
-- ================================================
DELIMITER $$

-- 1. Create Product
CREATE PROCEDURE sp_CreateProduct(IN p_sku VARCHAR(100), IN p_name VARCHAR(255),
    IN p_category VARCHAR(100), IN p_brand VARCHAR(100), IN p_price DECIMAL(10,2), IN p_stock INT, IN p_rating DECIMAL(2,1))
BEGIN
    INSERT INTO products (sku, name, category, brand, price, stock, rating)
    VALUES (p_sku, p_name, p_category, p_brand, p_price, p_stock, p_rating);
    SELECT LAST_INSERT_ID() AS new_product_id;
END $$

-- 2. Get Product by ID
CREATE PROCEDURE sp_GetProduct(IN p_product_id INT)
BEGIN
    SELECT * FROM products WHERE product_id = p_product_id;
END $$

-- 3. List All Active Products
CREATE PROCEDURE sp_ListProducts()
BEGIN
    SELECT product_id, sku, name, category, brand, price, price_category, rating, stock
    FROM products WHERE is_active = 1 ORDER BY created_at DESC;
END $$

-- 4. Update Product
CREATE PROCEDURE sp_UpdateProduct(IN p_product_id INT, IN p_name VARCHAR(255),
    IN p_price DECIMAL(10,2), IN p_stock INT, IN p_rating DECIMAL(2,1))
BEGIN
    UPDATE products
    SET name = p_name, price = p_price, stock = p_stock, rating = p_rating
    WHERE product_id = p_product_id;
END $$

-- 5. Update Stock
CREATE PROCEDURE sp_UpdateStock(IN p_product_id INT, IN p_delta INT)
BEGIN
    IF (SELECT stock FROM products WHERE product_id = p_product_id) + p_delta < 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Insufficient stock';
    END IF;
    UPDATE products SET stock = stock + p_delta WHERE product_id = p_product_id;
    SELECT stock AS updated_stock FROM products WHERE product_id = p_product_id;
END $$

-- 6. Soft Delete Product
CREATE PROCEDURE sp_DeleteProduct(IN p_product_id INT)
BEGIN
    UPDATE products SET is_active = 0 WHERE product_id = p_product_id;
END $$

-- 7. Search Products
CREATE PROCEDURE sp_SearchProducts(IN p_keyword VARCHAR(100))
BEGIN
    SELECT product_id, sku, name, brand, price, price_category, rating, stock
    FROM products
    WHERE is_active = 1 AND (name LIKE CONCAT('%', p_keyword, '%') OR brand LIKE CONCAT('%', p_keyword, '%'));
END $$

DELIMITER ;

-- ================================================
-- USAGE EXAMPLES
-- ================================================
-- CALL sp_CreateProduct('SKU-001', 'Running Shoes', 'Footwear', 'Nike', 2999.00, 50, 4.5);
-- CALL sp_GetProduct(1);
-- CALL sp_ListProducts();
-- CALL sp_UpdateProduct(1, 'Running Shoes Pro', 3499.00, 45, 4.8);
-- CALL sp_UpdateStock(1, -3);
-- CALL sp_SearchProducts('Nike');
-- CALL sp_DeleteProduct(1);
