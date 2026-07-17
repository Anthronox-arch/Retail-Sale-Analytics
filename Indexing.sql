EXPLAIN
SELECT invoice_no, invoice_date
FROM Invoices
WHERE invoice_date BETWEEN '2010-01-01' AND '2010-01-31';
-- MySQL goes through every row, even for just a fraction of demanded data. This is called a "Full Table Scan".

CREATE INDEX idx_invoice_date
ON Invoices (invoice_date);

EXPLAIN
SELECT invoice_no
FROM Invoices
WHERE invoice_date BETWEEN '2010-01-01'AND '2010-01-31';
-- After creating an index, MySQL onlywent through 1575 rows, instead of ~50,000 rows.
-- PRIMARY KEY also uses indexing. This is the reason a WHERE query using a PK is fast.

-- Composite indexing:
CREATE INDEX idx_invoices_customer_cancelled
ON Invoices (customer_id, is_cancelled);
-- Such a INDEX will work especially fast on a query using both: customer_id and is_cancelled.
	-- It will also work fast for queries using only customer_id, since it's the leading column.
    -- But it will not generally work on queries using only is_cancelled.
    
-- Why not create index on every column?
	-- Conusmes more storage (sorted copy + pointers)
    -- INSERT, UPDATE, DELETE are slower.