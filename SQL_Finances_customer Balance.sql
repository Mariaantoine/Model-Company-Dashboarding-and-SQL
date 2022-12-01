use toys_and_models;

-- we can see which clients are on debt and shows the comments about their relations with our company

SELECT 	*,
	CASE WHEN T4.orderCancelled IS NULL THEN T3.orderTurnover-T2.customerTurnover ELSE (T3.orderTurnover-T4.orderCancelled)-T2.customerTurnover END AS customerDebt,
	CASE WHEN T4.orderCancelled IS NULL THEN 0 ELSE T4.orderCancelled END AS Cancelledorder,
	CASE WHEN T1.comments = '' THEN 'No' ELSE 'Yes' END AS Incident
FROM (SELECT od.orderNumber,
		CASE WHEN o.comments IS NULL THEN '' ELSE o.comments END AS comments,
		o.customerNumber, o.orderDate, o.requiredDate,
		CASE WHEN o.shippedDate IS NULL THEN '' ELSE o.shippedDate END AS shippedDate,
		o.status, c.contactFirstName, c.contactLastName, c.country, c.creditLimit,
		SUM(od.quantityOrdered*od.priceEach) AS orderTotal
	FROM orders AS o
	JOIN orderdetails AS od 
    ON od.orderNumber = o.orderNumber
	JOIN customers AS c 
    ON c.customerNumber = o.customerNumber
	GROUP BY od.orderNumber) AS T1
		LEFT OUTER JOIN (SELECT p.customerNumber AS idclient2, SUM(p.amount) AS customerTurnover FROM payments AS p
	JOIN customers AS c ON 	p.customerNumber = c.customerNumber
	GROUP BY p.customerNumber) AS T2 ON T1.customerNumber = T2.idclient2
		LEFT OUTER JOIN (SELECT o.customerNumber AS idclient3, SUM(od.quantityOrdered*od.priceEach) AS orderTurnover
	FROM orders AS o 
    JOIN orderdetails AS od ON od.orderNumber = o.orderNumber
	GROUP BY o.customerNumber) AS T3 ON T1.customerNumber = T3.idclient3
		LEFT OUTER JOIN 
	(SELECT o.customerNumber AS idclient4, SUM(od.quantityOrdered*od.priceEach) AS orderCancelled FROM orders AS o
	JOIN orderdetails AS od ON od.orderNumber = o.orderNumber
	WHERE o.status = 'Cancelled'
	GROUP BY o.customerNumber) AS T4 ON T1.customerNumber = T4.idclient4;
