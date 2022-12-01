-- category sales of last month

SELECT
	SUM(quantityOrdered) Total,
	CASE WHEN productLine = 'Classic Cars' THEN SUM(quantityOrdered) ELSE 0 END `Classic Cars`,
    CASE WHEN productLine = 'Motorcycles' THEN SUM(quantityOrdered) ELSE 0 END `Motorcycles`,
    CASE WHEN productLine = 'Trucks and Buses' THEN SUM(quantityOrdered) ELSE 0 END `Trucks and Buses`,
    CASE WHEN productLine = 'Planes' THEN SUM(quantityOrdered) ELSE 0 END `Planes`,
    CASE WHEN productLine = 'Vintage Cars' THEN SUM(quantityOrdered) ELSE 0 END `Vintage Cars`,
    CASE WHEN productLine = 'Ships' THEN SUM(quantityOrdered) ELSE 0 END `Ships`,
    CASE WHEN productLine = 'Trains' THEN SUM(quantityOrdered) ELSE 0 END `Trains`
FROM orderdetails od
JOIN orders o
ON od.orderNumber = o.orderNumber
JOIN products p
ON p.productCode = od.productCode
WHERE MONTH(orderDate) =
	(SELECT MONTH(orderDate) date
	FROM
		(SELECT orderDate
		FROM orders
		ORDER BY orderDate DESC
		LIMIT 1) lastMonth
	)
AND YEAR(orderDate) =
	(SELECT YEAR(orderDate) date
	FROM
		(SELECT orderDate
		FROM orders
		ORDER BY orderDate DESC
		LIMIT 1) lastYear
	)
GROUP BY productLine;
