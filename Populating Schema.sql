-- Inserting into Customers table
INSERT INTO Customers (customer_id, country)
SELECT
	CAST(SUBSTRING_INDEX(customer_id, '.', 1) AS UNSIGNED) AS customer_id,
    MAX(country) AS country
FROM staging_online_retail
WHERE customer_id IS NOT NULL AND customer_id != ''
GROUP BY customer_id;
-- MAX(conuntry) picks alphabetically last country for a customer_id.

-- Insert the most frequent non-blank description per stock_code
INSERT INTO Products (stock_code, description)
SELECT s.stock_code, ANY_VALUE(s.description) AS description
	FROM (
		SELECT stock_code, description, COUNT(*) AS freq
		FROM staging_online_retail
		WHERE description IS NOT NULL AND description != ''
		GROUP BY stock_code, description
	) AS s
JOIN (
	SELECT stock_code, MAX(freq) AS max_freq
		FROM (
			SELECT stock_code, description, COUNT(*) AS freq
            FROM staging_online_retail
            WHERE description IS NOT NULL AND description != ''
            GROUP BY stock_code, description
            ) AS t GROUP BY stock_code
	) AS m
ON s.stock_code = m.stock_code AND s.freq = m.max_freq
GROUP BY s.stock_code;

INSERT INTO Products (stock_code, description)
SELECT DISTINCT s.stock_code, NULL
FROM staging_online_retail s
LEFT JOIN Products p ON s.stock_code = p.stock_code
WHERE p.stock_code IS NULL;

ALTER TABLE Invoices
ADD COLUMN is_cancelled BOOLEAN NOT NULL DEFAULT FALSE;

INSERT INTO Invoices(invoice_no, invoice_date, customer_id, is_cancelled)
SELECT
	invoice,
	MAX(invoice_date) AS invoice_date,
    CASE
		WHEN MAX(NULLIF(customer_id, '')) IS NULL THEN NULL
        ELSE CAST(SUBSTRING_INDEX(MAX(NULLIF(customer_id, '')), '.', 1) AS UNSIGNED)
	END AS customer_id,
    CASE WHEN invoice LIKE 'C%' THEN TRUE ELSE FALSE END AS is_cancelled
FROM staging_online_retail
GROUP BY invoice;

INSERT INTO Invoice_Items (invoice_no, stock_code, quantity, unit_price)
SELECT DISTINCT
	invoice,
    stock_code,
    CAST(quantity AS SIGNED),
    CAST(price AS DECIMAL(10, 2))
FROM staging_online_retail;

SELECT
    (SELECT COUNT(*) FROM customers)      AS customer_rows,
    (SELECT COUNT(*) FROM products)       AS product_rows,
    (SELECT COUNT(*) FROM invoices)       AS invoice_rows,
    (SELECT COUNT(*) FROM invoice_items)  AS invoice_item_rows;
    
DELETE FROM Invoices WHERE invoice_no LIKE 'A%';
DELETE FROM Products WHERE stock_code = 'B';

SELECT COUNT(*) FROM invoices WHERE invoice_no LIKE 'A%';
SELECT COUNT(*) FROM invoice_items WHERE stock_code = 'B';
SELECT COUNT(*) FROM products WHERE stock_code = 'B';

SELECT
    (SELECT COUNT(*) FROM customers)      AS customer_rows,
    (SELECT COUNT(*) FROM products)       AS product_rows,
    (SELECT COUNT(*) FROM invoices)       AS invoice_rows,
    (SELECT COUNT(*) FROM invoice_items)  AS invoice_item_rows,
    (SELECT COUNT(*) FROM invoices WHERE invoice_no LIKE 'A%') AS leftover_bad_debt_invoices;