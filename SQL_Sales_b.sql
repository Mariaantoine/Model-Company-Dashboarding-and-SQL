use toys_and_modesls;
SELECT actual.Category `CATÉGORIE`, CONVERT(CONCAT(SUBSTRING(actual.idDate,1,4),SUBSTRING(actual.idDate,6,2)),UNSIGNED) `id date`, DATE_FORMAT(TIMESTAMP(CONCAT(actual.idDate,'-01')),'%M %Y') `PÉRIODE`,
	CASE WHEN actual.Total IS NULL then 0 else actual.Total END `PRODUITS VENDUS`,
    CASE WHEN previous.Total IS NULL THEN 0 else previous.Total END `ANNÉE PRÉCÉDENTE`,
    CASE WHEN previous.Total IS NULL THEN 0
		WHEN actual.Total IS NULL THEN -1
        ELSE ROUND((actual.Total - previous.Total)/previous.Total,2) END `ÉVOLUTION`
FROM
	(SELECT CategoriesDates.Category, CategoriesDates.idDate, Sales.Total
	FROM
		(SELECT p.productLine Category, SUM(od.quantityOrdered) Total, DATE_FORMAT(o.orderDate,'%Y-%m') idDate
		FROM products p
		JOIN orderdetails od 
		ON od.productCode = p.productCode
		JOIN orders o 
		ON o.orderNumber = od.orderNumber
		GROUP BY Category, idDate) Sales
	RIGHT JOIN 
		(SELECT p.productLine Category, d.idDate 
		FROM 
			(SELECT DISTINCT DATE_FORMAT(o.orderDate,'%Y-%m') idDate
			FROM orders o
			) d
		JOIN productlines p) CategoriesDates
	ON Sales.idDate = CategoriesDates.idDate
	AND Sales.Category = CategoriesDates.Category)
    actual
JOIN
	(SELECT CategoriesDates.Category, CategoriesDates.idDate, Sales.Total
	FROM
		(SELECT p.productLine Category, SUM(od.quantityOrdered) Total, DATE_FORMAT(o.orderDate,'%Y-%m') idDate
		FROM products p
		JOIN orderdetails od 
		ON od.productCode = p.productCode
		JOIN orders o 
		ON o.orderNumber = od.orderNumber
		GROUP BY Category, idDate) Sales
	RIGHT JOIN 
		(SELECT p.productLine Category, d.idDate 
		FROM 
			(SELECT DISTINCT DATE_FORMAT(o.orderDate,'%Y-%m') idDate
			FROM orders o
			) d
		JOIN productlines p) CategoriesDates
	ON Sales.idDate = CategoriesDates.idDate
	AND Sales.Category = CategoriesDates.Category)
    previous
ON previous.Category = actual.Category 
AND TIMESTAMP(CONCAT(actual.idDate,'-01')) = TIMESTAMP(CONCAT(previous.idDate,'-01')) + INTERVAL 1 YEAR
WHERE 
	YEAR(TIMESTAMP(CONCAT(actual.idDate,'-01'))) =
	(SELECT DISTINCT YEAR(o.orderDate) Year
	FROM orders o
	ORDER BY Year DESC 
	LIMIT 1)
OR 
	(YEAR(TIMESTAMP(CONCAT(actual.idDate,'-01')) + INTERVAL 1 YEAR)  =
	(SELECT DISTINCT YEAR(o.orderDate) Year
	FROM orders o
	ORDER BY Year DESC 
	LIMIT 1)
    AND
	MONTH(TIMESTAMP(CONCAT(actual.idDate,'-01'))) > 
	(SELECT DISTINCT MONTH(o.orderDate) Month
	FROM orders o
	WHERE YEAR(o.orderDate) =
		(SELECT DISTINCT YEAR(o.orderDate) Year
		FROM orders o
		ORDER BY Year DESC 
		LIMIT 1)
	ORDER BY Month DESC 
	LIMIT 1))
ORDER BY `id date` DESC, `CATÉGORIE`
LIMIT 7;
