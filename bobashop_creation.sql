-- ------------CODING KICKSTARTER PROJECT------------

/* My project will be centred around the database for an imaginary bubble tea (or boba) shop.
   The DB will feature tables that store information about the staff, customers and ingredients
   at the store */

-- --------------CREATING DATABASE--------------------
CREATE DATABASE bobashop;
USE bobashop;

-- create payroll table
CREATE TABLE payment(
	paycode VARCHAR(5) PRIMARY KEY,
    job_title VARCHAR(30),
    hourly_rate DEC(4,2),
    bonus_percent INT
);

-- create staff table
CREATE TABLE staff(
	staff_id VARCHAR(5) PRIMARY KEY,
    first_name VARCHAR(25) NOT NULL,
    last_name VARCHAR(25) NOT NULL,
    supervisor_id VARCHAR(5),
    paycode VARCHAR(5) NOT NULL,
    monthly_hours INT NOT NULL,
    overtime INT DEFAULT 0,
    bonus BOOLEAN DEFAULT 0,
    
    FOREIGN KEY (paycode) REFERENCES payment(paycode)
);

-- create staff history table
CREATE TABLE staff_history(
	log_id INT PRIMARY KEY AUTO_INCREMENT,
    log_date DATE,
    staff_id VARCHAR(5),
    paycode VARCHAR(5),
    monthly_hours INT,
    overtime INT,
    bonus BOOLEAN,
    
    FOREIGN KEY (staff_ID) REFERENCES staff(staff_id),
    FOREIGN KEY (paycode) REFERENCES payment(paycode)
);

-- create customers table
CREATE TABLE customers(
	customer_id VARCHAR(5) PRIMARY KEY,
    first_name VARCHAR(25),
    last_name VARCHAR(25) NOT NULL,
    email VARCHAR(100) NOT NULL,
    phone_number INT,
    loyaltea_points INT DEFAULT 0,
    favourite_tea_id VARCHAR(5),
    favourite_flavour_id VARCHAR(5),
    favourite_topping_id VARCHAR(5),
    
    FOREIGN KEY (favourite_tea_id) REFERENCES teas(tea_id),
    FOREIGN KEY (favourite_flavour_id) REFERENCES flavours(flavour_id),
    FOREIGN KEY (favourite_topping_id) REFERENCES toppings(topping_id)
);

-- create teas table
CREATE TABLE teas(
	tea_id VARCHAR(5) PRIMARY KEY,
    tea_name VARCHAR(20),
    in_stock BOOLEAN
);

-- create flavours table
CREATE TABLE flavours(
	flavour_id VARCHAR(5) PRIMARY KEY,
    flavour_name VARCHAR(15),
    in_stock BOOLEAN
);

-- create toppings table
CREATE TABLE toppings(
	topping_id VARCHAR(5) PRIMARY KEY,
    topping_name VARCHAR(20),
    category VARCHAR(20),
    in_stock BOOLEAN
);

-- create sales table
CREATE TABLE sales(
	sale_id INT PRIMARY KEY AUTO_INCREMENT,
    customer_id VARCHAR(5) NOT NULL,
    staff_id VARCHAR(5) NOT NULL,
    sale_date DATE,
    sale_time TIME,
    price DEC(3,2) NOT NULL,
    tea_id VARCHAR(5) NOT NULL,
    flavour_id VARCHAR(5) NOT NULL,
    topping1_id VARCHAR(5),
    topping2_id VARCHAR(5),
    
    FOREIGN KEY (staff_id) REFERENCES staff(staff_id),
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id),
    FOREIGN KEY (tea_id) REFERENCES teas(tea_id),
    FOREIGN KEY (flavour_id) REFERENCES flavours(flavour_id),
    FOREIGN KEY (topping1_id) REFERENCES toppings(topping_id),
    FOREIGN KEY (topping2_id) REFERENCES toppings(topping_id)
);

-- ------------------INSERTING DATA------------------

-- create payment and staff data
INSERT INTO payment VALUES
	('SM14', 'Store Manager', 14.00, 25),
    ('AM12', 'Assistant Manager', 12.40, 20),
    ('BB11', 'Bubble Barista', 11.10, 10);

INSERT INTO staff VALUES
	('S001', 'Geoffrey', 'Rootes', NULL, 'SM14', 140, 14, 0),
    ('S102', 'Joey', 'Cartwright', 'S001', 'AM12', 112, 21, 1),
    ('S103', 'Sienna', 'Siu', 'S001', 'AM12', 112, 28, 0),
    ('S104', 'Jennie', 'Mugg', 'S001', 'AM12', 112, 32, 0),
    ('S205', 'Phil', 'Delphi', 'S102', 'BB11', 56, 0, 0),
    ('S206', 'Aki', 'Mame', 'S102', 'BB11', 70, 7, 0),
    ('S207', 'Eoin', 'Conway', 'S103', 'BB11', 70, 21, 1),
    ('S208', 'Layla', 'Wells', 'S103', 'BB11', 56, 0, 0),
    ('S209', 'Aaron', 'Handsome', 'S104', 'BB11', 56, 7, 0),
    ('S210', 'Brad', 'Boetticher', 'S104', 'BB11', 56, 14, 0);

-- create ingredients data
INSERT INTO teas VALUES
	('T1', 'Assam', 0),
    ('T2', 'EnglishBreakfast', 1),
    ('T3', 'Green', 1),
    ('T4', 'Matcha', 1),
    ('T5', 'Oolong', 0);

INSERT INTO flavours VALUES
	('F01', 'MilkDairy', 1),
    ('F02', 'MilkSoy', 0),
    ('F03', 'BrownSugar', 1),
    ('F04', 'Honeydew', 1),
    ('F05', 'Lychee', 1),
    ('F06', 'Mango', 1),
    ('F07', 'Passionfruit', 0),
    ('F08', 'Peach', 1),
    ('F09', 'Strawberry', 0),
    ('F10', 'Taro', 1);

INSERT INTO toppings VALUES
	('P01', 'Tapioca', 'Trad', 1),
    ('P02', 'Salted Cheese', 'Trad', 1),
    ('P03', 'Pudding', 'Trad', 1),
    ('P04', 'Red Bean', 'Trad', 0),
    ('P05', 'Taro', 'Trad', 1),
    ('P06', 'Grass Jelly', 'Jelly', 1),
    ('P07', 'Apple', 'Jelly', 1),
    ('P08', 'Grape', 'Jelly', 1),
    ('P09', 'Kiwi', 'PoppingPearl', 0),
    ('P10', 'Lychee', 'PoppingPearl', 1),
    ('P11', 'Passionfruit', 'PoppingPearl', 1),
    ('P12', 'Pineapple', 'Jelly', 1),
    ('P13', 'Strawberry', 'Popping Pearl', 0),
    ('P14', 'Watermelon', 'Jelly', 1);
    
-- customer and sales data will be imported from randomly generated .csv files

-- IMPORTING CUSTOMER DATA --
/*  Importing into pre-made table only transferred 5/61 of the records.
	Importing into into a new table transferred all records. 
    Since the import was into a new table, we will have to use ALTER
    to set key constraints and more precise data types. */

-- setting datatypes
ALTER TABLE customers
	CHANGE customer_id customer_id VARCHAR(5) PRIMARY KEY,
	CHANGE favourite_tea_id favourite_tea_id VARCHAR(5),
	CHANGE favourite_flavour_id favourite_flavour_id VARCHAR(5),
	CHANGE favourite_topping_id favourite_topping_id VARCHAR(5);

-- setting foreign key constraints
ALTER TABLE customers
	ADD FOREIGN KEY (favourite_tea_id) REFERENCES teas(tea_id),
	ADD FOREIGN KEY (favourite_flavour_id) REFERENCES flavours(flavour_id),
	ADD FOREIGN KEY (favourite_topping_id) REFERENCES toppings(topping_id);

-- IMPORTING SALES DATA --
/*  Process was much smoother so no further alterations necessary at this time. */

-- CHECK TABLES --
SELECT * FROM staff;
SELECT * FROM payment;
SELECT * FROM staff_history;
SELECT * FROM teas;
SELECT * FROM flavours;
SELECT * FROM toppings;
SELECT * FROM customers;
SELECT * FROM sales;

SELECT first_name, last_name FROM customers WHERE favourite_tea_id = 'T2';

    
-- CLEAN UP --
DROP DATABASE bobashop;
DROP TABLE staff;
DROP TABLE staff_history;
DROP TABLE payment;
DROP TABLE customers;
DROP TABLE sales;
DROP TABLE teas;
DROP TABLE flavours;
DROP TABLE toppings;