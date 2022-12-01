use toys_and_models;
-- The number of products sold by category and by month, 
-- with comparison and rate of change compared to the same month of the previous year.

-- remove the  order year 2021 and mponth 2021
-- My problem is that i cannot remove the order_year2021 and order_month2021 because i use these to calculate the rate of change

WITH part1 AS (
SELECT productline, YEAR(orderDate) order_year2022, MONTH(orderDate) order_month2022, SUM(quantityOrdered)as order_value2022
    FROM orders
    INNER JOIN orderdetails 
    USING (orderNumber)
    INNER JOIN products 
    USING (productCode)
    WHERE year(orderDate)=YEAR(current_timestamp) 
    GROUP BY productline, order_year2022, order_month2022
    ORDER BY order_year2022),
part2 AS (
SELECT productline, YEAR(orderDate) order_year2021, MONTH(orderDate) order_month2021, SUM(quantityOrdered) as order_value2021
    FROM orders
    INNER JOIN orderdetails 
    USING (orderNumber)
    INNER JOIN products 
    USING (productCode)
    WHERE year(orderDate)=YEAR(current_timestamp)-1 
    GROUP BY productline, order_year2021, order_month2021
    ORDER BY order_year2021)
    
    SELECT part1.productline, part1.order_year2022, part2.order_year2021, part1.order_month2022, part2.order_month2021, part1.order_value2022, part2.order_value2021,
ROUND((part1.order_value2022 - part2.order_value2021 )*100/part2.order_value2021, 2) AS rateofchange
FROM part1
LEFT JOIN part2
ON (part1.productline,part1.order_year2022,part1.order_month2022)=(part2.productline,(part2.order_year2021+1),part2.order_month2021)
order by order_month2022 desc;

-- Il affiche le CA par office, par pays et par ville

select  off.city,off.country, year(o.orderDate) as year_order, Month(o.orderDate) as month_order,Round(sum(od.quantityOrdered * od.PriceEach)) as CA_by_office from orders as ord
left join orderdetails as od
using(orderNumber)
left join customers as c
using (customerNumber)
left join orders as o
using(orderNumber)
left join employees as e
on e.employeeNumber = c.salesRepEmployeeNumber
left join offices as off
using(officeCode)
group by off.country, off.city, month_order, year_order
order by year_order asc, 
CA_by_office desc;


-- calculation of products sold per category, country and through the years in 2022-2021

SELECT c.country as Countries, p.productLine as category, SUM(od.quantityOrdered) as Products_sold, YEAR(o.orderDate) as Year
FROM orders as o
JOIN orderdetails od
ON o.orderNumber = od.orderNumber
JOIN customers as c
ON o.customerNumber = c.customerNumber
JOIN products as p
ON p.productCode = od.productCode
JOIN
	(SELECT DISTINCT YEAR(o.orderDate) Year
    FROM orders o
    ORDER BY YEAR(o.orderDate) DESC
    LIMIT 2) LastYear
ON YEAR(o.orderDate) = LastYear.Year
GROUP BY category, Countries, Year;

-- top 10 clientes en ca in the last 3 months

select customerName as Name_entreprise, MONTHNAME(orderDate) as Month_order, round(sum(priceEach*quantityOrdered)) as CA from customers
left join orders as o
using(customerNumber)
left join orderdetails as od
using(orderNumber)
WHERE year(orderDate) = year(now()) and MONTH(orderDate) between (month(now()) - 12) and month(now())
group by customerName, Month_order
order by CA desc limit 10;

-- CA par office sur les 3 derniers mois 

select  off.country,off.city,MONTHNAME(orderDate) as Month_order, round(sum(od.quantityOrdered * od.PriceEach)) as CA_by_office
from orders as ord
left join orderdetails as od
using(orderNumber)
left join customers as c
using (customerNumber)
left join employees as e
on e.employeeNumber = c.salesRepEmployeeNumber
left join offices as off
using(officeCode)
WHERE year(orderDate) = year(now()) and MONTH(orderDate) between (month(now()) - 3) and month(now())
group by off.country,off.city,Month_order
order by CA_by_office desc;

-- Number of clients by Country and their CA
SELECT c.country, COUNT(DISTINCT(c.customerNumber)) as Customer_no, Round(SUM(od.priceEach*od.quantityOrdered)) as CA
FROM customers as c
INNER JOIN orders as o
USING(customerNumber)
INNER JOIN orderdetails as od
USING(orderNumber)
WHERE (status like 'Shipped' or 'Resolved')
AND YEAR(o.orderdate) = YEAR(NOW())
GROUP BY c.country
ORDER BY CA desc;

-- For each entreprise/company client we can see the the total quantity of products ordered and their statuses.
select customerName, o.status, sum(quantityOrdered) as totalQuantity from customers
left join orders as o
using(customerNumber)
left join orderdetails as od
using(orderNumber)
where status != 'cancelled'
group by customerName, o.status
order by quantityOrdered desc limit 10;


-- history of sales and quantity of products
-- purpose of this script is to show the number of products ordered by month each year from the different partners and their CA

SELECT customerName as Name_entreprise,p.productCode,
p.productName,
concat(month(orderDate),"-", year(orderDate)) as month_year,
sum(od.quantityOrdered) as Products_sold,
round(sum(priceEach*quantityOrdered)) as CA
FROM orders
left join orderdetails as od
using(orderNumber)
JOIN products as p
ON p.productCode = od.productCode
left join customers as c
using (customerNumber)
GROUP BY
Name_entreprise,
od.productCode,
p.productName,
month_year
ORDER BY orderDate desc,sum(quantityOrdered) desc;

-- we can see the difference in price between the price we sell ans the price recommended towards in the retail

WITH test AS(
    SELECT DATE_FORMAT(o.orderDate,'%Y-%m') AS YearMonth, p.productName, 
    sum(od.quantityOrdered*od.priceEach) AS PriceSold,
    sum(od.quantityOrdered*p.MSRP) as RecommendedPrice
    FROM orderdetails as od
    INNER JOIN orders as o
    USING(orderNumber) 
    INNER JOIN products as p
    USING (productCode)
    WHERE YEAR(o.orderDate) = YEAR(NOW())   
    AND o.status !='Cancelled' 
    GROUP BY YearMonth, p.productName
    ORDER BY YearMonth, p.productName)

SELECT YearMonth, productName,PriceSold, RecommendedPrice,
PriceSold-RecommendedPrice as Differenceinprice
FROM test;

-- to compare the price sold with the MSRP we have and decide if we need to increase the prices

Create view Test_MSRP as (
SELECT productname, sum(quantityordered) as total_quantity_sold, round(avg(priceeach),2) as average_price_sold, MSRP,
sum(quantityordered)*MSRP as Total_RecommendedPrice, sum(quantityordered)*round(avg(priceeach),2) as Total_sold
FROM orderdetails
INNER JOIN products
USING (productcode)
INNER JOIN orders
USING (ordernumber)
WHERE YEAR(orderDate) = YEAR(NOW())   
AND 'status' !='Cancelled' 
GROUP BY Productname);

SELECT *, Total_sold - Total_RecommendedPrice as Difference
From Test_MSRP
ORDER BY Difference ASC;

-- Correction top 5 revenue by order POWERBI

select c.country as Customer_country,c.city as city_customer, customerName,
round(sum(priceEach*quantityOrdered)/ count(quantityOrdered)) as CA_par_commande from customers as c
left join offices as off
using(country)
left join orders as o
using(customerNumber)
left join orderdetails as od
using(orderNumber)
where status like 'Shipped' 
group by  customerName
order by  CA_par_commande desc , customerName;
