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

~~~sql
SELECT pizza_id, COUNT(pizza_id) as delivered_pizzas 
FROM customer_orders c 
	JOIN runner_orders r
	ON c.order_id =r.order_id
WHERE cancellation IS NULL
GROUP BY pizza_id;
~~~
Result:
| pizza_id | delivered_pizzas |
|----------|------------------|
|     1    |         9        |
|     2    |         3        |

###  5. How many Vegetarian and Meatlovers were ordered by each customer?
