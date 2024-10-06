-- ------------CODING KICKSTARTER PROJECT------------

-- -------------------DEMO QUERIES-------------------

USE bobashop;

-- VIEWS --
/*  I created 2 views:
		- one that shows customer information, but with names of favourite drink ingredients rather than ID
        numbers for readability;
        - one that shows staff information, but omits payment information for privacy and displays name of
		supervisor as opposed to ID number.
	Both of these were achieved using joins. */

SELECT * FROM vw_favourite_drinks;
SELECT * FROM vw_staff_common;

-- using the view to extract popularity of each flavour
SELECT
	favourite_flavour, COUNT(*) AS popularity
FROM
	vw_favourite_drinks
GROUP BY
	favourite_flavour
ORDER BY
	popularity DESC;

-- SUBQUERY --
/*  Suppose we want to send a promotional email advertising a discount on all matcha orders.
	We can use the customer and sales data to extract the email addresses of all customers who
    have ordered matcha or have it registered as their favourite tea. */

-- find ID of matcha
SELECT tea_id FROM teas WHERE tea_name = 'Matcha';

-- select details of relevant customers
SELECT
	customer_id, first_name, last_name, email
FROM
	customers c
WHERE customer_id IN (SELECT customer_id FROM sales WHERE tea_id = 'T4')
	  OR favourite_tea_id = 'T4';

-- AGGREGATE QUERY WITH GROUP BY AND HAVING --
/*  To monitor employee performance, we can extract the total amount of sales each staff member has made.
	In order to pick out the best of the bunch, we will use HAVING to filter for totals above a certain amount. */

SELECT
	sl.staff_id, first_name, last_name, SUM(price)
FROM
	sales sl
JOIN staff st
	ON sl.staff_id = st.staff_id
GROUP BY
	staff_id
HAVING
	SUM(price) > 250;

-- STORED FUNCTION --
/*  The function is_eligible_for_reward() determines whether a customer is eligible for a free or
	discounted drink based on thier number of loyaltea points. It will take number of points as
    the parameter. */

SELECT 
    customer_ID,
    first_name,
    last_name,
    IS_ELIGIBLE_FOR_REWARD(loyaltea_points) AS reward
FROM
    customers;
-- WHERE
	-- is_eligible_for_reward(loyaltea_points) = 'Free bubble tea!';

-- STORED PROCEDURE --
/*  The following procedure will create a new row in the sales table and increase the
	customer's number of loyaltea points by 1. It will take the customer id, staff id, tea id,
    flavour id, and topping ids as parameters. Sale_id, price and time will all be recorded
    automatically. */

SELECT * FROM sales WHERE sale_id > 590;
SELECT customer_id, loyaltea_points FROM customers WHERE customer_id = 'C23';

START TRANSACTION;

CALL new_sale('C23', 'S104', 'T1', 'F01', 'P01', NULL);
SELECT * FROM sales WHERE sale_id > 590;
SELECT customer_id, loyaltea_points FROM customers WHERE customer_id = 'C23';

ROLLBACK;
COMMIT;

-- TRIGGER & EVENT --
/*  My event will reset the overtime and bonus values of all staff records to 0.
	This will occur every month in theory but for the sake of the demo it will
    happen every 30 seconds. This works in tandem with a trigger that inserts
    a new row into the staff_history table, to log the old data. */
    
DELIMITER //
CREATE EVENT clear_all_overtime_and_bonus
ON SCHEDULE EVERY 30 SECOND
STARTS NOW() + INTERVAL 30 SECOND
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