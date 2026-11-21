/* =====================================================
   Week 7 Assignment: Database Design and Normalization
   ===================================================== */

CREATE DATABASE IF NOT EXISTS week7_normalization;
USE week7_normalization;

DROP TABLE IF EXISTS OrderItems;
DROP TABLE IF EXISTS Orders;
DROP TABLE IF EXISTS ProductDetail_1NF;


/* =====================================================
   QUESTION 1: Achieving First Normal Form (1NF)
   =====================================================
   Problem: the Products column held several values in one
   cell (e.g. "Laptop, Mouse"). 1NF needs one value per cell.

   Fix: one product per row. The primary key becomes
   (OrderID, Product) because OrderID now repeats.
*/

CREATE TABLE ProductDetail_1NF (
    OrderID      INT          NOT NULL,
    CustomerName VARCHAR(100) NOT NULL,
    Product      VARCHAR(100) NOT NULL,
    PRIMARY KEY (OrderID, Product)
);

INSERT INTO ProductDetail_1NF (OrderID, CustomerName, Product) VALUES
(101, 'John Doe',    'Laptop'),
(101, 'John Doe',    'Mouse'),
(102, 'Jane Smith',  'Tablet'),
(102, 'Jane Smith',  'Keyboard'),
(102, 'Jane Smith',  'Mouse'),
(103, 'Emily Clark', 'Phone');

SELECT * FROM ProductDetail_1NF;


/* =====================================================
   QUESTION 2: Achieving Second Normal Form (2NF)
   =====================================================
   Partial dependency: the key is (OrderID, Product), but
   CustomerName depends only on OrderID.
      OrderID -> CustomerName

   Fix: split into two tables.
   - Orders     : facts about the order (OrderID, CustomerName)
   - OrderItems : products and quantities for each order
*/

CREATE TABLE Orders (
    OrderID      INT          NOT NULL,
    CustomerName VARCHAR(100) NOT NULL,
    PRIMARY KEY (OrderID)
);

CREATE TABLE OrderItems (
    OrderID  INT          NOT NULL,
    Product  VARCHAR(100) NOT NULL,
    Quantity INT          NOT NULL,
    PRIMARY KEY (OrderID, Product),
    FOREIGN KEY (OrderID) REFERENCES Orders (OrderID)
);

/* Parent table first */
INSERT INTO Orders (OrderID, CustomerName) VALUES
(101, 'John Doe'),
(102, 'Jane Smith'),
(103, 'Emily Clark');

/* Then the child table */
INSERT INTO OrderItems (OrderID, Product, Quantity) VALUES
(101, 'Laptop',   2),
(101, 'Mouse',    1),
(102, 'Tablet',   3),
(102, 'Keyboard', 1),
(102, 'Mouse',    2),
(103, 'Phone',    1);

SELECT * FROM Orders;
SELECT * FROM OrderItems;

/* Join the tables to rebuild the original OrderDetails */
SELECT o.OrderID, o.CustomerName, i.Product, i.Quantity
FROM Orders o
JOIN OrderItems i ON o.OrderID = i.OrderID;