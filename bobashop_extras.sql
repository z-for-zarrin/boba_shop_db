-- ------------CODING KICKSTARTER PROJECT------------

-- ----------DATA RETRIEVAL & MANIPULATION----------

/*  This script contains the code for the views, functions, procedures etc that will be used to manage the
	databse as well as retirieve and manipulate data for analysis. */

-- VIEWS --
/*  I will create 2 views:
		- one that shows customer information, but with names of favourite drink ingredients rather than ID
        numbers for readability;
        - one that shows staff information, but omits payment information for privacy and displays name of
		supervisor as opposed to ID number.
	Both of these will be achieved using joins. */

-- create customer view
USE bobashop;

CREATE VIEW vw_favourite_drinks AS
SELECT
	customer_id,
    first_name,
    last_name,
    tea_name AS favourite_tea,
    flavour_name AS favourite_flavour,
    topping_name AS favourite_topping
FROM
	customers c
		LEFT JOIN
	teas t ON c.favourite_tea_id = t.tea_id
		LEFT JOIN
	flavours f ON c.favourite_flavour_id = f.flavour_id
		LEFT JOIN
	toppings p ON c.favourite_topping_id = p.topping_id;
    
SELECT * FROM vw_favourite_drinks;

-- test queries

SELECT
	first_name, last_name
FROM
	vw_favourite_drinks
WHERE
	favourite_tea = 'Green';

SELECT
	favourite_flavour, COUNT(*) AS popularity
FROM
	vw_favourite_drinks
GROUP BY
	favourite_flavour
ORDER BY
	popularity DESC; -- example query for presentation
    
-- create staff view

CREATE VIEW vw_staff_common AS
SELECT
	s1.staff_id,
	s1.first_name,
    s1.last_name,
    IFNULL (CONCAT(s2.first_name,' ',s2.last_name), 'N/A') AS supervisor
FROM
	staff s1
		LEFT JOIN
	staff s2 ON s2.staff_id = s1.supervisor_id;

SELECT * FROM vw_staff_common;

-- FUNCTION --
/*  My function will determine whether a customer is eligible for a free or discounted drink
	based on thier number of loyaltea points. It will take number of points as the parameter. */
    
DELIMITER //
CREATE FUNCTION is_eligible_for_reward(points INT)
RETURNS VARCHAR(20)
DETERMINISTIC
BEGIN
	DECLARE reward VARCHAR(20);
    IF points >=10 THEN
		SET reward = 'Free bubble tea!';
	ELSEIF (points >= 5 AND
			points < 10) THEN
		SET reward = '25% discount';
	ELSE
		SET reward = 'No reward';
	END IF;
    RETURN (reward);
END//
DELIMITER ;

-- CLEAN UP --
DROP FUNCTION is_eligible_for_reward;

-- test query

SELECT
	customer_ID,
	first_name,
    last_name,
	is_eligible_for_reward(loyaltea_points) AS reward
FROM
	customers
WHERE
	is_eligible_for_reward(loyaltea_points) = 'Free bubble tea!';
    
-- PROCEDURE --
/*  The following procedure will create a new row in the sales table and increase the
	customer's number of loyaltea points by 1. It will take the customer id, staff id, tea id,
    flavour id, and topping ids as parameters. Sale_id, price and time will all be recorded
    automatically. */
    
DELIMITER //
CREATE PROCEDURE new_sale(c_id VARCHAR(5), s_id VARCHAR(5), t_id VARCHAR(5),
f_id VARCHAR(5), p1_id VARCHAR(5), p2_id VARCHAR(5))
BEGIN
	DECLARE price DEC(3,2);
	IF (p1_id IS NULL AND p2_id IS NOT NULL) THEN
		SELECT CONCAT('Invalid order!') AS new_sale_error;
	ELSEIF (p1_id IS NULL AND p2_id IS NULL) THEN
		SET price = 3.5;
        INSERT INTO sales(customer_id, staff_id, sale_date, sale_time, price,
        tea_id, flavour_id) VALUES
			(c_id, s_id, CURDATE(), CURTIME(), price, t_id, f_id);
		UPDATE customers SET loyaltea_points = loyaltea_points + 1 WHERE customer_id = c_id;
	ELSEIF (p1_id IS NOT NULL AND p2_id IS NULL) THEN
		SET price = 4;
        INSERT INTO sales(customer_id, staff_id, sale_date, sale_time, price,
        tea_id, flavour_id, topping1_id) VALUES
			(c_id, s_id, CURDATE(), CURTIME(), price, t_id, f_id, p1_id);
		UPDATE customers SET loyaltea_points = loyaltea_points + 1 WHERE customer_id = c_id;
	ELSEIF (p1_id IS NOT NULL AND p2_id IS NOT NULL) THEN
		SET price = 4.5;
        INSERT INTO sales(customer_id, staff_id, sale_date, sale_time, price,
        tea_id, flavour_id, topping1_id, topping2_id) VALUES
			(c_id, s_id, CURDATE(), CURTIME(), price, t_id, f_id, p1_id, p2_id);
		UPDATE customers SET loyaltea_points = loyaltea_points + 1 WHERE customer_id = c_id;
	END IF;
END//
DELIMITER ;

-- test query
START TRANSACTION;

CALL new_sale('C23', 'S104', 'T1', 'F01', 'P01', NULL);
SELECT * FROM sales WHERE sale_id > 590;
SELECT customer_id, loyaltea_points FROM customers WHERE customer_id = 'C23';

ROLLBACK;
COMMIT;

-- CLEAN UP --
DROP PROCEDURE new_sale;

-- TRIGGER --
/*  This trigger will make use of the staff_history table by backing up old records
	whenever an update is made to the staff table. */

DELIMITER //
CREATE TRIGGER staff_backup
BEFORE UPDATE ON staff
FOR EACH ROW
BEGIN
	INSERT INTO staff_history(log_date, staff_id, paycode, monthly_hours, overtime, bonus) VALUES
		(CURDATE(), OLD.staff_id, OLD.paycode, OLD.monthly_hours, OLD.overtime, OLD.bonus);
END//
DELIMITER ;

UPDATE staff
SET
	staff.overtime = 8
WHERE
	staff.staff_id = 'S206';

SELECT * FROM staff_history;

-- EVENT --
/*  My event will reset the overtime and bonus values of all staff records to 0.
	This will occur every month in theory but for the sake of the demo it will
    happen every 30 seconds. */

DELIMITER //
CREATE EVENT clear_all_overtime_and_bonus
ON SCHEDULE EVERY 1 MONTH
STARTS 2023-12-06
DO BEGIN
	UPDATE staff
	SET
		staff.overtime = 0;
	UPDATE staff
	SET
		staff.bonus = 0;
END//
DELIMITER ;

SELECT * FROM staff;
SELECT * FROM staff_history;
DROP EVENT clear_all_overtime_and_bonus;

-- Resetting data after test
UPDATE staff
SET
	staff.bonus = 1
WHERE
	staff_id IN ('S102', 'S207');

UPDATE staff
SET staff.overtime = 7
WHERE staff_id IN ('S206', 'S209');

UPDATE staff
SET staff.overtime = 14
WHERE staff_id IN ('S001', 'S210');

UPDATE staff
SET staff.overtime = 21
WHERE staff_id IN ('S102', 'S209');

UPDATE staff
SET staff.overtime = 28
WHERE staff_id = 'S103';

UPDATE staff
SET staff.overtime = 32
WHERE staff_id = 'S104';