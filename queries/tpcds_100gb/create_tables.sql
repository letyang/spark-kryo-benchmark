-- TPC-DS Schema Definition for Spark SQL
-- This creates the necessary tables for the benchmark

CREATE DATABASE IF NOT EXISTS tpcds_100gb;
USE tpcds_100gb;

-- Customer dimension table
CREATE TABLE IF NOT EXISTS customer (
    c_customer_sk INT,
    c_customer_id STRING,
    c_first_name STRING,
    c_last_name STRING,
    c_birth_year INT,
    c_current_addr_sk INT,
    c_current_cdemo_sk INT,
    c_email_address STRING
) USING parquet;

-- Store sales fact table
CREATE TABLE IF NOT EXISTS store_sales (
    ss_sold_date_sk INT,
    ss_sold_time_sk INT,
    ss_item_sk INT,
    ss_customer_sk INT,
    ss_cdemo_sk INT,
    ss_hdemo_sk INT,
    ss_addr_sk INT,
    ss_store_sk INT,
    ss_promo_sk INT,
    ss_ticket_number INT,
    ss_quantity INT,
    ss_sales_price DECIMAL(7,2),
    ss_net_profit DECIMAL(7,2)
) USING parquet;

-- Date dimension table
CREATE TABLE IF NOT EXISTS date_dim (
    d_date_sk INT,
    d_date_id STRING,
    d_date DATE,
    d_year INT,
    d_moy INT,
    d_qoy INT
) USING parquet;

-- Item dimension table
CREATE TABLE IF NOT EXISTS item (
    i_item_sk INT,
    i_item_id STRING,
    i_category STRING,
    i_class STRING,
    i_brand STRING,
    i_manufact_id INT,
    i_current_price DECIMAL(7,2)
) USING parquet;

-- Store dimension table
CREATE TABLE IF NOT EXISTS store (
    s_store_sk INT,
    s_store_id STRING,
    s_store_name STRING,
    s_zip STRING,
    s_state STRING,
    s_market_id INT
) USING parquet;

-- Customer address dimension table
CREATE TABLE IF NOT EXISTS customer_address (
    ca_address_sk INT,
    ca_address_id STRING,
    ca_state STRING,
    ca_zip STRING,
    ca_country STRING
) USING parquet;

-- Customer demographics dimension table
CREATE TABLE IF NOT EXISTS customer_demographics (
    cd_demo_sk INT,
    cd_gender STRING,
    cd_marital_status STRING,
    cd_education_status STRING,
    cd_credit_rating STRING
) USING parquet;

-- Web sales fact table
CREATE TABLE IF NOT EXISTS web_sales (
    ws_sold_date_sk INT,
    ws_item_sk INT,
    ws_bill_customer_sk INT,
    ws_quantity INT,
    ws_sales_price DECIMAL(7,2),
    ws_net_profit DECIMAL(7,2)
) USING parquet;

-- Catalog sales fact table
CREATE TABLE IF NOT EXISTS catalog_sales (
    cs_sold_date_sk INT,
    cs_item_sk INT,
    cs_bill_customer_sk INT,
    cs_quantity INT,
    cs_sales_price DECIMAL(7,2),
    cs_net_profit DECIMAL(7,2)
) USING parquet;

-- Inventory fact table
CREATE TABLE IF NOT EXISTS inventory (
    inv_date_sk INT,
    inv_item_sk INT,
    inv_warehouse_sk INT,
    inv_quantity_on_hand INT
) USING parquet;

-- Warehouse dimension table
CREATE TABLE IF NOT EXISTS warehouse (
    w_warehouse_sk INT,
    w_warehouse_id STRING,
    w_warehouse_name STRING,
    w_zip STRING,
    w_state STRING
) USING parquet;

-- Verify tables were created
SHOW TABLES;