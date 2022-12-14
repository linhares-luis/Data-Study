/*
A. Pizza Metrics
1. How many pizzas were ordered?
2. How many unique customer orders were made?
3. How many successful orders were delivered by each runner?
4. How many of each type of pizza was delivered?
5. How many Vegetarian and Meatlovers were ordered by each customer?
6. What was the maximum number of pizzas delivered in a single order?
7. For each customer, how many delivered pizzas had at least 1 change and how many had no changes?
8. How many pizzas were delivered that had both exclusions and extras?
9. What was the total volume of pizzas ordered for each hour of the day?
10. What was the volume of orders for each day of the week?
*/

USE pizza_runner
GO
-- 1. How many pizzas were ordered?
-- The customer_order table has 1 row to each pizza, to find how many pizzas where ordered we just need to count the number of rows
SELECT COUNT(*) nb_pizzas FROM customer_orders /*14*/
GO
-- 2. How many unique customer orders were made?
-- Let's consider a unique customer order the combination of (pizza, extras and exclusions)
SELECT COUNT(*) AS unique_orders
FROM 
	(SELECT pizza_id,extras,exclusions 
	FROM customer_orders GROUP BY pizza_id,extras,exclusions) T

-- 3. How many successful orders were delivered by each runner?
SELECT runner_id, COUNT(order_id) delivered_order
FROM runner_orders
WHERE cancellation IS NULL
GROUP BY runner_id;

-- 4. How many of each type of pizza was delivered?
WITH pizzas_delivered (pizza_id, delivered_pizzas) as
(
	SELECT pizza_id, COUNT(pizza_id) as delivered_pizzas 
	FROM customer_orders c 
		JOIN runner_orders r
		ON c.order_id =r.order_id
	WHERE cancellation IS NULL
	GROUP BY pizza_id
)
SELECT p.pizza_name, d.delivered_pizzas
FROM pizzas_delivered d
	JOIN pizza_names p
	ON d.pizza_id = p.pizza_id

-- 5. How many Vegetarian and Meatlovers were ordered by each customer?
SELECT c.customer_id, 
	CAST(p.pizza_name AS VARCHAR(10)) pizza_name, 
	COUNT(c.pizza_id) amt_ordered
FROM customer_orders c
	JOIN pizza_names p
	ON c.pizza_id = p.pizza_id
GROUP BY c.customer_id, CAST(p.pizza_name AS VARCHAR(10))
ORDER BY c.customer_id



-- 6. What was the maximum number of pizzas delivered in a single order?
SELECT TOP 1 C.order_id, COUNT(c.order_id) pizza_in_order
FROM customer_orders c 
	JOIN runner_orders r
	ON c.order_id = r.order_id 
WHERE cancellation IS NULL
GROUP BY c.order_id
ORDER BY COUNT(c.order_id) DESC

-- 7. For each customer, how many delivered pizzas had at least 1 change and how many had no changes?
WITH delivered_order (customer_id, order_id, extras, exclusions, changed) AS (
SELECT c.customer_id, c.order_id, c.extras, c.exclusions, 
changed = CASE
	WHEN (c.extras IS NOT NULL) or (c.exclusions IS NOT NULL) THEN 1
	ELSE 0
	END
FROM customer_orders c 
	JOIN runner_orders r
	ON c.order_id = r.order_id 
WHERE cancellation IS NULL
)
SELECT customer_id, SUM(changed) pizza_w_change, (COUNT(customer_id) - SUM(changed)) no_change_orders
FROM delivered_order
GROUP BY customer_id;
go
-- 8. How many pizzas were delivered that had both exclusions and extras?
WITH delivered_order (customer_id, order_id, extras, exclusions, changed) AS (
SELECT c.customer_id, c.order_id, c.extras, c.exclusions, 
changed = CASE
	WHEN (c.extras IS NOT NULL) and (c.exclusions IS NOT NULL) THEN 1
	ELSE 0
	END
FROM customer_orders c 
	JOIN runner_orders r
	ON c.order_id = r.order_id 
WHERE cancellation IS NULL
)
SELECT SUM(changed) pizz_both_change
FROM delivered_order



-- 9. What was the total volume of pizzas ordered for each hour of the day?
SELECT DATENAME(hour, order_time) hour_day, COUNT(*) amt_pizzas 
FROM customer_orders
GROUP BY DATENAME(hour, order_time)

-- 10. What was the volume of orders for each day of the week?
SELECT DATENAME(WEEKDAY, order_time) week_day, COUNT(*) amt_pizzas 
FROM customer_orders
GROUP BY DATENAME(WEEKDAY, order_time)
