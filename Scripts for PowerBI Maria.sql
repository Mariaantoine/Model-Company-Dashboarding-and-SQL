use toys_and_models;

   
    -- CA par commande group by client
select YEAR(o.orderDate) AS Year, MONTH(o.orderDate) AS Month, customerName,round(sum(priceEach*quantityOrdered)/ count(quantityOrdered)) as CA_par_commande from customers
left join orders as o 
using(customerNumber)
left join orderdetails as od
using(orderNumber)
where status like 'Shipped'
group by  YEAR(o.orderDate), MONTH(o.orderDate), customerName
order by  YEAR(o.orderDate), MONTH(o.orderDate),CA_par_commande desc  limit 10
;

-- ALSO
select customerName,round(sum(priceEach*quantityOrdered)/ count(quantityOrdered)) as CA_par_commande from customers
left join orders as o
using(customerNumber)
left join orderdetails as od
using(orderNumber)
where status like 'Shipped'
group by  customerName
order by  CA_par_commande asc , customerName asc limit 5;

-- AND also

select customerName, Year(orderDate), Month(orderDate), round(sum(priceEach*quantityOrdered)/ count(quantityOrdered)) as CA_par_commande from customers
left join orders as o
using(customerNumber)
left join orderdetails as od
using(orderNumber)
where status like 'Shipped'
group by Year(orderDate), Month(orderDate)
order by  Year(orderDate), Month(orderDate)
;

-- CA by productline




-- Quantité de commande par mois par office
SELECT concat(month(orderDate)," ", year(orderDate)) as mois_annee, count(quantityOrdered) AS Total_quantity_by_month, off.city
FROM orders
left join orderdetails as od
using(orderNumber)
left join customers as c
using (customerNumber)
left join employees as e
on e.employeeNumber = c.salesRepEmployeeNumber
left join offices as off
using(officeCode)
GROUP BY concat(month(orderDate), year(orderDate)), off.city
ORDER BY orderDate desc,count(quantityOrdered) desc, off.city desc;

SELECT month(orderDate) as month, year(orderDate)as year, count(quantityOrdered) AS Total_quantity_by_month, off.city
FROM orders
left join orderdetails as od
using(orderNumber)
left join customers as c
using (customerNumber)
left join employees as e
on e.employeeNumber = c.salesRepEmployeeNumber
left join offices as off
using(officeCode)
GROUP BY year, month, off.city
ORDER BY orderDate desc,count(quantityOrdered) desc, off.city desc;

-- we can see the difference in price between the price we sell ans the price recommended towards in the retail

WITH test AS(
    SELECT DATE_FORMAT(o.orderDate,'%Y-%m') AS YearMonth, p.productName, buyPrice,
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

SELECT YearMonth, productName,PriceSold, RecommendedPrice,buyPrice,
PriceSold-RecommendedPrice as Differenceinprice
FROM test
order by Differenceinprice desc
;

-- difference entre produit de vente / achat / MSRP 
WITH test AS(
    SELECT  p.productName,DATE_FORMAT(o.orderDate,'%Y-%m') AS YearMonth, buyPrice,
    od.priceEach AS PriceSold,
    p.MSRP as RecommendedPrice
    FROM orderdetails as od
    INNER JOIN orders as o
    USING(orderNumber) 
    INNER JOIN products as p
    USING (productCode)
    WHERE YEAR(o.orderDate) = YEAR(NOW())   
    AND o.status !='Cancelled' 
    GROUP BY  p.productName, YearMonth
    ORDER BY p.productName, YearMonth)

SELECT productName,YearMonth, PriceSold, RecommendedPrice,buyPrice,
PriceSold-RecommendedPrice as Differenceinprice
FROM test
order by productName
;
-- we can see how many products (number of products) have NO difference in the MSRP nad the final price

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

SELECT YearMonth, Count(productName),PriceSold, RecommendedPrice,
PriceSold-RecommendedPrice as Differenceinprice
FROM test
where (PriceSold-RecommendedPrice)=0;

-- here we can see the top 5 products with the biggest difference in MSRP and final price sold

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
FROM test
order by Differenceinprice asc limit 5
;

-- to compare the price sold with the MSRP we have and decide if we need to increase the prices

Create view Maria as (
SELECT productname, sum(quantityordered) as total_sold, round(avg(priceeach),2) as average_price_sold, MSRP,
sum(quantityordered)*MSRP as Total_RecommendedPrice, sum(quantityordered)*round(avg(priceeach),2) as Totalamount
FROM orderdetails
INNER JOIN products
USING (productcode)
INNER JOIN orders
USING (ordernumber)
WHERE YEAR(orderDate) = YEAR(NOW())   
AND 'status' !='Cancelled' 
GROUP BY Productname);

SELECT *, Totalamount - Total_RecommendedPrice as Difference
From Maria
ORDER BY Difference ASC;


-- Le nombre de produits vendus par catégorie et par mois, 
-- avec comparaison et taux de variation par rapport au même mois de l'année précédente. DV maria

WITH order_number AS( 
    SELECT MONTH(o.orderDate) as month_per_order, p.productLine as productline, 
    sum(CASE  WHEN YEAR(o.orderDate)=year(now())-1 THEN od.quantityOrdered 
        ELSE 0 END) AS lastyearquantity, 
    sum(CASE WHEN YEAR(o.orderDate)=year(now()) THEN od.quantityOrdered 
        ELSE 0 END) AS currentyearquantity
    FROM orderdetails as od 
    INNER JOIN orders as o 
    USING(orderNumber) 
    LEFT JOIN products as p 
    USING (productCode) 
    WHERE o.status !='Cancelled' 
    GROUP BY p.productLine, month_per_order
    ORDER BY p.productLine,month_per_order) 

 
SELECT productline,month_per_order, lastyearquantity,currentyearquantity, currentyearquantity/lastyearquantity-1 as rateofchange
    FROM order_number; 
    
    
    -- commande annulée par client
select customerName, count(customerName) as nb_cmd_annulee from customers
left join orders as o
using(customerNumber)
left join orderdetails as od
using(orderNumber)
where status like 'Cancelled'
group by customerName
order by count(customerName)desc , customerName asc;

-- Le CA des commandes des deux derniers mois par pays. DV maria
select off.country, sum(od.quantityOrdered * od.PriceEach) as CA_last_2_months from orders as ord
inner join orderdetails as od
using(orderNumber)
inner join customers as c
using (customerNumber)
inner join employees as e
on e.employeeNumber = c.salesRepEmployeeNumber
inner join offices as off
using(officeCode)
WHERE year(orderDate) = year(now()) and MONTH(orderDate) between (month(now()) - 2) and month(now())
group by off.country
order by CA_last_2_months desc;

-- OR 
SELECT orders.orderNumber, orderDate, status, country, SUM(priceEach*quantityOrdered) AS totalPrice
FROM orders
INNER JOIN customers
ON orders.customerNumber=customers.customerNumber
INNER JOIN orderdetails
ON orderdetails.orderNumber=orders.orderNumber
WHERE year(orderDate) = year(now()) and MONTH(orderDate) between (month(now()) - 2) and month(now())
group by off.country
order by CA_last_2_months desc;

-- Chaque mois, les 2 vendeurs avec le CA le plus élevé.
-- top vendeur chaque mois
use toys_and_models;

SELECT	*FROM 
	(SELECT	YEAR(o.orderDate) AS Year, MONTH(o.orderDate) AS Month, CONCAT(e.lastName, e.firstName) AS Fullname, SUM(od.quantityOrdered*priceEach) AS CA
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
    
    
    -- sales per category in August and shows the difference with last year
    
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

Si la marge est faible, l'entreprise peut augmenter ses prix de vente. Si au contraire sa marge est haute, 
l'entreprise peut baisser ses prix de vente en vue d'augmenter ses volumes de vente. 
Dans les deux cas, l'entreprise augmente son chiffre d'affaires. L'entreprise détermine son seuil de rentabilité.
*/

-- utilisation d'un WITH pour pouvoir utiliser les alias créés.

WITH calculate_MCD AS(
    SELECT MONTH(orderDate) as monthDate, offices.country as Countries, productLine,
    SUM(CASE WHEN YEAR(orderDate)=YEAR(NOW()) THEN od.quantityOrdered*od.priceEach
    ELSE 0 END) AS pricesold,
    SUM(CASE WHEN YEAR(orderDate)=YEAR(NOW())-1 THEN od.quantityOrdered*od.priceEach
    ELSE 0 END) AS pricesoldyearbefore,
    SUM(CASE WHEN YEAR(orderdate)=YEAR(NOW()) THEN od.quantityOrdered*p.buyPrice
    ELSE 0 END)  as pricewebuy,
    SUM(CASE WHEN YEAR(orderdate)=YEAR(NOW())-1 THEN od.quantityOrdered*p.buyPrice
    ELSE 0 END)  as pricewebuyyearbefore
    FROM orderdetails as od
    INNER JOIN orders as o
    USING(orderNumber) 
    INNER JOIN products as p
    USING (productCode)
    INNER JOIN customers as c
    USING(customerNumber)
    INNER JOIN employees as e
    ON c.salesRepEmployeeNumber = e.employeeNumber
    INNER JOIN offices 
    USING(officeCode)
    WHERE YEAR(o.orderDate) >= YEAR(NOW())-1   
    AND o.status !='Cancelled' 
    GROUP BY monthDate,Countries
    ORDER BY monthDate,Countries)

SELECT monthDate,Countries,pricesold,pricewebuy,productLine,
pricesold-pricewebuy  as MCD,
pricesoldyearbefore,pricewebuyyearbefore,
pricesoldyearbefore-pricewebuyyearbefore  as MCD_lastyear

FROM calculate_MCD;


