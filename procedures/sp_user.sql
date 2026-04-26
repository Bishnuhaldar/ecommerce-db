-- ================================================
-- USER TABLE
-- ================================================
CREATE TABLE IF NOT EXISTS users (
    user_id     INT AUTO_INCREMENT PRIMARY KEY,
    name        VARCHAR(150)  NOT NULL,
    email       VARCHAR(255)  NOT NULL UNIQUE,
    phone       VARCHAR(20),
    password    VARCHAR(255)  NOT NULL,
    role        ENUM('customer', 'admin') DEFAULT 'customer',
    is_active   TINYINT(1)    NOT NULL DEFAULT 1,
    created_at  DATETIME      DEFAULT CURRENT_TIMESTAMP
);

-- ================================================
-- STORED PROCEDURES
-- ================================================
DELIMITER $$

-- 1. Register User
CREATE PROCEDURE sp_CreateUser(IN p_name VARCHAR(150), IN p_email VARCHAR(255),
    IN p_phone VARCHAR(20), IN p_password VARCHAR(255))
BEGIN
    INSERT INTO users (name, email, phone, password)
    VALUES (p_name, p_email, p_phone, p_password);
    SELECT LAST_INSERT_ID() AS new_user_id;
END $$

-- 2. Get User by ID
CREATE PROCEDURE sp_GetUser(IN p_user_id INT)
BEGIN
    SELECT user_id, name, email, phone, role, is_active, created_at
    FROM users WHERE user_id = p_user_id;
END $$

-- 3. Get User by Email (for login)
CREATE PROCEDURE sp_GetUserByEmail(IN p_email VARCHAR(255))
BEGIN
    SELECT user_id, name, email, password, role, is_active
    FROM users WHERE email = p_email;
END $$

-- 4. List All Active Users
CREATE PROCEDURE sp_ListUsers()
BEGIN
    SELECT user_id, name, email, phone, role, created_at
    FROM users WHERE is_active = 1 ORDER BY created_at DESC;
END $$

-- 5. Update User
CREATE PROCEDURE sp_UpdateUser(IN p_user_id INT, IN p_name VARCHAR(150), IN p_phone VARCHAR(20))
BEGIN
    UPDATE users SET name = p_name, phone = p_phone
    WHERE user_id = p_user_id;
END $$

-- 6. Change Password
CREATE PROCEDURE sp_ChangePassword(IN p_user_id INT, IN p_new_password VARCHAR(255))
BEGIN
    UPDATE users SET password = p_new_password WHERE user_id = p_user_id;
END $$

-- 7. Soft Delete User
CREATE PROCEDURE sp_DeleteUser(IN p_user_id INT)
BEGIN
    UPDATE users SET is_active = 0 WHERE user_id = p_user_id;
END $$

-- 8. Search Users
CREATE PROCEDURE sp_SearchUsers(IN p_keyword VARCHAR(100))
BEGIN
    SELECT user_id, name, email, phone, role
    FROM users
    WHERE is_active = 1 AND (name LIKE CONCAT('%', p_keyword, '%') OR email LIKE CONCAT('%', p_keyword, '%'));
END $$

DELIMITER ;

-- ================================================
-- USAGE EXAMPLES
-- ================================================
-- CALL sp_CreateUser('Rahul Sharma', 'rahul@example.com', '9876543210', 'hashed_password');
-- CALL sp_GetUser(1);
-- CALL sp_GetUserByEmail('rahul@example.com');
-- CALL sp_ListUsers();
-- CALL sp_UpdateUser(1, 'Rahul S', '9999999999');
-- CALL sp_ChangePassword(1, 'new_hashed_password');
-- CALL sp_SearchUsers('Rahul');
-- CALL sp_DeleteUser(1);
