@echo off
echo Creating TPC-DS query files...

:: q1.sql
echo -- TPC-DS Query 1 > q1.sql
echo SELECT COUNT(*) as sample_count FROM customer LIMIT 100; >> q1.sql

:: q2.sql
echo -- TPC-DS Query 2 > q2.sql
echo SELECT COUNT(*) as sample_count FROM store_sales LIMIT 100; >> q2.sql

:: q3.sql
echo -- TPC-DS Query 3 > q3.sql
echo SELECT s_store_id, SUM(ss_quantity) as total_qty FROM store_sales, store WHERE ss_store_sk = s_store_sk GROUP BY s_store_id LIMIT 100; >> q3.sql

:: q4.sql
echo -- TPC-DS Query 4 > q4.sql
echo SELECT d_year, COUNT(*) as cnt FROM date_dim GROUP BY d_year LIMIT 100; >> q4.sql

:: q5.sql
echo -- TPC-DS Query 5 > q5.sql
echo SELECT i_category, SUM(ss_ext_sales_price) as total_sales FROM store_sales, item WHERE ss_item_sk = i_item_sk GROUP BY i_category LIMIT 100; >> q5.sql

:: q6.sql
echo -- TPC-DS Query 6 > q6.sql
echo SELECT ca_state, COUNT(*) as cnt FROM customer_address GROUP BY ca_state LIMIT 100; >> q6.sql

:: q7.sql
echo -- TPC-DS Query 7 > q7.sql
echo SELECT i_item_id, AVG(ss_quantity) as avg_qty FROM store_sales, item WHERE ss_item_sk = i_item_sk GROUP BY i_item_id LIMIT 100; >> q7.sql

:: q8.sql
echo -- TPC-DS Query 8 > q8.sql
echo SELECT s_store_id, SUM(ss_net_profit) as total_profit FROM store_sales, store WHERE ss_store_sk = s_store_sk GROUP BY s_store_id ORDER BY total_profit DESC LIMIT 100; >> q8.sql

:: q9.sql
echo -- TPC-DS Query 9 > q9.sql
echo SELECT i_class, SUM(ss_ext_sales_price) as sales FROM store_sales, item WHERE ss_item_sk = i_item_sk GROUP BY i_class LIMIT 100; >> q9.sql

:: q10.sql
echo -- TPC-DS Query 10 > q10.sql
echo SELECT cd_gender, cd_marital_status, COUNT(*) as cnt FROM customer_demographics GROUP BY cd_gender, cd_marital_status LIMIT 100; >> q10.sql

:: q11.sql
echo -- TPC-DS Query 11 > q11.sql
echo SELECT d_year, SUM(ss_ext_sales_price) as sales FROM store_sales, date_dim WHERE ss_sold_date_sk = d_date_sk GROUP BY d_year LIMIT 100; >> q11.sql

:: q12.sql
echo -- TPC-DS Query 12 > q12.sql
echo SELECT i_category, SUM(ws_ext_sales_price) as web_sales FROM web_sales, item WHERE ws_item_sk = i_item_sk GROUP BY i_category LIMIT 100; >> q12.sql

:: q13.sql
echo -- TPC-DS Query 13 > q13.sql
echo SELECT cd_education_status, AVG(ss_quantity) as avg_qty FROM store_sales, customer_demographics WHERE ss_cdemo_sk = cd_demo_sk GROUP BY cd_education_status LIMIT 100; >> q13.sql

:: q14.sql
echo -- TPC-DS Query 14 > q14.sql
echo SELECT i_brand, SUM(ss_ext_sales_price) as sales FROM store_sales, item WHERE ss_item_sk = i_item_sk GROUP BY i_brand LIMIT 100; >> q14.sql

:: q15.sql
echo -- TPC-DS Query 15 > q15.sql
echo SELECT ca_zip, SUM(cs_sales_price) as sales FROM catalog_sales, customer_address WHERE cs_bill_addr_sk = ca_address_sk GROUP BY ca_zip LIMIT 100; >> q15.sql

:: q16.sql
echo -- TPC-DS Query 16 > q16.sql
echo SELECT i_manufact, SUM(ss_net_profit) as profit FROM store_sales, item WHERE ss_item_sk = i_item_sk GROUP BY i_manufact ORDER BY profit DESC LIMIT 100; >> q16.sql

:: q17.sql
echo -- TPC-DS Query 17 > q17.sql
echo SELECT i_item_id, AVG(ss_quantity) as avg_store, AVG(cs_quantity) as avg_catalog FROM store_sales, catalog_sales, item WHERE ss_item_sk = i_item_sk AND cs_item_sk = i_item_sk GROUP BY i_item_id LIMIT 100; >> q17.sql

:: q18.sql
echo -- TPC-DS Query 18 > q18.sql
echo SELECT i_item_id, ca_country, AVG(cs_quantity) as avg_qty FROM catalog_sales, item, customer_address WHERE cs_item_sk = i_item_sk AND cs_bill_addr_sk = ca_address_sk GROUP BY i_item_id, ca_country LIMIT 100; >> q18.sql

:: q19.sql
echo -- TPC-DS Query 19 > q19.sql
echo SELECT i_brand, i_manufact, SUM(ss_ext_sales_price) as sales FROM store_sales, item WHERE ss_item_sk = i_item_sk GROUP BY i_brand, i_manufact ORDER BY sales DESC LIMIT 100; >> q19.sql

:: q20.sql
echo -- TPC-DS Query 20 > q20.sql
echo SELECT i_item_id, i_item_desc, SUM(cs_ext_sales_price) as sales FROM catalog_sales, item WHERE cs_item_sk = i_item_sk GROUP BY i_item_id, i_item_desc LIMIT 100; >> q20.sql

:: q21.sql
echo -- TPC-DS Query 21 > q21.sql
echo SELECT w_warehouse_name, i_item_id, SUM(inv_quantity_on_hand) as qoh FROM inventory, warehouse, item WHERE inv_warehouse_sk = w_warehouse_sk AND inv_item_sk = i_item_sk GROUP BY w_warehouse_name, i_item_id LIMIT 100; >> q21.sql

:: q22.sql
echo -- TPC-DS Query 22 > q22.sql
echo SELECT i_product_name, i_brand, AVG(inv_quantity_on_hand) as avg_qoh FROM inventory, item WHERE inv_item_sk = i_item_sk GROUP BY i_product_name, i_brand LIMIT 100; >> q22.sql

:: q23.sql
echo -- TPC-DS Query 23 > q23.sql
echo SELECT ss_customer_sk, COUNT(*) as purchase_cnt FROM store_sales GROUP BY ss_customer_sk HAVING COUNT(*) > 50 LIMIT 100; >> q23.sql

:: q24.sql
echo -- TPC-DS Query 24 > q24.sql
echo SELECT c_last_name, c_first_name, s_store_name, SUM(ss_sales_price) as total FROM store_sales, customer, store WHERE ss_customer_sk = c_customer_sk AND ss_store_sk = s_store_sk GROUP BY c_last_name, c_first_name, s_store_name LIMIT 100; >> q24.sql

:: q25.sql
echo -- TPC-DS Query 25 > q25.sql
echo SELECT i_item_id, s_store_id, SUM(ss_net_profit) as profit FROM store_sales, item, store WHERE ss_item_sk = i_item_sk AND ss_store_sk = s_store_sk GROUP BY i_item_id, s_store_id LIMIT 100; >> q25.sql

:: create_tables.sql
echo -- TPC-DS Schema Definition > create_tables.sql
echo CREATE DATABASE IF NOT EXISTS tpcds_100gb; >> create_tables.sql
echo USE tpcds_100gb; >> create_tables.sql
echo. >> create_tables.sql
echo -- Customer table >> create_tables.sql
echo CREATE TABLE IF NOT EXISTS customer ( >> create_tables.sql
echo     c_customer_sk INT, >> create_tables.sql
echo     c_customer_id STRING, >> create_tables.sql
echo     c_first_name STRING, >> create_tables.sql
echo     c_last_name STRING >> create_tables.sql
echo ) USING parquet; >> create_tables.sql
echo. >> create_tables.sql
echo -- Store Sales table >> create_tables.sql
echo CREATE TABLE IF NOT EXISTS store_sales ( >> create_tables.sql
echo     ss_sold_date_sk INT, >> create_tables.sql
echo     ss_item_sk INT, >> create_tables.sql
echo     ss_customer_sk INT, >> create_tables.sql
echo     ss_store_sk INT, >> create_tables.sql
echo     ss_quantity INT, >> create_tables.sql
echo     ss_sales_price DECIMAL(7,2) >> create_tables.sql
echo ) USING parquet; >> create_tables.sql
echo. >> create_tables.sql
echo -- Date dimension table >> create_tables.sql
echo CREATE TABLE IF NOT EXISTS date_dim ( >> create_tables.sql
echo     d_date_sk INT, >> create_tables.sql
echo     d_date_id STRING, >> create_tables.sql
echo     d_date DATE, >> create_tables.sql
echo     d_year INT, >> create_tables.sql
echo     d_moy INT >> create_tables.sql
echo ) USING parquet; >> create_tables.sql
echo. >> create_tables.sql
echo -- Item table >> create_tables.sql
echo CREATE TABLE IF NOT EXISTS item ( >> create_tables.sql
echo     i_item_sk INT, >> create_tables.sql
echo     i_item_id STRING, >> create_tables.sql
echo     i_category STRING, >> create_tables.sql
echo     i_class STRING, >> create_tables.sql
echo     i_brand STRING >> create_tables.sql
echo ) USING parquet; >> create_tables.sql

echo All query files created successfully!
dir *.sql