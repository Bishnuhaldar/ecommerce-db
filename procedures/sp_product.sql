-- ================================================
-- PRODUCT TABLE
-- ================================================
ALTER TABLE products 
    ADD COLUMN stock_status VARCHAR(20) NOT NULL DEFAULT 'in_stock',
    ADD COLUMN restock_date DATE NULL;

-- Helper function to determine stock_status
-- (This is a comment for maintainers; actual logic is in procedures)
-- in_stock: stock > 10
-- low_stock: stock BETWEEN 1 AND 10
-- out_of_stock: stock = 0

-- ================================================
-- STORED PROCEDURES
-- ================================================
DELIMITER $$

-- 1. Create Product
CREATE PROCEDURE sp_CreateProduct(
    IN p_sku VARCHAR(100), IN p_name VARCHAR(255),
    IN p_category VARCHAR(100), IN p_brand VARCHAR(100), IN p_price DECIMAL(10,2), IN p_stock INT,
    IN p_restock_date DATE
)
BEGIN
    DECLARE v_stock_status VARCHAR(20);
    IF p_stock > 10 THEN
        SET v_stock_status = 'in_stock';
    ELSEIF p_stock BETWEEN 1 AND 10 THEN
        SET v_stock_status = 'low_stock';
    ELSE
        SET v_stock_status = 'out_of_stock';
    END IF;
    INSERT INTO products (sku, name, category, brand, price, stock, stock_status, restock_date)
    VALUES (p_sku, p_name, p_category, p_brand, p_price, p_stock, v_stock_status, 
        CASE WHEN v_stock_status = 'out_of_stock' THEN p_restock_date ELSE NULL END);
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
    SELECT product_id, sku, name, category, brand, price, stock, stock_status, restock_date
    FROM products WHERE is_active = 1 ORDER BY created_at DESC;
END $$

-- 4. Update Product
CREATE PROCEDURE sp_UpdateProduct(
    IN p_product_id INT, IN p_name VARCHAR(255),
    IN p_price DECIMAL(10,2), IN p_stock INT, IN p_restock_date DATE
)
BEGIN
    DECLARE v_stock_status VARCHAR(20);
    IF p_stock > 10 THEN
        SET v_stock_status = 'in_stock';
    ELSEIF p_stock BETWEEN 1 AND 10 THEN
        SET v_stock_status = 'low_stock';
    ELSE
        SET v_stock_status = 'out_of_stock';
    END IF;
    UPDATE products
    SET name = p_name, price = p_price, stock = p_stock, stock_status = v_stock_status,
        restock_date = CASE WHEN v_stock_status = 'out_of_stock' THEN p_restock_date ELSE NULL END
    WHERE product_id = p_product_id;
END $$

-- 5. Update Stock
CREATE PROCEDURE sp_UpdateStock(IN p_product_id INT, IN p_delta INT, IN p_restock_date DATE)
BEGIN
    DECLARE v_new_stock INT;
    DECLARE v_stock_status VARCHAR(20);
    SELECT stock + p_delta INTO v_new_stock FROM products WHERE product_id = p_product_id;
    IF v_new_stock < 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Insufficient stock';
    END IF;
    IF v_new_stock > 10 THEN
        SET v_stock_status = 'in_stock';
    ELSEIF v_new_stock BETWEEN 1 AND 10 THEN
        SET v_stock_status = 'low_stock';
    ELSE
        SET v_stock_status = 'out_of_stock';
    END IF;
    UPDATE products 
    SET stock = v_new_stock, stock_status = v_stock_status,
        restock_date = CASE WHEN v_stock_status = 'out_of_stock' THEN p_restock_date ELSE NULL END
    WHERE product_id = p_product_id;
    SELECT stock AS updated_stock, stock_status, restock_date FROM products WHERE product_id = p_product_id;
END $$

-- 6. Soft Delete Product
CREATE PROCEDURE sp_DeleteProduct(IN p_product_id INT)
BEGIN
    UPDATE products SET is_active = 0 WHERE product_id = p_product_id;
END $$

-- 7. Search Products
CREATE PROCEDURE sp_SearchProducts(IN p_keyword VARCHAR(100))
BEGIN
    SELECT product_id, sku, name, brand, price, stock, stock_status, restock_date
    FROM products
    WHERE is_active = 1 AND (name LIKE CONCAT('%', p_keyword, '%') OR brand LIKE CONCAT('%', p_keyword, '%'));
END $$

DELIMITER ;

-- ================================================
-- USAGE EXAMPLES
-- ================================================
-- CALL sp_CreateProduct('SKU-001', 'Running Shoes', 'Footwear', 'Nike', 2999.00, 50, NULL);
-- CALL sp_GetProduct(1);
-- CALL sp_ListProducts();
-- CALL sp_UpdateProduct(1, 'Running Shoes Pro', 3499.00, 45, NULL);
-- CALL sp_UpdateStock(1, -3, NULL);
-- CALL sp_SearchProducts('Nike');
-- CALL sp_DeleteProduct(1);
