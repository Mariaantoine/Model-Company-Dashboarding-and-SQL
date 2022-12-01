use toys_and_models;

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
