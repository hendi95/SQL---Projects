-- DASHBOARD 2 - Inventory Management


-- Calculated Cost of Pizza -- Percentage Stock Remaining by Ingredient

ALTER VIEW vw_Dashboard2_part1 AS
WITH RecipeOrders AS (
    SELECT
        o.item_id,
        i.sku,
        i.item_name,
		i.item_category,
        r.ing_id,
        ing.ing_name,
        r.quantity as recipe_quantity,
        SUM(o.quantity) as order_quantity,
        ing.ing_weight,
        ing.ing_price
    FROM orders o 
    LEFT JOIN items i ON o.item_id = i.item_id
    LEFT JOIN recipes r ON i.sku = r.recipe_id
    LEFT JOIN ingredients ing ON ing.ing_id = r.ing_id
    GROUP BY 
        o.item_id, 
        i.sku, 
        i.item_name, 
        r.ing_id, 
        r.quantity, 
        ing.ing_name, 
        ing.ing_weight, 
        ing.ing_price,
		i.item_category
)
SELECT 
    item_id,
	item_name,
	item_category,
    ing_name,
    ing_id,
    ing_weight,
    ing_price,
    order_quantity,
    recipe_quantity,
    order_quantity * recipe_quantity AS ordered_weight,
    ing_price / ing_weight AS unit_cost,
    (ing_price * recipe_quantity) * (ing_price / ing_weight) AS ingredient_cost
FROM RecipeOrders;







