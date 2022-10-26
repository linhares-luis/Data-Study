USE pizza_runner;


SELECT * FROM runners;
SELECT* FROM runner_orders;
SELECT * FROM customer_orders;
SELECT * FROM pizza_names;
SELECT * FROM pizza_toppings;
SELECT * FROM pizza_recipes;

-- CLEANING DATA
-- 1. Null and 0 values
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
UPDATE customer_orders SET exclusions=0  WHERE exclusions in  ('',' ','null');
UPDATE customer_orders SET extras=0  WHERE extras in  ('',' ','null');
select * from runner_orders

-- 2. Runnner orders Distance and duration
/*solution 1*/

-- Distance and duration are numerical data but there is units mixed between the data
-- Remove km from all  distance observations and create a new column
--ALTER TABLE runner_orders 
--ADD distance_km float  NULL,
 --duration_min int NULL;
--UPDATE runner_orders SET  distance_km = CAST(REPLACE(distance,'km','') AS FLOAT)
--select cast(duration as int) from runner_orders
--SELECT substring(duration,1,2) from runner_orders

-- Solution 2
DROP FUNCTION IF EXISTS dbo.udf_get_numbers;
go
CREATE FUNCTION udf_get_numbers(@str VARCHAR(20))
RETURNS float
BEGIN
	DECLARE @notNbCharIndex INT;
	SET @notNbCharIndex  = PATINDEX('%[^0-9.]%',@str)-1;
	IF @notNbCharIndex > 0 
		SET @str = substring(@str,1,@notNbCharIndex)
	return CAST(@str AS FLOAT);
END;
go
UPDATE runner_orders SET duration = dbo.udf_get_numbers(duration);
UPDATE runner_orders SET distance = dbo.udf_get_numbers(distance);
SELECT * FROM runner_orders
