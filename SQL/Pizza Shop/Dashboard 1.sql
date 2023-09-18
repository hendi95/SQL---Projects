-- DASHBOARD 1 - ORDER ACTIVITY

-- Total Orders -- Total Sales -- Total Items -- Average Order Value -- Sales by Category 
-- Top Selling Items -- Orders by Hour -- Sales by Hour -- Orders by Address -- Orders by Delivery/pick up

CREATE VIEW vw_Dashboard1 AS

SELECT 
    'ORDER' + RIGHT('000' + CAST(ROW_NUMBER() OVER (ORDER BY o.created_at) AS VARCHAR), 3) AS order_id,
    SUM(quantity) AS TotalItems,
    item_price,
	SUM(item_price * quantity) AS TotalSales,
    item_category AS SalesByCategory,
    item_name AS TopSellingItems,
    FORMAT(created_at, 'yyyy-MM-dd HH:mm:ss.fff') AS OrderTime,
    delivery_address1 + ', ' + 
    COALESCE(delivery_address2 + ', ', '') +delivery_zipcode AS OrderAddress,
    delivery_city, 
    
    CASE 
        WHEN delivery = 1 THEN 'Delivery'
        ELSE 'Pick up'
    END AS OrderDeliveryType
FROM orders o 
LEFT JOIN items i ON o.item_id = i.item_id
LEFT JOIN addresss a ON o.add_id = a.add_id
GROUP BY 
    item_category,
    item_name,
    created_at,
    delivery_address1,
    delivery_address2,
    delivery_city,
    delivery_zipcode,
    delivery,
	item_price

