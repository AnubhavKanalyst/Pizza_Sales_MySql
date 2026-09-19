Create database PizzaSales;

Create table Orders (
Order_id int not null,
Order_date date not null,
Order_time time not null,
primary key (Order_id) );



Create table Order_details (
Order_details_id int not null,
Order_id int not null,
Pizza_id text not null,
Quantity int not null,
primary key (Order_details_id) );



-- Retrieve the total number of orders placed. 
SELECT 
    COUNT(Order_id) AS Total_Orders
FROM
    orders;


-- Calculate the total revenue generated from pizza sales.
SELECT 
    ROUND(SUM(order_details.Quantity * pizzas.price),
            2) AS Total_revenue
FROM
    order_details
         JOIN
    pizzas ON order_details.Pizza_id = pizzas.pizza_id;
    
    
    
    -- Identify the highest-priced pizza.
SELECT 
    pizza_types.name, pizzas.Price
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
ORDER BY pizzas.price DESC
LIMIT 1;



-- Identify the most common pizza size ordered.
SELECT 
    pizzas.size,
    COUNT(order_details.Order_details_id) AS Order_Count
FROM
    order_details
        JOIN
    pizzas ON order_details.Pizza_id = pizzas.pizza_id
GROUP BY pizzas.size
ORDER BY Order_Count DESC;



-- List the top 5 most ordered pizza types along with their quantities.
SELECT 
    pizza_types.name,
    SUM(order_details.quantity) AS Total_quantity
FROM
    pizzas
        JOIN
    order_details ON pizzas.pizza_id = order_details.Pizza_id
        JOIN
    pizza_types ON pizza_types.pizza_type_id = pizzas.pizza_type_id
GROUP BY pizza_types.name
ORDER BY Total_quantity DESC
LIMIT 5;



-- Join the necessary tables to find the total quantity of each pizza category ordered.
SELECT 
    pizza_types.category,
    SUM(order_details.Quantity) AS Quantity
FROM
    pizzas
        JOIN
    pizza_types ON pizzas.pizza_type_id = pizza_types.pizza_type_id
        JOIN
    order_details ON order_details.Pizza_id = pizzas.pizza_id
GROUP BY pizza_types.category
ORDER BY Quantity DESC;



-- Determine the distribution of orders by hour of the day.
SELECT 
    HOUR(order_time) AS Hours, COUNT(order_id) AS Order_Count
FROM
    orders
GROUP BY Hours
ORDER BY Order_Count DESC;



-- Join relevant tables to find the category-wise distribution of pizzas.
SELECT 
    category, COUNT(name) AS Names
FROM
    pizza_types
GROUP BY category;




-- Group the orders by date and calculate the average number of pizzas ordered per day.
SELECT 
    ROUND(AVG(Quantity), 0) as Avg_Orders
FROM
    (SELECT 
        orders.Order_date, SUM(order_details.Quantity) AS Quantity
    FROM
        orders
    JOIN order_details ON orders.Order_id = order_details.Order_id
    GROUP BY orders.Order_date) AS Order_Quantity;
    
    
    
    -- Determine the top 3 most ordered pizza types based on revenue
SELECT 
    pizza_types.name,
    SUM(order_details.Quantity * pizzas.price) AS revenue
FROM
    pizzas
        JOIN
    pizza_types ON pizzas.pizza_type_id = pizza_types.pizza_type_id
        JOIN
    order_details ON order_details.Pizza_id = pizzas.pizza_id
GROUP BY pizza_types.name
ORDER BY revenue DESC
LIMIT 3;



-- Calculate the percentage contribution of each pizza type to total revenue.
SELECT 
    pizza_types.category,
    ROUND(SUM(order_details.Quantity * pizzas.price) / (SELECT 
                    ROUND(SUM(order_details.Quantity * pizzas.price),
                                2) AS Total_revenue
                FROM
                    order_details
                        JOIN
                    pizzas ON order_details.Pizza_id = pizzas.pizza_id) * 100,
            2) AS revenue
FROM
    order_details
        JOIN
    pizzas ON order_details.Pizza_id = pizzas.pizza_id
        JOIN
    pizza_types ON pizza_types.pizza_type_id = pizzas.pizza_type_id
GROUP BY pizza_types.category
ORDER BY revenue DESC;



-- Analyze the cumulative revenue generated over time.
select order_date,
sum(revenue) over(order by order_date) as cum_revenue
from
(select orders.order_date,
sum(order_details.quantity * pizzas.price) as revenue
from order_details join pizzas
on order_details.pizza_id = pizzas.pizza_id
join orders
on orders.order_id = order_details.order_id
group by orders.order_date) as sales;





-- Determine the top 3 most ordered pizza types based on revenue for each pizza category.
select category, name, revenue,
rank() over (partition by category order by revenue desc) as Ranks
from
(select pizza_types.category, pizza_types.name,
sum((order_details.quantity) * pizzas.price) as revenue
from pizza_types join pizzas
on pizza_types.pizza_type_id = pizzas.pizza_type_id
join order_details
on order_details.pizza_id = pizzas.pizza_id
group by pizza_types.category, pizza_types.name) as a;


