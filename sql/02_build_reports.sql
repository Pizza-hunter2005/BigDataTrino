DROP TABLE IF EXISTS clickhouse.default.report_product_sales;
DROP TABLE IF EXISTS clickhouse.default.report_customer_sales;
DROP TABLE IF EXISTS clickhouse.default.report_time_sales;
DROP TABLE IF EXISTS clickhouse.default.report_store_sales;
DROP TABLE IF EXISTS clickhouse.default.report_supplier_sales;
DROP TABLE IF EXISTS clickhouse.default.report_product_quality;

CREATE TABLE clickhouse.default.report_product_sales
WITH (engine = 'MergeTree')
AS
WITH product_sales AS (
    SELECT
        p.s_product_id AS product_id,
        pi.product_name,
        pc.product_category,
        pb.product_brand,
        sum(sp.sale_quantity) AS quantity_sold,
        round(sum(sp.sale_total_price), 2) AS revenue,
        count(fs.sale_id) AS orders_count,
        round(avg(sp.sale_total_price), 2) AS avg_order_amount,
        avg(pf.product_rating) AS avg_rating,
        max(pf.product_reviews) AS reviews_count
    FROM clickhouse.default.fact_sales fs
    JOIN clickhouse.default.sale_payment sp ON fs.sale_payment_id = sp.payment_id
    JOIN clickhouse.default.product p ON fs.sale_product_id = p.s_product_id
    JOIN clickhouse.default.product_info pi ON p.product_info_id = pi.info_id
    JOIN clickhouse.default.product_category pc ON p.product_category_id = pc.category_id
    JOIN clickhouse.default.product_brand pb ON p.product_brand_id = pb.brand_id
    JOIN clickhouse.default.product_feedback pf ON p.product_feedback_id = pf.feedback_id
    GROUP BY p.s_product_id, pi.product_name, pc.product_category, pb.product_brand
)
SELECT
    product_id,
    product_name,
    product_category,
    product_brand,
    quantity_sold,
    revenue,
    orders_count,
    avg_order_amount,
    avg_rating,
    reviews_count,
    row_number() OVER (ORDER BY quantity_sold DESC, revenue DESC) AS sales_rank
FROM product_sales;

CREATE TABLE clickhouse.default.report_customer_sales
WITH (engine = 'MergeTree')
AS
WITH country_distribution AS (
    SELECT cl.customer_country, count(DISTINCT c.s_customer_id) AS customers_in_country
    FROM clickhouse.default.customer c
    JOIN clickhouse.default.customer_location cl ON c.customer_location_id = cl.location_id
    GROUP BY cl.customer_country
),
customer_sales AS (
    SELECT
        c.s_customer_id AS customer_id,
        ci.customer_first_name,
        ci.customer_last_name,
        cc.customer_email,
        cl.customer_country,
        cd.customers_in_country,
        round(sum(sp.sale_total_price), 2) AS total_spent,
        count(fs.sale_id) AS orders_count,
        round(avg(sp.sale_total_price), 2) AS avg_check
    FROM clickhouse.default.fact_sales fs
    JOIN clickhouse.default.sale_payment sp ON fs.sale_payment_id = sp.payment_id
    JOIN clickhouse.default.customer c ON fs.sale_customer_id = c.s_customer_id
    JOIN clickhouse.default.customer_info ci ON c.customer_info_id = ci.info_id
    JOIN clickhouse.default.customer_contacts cc ON c.customer_contact_id = cc.contact_id
    JOIN clickhouse.default.customer_location cl ON c.customer_location_id = cl.location_id
    JOIN country_distribution cd ON cl.customer_country IS NOT DISTINCT FROM cd.customer_country
    GROUP BY c.s_customer_id, ci.customer_first_name, ci.customer_last_name, cc.customer_email, cl.customer_country, cd.customers_in_country
)
SELECT
    customer_id,
    customer_first_name,
    customer_last_name,
    customer_email,
    customer_country,
    customers_in_country,
    total_spent,
    orders_count,
    avg_check,
    row_number() OVER (ORDER BY total_spent DESC) AS customer_rank
FROM customer_sales;

CREATE TABLE clickhouse.default.report_time_sales
WITH (engine = 'MergeTree')
AS
SELECT
    year(sale_date) AS sale_year,
    month(sale_date) AS sale_month,
    round(sum(sp.sale_total_price), 2) AS revenue,
    sum(sp.sale_quantity) AS quantity_sold,
    count(fs.sale_id) AS orders_count,
    round(avg(sp.sale_total_price), 2) AS avg_order_amount
FROM clickhouse.default.fact_sales fs
JOIN clickhouse.default.sale_payment sp ON fs.sale_payment_id = sp.payment_id
GROUP BY year(sale_date), month(sale_date);

CREATE TABLE clickhouse.default.report_store_sales
WITH (engine = 'MergeTree')
AS
WITH store_sales AS (
    SELECT
        st.store_id,
        si.store_name,
        sl.store_city,
        sl.store_state,
        sl.store_country,
        round(sum(sp.sale_total_price), 2) AS revenue,
        sum(sp.sale_quantity) AS quantity_sold,
        count(fs.sale_id) AS orders_count,
        round(avg(sp.sale_total_price), 2) AS avg_check
    FROM clickhouse.default.fact_sales fs
    JOIN clickhouse.default.sale_payment sp ON fs.sale_payment_id = sp.payment_id
    JOIN clickhouse.default.store st ON fs.sale_store_id = st.store_id
    JOIN clickhouse.default.store_info si ON st.store_info_id = si.info_id
    JOIN clickhouse.default.store_location sl ON st.store_location_id = sl.location_id
    GROUP BY st.store_id, si.store_name, sl.store_city, sl.store_state, sl.store_country
)
SELECT
    store_id,
    store_name,
    store_city,
    store_state,
    store_country,
    revenue,
    quantity_sold,
    orders_count,
    avg_check,
    row_number() OVER (ORDER BY revenue DESC) AS store_rank
FROM store_sales;

CREATE TABLE clickhouse.default.report_supplier_sales
WITH (engine = 'MergeTree')
AS
WITH supplier_sales AS (
    SELECT
        su.supplier_id,
        si.supplier_name,
        sc.supplier_contact,
        sl.supplier_city,
        sl.supplier_country,
        round(sum(sp.sale_total_price), 2) AS revenue,
        sum(sp.sale_quantity) AS quantity_sold,
        count(fs.sale_id) AS orders_count,
        round(avg(pi.product_price), 2) AS avg_product_price
    FROM clickhouse.default.fact_sales fs
    JOIN clickhouse.default.sale_payment sp ON fs.sale_payment_id = sp.payment_id
    JOIN clickhouse.default.supplier su ON fs.product_supplier_id = su.supplier_id
    JOIN clickhouse.default.supplier_info si ON su.supplier_info_id = si.info_id
    JOIN clickhouse.default.supplier_location sl ON su.supplier_location_id = sl.location_id
    JOIN clickhouse.default.supplier_contacts sc ON su.supplier_contact_id = sc.contact_id
    JOIN clickhouse.default.product p ON fs.sale_product_id = p.s_product_id
    JOIN clickhouse.default.product_info pi ON p.product_info_id = pi.info_id
    GROUP BY su.supplier_id, si.supplier_name, sc.supplier_contact, sl.supplier_city, sl.supplier_country
)
SELECT
    supplier_id,
    supplier_name,
    supplier_contact,
    supplier_city,
    supplier_country,
    revenue,
    quantity_sold,
    orders_count,
    avg_product_price,
    row_number() OVER (ORDER BY revenue DESC) AS supplier_rank
FROM supplier_sales;

CREATE TABLE clickhouse.default.report_product_quality
WITH (engine = 'MergeTree')
AS
WITH quality AS (
    SELECT
        p.s_product_id AS product_id,
        pi.product_name,
        pc.product_category,
        pf.product_rating,
        pf.product_reviews,
        sum(sp.sale_quantity) AS quantity_sold,
        round(sum(sp.sale_total_price), 2) AS revenue
    FROM clickhouse.default.fact_sales fs
    JOIN clickhouse.default.sale_payment sp ON fs.sale_payment_id = sp.payment_id
    JOIN clickhouse.default.product p ON fs.sale_product_id = p.s_product_id
    JOIN clickhouse.default.product_info pi ON p.product_info_id = pi.info_id
    JOIN clickhouse.default.product_category pc ON p.product_category_id = pc.category_id
    JOIN clickhouse.default.product_feedback pf ON p.product_feedback_id = pf.feedback_id
    GROUP BY p.s_product_id, pi.product_name, pc.product_category, pf.product_rating, pf.product_reviews
),
correlation AS (
    SELECT corr(product_rating, CAST(quantity_sold AS double)) AS rating_sales_correlation
    FROM quality
)
SELECT
    q.product_id,
    q.product_name,
    q.product_category,
    q.product_rating,
    q.product_reviews,
    q.quantity_sold,
    q.revenue,
    row_number() OVER (ORDER BY q.product_rating DESC) AS rating_rank_high,
    row_number() OVER (ORDER BY q.product_rating ASC) AS rating_rank_low,
    row_number() OVER (ORDER BY q.product_reviews DESC) AS reviews_rank,
    c.rating_sales_correlation
FROM quality q
CROSS JOIN correlation c;
