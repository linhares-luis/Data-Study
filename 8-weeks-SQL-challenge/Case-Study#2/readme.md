
# **Case Study #2 - Pizza Runner**
------ 
 Luís Linhares<br>
 27/10/2022<br>
 MS SQL server<br>
 [Pizza Runner Link](https://8weeksqlchallenge.com/case-study-2/) <br>

-----
## DESCRIPTION
## Introduction
This case study has been divided as follow:
- A. Pizza Metrics
- B. Runner and Customer Experience
- C. Ingredient Optimisation
- D. Pricing and Ratings
- Bonus DML Challenges (DML = Data Manipulation Language)

## Problem Statement
We have the following tables available:
- runners
- runner_orders
- customer_orders
- pizza_name
- pizza_recipe
- pizza_toppings

You can inspect the entity relationship diagram and example data below.

<img src="relationship.png" alt="tables relationship" width="400"/>
<br>

----------------------------------------------------------------------
<details>
  <summary>A.Pizza Metrics </summary>

  ### Questions
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
</details>

  [SOLUTION](A_Pizza_Metric.md)  
  [PROPOSED_SOLUTION_SQL](SQL/A_PizzaMetrics.sql)<br>
  Tableau [Link](https://public.tableau.com/views/pizzarunner/PizzaMetrics?:language=en-US&publish=yes&:display_count=n&:origin=viz_share_link)
