
--Apple Sales Project -- 1M rows Dataset

/*===================
SECTION 1 : BASIC SQL
======================
*/
/*
Q1. Find the total revenue generated from all recorded sales.
*/

SELECT
    SUM(s.quantity * p.price) AS total_revenue
FROM sales s
JOIN products p
ON s.product_id = p.product_id;

/*
Q2.Which product categories contribute the most to the company's overall revenue?
*/

SELECT
    c.category_name,
    (SUM(s.quantity * p.price)) AS total_revenue
FROM sales s
JOIN products p
ON s.product_id = p.product_id
JOIN category c
ON p.category_id = c.category_id
GROUP BY c.category_name
ORDER BY total_revenue DESC;

/*
Q3.Which countries generate the highest revenue from Apple product sales?
*/

SELECT
    st.country,
    (SUM(s.quantity * p.price)) AS total_revenue
FROM sales s
JOIN products p
ON s.product_id = p.product_id
JOIN stores st
ON s.store_id = st.store_id
GROUP BY st.country
ORDER BY total_revenue DESC;

/*
Q4.Which Apple products contribute the most to overall sales revenue?
*/

SELECT
    p.product_name,
    (SUM(s.quantity * p.price)) AS total_revenue
FROM sales s
JOIN products p
ON s.product_id = p.product_id
GROUP BY p.product_name
ORDER BY total_revenue DESC;

/*
Q5.Which stores have generated the highest sales revenue across all recorded transactions?
*/

SELECT
    st.store_name,
    st.city,
    st.country,
    (SUM(s.quantity * p.price)) AS total_revenue
FROM sales s
JOIN products p
ON s.product_id = p.product_id
JOIN stores st
ON s.store_id = st.store_id
GROUP BY st.store_name, st.city, st.country
ORDER BY total_revenue DESC;

/*
=============================
SECTION 2 : INTERMEDIATE SQL
=============================
*/

/*
Q6.How has monthly sales revenue changed over time?
*/

SELECT
    DATE_TRUNC('month', s.sale_date)::date AS month,
    (SUM(s.quantity * p.price)) AS total_revenue
FROM sales s
JOIN products p
ON s.product_id = p.product_id
GROUP BY month
ORDER BY month;


/*
Q7.Which products generate the highest average revenue per unit sold?
*/

SELECT
    p.product_name,
    SUM(s.quantity) AS units_sold,
    SUM(s.quantity * p.price) AS total_revenue,
    (
        SUM(s.quantity * p.price)::numeric /
        SUM(s.quantity)
    ) AS avg_revenue_per_unit
FROM sales s
JOIN products p
ON s.product_id = p.product_id
GROUP BY
    p.product_name
ORDER BY
    avg_revenue_per_unit DESC,
    units_sold DESC;

/*
Q8.Which stores maintain the most balanced product mix across different categories?
*/

SELECT
    st.store_name,
    st.city,
    st.country,
    COUNT(DISTINCT c.category_id) AS categories_available,
    COUNT(DISTINCT p.product_id) AS unique_products,
    SUM(s.quantity) AS units_sold
FROM sales s
JOIN stores st
ON s.store_id = st.store_id
JOIN products p
ON s.product_id = p.product_id
JOIN category c
ON p.category_id = c.category_id
GROUP BY
    st.store_name,
    st.city,
    st.country
ORDER BY
    categories_available DESC,
    unique_products DESC,
    units_sold DESC;

/*
Q9.Which Apple products have the highest warranty claim rate compared to the number of units sold?
*/

WITH product_sales AS (
    SELECT
        p.product_id,
        p.product_name,
        SUM(s.quantity) AS units_sold
    FROM sales s
    JOIN products p
    ON s.product_id = p.product_id
    GROUP BY p.product_id, p.product_name
),

product_claims AS (
    SELECT
        s.product_id,
        COUNT(w.claim_id) AS warranty_claims
    FROM warranty w
    JOIN sales s
    ON w.sale_id = s.sale_id
    GROUP BY s.product_id
)

SELECT
    ps.product_name,
    ps.units_sold,
    COALESCE(pc.warranty_claims,0) AS warranty_claims,
    ROUND(
        COALESCE(pc.warranty_claims,0)::numeric /
        ps.units_sold * 100,
        2
    ) AS claim_rate_pct
FROM product_sales ps
LEFT JOIN product_claims pc
ON ps.product_id = pc.product_id
ORDER BY claim_rate_pct DESC;

/*
Q10.Which stores consistently process higher-value transactions?
*/

SELECT
    st.store_name,
    st.city,
    st.country,
    COUNT(s.sale_id) AS total_transactions,
    SUM(s.quantity) AS total_units_sold,
    (SUM(s.quantity * p.price)) AS total_revenue,
    (
        SUM(s.quantity * p.price)::numeric /
        COUNT(s.sale_id)
        
    ) AS avg_transaction_value
FROM sales s
JOIN stores st
ON s.store_id = st.store_id
JOIN products p
ON s.product_id = p.product_id
GROUP BY
    st.store_name,
    st.city,
    st.country
HAVING COUNT(s.sale_id) >= 10
ORDER BY
    avg_transaction_value DESC,
    total_transactions DESC;


/*
Q11.How quickly are newly launched Apple products contributing to overall sales?
*/

WITH latest_products AS (
    SELECT
        product_id,
        product_name,
        launch_date,
        price
    FROM products
    WHERE launch_date >= (
        SELECT MAX(launch_date) - INTERVAL '2 years'
        FROM products
    )
)

SELECT
    lp.product_name,
    lp.launch_date,
    SUM(s.quantity) AS units_sold,
    (SUM(s.quantity * lp.price)) AS total_revenue,
    COUNT(DISTINCT s.store_id) AS stores_selling
FROM latest_products lp
JOIN sales s
ON lp.product_id = s.product_id
GROUP BY
    lp.product_name,
    lp.launch_date
ORDER BY
    total_revenue DESC,
    units_sold DESC;

/*
Q12

Which cities generate strong customer demand despite having fewer retail stores?
*/

WITH city_summary AS (
    SELECT
        st.city,
        st.country,
        COUNT(DISTINCT st.store_id) AS total_stores,
        SUM(s.quantity) AS units_sold,
        SUM(s.quantity * p.price) AS total_revenue
    FROM sales s
    JOIN stores st
        ON s.store_id = st.store_id
    JOIN products p
        ON s.product_id = p.product_id
    GROUP BY
        st.city,
        st.country
)

SELECT
    city,
    country,
    total_stores,
    units_sold,
    total_revenue,
    ROUND(
        total_revenue::numeric / total_stores
    ) AS revenue_per_store
FROM city_summary
ORDER BY
    revenue_per_store DESC,
    units_sold DESC;

/*
==========================================================
SECTION 3 : JOINS & MULTI-TABLE ANALYSIS
==========================================================
*/

/*
Q13.Which stores generate high revenue despite selling a relatively smaller number of units?
*/

WITH store_performance AS (
    SELECT
        st.store_id,
        st.store_name,
        st.city,
        st.country,
        SUM(s.quantity) AS units_sold,
        (SUM(s.quantity * p.price)) AS total_revenue
    FROM sales s
    JOIN products p
    ON s.product_id = p.product_id
    JOIN stores st
    ON s.store_id = st.store_id
    GROUP BY
        st.store_id,
        st.store_name,
        st.city,
        st.country
)

SELECT
    store_name,
    city,
    country,
    units_sold,
    total_revenue,
    (total_revenue / units_sold) AS revenue_per_unit
FROM store_performance
ORDER BY revenue_per_unit DESC;

/*
Q14.Which product categories deliver the best balance between strong sales performance and product reliability?
*/

WITH category_sales AS (
    SELECT
        c.category_id,
        c.category_name,
        SUM(s.quantity) AS units_sold,
        SUM(s.quantity * p.price) AS total_revenue
    FROM sales s
    JOIN products p
        ON s.product_id = p.product_id
    JOIN category c
        ON p.category_id = c.category_id
    GROUP BY
        c.category_id,
        c.category_name
),

category_claims AS (
    SELECT
        c.category_id,
        COUNT(w.claim_id) AS warranty_claims
    FROM warranty w
    JOIN sales s
        ON w.sale_id = s.sale_id
    JOIN products p
        ON s.product_id = p.product_id
    JOIN category c
        ON p.category_id = c.category_id
    GROUP BY
        c.category_id
)

SELECT
    cs.category_name,
    cs.units_sold,
    cs.total_revenue,
    COALESCE(cc.warranty_claims, 0) AS warranty_claims,
    (
        COALESCE(cc.warranty_claims, 0)::numeric /
        NULLIF(cs.units_sold, 0) * 100
    ) AS claim_rate_pct
FROM category_sales cs
LEFT JOIN category_claims cc
ON cs.category_id = cc.category_id
ORDER BY
    claim_rate_pct ASC,
    total_revenue DESC;


/*
Q15

Which products achieve strong sales despite being available in fewer stores?
*/

WITH product_summary AS (
    SELECT
        p.product_id,
        p.product_name,
        COUNT(DISTINCT s.store_id) AS stores_available,
        SUM(s.quantity) AS units_sold,
        SUM(s.quantity * p.price) AS total_revenue
    FROM sales s
    JOIN products p
        ON s.product_id = p.product_id
    GROUP BY
        p.product_id,
        p.product_name
)

SELECT
    product_name,
    stores_available,
    units_sold,
    total_revenue,
    (
        units_sold::numeric /
        stores_available
    ) AS avg_units_per_store
FROM product_summary
ORDER BY
    avg_units_per_store DESC,
    total_revenue DESC;

/*
Q16.Which stores have the highest number of pending warranty claims?
*/

SELECT
    st.store_name,
    st.city,
    st.country,
    COUNT(w.claim_id) AS pending_claims
FROM warranty w
JOIN sales s
ON w.sale_id = s.sale_id
JOIN stores st
ON s.store_id = st.store_id
WHERE LOWER(w.repair_status) = 'pending'
GROUP BY
    st.store_name,
    st.city,
    st.country
ORDER BY
    pending_claims DESC;

/*
Q17.Which countries rely most heavily on a single product category for their sales?
*/

WITH category_sales AS (
    SELECT
        st.country,
        c.category_name,
        SUM(s.quantity * p.price) AS category_revenue
    FROM sales s
    JOIN stores st
        ON s.store_id = st.store_id
    JOIN products p
        ON s.product_id = p.product_id
    JOIN category c
        ON p.category_id = c.category_id
    GROUP BY
        st.country,
        c.category_name
),

country_totals AS (
    SELECT
        country,
        SUM(category_revenue) AS total_revenue
    FROM category_sales
    GROUP BY country
)

SELECT
    cs.country,
    cs.category_name,
    cs.category_revenue,
    (
        cs.category_revenue * 100.0 /
        ct.total_revenue
        
    ) AS revenue_share_pct
FROM category_sales cs
JOIN country_totals ct
ON cs.country = ct.country
ORDER BY
    cs.country,
    revenue_share_pct DESC;


/*
Q18.Which stores sell the widest variety of product categories while maintaining strong sales volume?
*/

SELECT
    st.store_name,
    st.city,
    st.country,
    COUNT(DISTINCT c.category_id) AS categories_sold,
    SUM(s.quantity) AS total_units_sold
FROM sales s
JOIN products p
    ON s.product_id = p.product_id
JOIN category c
    ON p.category_id = c.category_id
JOIN stores st
    ON s.store_id = st.store_id
GROUP BY
    st.store_name,
    st.city,
    st.country
ORDER BY
    categories_sold DESC,
    total_units_sold DESC;

/*
Q19.Which stores are performing above the average revenue of their respective country?
*/

WITH store_revenue AS (
    SELECT
        st.store_id,
        st.store_name,
        st.city,
        st.country,
        SUM(s.quantity * p.price) AS total_revenue
    FROM sales s
    JOIN products p
        ON s.product_id = p.product_id
    JOIN stores st
        ON s.store_id = st.store_id
    GROUP BY
        st.store_id,
        st.store_name,
        st.city,
        st.country
),

country_avg AS (
    SELECT
        country,
        AVG(total_revenue) AS avg_country_revenue
    FROM store_revenue
    GROUP BY country
)

SELECT
    sr.store_name,
    sr.city,
    sr.country,
    (sr.total_revenue) AS total_revenue,
    (ca.avg_country_revenue) AS avg_country_revenue
FROM store_revenue sr
JOIN country_avg ca
ON sr.country = ca.country
WHERE sr.total_revenue > ca.avg_country_revenue
ORDER BY sr.country, sr.total_revenue DESC;

/*
Q20.Which products outperform the average revenue within their respective category?
*/

WITH product_revenue AS (
    SELECT
        p.product_id,
        p.product_name,
        c.category_name,
        SUM(s.quantity * p.price) AS total_revenue
    FROM sales s
    JOIN products p
        ON s.product_id = p.product_id
    JOIN category c
        ON p.category_id = c.category_id
    GROUP BY
        p.product_id,
        p.product_name,
        c.category_name
),

category_average AS (
    SELECT
        category_name,
        AVG(total_revenue) AS avg_category_revenue
    FROM product_revenue
    GROUP BY category_name
)

SELECT
    pr.product_name,
    pr.category_name,
    (pr.total_revenue) AS product_revenue,
    (ca.avg_category_revenue) AS category_average,
    (
        ((pr.total_revenue - ca.avg_category_revenue) /
        ca.avg_category_revenue) * 100
        
    ) AS performance_vs_category_pct
FROM product_revenue pr
JOIN category_average ca
ON pr.category_name = ca.category_name
WHERE pr.total_revenue > ca.avg_category_revenue
ORDER BY
    performance_vs_category_pct DESC;
/*
==========================================================
SECTION 4 : ADVANCED SQL
==========================================================
*/

/*
Q21.How has monthly revenue changed compared to the previous month?
*/

WITH monthly_sales AS (
    SELECT
        DATE_TRUNC('month', s.sale_date)::date AS month,
        SUM(s.quantity * p.price) AS total_revenue
    FROM sales s
    JOIN products p
    ON s.product_id = p.product_id
    GROUP BY month
)

SELECT
    month,
    (total_revenue) AS total_revenue,
    (LAG(total_revenue) OVER(ORDER BY month)) AS previous_month_revenue,
    (
        total_revenue -
        LAG(total_revenue) OVER(ORDER BY month)
    ) AS revenue_change
FROM monthly_sales
ORDER BY month;

/*
Q22.Which products consistently remain among the top-performing products each month?
*/

WITH monthly_product_sales AS (
    SELECT
        DATE_TRUNC('month', s.sale_date)::date AS month,
        p.product_name,
        SUM(s.quantity * p.price) AS monthly_revenue
    FROM sales s
    JOIN products p
        ON s.product_id = p.product_id
    GROUP BY
        month,
        p.product_name
),

monthly_rankings AS (
    SELECT
        month,
        product_name,
        monthly_revenue,
        DENSE_RANK() OVER (
            PARTITION BY month
            ORDER BY monthly_revenue DESC
        ) AS revenue_rank
    FROM monthly_product_sales
)

SELECT
    product_name,
    COUNT(*) AS months_in_top_three
FROM monthly_rankings
WHERE revenue_rank <= 3
GROUP BY
    product_name
ORDER BY
    months_in_top_three DESC,
    product_name;

/*
Q23.Which stores have shown the most consistent monthly sales performance over time?
*/

WITH monthly_store_sales AS (
    SELECT
        DATE_TRUNC('month', s.sale_date)::date AS month,
        st.store_name,
        SUM(s.quantity * p.price) AS monthly_revenue
    FROM sales s
    JOIN products p
        ON s.product_id = p.product_id
    JOIN stores st
        ON s.store_id = st.store_id
    GROUP BY
        month,
        st.store_name
)

SELECT
    store_name,
    (AVG(monthly_revenue)) AS avg_monthly_revenue,
    (STDDEV(monthly_revenue)) AS revenue_variation
FROM monthly_store_sales
GROUP BY store_name
ORDER BY revenue_variation ASC,
         avg_monthly_revenue DESC;

/*
Q24.Which product categories are gaining or losing momentum compared to the previous month?
*/

WITH monthly_category_sales AS (
    SELECT
        DATE_TRUNC('month', s.sale_date)::date AS month,
        c.category_name,
        SUM(s.quantity) AS units_sold
    FROM sales s
    JOIN products p
        ON s.product_id = p.product_id
    JOIN category c
        ON p.category_id = c.category_id
    GROUP BY
        month,
        c.category_name
)

SELECT
    month,
    category_name,
    units_sold,
    LAG(units_sold) OVER(
        PARTITION BY category_name
        ORDER BY month
    ) AS previous_month_units,
    units_sold -
    LAG(units_sold) OVER(
        PARTITION BY category_name
        ORDER BY month
    ) AS change_in_units
FROM monthly_category_sales
ORDER BY
    category_name,
    month;

/*
Q25.Which products are becoming increasingly important to the business based on their contribution to monthly revenue?
*/

WITH monthly_product_revenue AS (
    SELECT
        DATE_TRUNC('month', s.sale_date)::date AS month,
        p.product_name,
        SUM(s.quantity * p.price) AS monthly_revenue
    FROM sales s
    JOIN products p
    ON s.product_id = p.product_id
    GROUP BY
        month,
        p.product_name
),

monthly_totals AS (
    SELECT
        month,
        SUM(monthly_revenue) AS total_monthly_revenue
    FROM monthly_product_revenue
    GROUP BY month
)

SELECT
    mpr.month,
    mpr.product_name,
    (mpr.monthly_revenue) AS monthly_revenue,
    (
        (mpr.monthly_revenue / mt.total_monthly_revenue) * 100
        
    ) AS revenue_share_pct
FROM monthly_product_revenue mpr
JOIN monthly_totals mt
ON mpr.month = mt.month
ORDER BY
    mpr.month,
    revenue_share_pct DESC;

/*
Q26.Which stores are steadily improving their position in the company's revenue rankings over time?
*/

WITH monthly_store_revenue AS (
    SELECT
        DATE_TRUNC('month', s.sale_date)::date AS month,
        st.store_name,
        SUM(s.quantity * p.price) AS monthly_revenue
    FROM sales s
    JOIN products p
    ON s.product_id = p.product_id
    JOIN stores st
    ON s.store_id = st.store_id
    GROUP BY
        month,
        st.store_name
)

SELECT
    month,
    store_name,
    (monthly_revenue) AS monthly_revenue,
    DENSE_RANK() OVER(
        PARTITION BY month
        ORDER BY monthly_revenue DESC
    ) AS revenue_rank
FROM monthly_store_revenue
ORDER BY
    store_name,
    month;

/*
Q27.Which stores rely heavily on a small number of products for their sales?
*/

WITH product_sales AS (
    SELECT
        st.store_name,
        p.product_name,
        SUM(s.quantity * p.price) AS revenue
    FROM sales s
    JOIN products p
        ON s.product_id = p.product_id
    JOIN stores st
        ON s.store_id = st.store_id
    GROUP BY
        st.store_name,
        p.product_name
),

store_totals AS (
    SELECT
        store_name,
        SUM(revenue) AS total_revenue
    FROM product_sales
    GROUP BY store_name
)

SELECT
    ps.store_name,
    ps.product_name,
    ps.revenue AS product_revenue,
    (st.total_revenue) AS total_store_revenue,
    (
        (ps.revenue / st.total_revenue) * 100
    ) AS revenue_share_pct
FROM product_sales ps
JOIN store_totals st
ON ps.store_name = st.store_name
ORDER BY
    ps.store_name,
    revenue_share_pct DESC;

/*
Q28.Which product categories generate the most balanced sales across different countries?
*/

WITH country_category_sales AS (
    SELECT
        st.country,
        c.category_name,
        SUM(s.quantity) AS units_sold
    FROM sales s
    JOIN products p
        ON s.product_id = p.product_id
    JOIN category c
        ON p.category_id = c.category_id
    JOIN stores st
        ON s.store_id = st.store_id
    GROUP BY
        st.country,
        c.category_name
)

SELECT
    category_name,
    (AVG(units_sold)) AS avg_units_sold,
    (STDDEV(units_sold)) AS variation_between_countries
FROM country_category_sales
GROUP BY category_name
ORDER BY variation_between_countries ASC,
         avg_units_sold DESC;

/*
==========================================================
SECTION 5 : STRATEGIC BUSINESS INSIGHTS
==========================================================
*/

/*
Q29.Which products should be prioritized for marketing based on strong sales performance and low warranty claim rates?
*/

WITH product_sales AS (
    SELECT
        p.product_id,
        p.product_name,
        SUM(s.quantity) AS units_sold,
        SUM(s.quantity * p.price) AS total_revenue
    FROM sales s
    JOIN products p
        ON s.product_id = p.product_id
    GROUP BY
        p.product_id,
        p.product_name
),

product_claims AS (
    SELECT
        s.product_id,
        COUNT(w.claim_id) AS warranty_claims
    FROM warranty w
    JOIN sales s
        ON w.sale_id = s.sale_id
    GROUP BY
        s.product_id
)

SELECT
    ps.product_name,
    ps.units_sold,
    (ps.total_revenue) AS total_revenue,
    COALESCE(pc.warranty_claims,0) AS warranty_claims,
    (
        COALESCE(pc.warranty_claims,0)::numeric /
        NULLIF(ps.units_sold,0) * 100
    ) AS claim_rate_pct
FROM product_sales ps
LEFT JOIN product_claims pc
ON ps.product_id = pc.product_id
ORDER BY
    claim_rate_pct ASC,
    total_revenue DESC;

/*
Q30.Which stores should be reviewed for operational improvements based on high warranty claims relative to their sales volume?
*/

WITH store_sales AS (
    SELECT
        st.store_id,
        st.store_name,
        st.city,
        st.country,
        SUM(s.quantity) AS units_sold
    FROM sales s
    JOIN stores st
        ON s.store_id = st.store_id
    GROUP BY
        st.store_id,
        st.store_name,
        st.city,
        st.country
),

store_claims AS (
    SELECT
        s.store_id,
        COUNT(w.claim_id) AS warranty_claims
    FROM warranty w
    JOIN sales s
        ON w.sale_id = s.sale_id
    GROUP BY
        s.store_id
)

SELECT
    ss.store_name,
    ss.city,
    ss.country,
    ss.units_sold,
    COALESCE(sc.warranty_claims,0) AS warranty_claims,
    (
        COALESCE(sc.warranty_claims,0)::numeric /
        NULLIF(ss.units_sold,0) * 100
    ) AS claim_rate_pct
FROM store_sales ss
LEFT JOIN store_claims sc
ON ss.store_id = sc.store_id
ORDER BY
    claim_rate_pct DESC,
    warranty_claims DESC;

/*
Q31.Which product categories have the strongest potential for expansion into additional stores?
*/

WITH category_performance AS (
    SELECT
        c.category_id,
        c.category_name,
        COUNT(DISTINCT s.store_id) AS stores_selling,
        SUM(s.quantity) AS units_sold,
        SUM(s.quantity * p.price) AS total_revenue
    FROM sales s
    JOIN products p
        ON s.product_id = p.product_id
    JOIN category c
        ON p.category_id = c.category_id
    GROUP BY
        c.category_id,
        c.category_name
)

SELECT
    category_name,
    stores_selling,
    units_sold,
    (total_revenue) AS total_revenue,
    (total_revenue / stores_selling) AS avg_revenue_per_store
FROM category_performance
ORDER BY
    avg_revenue_per_store DESC,
    units_sold DESC;

/*
Q32.Which products may require quality improvements based on their warranty claim rate?
*/

WITH product_sales AS (
    SELECT
        p.product_id,
        p.product_name,
        SUM(s.quantity) AS units_sold
    FROM sales s
    JOIN products p
        ON s.product_id = p.product_id
    GROUP BY
        p.product_id,
        p.product_name
),

product_claims AS (
    SELECT
        s.product_id,
        COUNT(w.claim_id) AS warranty_claims
    FROM warranty w
    JOIN sales s
        ON w.sale_id = s.sale_id
    GROUP BY
        s.product_id
)

SELECT
    ps.product_name,
    ps.units_sold,
    COALESCE(pc.warranty_claims,0) AS warranty_claims,
    (
        COALESCE(pc.warranty_claims,0)::numeric /
        NULLIF(ps.units_sold,0) * 100
    ) AS claim_rate_pct
FROM product_sales ps
LEFT JOIN product_claims pc
ON ps.product_id = pc.product_id
WHERE COALESCE(pc.warranty_claims,0) > 0
ORDER BY
    claim_rate_pct DESC,
    warranty_claims DESC;

/*
Q33.Which countries generate high revenue despite having relatively few stores?
*/

WITH country_summary AS (
    SELECT
        st.country,
        COUNT(DISTINCT st.store_id) AS total_stores,
        SUM(s.quantity * p.price) AS total_revenue
    FROM sales s
    JOIN products p
        ON s.product_id = p.product_id
    JOIN stores st
        ON s.store_id = st.store_id
    GROUP BY st.country
)

SELECT
    country,
    total_stores,
    (total_revenue) AS total_revenue,
    (total_revenue / total_stores) AS revenue_per_store
FROM country_summary
ORDER BY
    revenue_per_store DESC,
    total_revenue DESC;

/*
Q34.Is the company's revenue heavily dependent on a small number of products?
*/

WITH product_revenue AS (
    SELECT
        p.product_name,
        SUM(s.quantity * p.price) AS total_revenue
    FROM sales s
    JOIN products p
        ON s.product_id = p.product_id
    GROUP BY p.product_name
)

SELECT
    product_name,
    (total_revenue) AS total_revenue,
    (
        total_revenue /
        SUM(total_revenue) OVER () * 100
    ) AS revenue_share_pct
FROM product_revenue
ORDER BY
    revenue_share_pct DESC;

/*
Q35

Which product categories are showing signs of slowing demand over time?
*/

WITH monthly_category_sales AS (
    SELECT
        DATE_TRUNC('month', s.sale_date)::date AS month,
        c.category_name,
        SUM(s.quantity) AS units_sold
    FROM sales s
    JOIN products p
        ON s.product_id = p.product_id
    JOIN category c
        ON p.category_id = c.category_id
    GROUP BY
        month,
        c.category_name
),

category_trend AS (
    SELECT
        month,
        category_name,
        units_sold,
        LAG(units_sold) OVER(
            PARTITION BY category_name
            ORDER BY month
        ) AS previous_month_sales
    FROM monthly_category_sales
)

SELECT
    month,
    category_name,
    units_sold,
    previous_month_sales,
    units_sold - previous_month_sales AS sales_change
FROM category_trend
WHERE previous_month_sales IS NOT NULL
ORDER BY
    category_name,
    month;

/*
Q36.During which months does each product category experience its highest sales demand?
*/

WITH monthly_category_sales AS (
    SELECT
        DATE_TRUNC('month', s.sale_date)::date AS month,
        c.category_name,
        SUM(s.quantity) AS units_sold
    FROM sales s
    JOIN products p
        ON s.product_id = p.product_id
    JOIN category c
        ON p.category_id = c.category_id
    GROUP BY
        month,
        c.category_name
)

SELECT
    month,
    category_name,
    units_sold
FROM (
    SELECT *,
           RANK() OVER(
               PARTITION BY category_name
               ORDER BY units_sold DESC
           ) AS sales_rank
    FROM monthly_category_sales
) ranked_sales
WHERE sales_rank = 1
ORDER BY
    category_name;

/*
Q37.Which stores consistently combine strong sales performance with low warranty claim rates?
*/

WITH store_sales AS (
    SELECT
        st.store_id,
        st.store_name,
        SUM(s.quantity) AS units_sold,
        SUM(s.quantity * p.price) AS total_revenue
    FROM sales s
    JOIN stores st
        ON s.store_id = st.store_id
    JOIN products p
        ON s.product_id = p.product_id
    GROUP BY
        st.store_id,
        st.store_name
),

store_claims AS (
    SELECT
        s.store_id,
        COUNT(w.claim_id) AS warranty_claims
    FROM warranty w
    JOIN sales s
        ON w.sale_id = s.sale_id
    GROUP BY
        s.store_id
)

SELECT
    ss.store_name,
    ss.units_sold,
    (ss.total_revenue) AS total_revenue,
    COALESCE(sc.warranty_claims,0) AS warranty_claims,
    (
        COALESCE(sc.warranty_claims,0)::numeric /
        NULLIF(ss.units_sold,0) * 100
    ) AS claim_rate_pct
FROM store_sales ss
LEFT JOIN store_claims sc
ON ss.store_id = sc.store_id
ORDER BY
    claim_rate_pct ASC,
    total_revenue DESC;

/*
Q38.Which products maintain the most consistent demand throughout the year?
*/

WITH monthly_product_sales AS (
    SELECT
        DATE_TRUNC('month', s.sale_date)::date AS month,
        p.product_name,
        SUM(s.quantity) AS units_sold
    FROM sales s
    JOIN products p
        ON s.product_id = p.product_id
    GROUP BY
        month,
        p.product_name
)

SELECT
    product_name,
    AVG(units_sold) AS avg_monthly_sales,
    (STDDEV(units_sold)) AS sales_variation
FROM monthly_product_sales
GROUP BY
    product_name
ORDER BY
    sales_variation ASC,
    avg_monthly_sales DESC;


/*
Q39.How dependent is the business on each country's contribution to total revenue?
*/

WITH country_sales AS (
    SELECT
        st.country,
        SUM(s.quantity * p.price) AS total_revenue
    FROM sales s
    JOIN stores st
        ON s.store_id = st.store_id
    JOIN products p
        ON s.product_id = p.product_id
    GROUP BY
        st.country
)

SELECT
    country,
    (total_revenue) AS total_revenue,
    (
        total_revenue /
        SUM(total_revenue) OVER() * 100
    ) AS revenue_share_pct
FROM country_sales
ORDER BY
    revenue_share_pct DESC;

/*
Q40

Generate an executive summary of the company's overall business performance.
*/

WITH company_metrics AS (
    SELECT
        COUNT(s.sale_id) AS total_transactions,
        SUM(s.quantity) AS total_units_sold,
        SUM(s.quantity * p.price) AS total_revenue
    FROM sales s
    JOIN products p
        ON s.product_id = p.product_id
),

top_product AS (
    SELECT
        p.product_name
    FROM sales s
    JOIN products p
        ON s.product_id = p.product_id
    GROUP BY
        p.product_name
    ORDER BY
        SUM(s.quantity * p.price) DESC
    LIMIT 1
),

top_store AS (
    SELECT
        st.store_name
    FROM sales s
    JOIN stores st
        ON s.store_id = st.store_id
    JOIN products p
        ON s.product_id = p.product_id
    GROUP BY
        st.store_name
    ORDER BY
        SUM(s.quantity * p.price) DESC
    LIMIT 1
),

top_country AS (
    SELECT
        st.country
    FROM sales s
    JOIN stores st
        ON s.store_id = st.store_id
    JOIN products p
        ON s.product_id = p.product_id
    GROUP BY
        st.country
    ORDER BY
        SUM(s.quantity * p.price) DESC
    LIMIT 1
),

total_claims AS (
    SELECT COUNT(*) AS warranty_claims
    FROM warranty
)

SELECT
    (cm.total_revenue) AS total_revenue,
    cm.total_transactions,
    cm.total_units_sold,
    tc.warranty_claims,
    tp.product_name AS best_selling_product,
    ts.store_name AS best_performing_store,
    tco.country AS highest_revenue_country
FROM company_metrics cm
CROSS JOIN total_claims tc
CROSS JOIN top_product tp
CROSS JOIN top_store ts
CROSS JOIN top_country tco;