CREATE DATABASE air_cargo;

ALTER TABLE routes
MODIFY flight_num INT NOT NULL;
ALTER TABLE routes
ADD PRIMARY KEY (route_id),
ADD CHECK (distance_miles > 0);
DESCRIBE routes;

SELECT customer.customer_id, customer.first_name, customer.last_name, customer.gender, passengers_on_flights.travel_date, passengers_on_flights.route_id
FROM customer
LEFT JOIN passengers_on_flights USING (customer_id)
WHERE route_id BETWEEN 01 AND 25;

SELECT COUNT(no_of_tickets) AS NO_OF_PASSENGERS, SUM(Price_per_ticket) AS TOTAL_REVENUE
FROM ticket_details
WHERE class_id = "BUSSINESS";

SELECT customer_id, first_name, last_name, CONCAT(first_name, ' ', last_name) AS Full_Name 
FROM customer;

SELECT DISTINCT 
customer.customer_id, customer.first_name, customer.last_name
FROM customer
INNER JOIN ticket_details USING (customer_id);

SELECT DISTINCT customer.customer_id, customer.first_name, customer.last_name, ticket_details.brand
FROM customer
INNER JOIN ticket_details USING (customer_id)
WHERE brand = 'Emirates';

SELECT customer.customer_id, customer.first_name, customer.last_name, ticket_details.class_id
FROM ticket_details
RIGHT JOIN customer USING (customer_id)
GROUP BY customer.customer_id, customer.first_name, customer.last_name, ticket_details.class_id
HAVING class_id = 'Economy Plus';

SELECT SUM(Price_per_ticket * no_of_tickets) AS TOTAL_REVENUE,
IF(SUM(Price_per_ticket * no_of_tickets) > 10000, 'REVENUE TARGET MET', 'REVENUE TARGET NOT MET') AS TARGET_STATUS
FROM ticket_details;

CREATE USER 'new_user'@'localhost' IDENTIFIED BY 'password';
GRANT ALL PRIVILEGES ON database_name.* TO 'new_user'@'localhost';

SELECT DISTINCT class_id, MAX(price_per_ticket) OVER(partition by class_id) AS MAX_FARE_CLASS
FROM ticket_details;

CREATE INDEX idx_route_id ON passengers_on_flights(route_id);
SELECT * FROM passengers_on_flights
WHERE route_id = '4';

EXPLAIN SELECT * FROM passengers_on_flights
WHERE route_id = '4';

SELECT customer_id, aircraft_id, SUM(Price_per_ticket) AS Total_Sales
FROM ticket_details
GROUP BY customer_id, aircraft_id WITH ROLLUP;

CREATE VIEW BUS_VIEW AS
SELECT customer.customer_id, customer.first_name, customer.last_name, ticket_details.brand
FROM customer INNER JOIN ticket_details USING (customer_id)
WHERE class_id = 'Bussiness';

SELECT * FROM BUS_VIEW;

DELIMITER &%
CREATE PROCEDURE PASSENGER_DETAILS_BY_ROUTES (start_route INT, end_route INT)
BEGIN
	DECLARE table_exists INT;
	SELECT COUNT(*) INTO table_exists
	FROM information_schema.tables
	WHERE table_name = 'passengers_on_flights';

	IF table_exists > 0 THEN
	SELECT customer.customer_id, customer.first_name, customer.last_name, customer.gender, passengers_on_flights.class_id, passengers_on_flights.travel_date
	FROM customer INNER JOIN passengers_on_flights USING (customer_id)
	WHERE passengers_on_flights.route_id BETWEEN start_route AND end_route;

	ELSE 
	SELECT 'Error: The specified table does not exist' AS ErrorMessage;
	END IF;
END &%

CALL PASSENGER_DETAILS_BY_ROUTES (1 , 10);

DELIMITER %^
CREATE PROCEDURE GetRoutesInfor()
BEGIN
SELECT * FROM routes
WHERE distance_miles > 2000
ORDER BY distance_miles DESC;
END %^

CALL GetRoutesInfor();

DELIMITER &^
CREATE PROCEDURE FlightsCategory ()
BEGIN
SELECT * ,
	CASE
		WHEN distance_miles >=0 AND distance_miles <=2000 THEN 'SHORT DISTANCE TRAVEL'
		WHEN distance_miles > 2000 AND distance_miles <=6500 THEN 'INTERMEDIATE DISTANCE TRAVEL'
		ELSE 'LONG DISTANCE TRAVEL' 
	END AS FLIGHT_CATEGORY
	FROM routes;
END &^

CALL FlightsCategory ();

DELIMITER ^^
CREATE FUNCTION GetComplServices(class_id VARCHAR(25))
RETURNS VARCHAR (3) DETERMINISTIC 
BEGIN
	DECLARE result VARCHAR(3);
    IF class_id IN ('Bussiness', 'Economy Plus') THEN
    SET result = 'Yes';
    ELSE 
    SET result = 'No';
    END IF;
    
    RETURN result;
END ^^

DELIMITER ^!
CREATE PROCEDURE GetTicketsDetails ()
BEGIN
SELECT p_date, customer_id, class_id, GetCompServices(class_id) AS Complimentary_Services
FROM ticket_details;
END ^!

CALL GetTicketsDetails ();


DELIMITER $^
CREATE PROCEDURE GetCustomeScott()
BEGIN
DECLARE done INT DEFAULT FALSE;
DECLARE customer_id INT;
DECLARE first_name VARCHAR(255);
DECLARE last_name VARCHAR(255);
    
DECLARE custom_cursor CURSOR FOR
	SELECT customer_id, first_name, last_name
	FROM customer
	WHERE last_name LIKE '%Scott'
    ORDER BY customer_id
	LIMIT 1;
    
DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

OPEN custom_cursor;
FETCH custom_cursor INTO customer_id, first_name, last_name;
SELECT customer_id, first_name, last_name;
CLOSE custom_cursor;

END $^
CALL GetCustomeScott();


    
   








    