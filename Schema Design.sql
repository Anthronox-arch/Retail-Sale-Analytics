CREATE DATABASE IF NOT EXISTS retail_sale_analytics
CHARACTER SET utf8mb4
COLLATE utf8mb4_general_ci;

USE retail_sale_analytics;

CREATE TABLE Customers (
	customer_id INT NOT NULL,
    country varchar(50) NOT NULL
);


CREATE TABLE Products (
	stock_code VARCHAR(20) NOT NULL,
    description VARCHAR(225)
);

CREATE TABLE Invoices (
	invoice_no INT NOT NULL,
	invoice_date DATETIME NOT NULL,
	customer_id INT
);

ALTER TABLE Invoices
MODIFY invoice_no VARCHAR(10) NOT NULL;

CREATE TABLE Invoice_Items (
	item_id INT NOT NULL,
    invoice_no VARCHAR(10) NOT NULL,
    stock_code VARCHAR(20) NOT NULL,
    quantity INT NOT NULL,
    unit_price DECIMAL(10, 2) NOT NULL
);
ALTER TABLE Invoice_Items
MODIFY invoice_no VARCHAR(10) NOT NULL;

ALTER TABLE Customers
ADD PRIMARY KEY (customer_id);

ALTER TABLE Products
ADD PRIMARY KEY (stock_code);

ALTER TABLE Invoices
ADD PRIMARY KEY (invoice_no);

ALTER TABLE Invoice_Items
MODIFY item_id INT NOT NULL AUTO_INCREMENT,
ADD PRIMARY KEY (item_id);

DESCRIBE Invoice_Items;

ALTER TABLE Invoices
ADD CONSTRAINT fk_invoices_customer
FOREIGN KEY (customer_id) REFERENCES Customers(customer_id);

ALTER TABLE Invoice_Items
ADD CONSTRAINT fk_invoiceitems_invoice
FOREIGN KEY (invoice_no) REFERENCES Invoices(invoice_no);

ALTER TABLE Invoice_Items
ADD CONSTRAINT fk_invoiceitems_product
FOREIGN KEY (stock_code) REFERENCES Products(stock_code);

ALTER TABLE Invoices DROP FOREIGN KEY fk_invoices_customer;
ALTER TABLE Invoice_Items DROP FOREIGN KEY fk_invoiceitems_invoice;
ALTER TABLE Invoice_Items DROP FOREIGN KEY fk_invoiceitems_product;

ALTER TABLE Invoices
ADD CONSTRAINT fk_invoices_customer
FOREIGN KEY (customer_id) REFERENCES Customers (customer_id)
ON DELETE RESTRICT
ON UPDATE CASCADE;

ALTER TABLE Invoice_Items
ADD CONSTRAINT fk_invoiceitems_invoice
FOREIGN KEY (invoice_no) REFERENCES Invoices (invoice_no)
ON DELETE CASCADE
ON UPDATE CASCADE;

ALTER TABLE Invoice_Items
ADD CONSTRAINT fk_invoiceitems_products
FOREIGN KEY (stock_code) REFERENCES Products (stock_code)
ON DELETE RESTRICT
ON UPDATE CASCADE;

