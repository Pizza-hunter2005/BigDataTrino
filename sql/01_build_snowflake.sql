DROP TABLE IF EXISTS clickhouse.default.fact_sales;
DROP TABLE IF EXISTS clickhouse.default.sale_payment;
DROP TABLE IF EXISTS clickhouse.default.product;
DROP TABLE IF EXISTS clickhouse.default.product_info;
DROP TABLE IF EXISTS clickhouse.default.product_feedback;
DROP TABLE IF EXISTS clickhouse.default.product_category;
DROP TABLE IF EXISTS clickhouse.default.product_brand;
DROP TABLE IF EXISTS clickhouse.default.product_parameters;
DROP TABLE IF EXISTS clickhouse.default.supplier;
DROP TABLE IF EXISTS clickhouse.default.supplier_info;
DROP TABLE IF EXISTS clickhouse.default.supplier_location;
DROP TABLE IF EXISTS clickhouse.default.supplier_contacts;
DROP TABLE IF EXISTS clickhouse.default.store;
DROP TABLE IF EXISTS clickhouse.default.store_info;
DROP TABLE IF EXISTS clickhouse.default.store_location;
DROP TABLE IF EXISTS clickhouse.default.store_contacts;
DROP TABLE IF EXISTS clickhouse.default.seller;
DROP TABLE IF EXISTS clickhouse.default.seller_info;
DROP TABLE IF EXISTS clickhouse.default.seller_location;
DROP TABLE IF EXISTS clickhouse.default.seller_contacts;
DROP TABLE IF EXISTS clickhouse.default.customer;
DROP TABLE IF EXISTS clickhouse.default.customer_info;
DROP TABLE IF EXISTS clickhouse.default.customer_location;
DROP TABLE IF EXISTS clickhouse.default.customer_contacts;
DROP TABLE IF EXISTS clickhouse.default.customer_pet;
DROP TABLE IF EXISTS clickhouse.default.pet_category;
DROP TABLE IF EXISTS clickhouse.default.stg_mock_data;

CREATE TABLE clickhouse.default.stg_mock_data
WITH (engine = 'MergeTree')
AS
SELECT
    'clickhouse' AS source_system,
    CAST(id AS integer) AS source_id,
    customer_first_name,
    customer_last_name,
    CAST(customer_age AS integer) AS customer_age,
    customer_email,
    customer_country,
    customer_postal_code,
    customer_pet_type,
    customer_pet_name,
    customer_pet_breed,
    seller_first_name,
    seller_last_name,
    seller_email,
    seller_country,
    seller_postal_code,
    product_name,
    product_category,
    CAST(product_price AS double) AS product_price,
    CAST(product_quantity AS integer) AS product_quantity,
    sale_date,
    CAST(sale_customer_id AS integer) AS sale_customer_id,
    CAST(sale_seller_id AS integer) AS sale_seller_id,
    CAST(sale_product_id AS integer) AS sale_product_id,
    CAST(sale_quantity AS integer) AS sale_quantity,
    CAST(sale_total_price AS double) AS sale_total_price,
    store_name,
    store_location,
    store_city,
    store_state,
    store_country,
    store_phone,
    store_email,
    pet_category,
    CAST(product_weight AS double) AS product_weight,
    product_color,
    product_size,
    product_brand,
    product_material,
    product_description,
    CAST(product_rating AS double) AS product_rating,
    CAST(product_reviews AS integer) AS product_reviews,
    product_release_date,
    product_expiry_date,
    supplier_name,
    supplier_contact,
    supplier_email,
    supplier_phone,
    supplier_address,
    supplier_city,
    supplier_country
FROM clickhouse.default.mock_data
UNION ALL
SELECT
    'postgresql' AS source_system,
    CAST(id AS integer) AS source_id,
    customer_first_name,
    customer_last_name,
    CAST(customer_age AS integer) AS customer_age,
    customer_email,
    customer_country,
    customer_postal_code,
    customer_pet_type,
    customer_pet_name,
    customer_pet_breed,
    seller_first_name,
    seller_last_name,
    seller_email,
    seller_country,
    seller_postal_code,
    product_name,
    product_category,
    CAST(product_price AS double) AS product_price,
    CAST(product_quantity AS integer) AS product_quantity,
    sale_date,
    CAST(sale_customer_id AS integer) AS sale_customer_id,
    CAST(sale_seller_id AS integer) AS sale_seller_id,
    CAST(sale_product_id AS integer) AS sale_product_id,
    CAST(sale_quantity AS integer) AS sale_quantity,
    CAST(sale_total_price AS double) AS sale_total_price,
    store_name,
    store_location,
    store_city,
    store_state,
    store_country,
    store_phone,
    store_email,
    pet_category,
    CAST(product_weight AS double) AS product_weight,
    product_color,
    product_size,
    product_brand,
    product_material,
    product_description,
    CAST(product_rating AS double) AS product_rating,
    CAST(product_reviews AS integer) AS product_reviews,
    product_release_date,
    product_expiry_date,
    supplier_name,
    supplier_contact,
    supplier_email,
    supplier_phone,
    supplier_address,
    supplier_city,
    supplier_country
FROM postgresql.public.mock_data;

CREATE TABLE clickhouse.default.pet_category
WITH (engine = 'MergeTree')
AS
SELECT row_number() OVER (ORDER BY category_name) AS category_id, category_name
FROM (
    SELECT DISTINCT pet_category AS category_name
    FROM clickhouse.default.stg_mock_data
) t;

CREATE TABLE clickhouse.default.customer_pet
WITH (engine = 'MergeTree')
AS
SELECT
    row_number() OVER (ORDER BY customer_pet_type, customer_pet_name, customer_pet_breed, pc.category_id) AS pet_id,
    p.customer_pet_type,
    p.customer_pet_name,
    p.customer_pet_breed,
    pc.category_id AS pet_category_id
FROM (
    SELECT DISTINCT customer_pet_type, customer_pet_name, customer_pet_breed, pet_category
    FROM clickhouse.default.stg_mock_data
) p
JOIN clickhouse.default.pet_category pc
    ON p.pet_category IS NOT DISTINCT FROM pc.category_name;

CREATE TABLE clickhouse.default.customer_info
WITH (engine = 'MergeTree')
AS
SELECT
    row_number() OVER (ORDER BY customer_first_name, customer_last_name, customer_age) AS info_id,
    customer_first_name,
    customer_last_name,
    customer_age
FROM (
    SELECT DISTINCT customer_first_name, customer_last_name, customer_age
    FROM clickhouse.default.stg_mock_data
) t;

CREATE TABLE clickhouse.default.customer_location
WITH (engine = 'MergeTree')
AS
SELECT
    row_number() OVER (ORDER BY customer_country, customer_postal_code) AS location_id,
    customer_country,
    customer_postal_code
FROM (
    SELECT DISTINCT customer_country, customer_postal_code
    FROM clickhouse.default.stg_mock_data
) t;

CREATE TABLE clickhouse.default.customer_contacts
WITH (engine = 'MergeTree')
AS
SELECT row_number() OVER (ORDER BY customer_email) AS contact_id, customer_email
FROM (
    SELECT DISTINCT customer_email
    FROM clickhouse.default.stg_mock_data
) t;

CREATE TABLE clickhouse.default.customer
WITH (engine = 'MergeTree')
AS
SELECT
    row_number() OVER (ORDER BY m.sale_customer_id) AS customer_id,
    m.sale_customer_id AS s_customer_id,
    min(ci.info_id) AS customer_info_id,
    min(cl.location_id) AS customer_location_id,
    min(cp.pet_id) AS customer_pet_id,
    min(cc.contact_id) AS customer_contact_id
FROM clickhouse.default.stg_mock_data m
JOIN clickhouse.default.customer_info ci
    ON m.customer_first_name IS NOT DISTINCT FROM ci.customer_first_name
    AND m.customer_last_name IS NOT DISTINCT FROM ci.customer_last_name
    AND m.customer_age IS NOT DISTINCT FROM ci.customer_age
JOIN clickhouse.default.customer_location cl
    ON m.customer_country IS NOT DISTINCT FROM cl.customer_country
    AND m.customer_postal_code IS NOT DISTINCT FROM cl.customer_postal_code
JOIN clickhouse.default.customer_contacts cc
    ON m.customer_email IS NOT DISTINCT FROM cc.customer_email
JOIN clickhouse.default.customer_pet cp
    ON m.customer_pet_type IS NOT DISTINCT FROM cp.customer_pet_type
    AND m.customer_pet_name IS NOT DISTINCT FROM cp.customer_pet_name
    AND m.customer_pet_breed IS NOT DISTINCT FROM cp.customer_pet_breed
GROUP BY m.sale_customer_id;

CREATE TABLE clickhouse.default.seller_info
WITH (engine = 'MergeTree')
AS
SELECT
    row_number() OVER (ORDER BY seller_first_name, seller_last_name) AS info_id,
    seller_first_name,
    seller_last_name
FROM (
    SELECT DISTINCT seller_first_name, seller_last_name
    FROM clickhouse.default.stg_mock_data
) t;

CREATE TABLE clickhouse.default.seller_location
WITH (engine = 'MergeTree')
AS
SELECT
    row_number() OVER (ORDER BY seller_country, seller_postal_code) AS location_id,
    seller_country,
    seller_postal_code
FROM (
    SELECT DISTINCT seller_country, seller_postal_code
    FROM clickhouse.default.stg_mock_data
) t;

CREATE TABLE clickhouse.default.seller_contacts
WITH (engine = 'MergeTree')
AS
SELECT row_number() OVER (ORDER BY seller_email) AS contact_id, seller_email
FROM (
    SELECT DISTINCT seller_email
    FROM clickhouse.default.stg_mock_data
) t;

CREATE TABLE clickhouse.default.seller
WITH (engine = 'MergeTree')
AS
SELECT
    row_number() OVER (ORDER BY m.sale_seller_id) AS seller_id,
    m.sale_seller_id AS s_seller_id,
    min(si.info_id) AS seller_info_id,
    min(sl.location_id) AS seller_location_id,
    min(sc.contact_id) AS seller_contact_id
FROM clickhouse.default.stg_mock_data m
JOIN clickhouse.default.seller_info si
    ON m.seller_first_name IS NOT DISTINCT FROM si.seller_first_name
    AND m.seller_last_name IS NOT DISTINCT FROM si.seller_last_name
JOIN clickhouse.default.seller_location sl
    ON m.seller_country IS NOT DISTINCT FROM sl.seller_country
    AND m.seller_postal_code IS NOT DISTINCT FROM sl.seller_postal_code
JOIN clickhouse.default.seller_contacts sc
    ON m.seller_email IS NOT DISTINCT FROM sc.seller_email
GROUP BY m.sale_seller_id;

CREATE TABLE clickhouse.default.store_info
WITH (engine = 'MergeTree')
AS
SELECT row_number() OVER (ORDER BY store_name) AS info_id, store_name
FROM (
    SELECT DISTINCT store_name
    FROM clickhouse.default.stg_mock_data
) t;

CREATE TABLE clickhouse.default.store_location
WITH (engine = 'MergeTree')
AS
SELECT
    row_number() OVER (ORDER BY store_location, store_city, store_state, store_country) AS location_id,
    store_location,
    store_city,
    store_state,
    store_country
FROM (
    SELECT DISTINCT store_location, store_city, store_state, store_country
    FROM clickhouse.default.stg_mock_data
) t;

CREATE TABLE clickhouse.default.store_contacts
WITH (engine = 'MergeTree')
AS
SELECT row_number() OVER (ORDER BY store_phone, store_email) AS contact_id, store_phone, store_email
FROM (
    SELECT DISTINCT store_phone, store_email
    FROM clickhouse.default.stg_mock_data
) t;

CREATE TABLE clickhouse.default.store
WITH (engine = 'MergeTree')
AS
SELECT
    row_number() OVER (ORDER BY si.info_id, sl.location_id, sc.contact_id) AS store_id,
    si.info_id AS store_info_id,
    sl.location_id AS store_location_id,
    sc.contact_id AS store_contact_id
FROM (
    SELECT DISTINCT store_name, store_location, store_city, store_state, store_country, store_phone, store_email
    FROM clickhouse.default.stg_mock_data
) m
JOIN clickhouse.default.store_info si
    ON m.store_name IS NOT DISTINCT FROM si.store_name
JOIN clickhouse.default.store_location sl
    ON m.store_location IS NOT DISTINCT FROM sl.store_location
    AND m.store_city IS NOT DISTINCT FROM sl.store_city
    AND m.store_state IS NOT DISTINCT FROM sl.store_state
    AND m.store_country IS NOT DISTINCT FROM sl.store_country
JOIN clickhouse.default.store_contacts sc
    ON m.store_phone IS NOT DISTINCT FROM sc.store_phone
    AND m.store_email IS NOT DISTINCT FROM sc.store_email;

CREATE TABLE clickhouse.default.supplier_info
WITH (engine = 'MergeTree')
AS
SELECT row_number() OVER (ORDER BY supplier_name) AS info_id, supplier_name
FROM (
    SELECT DISTINCT supplier_name
    FROM clickhouse.default.stg_mock_data
) t;

CREATE TABLE clickhouse.default.supplier_location
WITH (engine = 'MergeTree')
AS
SELECT
    row_number() OVER (ORDER BY supplier_address, supplier_city, supplier_country) AS location_id,
    supplier_address,
    supplier_city,
    supplier_country
FROM (
    SELECT DISTINCT supplier_address, supplier_city, supplier_country
    FROM clickhouse.default.stg_mock_data
) t;

CREATE TABLE clickhouse.default.supplier_contacts
WITH (engine = 'MergeTree')
AS
SELECT
    row_number() OVER (ORDER BY supplier_contact, supplier_email, supplier_phone) AS contact_id,
    supplier_contact,
    supplier_email,
    supplier_phone
FROM (
    SELECT DISTINCT supplier_contact, supplier_email, supplier_phone
    FROM clickhouse.default.stg_mock_data
) t;

CREATE TABLE clickhouse.default.supplier
WITH (engine = 'MergeTree')
AS
SELECT
    row_number() OVER (ORDER BY si.info_id, sl.location_id, sc.contact_id) AS supplier_id,
    si.info_id AS supplier_info_id,
    sl.location_id AS supplier_location_id,
    sc.contact_id AS supplier_contact_id
FROM (
    SELECT DISTINCT supplier_name, supplier_address, supplier_city, supplier_country, supplier_contact, supplier_email, supplier_phone
    FROM clickhouse.default.stg_mock_data
) m
JOIN clickhouse.default.supplier_info si
    ON m.supplier_name IS NOT DISTINCT FROM si.supplier_name
JOIN clickhouse.default.supplier_location sl
    ON m.supplier_address IS NOT DISTINCT FROM sl.supplier_address
    AND m.supplier_city IS NOT DISTINCT FROM sl.supplier_city
    AND m.supplier_country IS NOT DISTINCT FROM sl.supplier_country
JOIN clickhouse.default.supplier_contacts sc
    ON m.supplier_contact IS NOT DISTINCT FROM sc.supplier_contact
    AND m.supplier_email IS NOT DISTINCT FROM sc.supplier_email
    AND m.supplier_phone IS NOT DISTINCT FROM sc.supplier_phone;

CREATE TABLE clickhouse.default.product_category
WITH (engine = 'MergeTree')
AS
SELECT row_number() OVER (ORDER BY product_category) AS category_id, product_category
FROM (
    SELECT DISTINCT product_category
    FROM clickhouse.default.stg_mock_data
) t;

CREATE TABLE clickhouse.default.product_brand
WITH (engine = 'MergeTree')
AS
SELECT row_number() OVER (ORDER BY product_brand) AS brand_id, product_brand
FROM (
    SELECT DISTINCT product_brand
    FROM clickhouse.default.stg_mock_data
) t;

CREATE TABLE clickhouse.default.product_parameters
WITH (engine = 'MergeTree')
AS
SELECT
    row_number() OVER (ORDER BY product_weight, product_color, product_size, product_material) AS parameters_id,
    product_weight,
    product_color,
    product_size,
    product_material
FROM (
    SELECT DISTINCT product_weight, product_color, product_size, product_material
    FROM clickhouse.default.stg_mock_data
) t;

CREATE TABLE clickhouse.default.product_feedback
WITH (engine = 'MergeTree')
AS
SELECT
    row_number() OVER (ORDER BY product_rating, product_reviews) AS feedback_id,
    product_rating,
    product_reviews
FROM (
    SELECT DISTINCT product_rating, product_reviews
    FROM clickhouse.default.stg_mock_data
) t;

CREATE TABLE clickhouse.default.product_info
WITH (engine = 'MergeTree')
AS
SELECT
    row_number() OVER (ORDER BY product_name, product_price, product_quantity, product_release_date, product_expiry_date, product_description) AS info_id,
    product_name,
    product_price,
    product_quantity,
    CAST(date_parse(product_release_date, '%c/%e/%Y') AS date) AS product_release_date,
    CAST(date_parse(product_expiry_date, '%c/%e/%Y') AS date) AS product_expiry_date,
    product_description
FROM (
    SELECT DISTINCT product_name, product_price, product_quantity, product_release_date, product_expiry_date, product_description
    FROM clickhouse.default.stg_mock_data
) t;

CREATE TABLE clickhouse.default.product
WITH (engine = 'MergeTree')
AS
SELECT
    row_number() OVER (ORDER BY m.sale_product_id) AS product_id,
    m.sale_product_id AS s_product_id,
    min(pi.info_id) AS product_info_id,
    min(pp.parameters_id) AS product_parameters_id,
    min(pb.brand_id) AS product_brand_id,
    min(pf.feedback_id) AS product_feedback_id,
    min(pc.category_id) AS product_category_id
FROM clickhouse.default.stg_mock_data m
JOIN clickhouse.default.product_info pi
    ON m.product_name IS NOT DISTINCT FROM pi.product_name
    AND m.product_price IS NOT DISTINCT FROM pi.product_price
    AND m.product_quantity IS NOT DISTINCT FROM pi.product_quantity
JOIN clickhouse.default.product_parameters pp
    ON m.product_weight IS NOT DISTINCT FROM pp.product_weight
    AND m.product_color IS NOT DISTINCT FROM pp.product_color
    AND m.product_size IS NOT DISTINCT FROM pp.product_size
    AND m.product_material IS NOT DISTINCT FROM pp.product_material
JOIN clickhouse.default.product_brand pb
    ON m.product_brand IS NOT DISTINCT FROM pb.product_brand
JOIN clickhouse.default.product_feedback pf
    ON m.product_rating IS NOT DISTINCT FROM pf.product_rating
    AND m.product_reviews IS NOT DISTINCT FROM pf.product_reviews
JOIN clickhouse.default.product_category pc
    ON m.product_category IS NOT DISTINCT FROM pc.product_category
GROUP BY m.sale_product_id;

CREATE TABLE clickhouse.default.sale_payment
WITH (engine = 'MergeTree')
AS
SELECT
    row_number() OVER (ORDER BY sale_quantity, sale_total_price) AS payment_id,
    sale_quantity,
    sale_total_price
FROM (
    SELECT DISTINCT sale_quantity, sale_total_price
    FROM clickhouse.default.stg_mock_data
) t;

CREATE TABLE clickhouse.default.fact_sales
WITH (engine = 'MergeTree')
AS
SELECT
    row_number() OVER (
        ORDER BY m.source_system, m.source_id, m.sale_customer_id, m.sale_seller_id, m.sale_product_id, m.sale_date
    ) AS sale_id,
    CAST(date_parse(m.sale_date, '%c/%e/%Y') AS date) AS sale_date,
    m.sale_customer_id,
    m.sale_seller_id,
    m.sale_product_id,
    sp.payment_id AS sale_payment_id,
    st.store_id AS sale_store_id,
    su.supplier_id AS product_supplier_id
FROM clickhouse.default.stg_mock_data m
JOIN clickhouse.default.sale_payment sp
    ON m.sale_quantity IS NOT DISTINCT FROM sp.sale_quantity
    AND m.sale_total_price IS NOT DISTINCT FROM sp.sale_total_price
JOIN clickhouse.default.store_info sti
    ON m.store_name IS NOT DISTINCT FROM sti.store_name
JOIN clickhouse.default.store_location stl
    ON m.store_location IS NOT DISTINCT FROM stl.store_location
    AND m.store_city IS NOT DISTINCT FROM stl.store_city
    AND m.store_state IS NOT DISTINCT FROM stl.store_state
    AND m.store_country IS NOT DISTINCT FROM stl.store_country
JOIN clickhouse.default.store_contacts stc
    ON m.store_phone IS NOT DISTINCT FROM stc.store_phone
    AND m.store_email IS NOT DISTINCT FROM stc.store_email
JOIN clickhouse.default.store st
    ON sti.info_id = st.store_info_id
    AND stl.location_id = st.store_location_id
    AND stc.contact_id = st.store_contact_id
JOIN clickhouse.default.supplier_info sui
    ON m.supplier_name IS NOT DISTINCT FROM sui.supplier_name
JOIN clickhouse.default.supplier_location sul
    ON m.supplier_address IS NOT DISTINCT FROM sul.supplier_address
    AND m.supplier_city IS NOT DISTINCT FROM sul.supplier_city
    AND m.supplier_country IS NOT DISTINCT FROM sul.supplier_country
JOIN clickhouse.default.supplier_contacts suc
    ON m.supplier_contact IS NOT DISTINCT FROM suc.supplier_contact
    AND m.supplier_email IS NOT DISTINCT FROM suc.supplier_email
    AND m.supplier_phone IS NOT DISTINCT FROM suc.supplier_phone
JOIN clickhouse.default.supplier su
    ON sui.info_id = su.supplier_info_id
    AND sul.location_id = su.supplier_location_id
    AND suc.contact_id = su.supplier_contact_id;
