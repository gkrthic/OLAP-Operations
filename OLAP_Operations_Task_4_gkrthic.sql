-- 4.OLAP Operations 

--1.Database creation

CREATE TABLE sales_sample (
    Product_id INT,
    Region VARCHAR(50),
    Sales_date DATE,
    Sales_amount NUMERIC(10,2) 
);

--2.Data creation

INSERT INTO sales_sample (product_id, region, sales_date, sales_amount)
VALUES
(1, 'Gotham', '2024-01-01', 500.00),
(2, 'Metropolis', '2024-01-02', 700.00),
(3, 'Themyscira', '2024-01-03', 800.00),
(4, 'Central City', '2024-01-04', 600.00),
(5, 'Atlantis', '2024-01-05', 750.00),
(6, 'New York', '2024-01-06', 550.00),     
(7, 'Asgard', '2024-01-07', 850.00),        
(8, 'Wakanda', '2024-01-08', 650.00),    
(9, 'Xandar', '2024-01-09', 720.00),        
(10, 'Latveria', '2024-01-10', 900.00);    

--3.OLAP operation

--a Drill Down Analyses


WITH RegionSales AS (
    SELECT 
        region,
        SUM(sales_amount) AS total_sales_region
    FROM sales_sample
    GROUP BY region
),
ProductSales AS (
    SELECT 
        region,
        product_id,
        SUM(sales_amount) AS total_sales_product
    FROM sales_sample
    GROUP BY region, product_id
)
SELECT 
    R.region,
    R.total_sales_region,
    P.product_id,
    P.total_sales_product,
    P.total_sales_product * 100.0 / R.total_sales_region AS percentage_of_region_sales
FROM 
    RegionSales R
JOIN 
    ProductSales P ON R.region = P.region
ORDER BY 
    R.region, P.product_id;
	
--single region





--b Roll up

SELECT 
    region,
    product_id,
    SUM(sales_amount) AS total_sales
FROM sales_sample
GROUP BY region, product_id WITH ROLLUP
ORDER BY region, product_id;

--c. Cube

SELECT 
    product_id,
    region,
    sales_date,
    SUM(sales_amount) AS total_sales
FROM sales_sample
GROUP BY CUBE (product_id, region, sales_date)
ORDER BY product_id, region, sales_date;

--Cube is not working for me in mysql, hence generated similar output using multiple aggregation command

SELECT 
    product_id,
    region,
    sales_date,
    SUM(sales_amount) AS total_sales
FROM sales_sample
GROUP BY product_id, region, sales_date

UNION ALL

SELECT 
    product_id,
    region,
    NULL AS sales_date,
    SUM(sales_amount) AS total_sales
FROM sales_sample
GROUP BY product_id, region

UNION ALL

SELECT 
    product_id,
    NULL AS region,
    NULL AS sales_date,
    SUM(sales_amount) AS total_sales
FROM sales_sample
GROUP BY product_id

UNION ALL

SELECT 
    NULL AS product_id,
    region,
    NULL AS sales_date,
    SUM(sales_amount) AS total_sales
FROM sales_sample
GROUP BY region

UNION ALL

SELECT 
    NULL AS product_id,
    NULL AS region,
    sales_date,
    SUM(sales_amount) AS total_sales
FROM sales_sample
GROUP BY sales_date

UNION ALL

SELECT 
    NULL AS product_id,
    NULL AS region,
    NULL AS sales_date,
    SUM(sales_amount) AS total_sales
FROM sales_sample

ORDER BY product_id, region, sales_date;



-- d.slice 

--by region
SELECT 
    product_id,
    sales_date,
    SUM(sales_amount) AS total_sales
FROM sales_sample
WHERE region = 'Gotham' 
GROUP BY product_id, sales_date
ORDER BY product_id, sales_date;
-- by date

SELECT product_id,
    region,
    SUM(sales_amount) AS total_sales
FROM sales_sample
WHERE sales_date BETWEEN '2024-01-01' AND '2024-01-31'
GROUP BY product_id, region
ORDER BY product_id, region;


--e.dice
SELECT 
    product_id,
    region,
    sales_date,
    SUM(sales_amount) AS total_sales
FROM sales_sample
WHERE 
    product_id IN (1, 2) 
    AND region IN ('Gotham', 'Metropolis')  
    AND sales_date BETWEEN '2024-01-01' AND '2024-01-05' 
GROUP BY product_id, region, sales_date
ORDER BY product_id, region, sales_date;

