USE pizza_runner


SELECT * FROM runners;
SELECT* FROM runner_orders;
SELECT * FROM customer_orders;
SELECT * FROM pizza_names;
SELECT * FROM pizza_toppings;
SELECT * FROM pizza_recipes;

-- CLEANING DATA
-- 1. Runner Order Table
--- runner_order table has 2 main problems some  null values and data with wrong data type (distance and duration)
SELECT* FROM runner_orders;
--- cleaning all null values 
UPDATE runner_orders 
SET pickup_time = null, 
	distance = 0,
	duration = 0
	WHERE cancellation LIKE '%cancel%'
UPDATE runner_orders 
SET cancellation = NULL WHERE cancellation IN ('',' ','null');
select * from runner_orders
-- Distance and duration are numerical data but there is units mixed between the data
-- Remove km from all  distance observations and create a new column
ALTER TABLE runner_orders 
ADD distance_km float  NULL,
 duration_min int NULL;
UPDATE runner_orders SET  distance_km = CAST(REPLACE(distance,'km','') AS FLOAT)
select cast(duration as int) from runner_orders

SELECT substring(duration,1,PATINDEX('%[^0-9]%',duration )-1) from runner_orders
