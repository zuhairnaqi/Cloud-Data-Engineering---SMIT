-- Q1. List top 5 customers by total order amount.
-- Retrieve the top 5 customers who have spent the most across all sales orders. Show CustomerID, CustomerName, and TotalSpent.

WITH top_10_total_spend AS (
	SELECT TOP(10) * FROM (
		SELECT CustomerID, SUM(TotalAmount) AS TotalSpend FROM SalesOrder
		GROUP BY CustomerID
	) AS t ORDER BY t.TotalSpend DESC
)

SELECT c.Name AS CustomerName, t.CustomerID, t.TotalSpend FROM top_10_total_spend t
	INNER JOIN customer c
	ON c.CustomerID = t.CustomerID
	
-- Q2. Find the number of products supplied by each supplier.
-- Display SupplierID, SupplierName, and ProductCount. Only include suppliers that have more than 10 products.

SELECT s.Name, sp.SupplierID, ProductCount FROM (
	SELECT SupplierID, COUNT(DISTINCT ProductID) as ProductCount FROM PurchaseOrder o
		LEFT JOIN PurchaseOrderDetail od
		ON od.OrderID = o.OrderID
		GROUP BY o.SupplierID
) AS sp
	INNER JOIN Supplier AS s
	ON s.SupplierID = sp.SupplierID
	WHERE ProductCount >= 10

-- Q3. Identify products that have been ordered but never returned.
-- Show ProductID, ProductName, and total order quantity.

with returned_produces_cte AS (
	SELECT DISTINCT ProductID FROM PurchaseOrderDetail od
		WHERE EXISTS (
			SELECT 1 FROM ReturnDetail r
			where r.ProductID = od.ProductID
		)
)

SELECT p.ProductID, p.Name as ProductName, pto.TotalOrderQuantity  FROM (
	SELECT ProductID, count(*) as TotalOrderQuantity FROM SalesOrderDetail od
		GROUP BY ProductID
) AS pto
	INNER JOIN Product p
	ON p.ProductID = pto.ProductID
	WHERE NOT EXISTS (
		SELECT r.ProductID FROM returned_produces_cte r
		where r.ProductID = p.ProductID
	)

-- Q4. For each category, find the most expensive product.
-- Display CategoryID, CategoryName, ProductName, and Price. Use a subquery to get the max price per category.

WITH max_price_product_category AS (
	SELECT p.ProductID, p.Name, p.CategoryID, p.Price FROM Product p
		WHERE p.price = (
			SELECT MAX(price) FROM Product pc
			WHERE pc.CategoryID = p.CategoryID
		)
)

SELECT pc.CategoryID, c.Name as CategoryName, pc.ProductID, pc.Name as ProductName, pc.Price FROM max_price_product_category pc
	INNER JOIN Category c
	ON c.CategoryID = pc.CategoryID
	ORDER BY pc.CategoryID

-- Q5. List all sales orders with customer name, product name, category, and supplier.
-- For each sales order, display:
-- OrderID, CustomerName, ProductName, CategoryName, SupplierName, and Quantity.

SELECT 
	so.OrderID,
	 c.Name AS CustomerName,
    p.Name AS ProductName,
    cat.Name AS CategoryName,
    m.Name AS ManufacturerName,
	od.Quantity
FROM SalesOrder so
	INNER JOIN SalesOrderDetail od ON od.OrderID = so.OrderID
	INNER JOIN Customer c ON c.CustomerID = so.CustomerID
	INNER JOIN Product p ON p.ProductID = od.ProductID
	INNER JOIN Category cat ON cat.CategoryID= p.CategoryID
	INNER JOIN manufacturer m ON p.ManufacturerID = m.ManufacturerID
	ORDER BY so.OrderID, od.ProductID



