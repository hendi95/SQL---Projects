-- DASHBOARD 2 - Inventory Management


-- Calculated Cost of Pizza -- Percentage Stock Remaining by Ingredient

ALTER VIEW vw_Dashboard2_part2 AS
SELECT 
    s2.ing_name,
    s2.ordered_weight,
    ing.ing_weight * inv.quantity AS total_inv_weight,
    (ing.ing_weight * inv.quantity) - s2.ordered_weight AS remaining_weight,
    CAST(((ing.ing_weight * inv.quantity) - s2.ordered_weight) AS DECIMAL(10, 2)) / (ing.ing_weight * inv.quantity) AS percentage_remaining
FROM (
    SELECT
        ing_id,
        ing_name,
        item_id,
        SUM(ordered_weight) AS ordered_weight
    FROM
        vw_Dashboard2_part1
    GROUP BY 
        ing_id,
        ing_name,
        item_id
) s2
LEFT JOIN inventory inv ON inv.item_id = s2.item_id
LEFT JOIN ingredients ing ON ing.ing_id = s2.ing_id;

