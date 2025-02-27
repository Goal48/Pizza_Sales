-- Creating Database First

create database pizzahut;
use pizzahut;

-- Creating Table - "Ordered Table"

create table ordered(
order_id int not null,
order_date date not null,
order_time time not null,
primary key(order_id)
);

SELECT * FROM pizzahut.ordered;

-- Creating Table - "Order_details"

create table order_details(
order_details_id int not null,
order_id int not null,
pizza_id text not null,
quantity int not null,
primary key(order_details_id)
);

SELECT * FROM pizzahut.order_details;

-- Another Two Table are - "Pizza_type" & "Pizzas"

SELECT * FROM pizzahut.pizza_types;

SELECT * FROM pizzahut.pizzas;



-- Data Analysis & Business Key Problems & Answers

-- Basic:

--Retrieve the total number of orders placed.
-- 1. Calculate the total revenue generated from pizza sales.
-- 2. Identify the highest-priced pizza.
-- 3. Identify the most common pizza size ordered.
-- 4. List the top 5 most ordered pizza types along with their quantities.


-- Intermediate:

-- 5. Join the necessary tables to find the total quantity of each pizza category ordered.
-- 6. Determine the distribution of orders by hour of the day.
-- 7. Join relevant tables to find the category-wise distribution of pizzas.
-- 8. Group the orders by date and calculate the average number of pizzas ordered per day.
-- 9. Determine the top 3 most ordered pizza types based on revenue.

-- Advanced:

-- 10. Calculate the percentage contribution of each pizza type to total revenue.
-- 11. Analyze the cumulative revenue generated over time.
-- 12. Determine the top 3 most ordered pizza types based on revenue for each pizza category.



-- Q.1. Calculate the total revenue generated from pizza sales.

SELECT 
    SUM(order_details.quantity * pizzas.price) AS Total_Sales
FROM
    order_details
        JOIN
    pizzas ON pizzas.pizza_id = order_details.pizza_id;


-- Q.2. Identify the highest-priced pizza.

SELECT 
    pizza_types.name, pizzas.price
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
ORDER BY pizzas.price DESC
LIMIT 1;


-- Q.3. Identify the most common pizza size ordered.

SELECT 
    pizzas.size,
    COUNT(order_details.order_details_id) AS order_count
FROM
    pizzas
        JOIN
    order_details ON pizzas.pizza_id = order_details.pizza_id
GROUP BY pizzas.size
ORDER BY order_count DESC;


-- Q.4.  List the top 5 most ordered pizza types along with their quantities.

SELECT 
    pizza_types.name, SUM(order_details.quantity) AS quantity
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
        JOIN
    order_details ON order_details.pizza_id = pizzas.pizza_id
GROUP BY pizza_types.name
ORDER BY quantity DESC
LIMIT 5;


-- Q.5. Join the necessary tables to find the total quantity of each pizza category ordered.

SELECT 
    pizza_types.category,
    SUM(order_details.quantity) AS quantity
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
        JOIN
    order_details ON order_details.pizza_id = pizzas.pizza_id
GROUP BY pizza_types.category
ORDER BY quantity DESC;


-- Q.6. Determine the distribution of orders by hour of the day.

SELECT 
    HOUR(order_time) AS hour, COUNT(order_id) AS order_count
FROM
    ordered
GROUP BY HOUR(order_time);


-- Q.7. Join relevant tables to find the category-wise distribution of pizzas.

SELECT 
    category, COUNT(name)
FROM
    pizza_types
GROUP BY category;


-- Q.8. Group the orders by date and calculate the average number of pizzas ordered per day.

SELECT 
    AVG(quantity) as avg_pizza_per_day
FROM
    (SELECT 
        ordered.order_date, SUM(order_details.quantity) AS quantity
    FROM
        ordered
    JOIN order_details ON ordered.order_id = order_details.order_id
    GROUP BY ordered.order_date) AS order_quantity;


-- Q. 9. Determine the top 3 most ordered pizza types based on revenue.

SELECT 
    pizza_types.name,
    SUM(order_details.quantity * pizzas.price) AS revenue
FROM
    pizza_types
        JOIN
    pizzas ON pizzas.pizza_type_id = pizza_types.pizza_type_id
        JOIN
    order_details ON order_details.pizza_id = pizzas.pizza_id
GROUP BY pizza_types.name
ORDER BY revenue DESC
LIMIT 3;


-- Q.10. Calculate the percentage contribution of each pizza type to total revenue.

SELECT 
    pizza_types.category,
    (SUM(order_details.quantity * pizzas.price) / (SELECT 
            SUM(order_details.quantity * pizzas.price) AS Total_Sales
        FROM
            order_details
                JOIN
            pizzas ON pizzas.pizza_id = order_details.pizza_id)) * 100 AS revenue
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
        JOIN
    order_details ON order_details.pizza_id = pizzas.pizza_id
GROUP BY pizza_types.category
ORDER BY revenue DESC;


-- Q.11. Analyze the cumulative revenue generated over time.

select order_date,
sum(revenue) over (order by order_date) as cum_revenue
from
(select ordered.order_date,
sum(order_details.quantity * pizzas.price) as revenue
from order_details join pizzas
on order_details.pizza_id = pizzas.pizza_id
join ordered
on ordered.order_id =  order_details.order_id
group by ordered.order_date) as sales;


-- Q.12. Determine the top 3 most ordered pizza types based on revenue for each pizza category.

select name , revenue
from
(select category , name , revenue, 
rank() over(partition by category order by revenue desc ) as rn
from
 (select pizza_types.category,pizza_types.name,
sum(order_details.quantity*pizzas.price) as revenue
from pizza_types join pizzas
on pizza_types.pizza_type_id = pizzas.pizza_type_id
join order_details
on order_details.pizza_id = pizzas.pizza_id
group by pizza_types.category,pizza_types.name) as a ) as b
where rn <= 3;


-- End of the Project
