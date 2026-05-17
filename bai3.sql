CREATE DATABASE bai3_db;

USE bai3_db;

-- 7. Bảng Kho Thuốc (Medicines)
CREATE TABLE Medicines (
    medicine_id INT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    price DECIMAL(18,0) NOT NULL,
    stock INT NOT NULL DEFAULT 0
);

CREATE TABLE Price_Changes_Log (
    log_id INT PRIMARY KEY AUTO_INCREMENT,
    medicine_id INT NOT NULL,
    old_price DECIMAL(18,0),
    new_price DECIMAL(18,0),
    status_change VARCHAR(20),
    price_difference DECIMAL(18,0),
    changed_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- Chèn Thuốc
INSERT INTO Medicines (medicine_id, name, price, stock) VALUES
(1, 'Amoxicillin 500mg', 15000, 100),  -- Tồn kho nhiều
(2, 'Panadol Extra', 5000, 5);         -- Tồn kho ít

DELIMITER \\
CREATE TRIGGER trigger_price_change
BEFORE UPDATE ON Medicines
FOR EACH ROW
BEGIN
	
    IF NEW.price <= 0 THEN
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Lỗi: Giá thuốc mới không hợp lệ';
	END IF;

	IF NEW.price <> OLD.price THEN
    
		IF NEW.price > OLD.price THEN
			INSERT INTO Price_Changes_Log(medicine_id,old_price,new_price,status_change,price_difference)
			VALUES(OLD.medicine_id,OLD.price,NEW.price,'Tăng Giá',NEW.price - OLD.price);
		ELSEIF NEW.price < OLD.price THEN
			INSERT INTO Price_Changes_Log(medicine_id,old_price,new_price,status_change,price_difference)
			VALUES(OLD.medicine_id,OLD.price,NEW.price,'Giảm Giá',OLD.price - NEW.price);
		END IF;
        
	END IF;
END \\
DELIMITER ;

UPDATE Medicines
SET price = 10
WHERE medicine_id = 1;
