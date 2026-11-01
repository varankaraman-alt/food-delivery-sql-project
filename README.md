# food-delivery-sql-project
# Food Delivery SQL Project

A MySQL project that analyses a food delivery database (think Swiggy/Zomato style). It covers customers, restaurants, menu items, orders, delivery partners and reviews, and answers common business questions using SQL.

## Files

| File | What it contains |
|------|------------------|
| `food_delivery_SQL_PROJECT.sql` | Table creation scripts and all analysis queries |
| `food_delivery_data.sql` | Sample data to load into the tables |
| `food_delivery_project_data_modal.mwb` | MySQL Workbench ER diagram (data model) |

## Database Tables

1. `cities` - city, state, tier, launch date
2. `customers` - customer details and membership type (Gold / Regular)
3. `restaurants` - cuisine, rating, price range, veg-only flag
4. `menu_items` - items, category, price, availability
5. `delivery_partners` - partner details, vehicle type, rating
6. `orders` - order status, payment mode, delivery fee
7. `order_items` - items in each order, quantity, price, discount
8. `reviews` - customer ratings and review text

## How to Run

1. Open **MySQL Workbench** (or any MySQL client).
2. Run the table creation part of `food_delivery_SQL_PROJECT.sql` (the `CREATE TABLE` statements at the top).
3. Run `food_delivery_data.sql` to load the data.
4. Run the queries in `food_delivery_SQL_PROJECT.sql` one by one.
5. Optional: open the `.mwb` file in MySQL Workbench to see the ER diagram.

## Business Questions Answered

- How many orders are in each status?
- How many customers are Gold vs Regular members?
- Which are the 5 most expensive menu items?
- How many delivery partners use each vehicle type?
- Top 5 restaurants by revenue (Delivered orders)
- Revenue and order count by cuisine
- Restaurants with no reviews
- Menu items that were never ordered
- Average rating and review count per restaurant
- Top 5 delivery partners by completed deliveries
- Categorising items by price and orders by delivery fee
- Ranking restaurants by total sales
- Menu items priced above average
- Total revenue, monthly revenue and average delivery fee by city
- Customers per city
- Top 10 restaurants by order count
- Top 5 customers by spending

## SQL Concepts Used

- `JOIN` (INNER and LEFT)
- `GROUP BY`, `ORDER BY`, `LIMIT`
- Aggregate functions: `COUNT`, `SUM`, `AVG`
- `CASE WHEN`
- Subqueries
- Window function: `RANK() OVER`
- `DATE_FORMAT`, `CONCAT`, `ROUND`

## Tools

- MySQL
- MySQL Workbench
