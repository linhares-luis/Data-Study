## Pizza Metric Questions Solutions
### 1. How many pizzas were ordered?

To answer that question we just need to count the number of observations in customer_orders table
~~~~sql
SELECT COUNT(*) nb_pizzas FROM customer_orders
~~~~
Result:
| nb_pizzas |
|-----------|
| 14        |

### 2. How many unique customer orders were made?

To solve this problem let's consider a unique customer order the combination of pizza, extras and exclusions.
1. First I made a subquery and grouped the orders by pizza, extras and exclusions
2. I counted how many unique pizzas where ordered
~~~~sql
SELECT COUNT(*) AS unique_orders
FROM 
	(SELECT pizza_id,extras,exclusions 
	FROM customer_orders GROUP BY pizza_id,extras,exclusions) T
~~~~

Result:
| unique_orders |
|---------------|
| 8             |

### 3. How many successful orders were delivered by each runner?

The information about cancellation is on the runner_orders table, we just need to count
~~~sql
SELECT runner_id, COUNT(order_id) delivered_order
FROM runner_orders
WHERE cancellation IS NULL
GROUP BY runner_id;
~~~
Result:
| runner_id | delivered_order |
|-----------|-----------------|
| 1         | 4               |
| 2         | 3               |
| 3         | 1               |

###  4. How many of each type of pizza was delivered?
Step 1: count how many times each pizza appears in customers_order table
Step 2: Join the result with pizza_name table

~~~sql
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
~~~
Result:
| pizza_name | delivered_pizzas |
|------------|------------------|
| Meatlovers | 9                |
| Vegetarian | 3                |

###  5. How many Vegetarian and Meatlovers were ordered by each customer?
It was necessary to convert the pizza_name variable from **TEXT**  to **VARCHAR**  to apply the group by
~~~sql
SELECT c.customer_id, 
	CAST(p.pizza_name AS VARCHAR(10)) pizza_name, 
	COUNT(c.pizza_id) amt_ordered
FROM customer_orders c
	JOIN pizza_names p
	ON c.pizza_id = p.pizza_id
GROUP BY c.customer_id, CAST(p.pizza_name AS VARCHAR(10))
ORDER BY c.customer_id
~~~

Result:
| customer_id | pizza_name | amt_ordered |
|-------------|------------|-------------|
| 101         | Meatlovers | 2           |
| 101         | Vegetarian | 1           |
| 102         | Meatlovers | 2           |
| 102         | Vegetarian | 1           |
| 103         | Meatlovers | 3           |
| 103         | Vegetarian | 1           |
| 104         | Meatlovers | 3           |
| 105         | Vegetarian | 1           |

###  6. What was the maximum number of pizzas delivered in a single order?
To solve this question I counted the number of pizza in each order and ordered the query in descending order and limited the result to one
~~~sql
SELECT TOP 1 C.order_id, COUNT(c.order_id) pizza_in_order
FROM customer_orders c 
	JOIN runner_orders r
	ON c.order_id = r.order_id 
WHERE cancellation IS NULL
GROUP BY c.order_id
ORDER BY COUNT(c.order_id) DESC
~~~
Result:
| order_id | pizza_in_order |
|----------|----------------|
| 4        | 3              |

###  7. For each customer, how many delivered pizzas had at least 1 change and how many had no changes?
A new column (change) was create to save the information about changes in the order, if there is any change the change column will have the value 1, to discover the number of orders with changes we just need to sum the change column
~~~sql
WITH delivered_order (customer_id, order_id, extras, exclusions, changed) AS (
	SELECT c.customer_id, c.order_id, c.extras, c.exclusions, 
	changed = CASE
		WHEN c.extras IS NOT NULL THEN 1
		WHEN c.exclusions IS NOT NULL THEN 1
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
~~~

Result:
| customer_id | pizza_w_change | no_change_orders |
|:-----------:|----------------|------------------|
| 101         | 0              | 2                |
| 102         | 0              | 3                |
| 103         | 3              | 0                |
| 104         | 2              | 1                |
| 105         | 1              | 0                |

### 8. How many pizzas were delivered that had both exclusions and extras?
I used the same strategy from last question, created a new column as a flag with the desired characteristic 
~~~sql
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
~~~

Result:
| pizz_both_change |
|------------------|
| 1                |

### 9. What was the total volume of pizzas ordered for each hour of the day?

~~~sql
SELECT DATENAME(hour, order_time) hour_day, COUNT(*) amt_pizzas 
FROM customer_orders
GROUP BY DATENAME(hour, order_time)
~~~
| hour_day | amt_pizzas |
|----------|------------|
| 11       | 1          |
| 13       | 3          |
| 18       | 3          |
| 19       | 1          |
| 21       | 3          |
| 23       | 3          |

### 10. What was the volume of orders for each day of the week?
~~~sql
SELECT DATENAME(WEEKDAY, order_time) week_day, COUNT(*) amt_pizzas 
FROM customer_orders
GROUP BY DATENAME(WEEKDAY, order_time)
~~~

Result:
| week_day     | amt_pizzas |
|--------------|------------|
| Wednesday    | 5          |
| Thursday     | 3          |
| Saturday     | 5          |
| Friday       | 1          |