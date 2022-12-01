use toys_and_models;

-- The stock of the 5 most ordered products.

SELECT products.productname,
       products.productcode,
       products.quantityinstock,
       Sum(orderdetails.quantityordered) AS Total_quantity
FROM   products
       INNER JOIN orderdetails
               ON products.productcode = orderdetails.productcode
       INNER JOIN orders
               ON orderdetails.ordernumber = orders.ordernumber
GROUP  BY products.productname,
          products.productcode,
          products.quantityinstock
ORDER  BY total_quantity DESC
LIMIT  5; 


-- the quantity of the 5 most ordered products

SELECT quantityordered,
       productcode,
       products.productname AS ProdName,
       products.productscale
FROM   orders
       LEFT JOIN orderdetails USING(ordernumber)
       LEFT JOIN products USING(productcode)
WHERE  orderdate BETWEEN '2021-01-01' AND '2021-12-31'
GROUP  BY prodname
ORDER  BY quantityordered ASC
LIMIT  5; 


-- source https://database.guide/datediff-examples-mysql/
-- calculates the number of orders being delivered on time etc etc
-- we do the difference bwtween the shipping date and the expecting date of delivert 
-- then with case we introduce our comments for the orders statuses
-- not shipped its written like the orders left the same date with the date of order
-- add a period of months in order to see all delays in expedition during the year


    SELECT dateanalysis.comments as OrdersStatus, COUNT(dateanalysis.orderNumber) AS Numberoforders
FROM (SELECT orders.orderNumber, DATEDIFF(orders.shippedDate,orders.requiredDate) AS datediff,
	CASE 
		WHEN DATEDIFF(orders.shippedDate,orders.requiredDate)<0 THEN 'Shipment date prior to expected date'
		WHEN DATEDIFF(orders.shippedDate,orders.requiredDate)>0 THEN 'Shipment date anterior to expected date'
		WHEN DATEDIFF(orders.shippedDate,orders.requiredDate) IS NULL THEN 'Not shipped'
		ELSE 'Delivery date = Expected date'
	END comments FROM orders) AS dateanalysis
GROUP BY dateanalysis.comments 
ORDER BY Numberoforders DESC;

-- here we can see how long it takes the entrepot/warehouse to prepare the orders

SELECT
	orderDate AS Date,
	ROUND(DATEDIFF(orders.shippedDate,orders.orderDate),1)as `Processing time in days`
FROM orders
order by Date desc;

-- average time of order preparation in all database

SELECT avg(ROUND(DATEDIFF(orders.shippedDate,orders.orderDate),1)) as Processing_time_in_days
FROM orders;


-- average time of order preparation for the last 2 months

SELECT avg(ROUND(DATEDIFF(orders.shippedDate,orders.orderDate),1)) as Processing_time_in_days
FROM orders
WHERE year(orderDate) = year(now()) and MONTH(orderDate) between (month(now()) -2) and month(now())
;

-- average time of order preparation for all years

SELECT year(orderDate), avg(ROUND(DATEDIFF(orders.shippedDate,orders.orderDate),1)) as Processing_time_in_days
FROM orders
group by year(orderDate);

select * from orderdetails;
