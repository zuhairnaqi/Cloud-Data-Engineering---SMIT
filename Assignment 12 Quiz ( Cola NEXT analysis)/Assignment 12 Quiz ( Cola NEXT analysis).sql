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

with successful_orders_cts AS (
	SELECT ProductID, count(*) as total FROM PurchaseOrderDetail od
		WHERE NOT EXISTS (
			SELECT * FROM Returns r
			where r.OrderID = od.OrderID
		)
		GROUP BY ProductID
)
SELECT p.ProductID, p.Name as ProductName, so.total  FROM successful_orders_cts AS so
	INNER JOIN Product p
	ON p.ProductID = so.ProductID


