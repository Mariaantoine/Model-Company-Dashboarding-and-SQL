use toys_and_models;

-----**-------------------------------BASIC FUNCTIONS EXplanations that I used--------------------------------------------------*-----
```
-- MONTHNAME - function that returns the month according to the orderDate
-- Concat in order to show the full name of the employee in one cell
```
-----**---------------------------------------------------------------------------------------------------------------------------------------------------------*-----


-- Dispaly the top 2 Employees for August

SELECT orderdate,
       Monthname(orders.orderdate)      AS Month,
       Concat(firstname, ' ', lastname) AS Name,
       priceeach * quantityordered      AS TotalPrice
FROM   employees
       INNER JOIN customers
               ON customers.salesrepemployeenumber = employees.employeenumber
       INNER JOIN orders
               ON orders.customernumber = customers.customernumber
       INNER JOIN orderdetails
               ON orderdetails.ordernumber = orders.ordernumber
                  AND 12 * Year(orderdate) + Month(orderdate) =
                      12 * Year(CURRENT_TIMESTAMP) + Month(CURRENT_TIMESTAMP)
                      - 1
GROUP  BY Monthname(orders.orderdate),
          name
ORDER  BY totalprice DESC
LIMIT  2; 


-- Revenue for the top 5 employees, automatically updated every month 

SELECT Date_format(orderdate, '%m-%Y')  AS month_year_order,
       Concat(firstname, ' ', lastname) AS full_name,
       Sum(priceeach * quantityordered) AS TotalPrice
FROM   employees
       INNER JOIN customers
               ON customers.salesrepemployeenumber = employees.employeenumber
       INNER JOIN orders
               ON orders.customernumber = customers.customernumber
       INNER JOIN orderdetails
               ON orderdetails.ordernumber = orders.ordernumber
WHERE  ( Year(orderdate) = Year(Now()) )
       AND ( Month(orderdate) = Month(Now()) - 1 )
GROUP  BY month_year_order,
          full_name
ORDER  BY totalprice DESC
LIMIT  5; 


SELECT Month(orderdate),
       Year(orderdate),
       Concat(firstname, ' ', lastname)                  AS full_name,
       Sum(priceeach * quantityordered)                  AS TotalPrice,
       Rank()
         OVER(
           partition BY Month(orderdate), Year(orderdate)
           ORDER BY Sum(priceeach*quantityordered) DESC) AS Classement
FROM   employees
       INNER JOIN customers
               ON customers.salesrepemployeenumber = employees.employeenumber
       INNER JOIN orders
               ON orders.customernumber = customers.customernumber
       INNER JOIN orderdetails
               ON orderdetails.ordernumber = orders.ordernumber
GROUP  BY orderdate
ORDER  BY orderdate DESC,
          classement ASC; 
          
--- CODE to disply the top 2 employees with the highest revenue for all the months

SELECT	*FROM 
	(SELECT	YEAR(o.orderDate) AS Year, MONTH(o.orderDate) AS Month, CONCAT(e.lastName," ", e.firstName) AS Fullname, SUM(od.quantityOrdered*priceEach) AS CA
	FROM employees AS e
	JOIN customers AS c ON e.employeeNumber = c.salesRepEmployeeNumber
	JOIN orders AS o ON c.customerNumber = o.customerNumber
	JOIN orderdetails AS od ON od.orderNumber = o.orderNumber
	GROUP BY YEAR(o.orderDate), MONTH(o.orderDate), Fullname
	ORDER BY YEAR(o.orderDate), MONTH(o.orderDate), SUM(od.quantityOrdered*priceEach) desc) AS Table1
WHERE (SELECT COUNT(*) FROM
		(SELECT YEAR(o.orderDate) AS Year, MONTH(o.orderDate) AS Month,
			CONCAT(e.lastName,e.firstName) AS Fullname, SUM(od.quantityOrdered*priceEach) AS CA
		FROM employees AS e
		JOIN customers c ON e.employeeNumber = c.salesRepEmployeeNumber
		JOIN orders AS o ON c.customerNumber=o.customerNumber
		JOIN orderdetails AS od ON od.orderNumber = o.orderNumber
		GROUP BY YEAR(o.orderDate), MONTH(o.orderDate), Fullname
		ORDER BY YEAR(o.orderDate), MONTH(o.orderDate), SUM(od.quantityOrdered*priceEach) desc) Table2
	WHERE Table1.Year = Table2.Year	AND Table1.Month = Table2.Month AND Table2.CA >= Table1.CA) <= 2 ;


