/*
B. Runner and Customer Experience
1. How many runners signed up for each 1 week period? (i.e. week starts 2021-01-01)
2. What was the average time in minutes it took for each runner to arrive at the Pizza Runner HQ to pickup the order?
3. Is there any relationship between the number of pizzas and how long the order takes to prepare?
4. What was the average distance travelled for each customer?
5. What was the difference between the longest and shortest delivery times for all orders?
6. What was the average speed for each runner for each delivery and do you notice any trend for these values?
7. What is the successful delivery percentage for each runner?
*/

USE pizza_runner;
GO


-- 1. How many runners signed up for each 1 week period? (i.e. week starts 2021-01-01)
-- To solve this question I broke the problem into 2 parts:
--   > Find wich week the runner registered, I used the following formula
--   >>> w = (Date_of_registration - First_date_of_first_week)/7, the integer part of this division will tells us the week (
--   >>> If w = 0 it is the first week, if w= 1 it is the second, .... etc
WITH runners_week (runner_id, registration_date,registration_week) AS( 
SELECT runner_id, registration_date, 
	(DATEDIFF(DAY,'2021-01-01', registration_date)/7) AS registration_week 
	FROM runners
)
SELECT COUNT(runner_id) as nb_runners_registered,
	CAST('2021-01-01' AS smalldatetime) + registration_week*7  
	AS week
FROM runners_week
GROUP BY registration_week
GO

-- 2. What was the average time in minutes it took for each runner to arrive at the Pizza Runner HQ to pickup the order?
WITH runner_pickup(order_id,runner_id, order_time, pickup_time,pickup_duration ) as (
	SELECT 
		Distinct c.order_id,
		r.runner_id, 
		c.order_time,
		r.pickup_time,
		DATEDIFF(MINUTE,C.order_time,R.pickup_time)	pickup_duration
		FROM runner_orders r
		JOIN customer_orders c
		ON c.order_id = r.order_id
		WHERE r.cancellation IS NULL
)
SELECT runner_id, 
	AVG(pickup_duration) avg_arrival,
	SUM(pickup_duration) total_time,
	COUNT(*) nb_orders
FROM runner_pickup
GROUP BY runner_id

-- 3. Is there any relationship between the number of pizzas and how long the order takes to prepare?
-- Yes, each pizza usually takes 10 minutes to be prepared 
SELECT 
	c.order_id,
	avg(DATEDIFF(MINUTE,C.order_time,R.pickup_time))	pickup_duration,
	count(c.order_id) nb_pizza
FROM runner_orders r
	JOIN customer_orders c
	ON c.order_id = r.order_id
WHERE r.cancellation IS NULL
group by c.order_id
ORDER BY count(c.order_id)
select * from customer_orders


-- 4. What was the average distance travelled for each customer?
SELECT 
	c.customer_id,
	AVG(r.distance) avg_distance
FROM runner_orders r
	JOIN customer_orders c
	ON c.order_id = r.order_id
WHERE r.cancellation IS NULL
group by c.customer_id

-- 5. What was the difference between the longest and shortest delivery times for all orders?
SELECT MAX(distance) max_distance,
	MIN(distance) min_distance,
	(MAX(distance) - MIN(distance)) diff
FROM runner_orders;

-- 6. What was the average speed for each runner for each delivery and do you notice any trend for these values?
SELECT *,
	(60*distance/duration) speed_kmh
FROM  runner_orders
WHERE cancellation IS NULL;

-- 7. What is the successful delivery percentage for each runner?
WITH runner_cancellations (runner_id, total_ordes, total_cancelation)
as(
	SELECT runner_id,
		COUNT(*) total_orders,
		total_cancellation =
		SUM(CASE WHEN cancellation is not null then 1
		else 0 END) 
	FROM runner_orders
	GROUP BY runner_id
) SELECT *, 
	pct_cancelation = 100*((1.0*total_cancelation)/(1.0*total_ordes))
	from runner_cancellations