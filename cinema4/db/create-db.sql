-- Tao CSDL va tai khoan rieng cho ung dung; chay mot lan bang tai khoan root:
--   mysql -uroot -p < db/create-db.sql
-- Sau do tao bang va nap du lieu mau bang tai khoan cinema4:
--   mysql -ucinema4 -pcinema4 cinema4 < db/schema.sql
--   mysql -ucinema4 -pcinema4 cinema4 < db/seed.sql

CREATE DATABASE IF NOT EXISTS cinema4 CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE USER IF NOT EXISTS 'cinema4'@'localhost' IDENTIFIED BY 'cinema4';
GRANT ALL PRIVILEGES ON cinema4.* TO 'cinema4'@'localhost';
FLUSH PRIVILEGES;
