USE retail_sale_analytics;

LOAD DATA LOCAL INFILE 'C:/Users/M USER/Desktop/Projects/SQL/CSV Files/online_retail_II.csv'
INTO TABLE staging_online_retail
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(invoice, stock_code, description, quantity, invoice_date, price, customer_id, country);

SELECT COUNT(*) FROM staging_online_retail;

-- Check missing and NULL values. They're not the same.
SELECT
	SUM(CASE
			WHEN description IS NULL OR description = ''
				THEN 1
                ELSE 0
			END) AS missing_description,
	SUM(CASE
			WHEN customer_id IS NULL OR customer_id = ''
				THEN 1
                ELSE 0
			END) AS missing_customer_id
FROM staging_online_retail;

-- Cancelles orders. These start with a 'C'.
SELECT COUNT(*) AS cancelled_invoice_rows
FROM staging_online_retail
WHERE invoice LIKE 'C%';

-- Negative/Free-of-Charge Items
SELECT
	SUM(CASE
			WHEN CAST(quantity AS SIGNED) < 0
				THEN 1
                ELSE 0
			END) AS negative_quntity_rows,
	SUM(CASE
			WHEN CAST(price AS DECIMAL(10, 2)) <= 0
				THEN 1
                ELSE 0
			END) AS zero_or_negative_price_rows
FROM staging_online_retail;

-- Stock codes with more than 1 distinct descriptions.
SELECT stock_code, COUNT(DISTINCT description) AS description_variants
FROM staging_online_retail
GROUP BY stock_code
HAVING COUNT(DISTINCT description) > 1
ORDER BY description_variants DESC
LIMIT 10;

-- Duplicate rows.
SELECT invoice, stock_code, quantity, invoice_date, price, customer_id, country, COUNT(*) AS occurences
FROM staging_online_retail
GROUP BY invoice, stock_code, quantity, invoice_date, price, customer_id, country
HAVING COUNT(*) > 1
ORDER BY occurences DESC
LIMIT 10;

-- See if all customer_id are of the form "XXXX.0" or no. Ideally should return 0 rows.
SELECT DISTINCT customer_id
FROM staging_online_retail
WHERE customer_id NOT LIKE '%.0' AND customer_id != ''
LIMIT 10;

-- Sanity checking the data range.
SELECT MIN(invoice_date) AS earliest, MAX(invoice_date) as latest
FROM staging_online_retail;

-- DATA VALIDATION SUMMARY (staging_online_retail)
-- Missing description: 4382
-- Missing customer_id: 243,007
-- Cancelled invoice rows/Cancelled orders: 19,494
-- Negative quantity: 22,950
-- Zero or negative price: 6225
-- 67,242 duplicate rows.
-- Many stock_codes with more then one variant of description (≈ 1232 rows affected)).
-- All customer_id of the form "%.0".
-- Data range --> Earliest : 2009-12-01 07:45:00 and latest : 2011-12-09 12:50:00

-- DECISIONS
-- Keep missing customer_id rows. They're guest orders contributing to revenue.
-- Keep the missing descriptions rows. The product was sold. No description doesn't invalidate the revenue generated.
-- Keep the cancelled orders. We can create a boolean column in invoices to flag cancelled orders.
	-- These contribute significantly to understand sales, gross revenue, net revenue etc.
-- We keep the negative price rows, since we don't know why they're negative (free, promotional item, daat entry error).
	-- Deleting them may prove catastrophic down the line. We can filter them out in queries and even investigate later.
-- For eachstock_code, keep the most frequent description to favour the real product description instead of one-off junk entries.
-- Collapse duplicate rows into one row. Duplicate here means rows with exact values in all fields.
	-- So these aren't two purchases of the same product (because even the time stamp is same).
-- Strip the ".0" from suctomer_id. All customer_id have this, so it'll have no consequence.