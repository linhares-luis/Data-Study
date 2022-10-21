/* --------------------
   Case Study #1
   -- Luís Linhares
   -- 21/10/2022
   -- MS SQL server
   --------------------*/
    /*	QUESTIONS	*/
-- 1. What is the total amount each customer spent at the restaurant?
-- 2. How many days has each customer visited the restaurant?
-- 3. What was the first item from the menu purchased by each customer?
-- 4. What is the most purchased item on the menu and how many times was it purchased by all customers?
-- 5. Which item was the most popular for each customer?
-- 6. Which item was purchased first by the customer after they became a member?
-- 7. Which item was purchased just before the customer became a member?
-- 8. What is the total items and amount spent for each member before they became a member?
-- 9.  If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?
-- 10. In the first week after a customer joins the program (including their join date) 
---   they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January?
-----------------------------------------------------------
USE dannys_diner
/* Question 1
--- What is the total amount each customer spent at the restaurant?*/
SELECT s.customer_id, SUM(m.price) as amount_spent
FROM sales s, menu m
WHERE s.product_id = m.product_id
GROUP BY s.customer_id

/* Question 2
--- How many days has each customer visited the restaurant?*/
SELECT s.customer_id, COUNT(DISTINCT s.order_date) AS days_visited
FROM sales s
GROUP BY s.customer_id


/* Question 3
 What was the first item from the menu purchased by each customer?*/

-- Solution 1
SELECT a.customer_id, a.order_date, a.product_name
FROM 
	(SELECT  s.customer_id, s.order_date, m.product_name
	FROM sales s, menu m
	where s.product_id = m.product_id)
   a, 
	(SELECT  min(s.order_date) as min_date, s.customer_id
		FROM sales s, menu m
		WHERE s.product_id = m.product_id
		GROUP BY s.customer_id) b
WHERE a.customer_id = b.customer_id
	and a.order_date = b.min_date
/* SOLUTION 1 v2 */
SELECT a.customer_id, a.order_date, STRING_AGG(a.product_name,'; ') as product_name
FROM 
	(SELECT  s.customer_id, s.order_date, m.product_name
	FROM sales s, menu m
	WHERE s.product_id = m.product_id)
   a, 
	(SELECT  min(s.order_date) as min_date, s.customer_id
		FROM sales s, menu m
		WHERE s.product_id = m.product_id
		GROUP BY s.customer_id) b
WHERE a.customer_id = b.customer_id
	and a.order_date = b.min_date
GROUP BY a.customer_id, a.order_date;
 
 /*Question 4
   What is the most purchased item on the menu and how many times was it purchased by all customers? */

SELECT TOP 1 m.product_name, s.product_id, COUNT(s.product_id) as nb_orders
FROM sales s,
	menu m
WHERE s.product_id = m.product_id
GROUP BY s.product_id, m.product_name
ORDER BY nb_orders DESC;
 

 /*Question 5
   Which item was the most popular for each customer?*/
-- ANSWER WITH SUBQUERY
SELECT r.rank_order, r.customer_id, number_orders, STRING_AGG(r.product_name, '; ') as product_names
FROM (SELECT s.customer_id, m.product_name, COUNT(m.product_name) as number_orders,
			RANK() OVER(PARTITION BY s.customer_id ORDER BY COUNT(m.product_name) DESC ) rank_order
		FROM sales s, menu m
		WHERE s.product_id = m.product_id
		GROUP BY s.customer_id, m.product_name) r
GROUP BY r.rank_order, r.customer_id, number_orders
HAVING r.rank_order = 1
ORDER BY r.customer_id;

-- ANSWER WITH CTE
WITH RANK_CTE (customer_id, product_name,number_orders, rank_order) 
AS(
SELECT s.customer_id, m.product_name, COUNT(m.product_name) as number_orders,
	RANK() OVER(PARTITION BY s.customer_id ORDER BY COUNT(m.product_name) DESC ) rank_order
FROM sales s LEFT JOIN  menu m ON s.product_id = m.product_id
GROUP BY s.customer_id, m.product_name
)
SELECT rank_order, customer_id, number_orders, STRING_AGG(product_name, '; ') as product_names 
FROM RANK_CTE
GROUP BY rank_order, customer_id, number_orders
HAVING rank_order = 1
ORDER BY customer_id;

/* Question 6
--- Which item was purchased first by the customer after they became a member?*/
with ranked_date (customer_id,order_date,product_id,join_date,rank_date) as (
		select s.customer_id, s.order_date, s.product_id, m.join_date,
		rank() over (partition by s.customer_id order by s.order_date asc) rank_date
		from sales s
			inner join members m
			on s.customer_id = m.customer_id
		where s.order_date > m.join_date
)
select r.customer_id, r.order_date, m.product_name
from ranked_date r inner join menu m
	on r.product_id = m.product_id
where r.rank_date = 1

--- solution 2
select a.*, b.product_name
from (select s.customer_id, min(s.order_date) min_date, m.join_date
	from sales s
		inner join members m
		on s.customer_id = m.customer_id
	where s.order_date > m.join_date
	group by s.customer_id,m.join_date) a,
	(select s.customer_id, s.order_date,
		s.product_id, m.product_name
	from sales s inner join menu m
	on m.product_id = s.product_id) b
	where b.order_date = a.min_date
		and b.customer_id = a.customer_id;

/* Question 7
--- Which item was purchased just before the customer became a member??*/
select a.*, b.product_name
from (select s.customer_id, max(s.order_date) max_date, m.join_date
	from sales s
		inner join members m
		on s.customer_id = m.customer_id
	where s.order_date < m.join_date
	group by s.customer_id,m.join_date) a,
	(select s.customer_id, s.order_date,
		s.product_id, m.product_name
	from sales s inner join menu m
	on m.product_id = s.product_id) b
	where b.order_date = a.max_date
		and b.customer_id = a.customer_id;
/* Question 8
--- What is the total items and amount spent for each member before they became a member??*/
SELECT a.customer_id, COUNT( DISTINCT a.product_id) as number_itens, sum(a.price) as total_amt
FROM ( SELECT s.product_id,s.customer_id, m.price, s.order_date
		FROM sales s inner join menu m
			ON s.product_id = m.product_id) a
	inner join members b on a.customer_id = b.customer_id
WHERE a.order_date < b.join_date
GROUP BY a.customer_id;


/* Question 9
-- If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?*/
SELECT a.customer_id, sum(a.points) points
FROM
(
	SELECT s.customer_id, m.product_name, SUM(m.price) as amt_paid,
		points = CASE m.product_name
		WHEN 'sushi' then SUM(m.price)*20
		ELSE SUM(m.price)*10
		END
	FROM sales s join menu m
		on s.product_id = m.product_id
	GROUP BY s.customer_id,m.product_name) a
GROUP BY a.customer_id;

-- 10. In the first week after a customer joins the program (including their join date) 
---   they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January?
 WITH members_points (customer_id,order_date, product_id, product_name, price, join_date,first_week, points)
 as(
 SELECT s.customer_id, s.order_date, s.product_id, m.product_name, m.price, a.join_date,
	first_week = CASE  
		WHEN s.order_date BETWEEN join_date and DATEADD(day,6,join_date) then 1
		ELSE 0
	END,
		points = CASE 
		WHEN m.product_name = 'sushi' THEN m.price*20
		WHEN s.order_date BETWEEN join_date and DATEADD(day,6,join_date) then m.price*20
		else m.price*10
	END
 FROM sales s JOIN menu m
	ON s.product_id = m.product_id
JOIN members a on s.customer_id = a.customer_id)
SELECT customer_id, SUM(points) as amt_points
FROM members_points
	WHERE order_date <= '2021-01-31'
GROUP BY customer_id
