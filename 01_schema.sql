-- MySQL 8.0 | third-party REES46 proxy events, NOT Flipkart database
CREATE DATABASE IF NOT EXISTS flipkart_conversion_case CHARACTER SET utf8mb4;
USE flipkart_conversion_case;
CREATE TABLE IF NOT EXISTS raw_events (
  event_id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
  event_time VARCHAR(40), event_type VARCHAR(40), product_id VARCHAR(80),
  category_id VARCHAR(80), category_code VARCHAR(255), brand VARCHAR(255),
  price_text VARCHAR(60), user_id VARCHAR(80), user_session VARCHAR(80),
  INDEX idx_session (user_session), INDEX idx_type (event_type), INDEX idx_product(product_id)
);
-- Load exact source CSV only after checking column order, quoting, encoding and line endings.
-- DBeaver Import Data GUI is recommended; map source `price` to `price_text`.
-- Do not deduplicate the raw import automatically: source logs may contain repeat interactions.
CREATE OR REPLACE VIEW valid_events AS
SELECT event_id, STR_TO_DATE(REPLACE(SUBSTRING_INDEX(event_time,'.',1),' UTC',''),'%Y-%m-%d %H:%i:%s') AS event_at,
 LOWER(TRIM(event_type)) AS event_type, product_id,category_id,category_code,brand,
 CASE WHEN price_text REGEXP '^[0-9]+(\.[0-9]+)?$' THEN CAST(price_text AS DECIMAL(14,2)) END AS unit_price,
 user_id, NULLIF(TRIM(user_session),'') AS user_session FROM raw_events;
