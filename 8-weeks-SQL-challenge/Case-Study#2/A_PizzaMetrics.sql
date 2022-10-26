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

-- 1. How many pizzas were ordered?
-- The customer_order table has 1 row to each pizza, to find how many pizzas where ordered we just need to count the number of rows
SELECT COUNT(*) nb_pizzas FROM customer_orders /*14*/

-- 2. How many unique customer orders were made?
-- Let's consider a unique customer order the combination of (pizza, extras and exclusions)
SELECT COUNT(*) AS unique_orders
FROM 
	(SELECT pizza_id,extras,exclusions 
	FROM customer_orders GROUP BY pizza_id,extras,exclusions) T

-- 3. How many successful orders were delivered by each runner?
SELECT runner_id, COUNT(order_id) order_runner
FROM runner_orders
WHERE cancellation IS NULL
GROUP BY runner_id;

-- 4. How many of each type of pizza was delivered?
SELECT pizza_id, COUNT(pizza_id) as delivered_pizzas 
FROM customer_orders c 
	JOIN runner_orders r
	ON c.order_id =r.order_id
WHERE cancellation IS NULL
GROUP BY pizza_id;

-- 5. How many Vegetarian and Meatlovers were ordered by each customer?
SELECT c.customer_id, n.pizza_name, c.ordered_customer
FROM ( SELECT customer_id, pizza_id,  COUNT(pizza_id) ordered_customer
	   FROM customer_orders 
	   GROUP BY customer_id, pizza_id) as c
	JOIN pizza_names n
	ON c.pizza_id = n.pizza_id
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
