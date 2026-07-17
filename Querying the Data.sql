SELECT
	i.invoice_no,
    i.invoice_date,
    ii.stock_code,
    p.description,
    ii.quantity,
    ii.unit_price
FROM Invoices i
JOIN Invoice_Items ii ON i.invoice_no = ii.invoice_no
JOIN Products p ON ii.stock_code = p.stock_code
WHERE i.is_cancelled = FALSE
	AND ii.unit_price > 0
    AND p.description LIKE '%LIGHTS%'
ORDER BY unit_price DESC
LIMIT 10;

SELECT SUM(quantity * unit_price) AS total_revenue
FROM invoice_items
WHERE unit_price > 0;

SELECT Country, COUNT(*) AS cutomer_count
FROM Customers
GROUP BY country;

SELECT
	c.country,
    c.customer_id,
    i.invoice_no,
    i.invoice_date
FROM Customers c
INNER JOIN Invoices i ON c.customer_id = i.customer_id
LIMIT 5;

SELECT
	c.country,
    i.invoice_no,
    i.invoice_date,
    p.description,
    ii.quantity,
    ii.unit_price,
    (ii.quantity * ii.unit_price) AS line_total
FROM Customers c
JOIN Invoices i ON c.customer_id = i.customer_id
JOIN Invoice_Items ii ON i.invoice_no = ii.invoice_no
JOIN Products p ON p.stock_code = ii.stock_code
WHERE is_cancelled = False
ORDER BY line_total DESC
LIMIT 10;

SELECT invoice_no, stock_code, quantity, unit_price
FROM invoice_items
WHERE unit_price > (SELECT AVG(unit_price) FROM invoice_items)
LIMIT 10;

SELECT customer_id, country
FROM Customers
WHERE customer_id IN (
	SELECT i.customer_id
    FROM Invoices i
    JOIN Invoice_Items ii ON i.invoice_no = ii.invoice_no
    WHERE ii.stock_code = '85048')
Limit 5;

-- Goal: Compute average per voice, not per line-item.
SELECT AVG(quantity * unit_price) FROM Invoice_Items;
-- Wrong.

SELECT AVG(invoice_total) AS avg_invoice_total
FROM (
	SELECT i.invoice_no, SUM(ii.quantity * ii.unit_price) AS invoice_total
    FROM Invoices i
    JOIN Invoice_Items ii ON i.invoice_no = ii.invoice_no
    WHERE i.is_cancelled = False
    GROUP BY i.invoice_no) AS invoice_totals;
    
CREATE VIEW vw_sales_detail AS
	SELECT
		c.customer_id,
        c.country,
        i.invoice_no,
        i.invoice_date,
        i.is_cancelled,
        p.stock_code,
        p.description,
        ii.quantity,
        ii.unit_price,
        (ii.quantity * ii.unit_price) AS line_total
	FROM Customers c
    INNER JOIN Invoices i ON c.customer_id = i.customer_id
    INNER JOIN Invoice_Items ii ON ii.invoice_no = i.invoice_no
    INNER JOIN Products p ON p.stock_code = ii.stock_code;

CREATE VIEW vw_customer_lifetime_value AS
	SELECT
		c.customer_id,
        c.country,
        COUNT(DISTINCT i.invoice_no),
        SUM(ii.quantity * ii.unit_price) AS lifetime_revenue
	FROM Customers c
    JOIN Invoices i ON c.customer_id = i.customer_id
    JOIN Invoice_Items ii ON ii.invoice_no = i.invoice_no
    WHERE i.is_cancelled = FALSE AND unit_price > 0
    GROUP BY c.customer_id, c.country;

CREATE OR REPLACE VIEW vw_customer_lifetime_value AS
	SELECT
		c.customer_id,
        c.country,
        COUNT(DISTINCT i.invoice_no) AS total_orders,
        SUM(ii.quantity * ii.unit_price) AS lifetime_revenue
	FROM Customers c
    JOIN Invoices i ON c.customer_id = i.customer_id
    JOIN Invoice_Items ii ON ii.invoice_no = i.invoice_no
    WHERE i.is_cancelled = FALSE AND unit_price > 0
    GROUP BY c.customer_id, c.country;
    
SELECT *
FROM vw_customer_lifetime_value
ORDER BY lifetime_revenue DESC
LIMIT 10;
