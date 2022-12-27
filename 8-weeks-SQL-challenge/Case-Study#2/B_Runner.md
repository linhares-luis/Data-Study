## B. Runner and Customer Experience
### 1. How many runners signed up for each 1 week period? (i.e. week starts 2021-01-01)
To solve this question I broke the problem into 2 parts:
1. Find which week the runner registered, I used the following formula:
$$ week = (DatoOfRegistration - FirstDateOfFirstWeek)/7 $$
The integer part of this division will tells us the week.

2.  Count  how many runners registered each week 
~~~SQL
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
~~~
| nb_runners_registered | week                |
|-----------------------|---------------------|
| 2                     | 2021-01-01 00:00:00 |   
| 1                     | 2021-01-08 00:00:00 |   
| 1                     | 2021-01-15 00:00:00 | 

### 2. What was the average time in minutes it took for each runner to arrive at the Pizza Runner HQ to pickup the order?
- I used the DATEDIFF function from SQL Server to calculate the duration of each pickup
- Group By runner id and calculate the average to each runner. 

~~~SQL
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
~~~

| runner_id | avg_arrival | total_time | nb_orders |
|-----------|-------------|------------|-----------|
| 1         | 13          | 55         | 4         |
| 2         | 19          | 59         | 3         |
| 3         | 10          | 10         | 1         |

### 4. What was the average distance travelled for each customer?
~~~SQL
SELECT 
	c.customer_id,
	AVG(r.distance) avg_distance
FROM runner_orders r
	JOIN customer_orders c
	ON c.order_id = r.order_id
WHERE r.cancellation IS NULL
group by c.customer_id
~~~

| customer_id | avg_distance     |  
|-------------|------------------|
| 101         | 20               |      
| 102         | 16,73            |    
| 103         | 23,4             |   
| 104         | 10               |   
| 105         | 25               |    

### 5. What was the difference between the longest and shortest delivery times for all orders?
~~~SQL
SELECT MAX(distance) max_distance,
	MIN(distance) min_distance,
	(MAX(distance) - MIN(distance)) diff
FROM runner_orders;
~~~
| max_distance | min_distance | diff |
|--------------|--------------|------|
| 25           | 10           | 15   |

### 6. What was the average speed for each runner for each delivery and do you notice any trend for these values?
To answer this question I choose to use the speed in Km/h 
~~~SQL
SELECT *,
	(60*distance/duration) speed_kmh
FROM  runner_orders
WHERE cancellation IS NULL;
~~~

| order_id | runner_id | pickup_time         | distance | duration | cancellation | speed_kmh        |
|----------|-----------|---------------------|----------|----------|--------------|------------------|
| 1        | 1         | 2020-01-01 18:15:34 | 20       | 32       | NULL         | 37,5             |
| 2        | 1         | 2020-01-01 19:10:54 | 20       | 27       | NULL         | 44,44            |
| 3        | 1         | 2020-01-03 00:12:37 | 13,4     | 20       | NULL         | 40,2             |
| 4        | 2         | 2020-01-04 13:53:03 | 23,4     | 40       | NULL         | 35,1             |
| 5        | 3         | 2020-01-08 21:10:57 | 10       | 15       | NULL         | 40               |
| 7        | 2         | 2020-01-08 21:30:45 | 25       | 25       | NULL         | 60               |
| 8        | 2         | 2020-01-10 00:15:02 | 23,4     | 15       | NULL         | 93,6             |
| 10       | 1         | 2020-01-11 18:50:20 | 10       | 10       | NULL         | 60               |

Most of the order's delivery have a delivery speed around 40km/h, we have two orders with 60km/h. The order with id 8 was a outlier with 93,6km/h, probably a recording mistake 

###  7. What is the successful delivery percentage for each runner?
~~~SQL
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
~~~

| runner_id | total_ordes | total_cancelation | pct_cancelation    |
|-----------|-------------|-------------------|--------------------|
| 1         | 4           | 0                 | 0.0                |
| 2         | 4           | 1                 | 25.0               |
| 3         | 2           | 1                 | 50.0               |