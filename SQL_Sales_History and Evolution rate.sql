use toys_and_models;


select SUM(od.quantityOrdered) as Products_sold, customerName as Name_entreprise, sum(priceEach*quantityOrdered) as CA,  
CAST(DATE_FORMAT(o.orderDate,'%Y%m') AS UNSIGNED) `id date`, DATE_FORMAT(o.orderDate,'%M %Y') `Period`,
		SUM(CASE WHEN CAST(DATE_FORMAT(o.orderDate,'%Y') AS UNSIGNED) like 2021
		THEN od.quantityOrdered
		ELSE NULL
	END) ,
    SUM(CASE WHEN CAST(DATE_FORMAT(o.orderDate,'%Y%m') AS UNSIGNED) BETWEEN 201900 AND 202000
		THEN od.quantityOrdered
		ELSE NULL
	END) `Year 2020`,
	SUM(CASE WHEN CAST(DATE_FORMAT(o.orderDate,'%Y%m') AS UNSIGNED) BETWEEN 202100 AND 202200
		THEN od.quantityOrdered
		ELSE NULL
	END) `Year 2022`
FROM orders as o
JOIN orderdetails od
ON o.orderNumber = od.orderNumber
JOIN customers as c
ON o.customerNumber = c.customerNumber
group by customerName
order by CA desc limit 10;

