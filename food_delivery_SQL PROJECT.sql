-- CREATE DATABASE IF NOT EXISTS food_delivery;
USE food_delivery;


DROP TABLE IF EXISTS reviews;
DROP TABLE IF EXISTS order_items;
DROP TABLE IF EXISTS orders;
DROP TABLE IF EXISTS menu_items;
DROP TABLE IF EXISTS delivery_partners;
DROP TABLE IF EXISTS restaurants;
DROP TABLE IF EXISTS customers;
DROP TABLE IF EXISTS cities;


CREATE TABLE cities (
    city_id        INT PRIMARY KEY,
    city_name      VARCHAR(50) NOT NULL,
    state          VARCHAR(50) NOT NULL,
    tier           VARCHAR(10) NOT NULL,          
    pincode_start  VARCHAR(6),
    launch_date    DATE        NOT NULL
);


CREATE TABLE customers (
    customer_id  INT PRIMARY KEY,
    first_name   VARCHAR(40)  NOT NULL,
    last_name    VARCHAR(40)  NOT NULL,
    email        VARCHAR(100) UNIQUE,
    phone        VARCHAR(15),
    city_id      INT          NOT NULL,
    signup_date  DATE         NOT NULL,
    membership   VARCHAR(10)  NOT NULL,          
    FOREIGN KEY (city_id) REFERENCES cities(city_id)
);

-- 3. Restaurants (8 columns)
CREATE TABLE restaurants (
    restaurant_id    INT PRIMARY KEY,
    restaurant_name  VARCHAR(80)  NOT NULL,
    cuisine          VARCHAR(40)  NOT NULL,       
    city_id          INT          NOT NULL,
    rating           DECIMAL(2,1),
    price_range      VARCHAR(10),                
    is_veg_only      BOOLEAN      NOT NULL,
    opened_on        DATE         NOT NULL,
    FOREIGN KEY (city_id) REFERENCES cities(city_id)
);


CREATE TABLE menu_items (
    item_id        INT PRIMARY KEY,
    restaurant_id  INT          NOT NULL,
    item_name      VARCHAR(80)  NOT NULL,
    category       VARCHAR(30),                   
    price          DECIMAL(8,2) NOT NULL,
    is_veg         BOOLEAN      NOT NULL,
    is_available   BOOLEAN      NOT NULL,
    FOREIGN KEY (restaurant_id) REFERENCES restaurants(restaurant_id)
);


CREATE TABLE delivery_partners (
    partner_id    INT PRIMARY KEY,
    partner_name  VARCHAR(60) NOT NULL,
    phone         VARCHAR(15),
    city_id       INT         NOT NULL,
    vehicle_type  VARCHAR(20),                    
    joined_on     DATE        NOT NULL,
    rating        DECIMAL(2,1),
    FOREIGN KEY (city_id) REFERENCES cities(city_id)
);

CREATE TABLE orders (
    order_id       INT PRIMARY KEY,
    customer_id    INT         NOT NULL,
    restaurant_id  INT         NOT NULL,
    partner_id     INT,                           
    order_date     DATE        NOT NULL,
    order_status   VARCHAR(20) NOT NULL,          
    payment_mode   VARCHAR(20) NOT NULL,          
    delivery_fee   DECIMAL(6,2) NOT NULL,
    FOREIGN KEY (customer_id)   REFERENCES customers(customer_id),
    FOREIGN KEY (restaurant_id) REFERENCES restaurants(restaurant_id),
    FOREIGN KEY (partner_id)    REFERENCES delivery_partners(partner_id)
);

CREATE TABLE order_items (
    order_item_id  INT PRIMARY KEY,
    order_id       INT          NOT NULL,
    item_id        INT          NOT NULL,
    quantity       INT          NOT NULL,
    unit_price     DECIMAL(8,2) NOT NULL,         
    discount_amt   DECIMAL(8,2) NOT NULL DEFAULT 0,
    FOREIGN KEY (order_id) REFERENCES orders(order_id),
    FOREIGN KEY (item_id)  REFERENCES menu_items(item_id)
);


CREATE TABLE reviews (
    review_id      INT PRIMARY KEY,
    customer_id    INT  NOT NULL,
    restaurant_id  INT  NOT NULL,
    rating         INT  NOT NULL,                 
    review_text    VARCHAR(200),
    review_date    DATE NOT NULL,
    FOREIGN KEY (customer_id)   REFERENCES customers(customer_id),
    FOREIGN KEY (restaurant_id) REFERENCES restaurants(restaurant_id)
);

SELECT 'cities' AS table_name, COUNT(*) AS total_rows FROM cities
UNION ALL SELECT 'customers', COUNT(*) FROM customers
UNION ALL SELECT 'restaurants', COUNT(*) FROM restaurants
UNION ALL SELECT 'menu_items', COUNT(*) FROM menu_items
UNION ALL SELECT 'delivery_partners', COUNT(*) FROM delivery_partners
UNION ALL SELECT 'orders', COUNT(*) FROM orders
UNION ALL SELECT 'order_items', COUNT(*) FROM order_items
UNION ALL SELECT 'reviews', COUNT(*) FROM reviews;

-- Q1. Order status overview.
-- How many orders are there in each status? Show the highest count first.

SELECT order_status,COUNT(*) AS total_orders 
FROM orders
GROUP BY order_status 
ORDER BY total_orders DESC ;

-- Q2. Membership split.
-- How many customers are Gold members, and how many are Regular?

SELECT membership,count(*) AS total_member FROM customers
GROUP BY membership
ORDER BY total_member DESC ;

-- Q3. Top 5 most expensive menu items.
-- Which are the 5 most expensive menu items?

SELECT item_name,price 
FROM menu_items
ORDER BY price DESC 
LIMIT 5 ;

-- Q4. Delivery fleet by vehicle type.
-- How many delivery partners use each vehicle type?

SELECT vehicle_type,COUNT(*) AS total_delivery_partners
FROM delivery_partners
GROUP BY vehicle_type
ORDER BY total_delivery_partners DESC ;

--  Q5. Top 5 restaurants by revenue (Delivered orders).
-- Which 5 restaurants earn the most food revenue from Delivered orders?

SELECT 
r.restaurant_name,
SUM(oi.quantity * oi.unit_price - oi.discount_amt) AS revenue
FROM restaurants as r
INNER JOIN orders AS o
ON r.restaurant_id = o.restaurant_id
INNER JOIN order_items AS oi
ON o.order_id = oi.order_id
WHERE o.order_status = "Delivered"
GROUP BY r.restaurant_name 
ORDER BY revenue DESC 
LIMIT 5 ;

-- Q6. Revenue by cuisine.
-- Show the number of orders and total revenue for each cuisine (Delivered orders only).

SELECT 
r.cuisine,
COUNT(DISTINCT o.order_id) AS total_orders ,
SUM(oi.quantity * oi.unit_price - oi.discount_amt) AS revenue
FROM restaurants as r
INNER JOIN orders AS o
ON r.restaurant_id = o.restaurant_id
INNER JOIN order_items AS oi
ON o.order_id = oi.order_id
WHERE o.order_status = "Delivered"
GROUP BY r.cuisine
ORDER BY revenue DESC ;

-- Q7. Restaurants with no customer reviews.
-- Which restaurants have no customer reviews? Show the restaurant name and city.
SELECT
r.restaurant_id,
r.restaurant_name,
c.city_name
FROM restaurants AS r
JOIN cities AS c
ON r.city_id = c.city_id
LEFT JOIN reviews AS rv
ON r.restaurant_id = rv.restaurant_id 
WHERE rv.review_id IS NULL ;

-- Q8. Menu items that were never ordered.
-- Which menu items were never ordered? Show the item name and its restaurant.

SELECT
m.item_name,
r.restaurant_name
FROM menu_items AS m
JOIN restaurants AS r
ON r.restaurant_id = m.restaurant_id
LEFT JOIN order_items AS oi
ON m.item_id = oi.item_id
WHERE oi.order_item_id IS NULL ;

-- Q9. Average rating and review count per restaurant.
-- What is the number of reviews and the average rating for each restaurant? Show the best rated first.

SELECT 
r.restaurant_name,
COUNT(rv.review_id) AS total_review,
AVG(rv.rating) AS avg_rating
FROM restaurants AS r
JOIN reviews AS rv
ON r.restaurant_id = rv.restaurant_id
GROUP BY r.restaurant_name
ORDER BY avg_rating DESC 
;

-- Q10. Top 5 delivery partners by completed deliveries.
-- Who are the top 5 delivery partners by Delivered orders? Show their city and vehicle type.

SELECT
d.partner_name,
d.vehicle_type,
COUNT(o.order_id) AS total_deliveries,
c.city_name
FROM delivery_partners AS d
JOIN cities AS c
ON d.city_id = c.city_id
JOIN orders AS o 
ON d.partner_id = o.partner_id 
WHERE o.order_status = "Delivered"
GROUP BY d.partner_name,c.city_name,d.vehicle_type
ORDER BY total_deliveries
LIMIT 5 ;

-- Q11
-- Order Size by Price (order_items)

SELECT 
order_item_id,
unit_price,
CASE
WHEN unit_price >= 300 THEN "Expensive"
WHEN unit_price >= 150 THEN "Modrate"
Else "Affordable"
END AS price_category
FROM order_items ;

-- Q12 How can we categorize orders based on their delivery fees?

SELECT 
order_id,
delivery_fee,
CASE
WHEN delivery_fee >= 40 THEN "High"
WHEN delivery_fee >= 20 THEN "Low"
ELSE "Low"
END AS fee_category
FROM orders ;

-- Q13. Rank Restaurants by Total Food Sales
SELECT
    restaurant_name,
    total_sales,
    RANK() OVER (ORDER BY total_sales DESC) AS sales_rank
FROM (
    SELECT
        r.restaurant_name,
        SUM(oi.quantity * oi.unit_price - oi.discount_amt) AS total_sales
    FROM restaurants AS r
    INNER JOIN orders AS o
        ON r.restaurant_id = o.restaurant_id
    INNER JOIN order_items AS oi
        ON o.order_id = oi.order_id
    WHERE o.order_status = 'Delivered'
    GROUP BY r.restaurant_id, r.restaurant_name
) AS restaurant_sales;

-- Q14.— Find Menu Items Priced Above Average

SELECT 
item_name,
price 
FROM menu_items
WHERE price > (SELECT AVG(price) FROM menu_items) ;

-- Calculate total revenue from delivered orders

SELECT 
SUM(oi.unit_price * oi.quantity - discount_amt) AS total_revenue
FROM order_items AS oi
INNER JOIN orders AS o
ON oi.order_id = o.order_id
WHERE o.order_status = "Delivered" ;

-- Average delivery fee by city
SELECT
ct.city_name,
ROUND(AVG(o.delivery_fee),2) AS avg_delivery_fee
FROM cities AS ct
INNER JOIN customers AS c
ON ct.city_id = c.city_id
INNER JOIN orders AS o
ON c.customer_id = o.customer_id 
GROUP BY ct.city_name ;

-- Count customers registered in each city

SELECT 
ct.city_id,
ct.city_name,
COUNT(c.customer_id) AS total_customers 
FROM cities AS ct
INNER JOIN customers AS c
ON ct.city_id = c.city_id 
GROUP BY ct.city_id ,ct.city_name
ORDER BY total_customers DESC ;

-- Top 10 restaurants by order count

SELECT 
r.restaurant_id,
r.restaurant_name,
COUNT(o.order_id) AS total_orders
FROM restaurants AS r
INNER JOIN orders AS o 
ON r.restaurant_id = o.restaurant_id
GROUP BY r.restaurant_id ,r.restaurant_name
ORDER BY total_orders DESC 
LIMIT 10 ;

SELECT 
DATE_FORMAT(o.order_date,'%b') AS order_month,
SUM(oi.unit_price * oi.quantity - discount_amt) AS total_revenue
FROM orders AS o
INNER JOIN order_items AS oi
ON o.order_id = oi.order_id
WHERE o.order_status = "Delivered"
GROUP BY order_month
ORDER BY total_revenue DESC ; 

-- Top 5 Customers by Spending

SELECT 
c.customer_id,
CONCAT(c.first_name ," ",c.last_name) AS customer_name,
SUM(oi.unit_price * oi.quantity - discount_amt) AS total_spending
FROM customers AS c
INNER JOIN orders AS o
ON c.customer_id = o.customer_id
INNER JOIN order_items AS oi
ON o.order_id = oi.order_id
WHERE o.order_status = "Delivered" 
GROUP BY c.customer_id,customer_name
ORDER BY total_spending DESC 
LIMIT 5 ;












































