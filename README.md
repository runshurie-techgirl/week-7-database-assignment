# Week 7: Database Design and Normalization

This project shows how to clean up a database
design using normalization. It covers First
Normal Form (1NF) and Second Normal Form (2NF).

All the SQL is in one file: `answer.sql`.

---

## Table of Contents

1. What is in this repository
2. How to run the code
3. What is normalization?
4. Database setup
5. Question 1: First Normal Form (1NF)
6. Question 2: Second Normal Form (2NF)
7. Final tables at a glance
8. Reflection

---

## 1. What is in this repository

| File | Purpose |
|------|---------|
| `answer.sql` | SQL for Questions 1 and 2 |
| `README.md` | Explains the work and the code |

---

## 2. How to run the code

1. Open MySQL Workbench and connect to
   your local server.
2. Open `answer.sql` in a new SQL tab.
3. Run the whole script (lightning bolt
   icon or Ctrl + Shift + Enter).
4. Check the result tabs at the bottom.

Expected output:

- `ProductDetail_1NF` has 6 rows.
- `Orders` has 3 rows.
- `OrderItems` has 6 rows.
- The final join shows 6 rows.

"0 rows affected" for CREATE and DROP
statements is normal. They change the
structure, not the rows.

---

## 3. What is normalization?

Normalization is organizing data into
tables so that:

- the same fact is not stored many times
  (less redundancy);
- updates, inserts and deletes do not
  cause errors (better integrity).

Think of a shop receipt book. If you write
the customer's full details on every line,
one spelling mistake creates two "different"
customers. It is better to write the
customer once and point to it.

Normal forms used in this assignment:

| Form | Rule |
|------|------|
| 1NF | Every cell holds one value. No repeating groups. |
| 2NF | Already 1NF, and no partial dependencies. |

A partial dependency happens when a column
depends on only part of a composite key.

---

## 4. Database setup

```sql
CREATE DATABASE IF NOT EXISTS
    week7_normalization;
USE week7_normalization;

DROP TABLE IF EXISTS OrderItems;
DROP TABLE IF EXISTS Orders;
DROP TABLE IF EXISTS ProductDetail_1NF;
```

What each part does:

- `CREATE DATABASE IF NOT EXISTS` makes a
  new database, only if it is missing.
- `USE` selects it, so every table below
  is created inside it.
- `DROP TABLE IF EXISTS` removes old copies
  so the script can be run many times.
- Child tables are dropped first. A table
  with a foreign key cannot outlive the
  table it points to.

A separate database was used so these
tables do not clash with other databases,
such as the sales database.

---

## 5. Question 1: First Normal Form (1NF)

### The problem

The original `ProductDetail` table:

| OrderID | CustomerName | Products |
|---------|--------------|----------|
| 101 | John Doe | Laptop, Mouse |
| 102 | Jane Smith | Tablet, Keyboard, Mouse |
| 103 | Emily Clark | Phone |

The `Products` column holds many values in
one cell. This breaks 1NF. It is hard to
search, count or update one product.

### The fix

Give each product its own row.

```sql
CREATE TABLE ProductDetail_1NF (
    OrderID      INT          NOT NULL,
    CustomerName VARCHAR(100) NOT NULL,
    Product      VARCHAR(100) NOT NULL,
    PRIMARY KEY (OrderID, Product)
);
```

Explanation:

- `OrderID` is a whole number.
- `CustomerName` and `Product` are text
  of up to 100 characters.
- `NOT NULL` means a value is required.
- `OrderID` now repeats (101 appears twice),
  so it cannot be the key alone.
- The primary key is the pair
  `(OrderID, Product)`. Each pair is unique.

### Inserting the data

```sql
INSERT INTO ProductDetail_1NF
    (OrderID, CustomerName, Product)
VALUES
(101, 'John Doe',    'Laptop'),
(101, 'John Doe',    'Mouse'),
(102, 'Jane Smith',  'Tablet'),
(102, 'Jane Smith',  'Keyboard'),
(102, 'Jane Smith',  'Mouse'),
(103, 'Emily Clark', 'Phone');

SELECT * FROM ProductDetail_1NF;
```

The three original rows became six rows.
The `SELECT` shows the result.

### Result

| OrderID | CustomerName | Product |
|---------|--------------|---------|
| 101 | John Doe | Laptop |
| 101 | John Doe | Mouse |
| 102 | Jane Smith | Tablet |
| 102 | Jane Smith | Keyboard |
| 102 | Jane Smith | Mouse |
| 103 | Emily Clark | Phone |

Every cell now holds a single value, so
the table is in 1NF.

Note: the customer name is still repeated.
That is expected at this stage. Question 2
fixes it.

---

## 6. Question 2: Second Normal Form (2NF)

### The problem

The `OrderDetails` table is in 1NF:

| OrderID | CustomerName | Product | Quantity |
|---------|--------------|---------|----------|
| 101 | John Doe | Laptop | 2 |
| 101 | John Doe | Mouse | 1 |
| 102 | Jane Smith | Tablet | 3 |
| 102 | Jane Smith | Keyboard | 1 |
| 102 | Jane Smith | Mouse | 2 |
| 103 | Emily Clark | Phone | 1 |

The primary key is `(OrderID, Product)`.

### Identifying the partial dependency

- `Quantity` depends on the whole key. You
  need both the order and the product.
- `CustomerName` depends on `OrderID` only.
  The product does not change who ordered.

```
OrderID -> CustomerName
```

This is a partial dependency, so the table
breaks 2NF. It also causes repeated names
(John Doe is stored twice).

### The fix: split into two tables

| Table | Holds |
|-------|-------|
| `Orders` | Facts about the order |
| `OrderItems` | Products and quantities |

### Table 1: Orders

```sql
CREATE TABLE Orders (
    OrderID      INT          NOT NULL,
    CustomerName VARCHAR(100) NOT NULL,
    PRIMARY KEY (OrderID)
);
```

- One row per order.
- `OrderID` alone is the primary key.
- The customer name is stored once per order.

### Table 2: OrderItems

```sql
CREATE TABLE OrderItems (
    OrderID  INT          NOT NULL,
    Product  VARCHAR(100) NOT NULL,
    Quantity INT          NOT NULL,
    PRIMARY KEY (OrderID, Product),
    FOREIGN KEY (OrderID)
        REFERENCES Orders (OrderID)
);
```

- One row per product in an order.
- The composite primary key is
  `(OrderID, Product)`.
- `OrderID` is also a foreign key. It must
  match an existing order in `Orders`.
- `Quantity` depends on the full key.

### Inserting the data

Parent table first:

```sql
INSERT INTO Orders (OrderID, CustomerName)
VALUES
(101, 'John Doe'),
(102, 'Jane Smith'),
(103, 'Emily Clark');
```

Then the child table:

```sql
INSERT INTO OrderItems
    (OrderID, Product, Quantity)
VALUES
(101, 'Laptop',   2),
(101, 'Mouse',    1),
(102, 'Tablet',   3),
(102, 'Keyboard', 1),
(102, 'Mouse',    2),
(103, 'Phone',    1);
```

The order matters. The foreign key rule
stops you from adding an item for an order
that does not exist yet.

### Checking the result

```sql
SELECT * FROM Orders;
SELECT * FROM OrderItems;

SELECT o.OrderID, o.CustomerName,
       i.Product, i.Quantity
FROM Orders o
JOIN OrderItems i
    ON o.OrderID = i.OrderID;
```

- The first two queries show each table.
- The `JOIN` rebuilds the original
  `OrderDetails` view. It proves that no
  information was lost.

---

## 7. Final tables at a glance

```
Orders                OrderItems
------                ----------
OrderID (PK)  <----   OrderID (PK, FK)
CustomerName          Product (PK)
                      Quantity
```

One order can have many items. This is a
one-to-many relationship.

---

## 8. Reflection

This assignment helped me see that a table
can work and still be badly designed.

At first, the `Products` column looked fine
to me. Then I thought about searching for
every order that includes a Mouse. With
"Laptop, Mouse" in one cell, that is hard.
One product per row makes it simple.

The 2NF step was harder. I had to ask for
each column: does it depend on the whole
key or only on part of it? Once I saw that
`CustomerName` depends only on `OrderID`,
splitting the table made sense. A customer
name is now stored once, so fixing a
spelling mistake means changing one row.

I also learned practical SQL habits:

- insert into the parent table first;
- drop child tables before parent tables;
- use `DROP TABLE IF EXISTS` so the script
  can run again without errors.

My main lesson: good design saves time
later. A few minutes of planning tables
can prevent many data errors in a real
business system.
