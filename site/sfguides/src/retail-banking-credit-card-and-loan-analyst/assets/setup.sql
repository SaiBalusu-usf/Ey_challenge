-- ============================================================
-- Retail Banking Credit Card and Loan Analyst - Setup Script
-- ============================================================
-- Run this script as ACCOUNTADMIN to set up the complete demo environment
-- This guide demonstrates Snowflake Cortex Agents with Semantic Views
-- for conversational analytics across auto loans and credit card portfolios

USE ROLE ACCOUNTADMIN;
ALTER SESSION SET query_tag = '{"origin":"sf_sit-is","name":"retail_banking_credit_card_loan_analyst","version":{"major":1,"minor":0},"attributes":{"is_quickstart":1,"source":"sql"}}';

-- ============================================================
-- SECTION 1: CUSTOM ROLE & WAREHOUSE SETUP
-- ============================================================

USE ROLE USERADMIN;
CREATE OR REPLACE ROLE BANKING_ROLE;
SET curr_user = CURRENT_USER();
GRANT ROLE BANKING_ROLE TO USER IDENTIFIER($curr_user); 
GRANT ROLE BANKING_ROLE TO ROLE sysadmin;

USE ROLE ACCOUNTADMIN;
CREATE OR REPLACE WAREHOUSE BANKING_WH
  WAREHOUSE_SIZE = 'XSMALL'
  AUTO_SUSPEND = 60
  AUTO_RESUME = TRUE
  INITIALLY_SUSPENDED = TRUE;

GRANT CREATE DATABASE ON ACCOUNT TO ROLE BANKING_ROLE;
GRANT CREATE SNOWFLAKE INTELLIGENCE ON ACCOUNT TO ROLE BANKING_ROLE;
GRANT USAGE ON WAREHOUSE BANKING_WH TO ROLE BANKING_ROLE;
GRANT OPERATE ON WAREHOUSE BANKING_WH TO ROLE BANKING_ROLE;
GRANT ROLE BANKING_ROLE TO ROLE SYSADMIN;
GRANT DATABASE ROLE SNOWFLAKE.CORTEX_USER TO ROLE BANKING_ROLE;

USE ROLE BANKING_ROLE;
USE WAREHOUSE BANKING_WH;

-- ============================================================
-- SECTION 2: DATABASE & SCHEMAS
-- ============================================================
CREATE OR REPLACE DATABASE BANKING_DB;
USE DATABASE BANKING_DB;

CREATE OR REPLACE SCHEMA AUTO_LOANS;
CREATE OR REPLACE SCHEMA CREDIT;

-- ============================================================
-- SECTION 3: AUTO LOANS TABLES
-- ============================================================
USE SCHEMA AUTO_LOANS;

CREATE OR REPLACE TABLE CUSTOMERS (
  CUSTOMER_ID         NUMBER        NOT NULL,
  FIRST_NAME          STRING        NOT NULL,
  LAST_NAME           STRING        NOT NULL,
  EMAIL               STRING,
  PHONE               STRING,
  DOB                 DATE,
  ADDRESS_LINE1       STRING,
  CITY                STRING,
  STATE               STRING,
  POSTAL_CODE         STRING,
  CREATED_AT          TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
  SEGMENT             STRING,
  PRIMARY KEY (CUSTOMER_ID)
);

CREATE OR REPLACE TABLE CUSTOMER_ACCOUNTS (
  ACCOUNT_ID          NUMBER        NOT NULL,
  CUSTOMER_ID         NUMBER        NOT NULL,
  ACCOUNT_OPEN_DATE   DATE          NOT NULL,
  STATUS              STRING,
  BRANCH_ID           STRING,
  PRIMARY KEY (ACCOUNT_ID)
);

CREATE OR REPLACE TABLE LOAN_APPLICATIONS (
  APPLICATION_ID      NUMBER        NOT NULL,
  CUSTOMER_ID         NUMBER        NOT NULL,
  SUBMITTED_AT        TIMESTAMP_NTZ NOT NULL,
  CHANNEL             STRING,
  PRODUCT             STRING,
  AMOUNT_REQUESTED    NUMBER(12,2)  NOT NULL,
  TERM_MONTHS         NUMBER        NOT NULL,
  INTEREST_RATE_OFFERED NUMBER(5,3),
  STATUS              STRING,
  DECISION_AT         TIMESTAMP_NTZ,
  REASON_CODE         STRING,
  PRIMARY KEY (APPLICATION_ID)
);

CREATE OR REPLACE TABLE LOANS (
  LOAN_ID             NUMBER        NOT NULL,
  CUSTOMER_ID         NUMBER        NOT NULL,
  APPLICATION_ID      NUMBER,
  ACCOUNT_ID          NUMBER,
  ORIGINATION_DATE    DATE          NOT NULL,
  PRINCIPAL           NUMBER(12,2)  NOT NULL,
  INTEREST_RATE       NUMBER(5,3)   NOT NULL,
  TERM_MONTHS         NUMBER        NOT NULL,
  MATURITY_DATE       DATE          NOT NULL,
  LOAN_STATUS         STRING,
  PRIMARY KEY (LOAN_ID)
);

CREATE OR REPLACE TABLE PAYMENTS (
  PAYMENT_ID          NUMBER        NOT NULL,
  LOAN_ID             NUMBER        NOT NULL,
  CUSTOMER_ID         NUMBER        NOT NULL,
  PAYMENT_DATE        DATE          NOT NULL,
  AMOUNT_DUE          NUMBER(12,2),
  AMOUNT_PAID         NUMBER(12,2),
  PRINCIPAL_COMPONENT NUMBER(12,2),
  INTEREST_COMPONENT  NUMBER(12,2),
  LATE_FEE            NUMBER(12,2),
  PAST_DUE_DAYS       NUMBER,
  PAYMENT_STATUS      STRING,
  PRIMARY KEY (PAYMENT_ID)
);

CREATE OR REPLACE TABLE VEHICLES (
  VEHICLE_ID          NUMBER        NOT NULL,
  LOAN_ID             NUMBER        NOT NULL,
  VIN                 STRING        NOT NULL,
  MAKE                STRING,
  MODEL               STRING,
  MODEL_YEAR          NUMBER,
  MSRP                NUMBER(12,2),
  PURCHASE_PRICE      NUMBER(12,2),
  MILEAGE_AT_PURCHASE NUMBER,
  DEALER_ID           STRING,
  PRIMARY KEY (VEHICLE_ID)
);

-- ============================================================
-- SECTION 4: AUTO LOANS SAMPLE DATA
-- ============================================================
INSERT INTO CUSTOMERS (CUSTOMER_ID, FIRST_NAME, LAST_NAME, EMAIL, PHONE, DOB, ADDRESS_LINE1, CITY, STATE, POSTAL_CODE, SEGMENT, CREATED_AT) VALUES
  (1001,'Ava','Johnson','ava.johnson@example.com','555-111-0001','1987-03-14','12 Oak St','Austin','TX','73301','Prime',CURRENT_TIMESTAMP()),
  (1002,'Ben','Martinez','ben.martinez@example.com','555-111-0002','1991-07-22','99 Pine Ave','Phoenix','AZ','85001','Near-Prime',CURRENT_TIMESTAMP()),
  (1003,'Cara','Lee','cara.lee@example.com','555-111-0003','1983-12-03','77 Maple Dr','Denver','CO','80014','Prime',CURRENT_TIMESTAMP()),
  (1004,'Dev','Singh','dev.singh@example.com','555-111-0004','1996-05-18','450 Elm St','Columbus','OH','43004','Subprime',CURRENT_TIMESTAMP()),
  (1005,'Ella','Nguyen','ella.nguyen@example.com','555-111-0005','1979-09-09','8 Birch Rd','Tampa','FL','33601','Prime',CURRENT_TIMESTAMP());

INSERT INTO CUSTOMER_ACCOUNTS (ACCOUNT_ID, CUSTOMER_ID, ACCOUNT_OPEN_DATE, STATUS, BRANCH_ID) VALUES
  (20001,1001,'2021-01-15','active','BR001'),
  (20002,1002,'2022-05-03','active','BR002'),
  (20003,1003,'2020-08-24','active','BR003'),
  (20004,1004,'2023-02-11','active','BR004'),
  (20005,1005,'2019-10-02','active','BR005');

INSERT INTO LOAN_APPLICATIONS (APPLICATION_ID, CUSTOMER_ID, SUBMITTED_AT, CHANNEL, PRODUCT, AMOUNT_REQUESTED, TERM_MONTHS, INTEREST_RATE_OFFERED, STATUS, DECISION_AT, REASON_CODE) VALUES
  (30001,1001,'2023-11-02 10:15','Dealer','New Auto',35000,72,4.250,'Approved','2023-11-02 15:30',NULL),
  (30002,1002,'2024-01-18 09:05','Online','Used Auto',18000,60,7.750,'Approved','2024-01-18 14:10',NULL),
  (30003,1003,'2024-03-05 13:20','Branch','Refinance',22000,48,5.490,'Approved','2024-03-05 16:05',NULL),
  (30004,1004,'2024-04-22 11:40','Dealer','Used Auto',24000,72,12.990,'Denied','2024-04-22 17:50','CreditScore'),
  (30005,1005,'2023-09-14 12:00','Online','New Auto',42000,72,4.990,'Approved','2023-09-14 16:45',NULL),
  (30006,1002,'2024-06-09 08:55','Dealer','Refinance',15000,36,6.990,'Pending',NULL,NULL),
  (30007,1004,'2024-07-12 10:30','Online','Used Auto',16000,60,11.490,'Approved','2024-07-12 15:00',NULL);

INSERT INTO LOANS (LOAN_ID, CUSTOMER_ID, APPLICATION_ID, ACCOUNT_ID, ORIGINATION_DATE, PRINCIPAL, INTEREST_RATE, TERM_MONTHS, MATURITY_DATE, LOAN_STATUS) VALUES
  (40001,1001,30001,20001,'2023-11-10',35000,4.250,72,'2029-11-10','active'),
  (40002,1002,30002,20002,'2024-01-25',18000,7.750,60,'2029-01-25','active'),
  (40003,1003,30003,20003,'2024-03-12',22000,5.490,48,'2028-03-12','active'),
  (40004,1005,30005,20005,'2023-09-20',42000,4.990,72,'2029-09-20','active'),
  (40005,1004,30007,20004,'2024-07-20',16000,11.490,60,'2029-07-20','active');

INSERT INTO VEHICLES (VEHICLE_ID, LOAN_ID, VIN, MAKE, MODEL, MODEL_YEAR, MSRP, PURCHASE_PRICE, MILEAGE_AT_PURCHASE, DEALER_ID) VALUES
  (50001,40001,'1FTFW1EF1EFA12345','Ford','F-150',2023,54000,38000,12,'DLR-TX-001'),
  (50002,40002,'2C4RC1BG0ERB67890','Toyota','Camry',2021,30000,18500,24000,'DLR-AZ-014'),
  (50003,40003,'3FA6P0H72FRG45678','Honda','Civic',2020,25000,21000,19000,'DLR-CO-207'),
  (50004,40004,'5N1AT2MV7EC987654','Tesla','Model 3',2023,42000,41500,5,'DLR-FL-300'),
  (50005,40005,'1HGBH41JXMN109186','Hyundai','Elantra',2022,21000,16200,8000,'DLR-OH-120');

INSERT INTO PAYMENTS (PAYMENT_ID, LOAN_ID, CUSTOMER_ID, PAYMENT_DATE, AMOUNT_DUE, AMOUNT_PAID, PRINCIPAL_COMPONENT, INTEREST_COMPONENT, LATE_FEE, PAST_DUE_DAYS, PAYMENT_STATUS) VALUES
  (60001,40001,1001,'2023-12-15',550.00,550.00,420.00,130.00,0.00,0,'OnTime'),
  (60002,40001,1001,'2024-01-15',550.00,550.00,422.00,128.00,0.00,0,'OnTime'),
  (60003,40001,1001,'2024-02-16',550.00,560.00,425.00,125.00,10.00,1,'Late'),
  (60004,40002,1002,'2024-02-25',400.00,400.00,310.00,90.00,0.00,0,'OnTime'),
  (60005,40002,1002,'2024-03-25',400.00,380.00,290.00,90.00,0.00,5,'Late'),
  (60006,40002,1002,'2024-04-25',400.00,0.00,0.00,0.00,0.00,35,'Missed'),
  (60007,40003,1003,'2024-04-12',520.00,520.00,400.00,120.00,0.00,0,'OnTime'),
  (60008,40003,1003,'2024-05-12',520.00,520.00,402.00,118.00,0.00,0,'OnTime'),
  (60009,40004,1005,'2023-10-20',600.00,600.00,470.00,130.00,0.00,0,'OnTime'),
  (60010,40004,1005,'2023-11-20',600.00,600.00,472.00,128.00,0.00,0,'OnTime'),
  (60011,40004,1005,'2023-12-20',600.00,600.00,474.00,126.00,0.00,0,'OnTime'),
  (60012,40005,1004,'2024-08-20',360.00,360.00,270.00,90.00,0.00,0,'OnTime'),
  (60013,40005,1004,'2024-09-20',360.00,320.00,230.00,90.00,0.00,7,'Late');

-- ============================================================
-- SECTION 5: CREDIT TABLES
-- ============================================================
USE SCHEMA CREDIT;

CREATE OR REPLACE TABLE CREDIT_CARD_APPLICATIONS (
  CC_APPLICATION_ID       NUMBER        NOT NULL,
  CUSTOMER_ID             NUMBER        NOT NULL,
  SUBMITTED_AT            TIMESTAMP_NTZ NOT NULL,
  CHANNEL                 STRING,
  CARD_PRODUCT            STRING,
  CREDIT_LIMIT_REQUESTED  NUMBER(12,2),
  APR_OFFERED             NUMBER(5,3),
  STATUS                  STRING,
  DECISION_AT             TIMESTAMP_NTZ,
  REASON_CODE             STRING,
  PRIMARY KEY (CC_APPLICATION_ID)
);

CREATE OR REPLACE TABLE CREDIT_CARDS (
  CARD_ID                 NUMBER        NOT NULL,
  CUSTOMER_ID             NUMBER        NOT NULL,
  ACCOUNT_ID              NUMBER,
  APPLICATION_ID          NUMBER,
  CARD_NUMBER_TOKEN       STRING        NOT NULL,
  CARD_PRODUCT            STRING,
  OPEN_DATE               DATE          NOT NULL,
  STATUS                  STRING,
  CREDIT_LIMIT            NUMBER(12,2)  NOT NULL,
  CURRENT_BALANCE         NUMBER(12,2)  DEFAULT 0,
  APR                     NUMBER(5,3)   NOT NULL,
  PRIMARY KEY (CARD_ID)
);

CREATE OR REPLACE TABLE MERCHANTS (
  MERCHANT_ID             NUMBER        NOT NULL,
  MERCHANT_NAME           STRING        NOT NULL,
  MCC                     STRING,
  CITY                    STRING,
  STATE                   STRING,
  COUNTRY                 STRING,
  PRIMARY KEY (MERCHANT_ID)
);

CREATE OR REPLACE TABLE CARD_TRANSACTIONS (
  TRANSACTION_ID          NUMBER        NOT NULL,
  CARD_ID                 NUMBER        NOT NULL,
  CUSTOMER_ID             NUMBER        NOT NULL,
  MERCHANT_ID             NUMBER,
  AUTH_TIMESTAMP          TIMESTAMP_NTZ NOT NULL,
  POST_DATE               DATE,
  AMOUNT                  NUMBER(12,2)  NOT NULL,
  CURRENCY                STRING        DEFAULT 'USD',
  CATEGORY                STRING,
  CHANNEL                 STRING,
  STATUS                  STRING,
  PRIMARY KEY (TRANSACTION_ID)
);

CREATE OR REPLACE TABLE CARD_STATEMENTS (
  STATEMENT_ID            NUMBER        NOT NULL,
  CARD_ID                 NUMBER        NOT NULL,
  STATEMENT_PERIOD_START  DATE          NOT NULL,
  STATEMENT_PERIOD_END    DATE          NOT NULL,
  DUE_DATE                DATE          NOT NULL,
  STATEMENT_BALANCE       NUMBER(12,2)  NOT NULL,
  MIN_PAYMENT_DUE         NUMBER(12,2)  NOT NULL,
  PRIMARY KEY (STATEMENT_ID)
);

CREATE OR REPLACE TABLE CARD_PAYMENTS (
  CARD_PAYMENT_ID         NUMBER        NOT NULL,
  CARD_ID                 NUMBER        NOT NULL,
  CUSTOMER_ID             NUMBER        NOT NULL,
  STATEMENT_ID            NUMBER,
  PAYMENT_DATE            DATE          NOT NULL,
  AMOUNT                  NUMBER(12,2)  NOT NULL,
  METHOD                  STRING,
  STATUS                  STRING,
  PRIMARY KEY (CARD_PAYMENT_ID)
);

-- ============================================================
-- SECTION 6: CREDIT SAMPLE DATA
-- ============================================================
INSERT INTO CREDIT_CARD_APPLICATIONS (CC_APPLICATION_ID, CUSTOMER_ID, SUBMITTED_AT, CHANNEL, CARD_PRODUCT, CREDIT_LIMIT_REQUESTED, APR_OFFERED, STATUS, DECISION_AT, REASON_CODE) VALUES
  (70001,1001,'2024-06-10 09:45','Online','CashBack',15000,18.990,'Approved','2024-06-10 14:30',NULL),
  (70002,1002,'2024-07-02 11:20','Branch','Travel',12000,22.990,'Approved','2024-07-02 16:05',NULL),
  (70003,1003,'2024-07-15 13:10','Online','Platinum',20000,16.990,'Denied','2024-07-15 17:25','CreditScore'),
  (70004,1004,'2024-08-01 10:05','Partner','CashBack',8000,27.990,'Approved','2024-08-01 15:40',NULL),
  (70005,1005,'2024-06-25 12:00','Online','Travel',25000,17.990,'Approved','2024-06-25 15:10',NULL);

INSERT INTO CREDIT_CARDS (CARD_ID, CUSTOMER_ID, ACCOUNT_ID, APPLICATION_ID, CARD_NUMBER_TOKEN, CARD_PRODUCT, OPEN_DATE, STATUS, CREDIT_LIMIT, CURRENT_BALANCE, APR) VALUES
  (80001,1001,20001,70001,'4111-XXXX-XXXX-1234','CashBack','2024-06-15','active',15000,1250.35,18.990),
  (80002,1002,20002,70002,'4111-XXXX-XXXX-2345','Travel','2024-07-05','active',12000,3420.00,22.990),
  (80003,1004,20004,70004,'4111-XXXX-XXXX-3456','CashBack','2024-08-05','active',8000,610.50,27.990),
  (80004,1005,20005,70005,'4111-XXXX-XXXX-4567','Travel','2024-06-28','active',25000,9875.20,17.990);

INSERT INTO MERCHANTS (MERCHANT_ID, MERCHANT_NAME, MCC, CITY, STATE, COUNTRY) VALUES
  (90001,'FreshMarket Grocery','5411','Austin','TX','US'),
  (90002,'FuelFast Station','5541','Phoenix','AZ','US'),
  (90003,'Skyways Airlines','4511','Denver','CO','US'),
  (90004,'Bistro Bella','5812','Columbus','OH','US'),
  (90005,'TechHub Electronics','5732','Tampa','FL','US'),
  (90006,'Global Hotel Group','7011','Miami','FL','US');

INSERT INTO CARD_TRANSACTIONS (TRANSACTION_ID, CARD_ID, CUSTOMER_ID, MERCHANT_ID, AUTH_TIMESTAMP, POST_DATE, AMOUNT, CURRENCY, CATEGORY, CHANNEL, STATUS) VALUES
  (91001,80001,1001,90001,'2024-08-05 18:10','2024-08-06',82.45,'USD','Grocery','POS','Posted'),
  (91002,80001,1001,90004,'2024-08-10 19:30','2024-08-11',56.20,'USD','Dining','POS','Posted'),
  (91003,80001,1001,90005,'2024-08-20 14:05','2024-08-21',399.99,'USD','Electronics','ECOM','Posted'),
  (91004,80002,1002,90002,'2024-08-07 08:25','2024-08-07',65.30,'USD','Fuel','POS','Posted'),
  (91005,80002,1002,90003,'2024-08-22 12:00','2024-08-23',780.00,'USD','Travel','ECOM','Posted'),
  (91006,80002,1002,90006,'2024-08-25 21:10',NULL,450.00,'USD','Travel','ECOM','Authorized'),
  (91007,80003,1004,90001,'2024-08-12 09:15','2024-08-13',34.18,'USD','Grocery','POS','Posted'),
  (91008,80003,1004,90002,'2024-08-15 07:50','2024-08-15',42.60,'USD','Fuel','POS','Posted'),
  (91009,80003,1004,90004,'2024-08-28 20:45','2024-08-29',88.00,'USD','Dining','POS','Reversed'),
  (91010,80004,1005,90005,'2024-08-03 10:05','2024-08-04',1299.00,'USD','Electronics','ECOM','Posted'),
  (91011,80004,1005,90006,'2024-08-18 22:10','2024-08-19',650.00,'USD','Travel','ECOM','Posted'),
  (91012,80004,1005,90003,'2024-08-28 06:40','2024-08-29',420.00,'USD','Travel','ECOM','Disputed');

INSERT INTO CARD_STATEMENTS (STATEMENT_ID, CARD_ID, STATEMENT_PERIOD_START, STATEMENT_PERIOD_END, DUE_DATE, STATEMENT_BALANCE, MIN_PAYMENT_DUE) VALUES
  (92001,80001,'2024-08-01','2024-08-31','2024-09-25',538.64,35.00),
  (92002,80002,'2024-08-01','2024-08-31','2024-09-20',1245.30,40.00),
  (92003,80003,'2024-08-01','2024-08-31','2024-09-22',164.78,30.00),
  (92004,80004,'2024-08-01','2024-08-31','2024-09-18',2369.00,71.00),
  (92005,80001,'2024-09-01','2024-09-30','2024-10-25',711.91,35.00),
  (92006,80002,'2024-09-01','2024-09-30','2024-10-20',2310.00,69.00),
  (92007,80003,'2024-09-01','2024-09-30','2024-10-22',205.38,30.00),
  (92008,80004,'2024-09-01','2024-09-30','2024-10-18',3150.40,95.00);

INSERT INTO CARD_PAYMENTS (CARD_PAYMENT_ID, CARD_ID, CUSTOMER_ID, STATEMENT_ID, PAYMENT_DATE, AMOUNT, METHOD, STATUS) VALUES
  (93001,80001,1001,92001,'2024-09-20',200.00,'ACH','Received'),
  (93002,80002,1002,92002,'2024-09-18',50.00,'Debit','Returned'),
  (93003,80003,1004,92003,'2024-09-21',40.00,'ACH','Received'),
  (93004,80004,1005,92004,'2024-09-16',100.00,'ACH','Received'),
  (93005,80001,1001,92005,'2024-10-22',100.00,'ACH','Received'),
  (93006,80002,1002,92006,'2024-10-18',80.00,'ACH','Received'),
  (93007,80003,1004,92007,'2024-10-20',35.00,'Debit','Received'),
  (93008,80004,1005,92008,'2024-10-15',95.00,'ACH','Received');

-- ============================================================
-- SECTION 7: AUTO LOANS SEMANTIC VIEW (YAML-based)
-- ============================================================
CALL SYSTEM$CREATE_SEMANTIC_VIEW_FROM_YAML(
  'BANKING_DB.AUTO_LOANS',
  $$
name: AUTO_LOANS_SEMANTIC_VIEW
tables:
  - name: CUSTOMERS
    base_table:
      database: BANKING_DB
      schema: AUTO_LOANS
      table: CUSTOMERS
    primary_key:
      columns:
        - CUSTOMER_ID
    dimensions:
      - name: CUSTOMER_ID
        expr: CUSTOMER_ID
        data_type: NUMBER
        description: Unique identifier for each customer.
        synonyms:
          - customer_key
          - client_id
          - user_id
          - account_number
      - name: FIRST_NAME
        expr: FIRST_NAME
        data_type: VARCHAR
        description: The first name of the customer.
        synonyms:
          - given_name
          - forename
          - personal_name
      - name: LAST_NAME
        expr: LAST_NAME
        data_type: VARCHAR
        description: The last name of the customer.
        synonyms:
          - surname
          - family_name
      - name: EMAIL
        expr: EMAIL
        data_type: VARCHAR
        description: The email address of the customer.
        synonyms:
          - email_address
          - contact_email
          - customer_email
      - name: PHONE
        expr: PHONE
        data_type: VARCHAR
        description: The phone number of the customer.
        synonyms:
          - telephone
          - mobile
          - cell
          - contact_number
      - name: ADDRESS_LINE1
        expr: ADDRESS_LINE1
        data_type: VARCHAR
        description: The street address of the customer.
        synonyms:
          - street_address
          - street_number
          - mailing_address
          - physical_address
      - name: CITY
        expr: CITY
        data_type: VARCHAR
        description: The city where the customer is located.
        synonyms:
          - town
          - municipality
          - metropolis
          - urban_area
          - locality
      - name: STATE
        expr: STATE
        data_type: VARCHAR
        description: The state where the customer resides.
        synonyms:
          - province
          - region
          - territory
          - county
      - name: POSTAL_CODE
        expr: POSTAL_CODE
        data_type: VARCHAR
        description: The postal code of the customer.
        synonyms:
          - zip_code
          - postcode
          - zip
          - mailing_code
      - name: SEGMENT
        expr: SEGMENT
        data_type: VARCHAR
        description: Customer creditworthiness classification (Prime, Near-Prime, Subprime).
        synonyms:
          - category
          - group
          - classification
          - tier
        sample_values:
          - "Prime"
          - "Near-Prime"
          - "Subprime"
    time_dimensions:
      - name: DOB
        expr: DOB
        data_type: DATE
        description: Date of Birth of the customer.
        synonyms:
          - date_of_birth
          - birth_date
          - birthdate
          - birthday
      - name: CREATED_AT
        expr: CREATED_AT
        data_type: TIMESTAMP_NTZ
        description: Date and time when the customer account was created.
        synonyms:
          - created_date
          - creation_date
          - registration_date
          - signup_date

  - name: CUSTOMER_ACCOUNTS
    base_table:
      database: BANKING_DB
      schema: AUTO_LOANS
      table: CUSTOMER_ACCOUNTS
    primary_key:
      columns:
        - ACCOUNT_ID
    dimensions:
      - name: ACCOUNT_ID
        expr: ACCOUNT_ID
        data_type: NUMBER
        description: Unique identifier for a customer account.
        synonyms:
          - account_number
          - account_key
          - account_identifier
      - name: CUSTOMER_ID
        expr: CUSTOMER_ID
        data_type: NUMBER
        description: Unique identifier for each customer account.
        synonyms:
          - client_id
          - customer_number
      - name: STATUS
        expr: STATUS
        data_type: VARCHAR
        description: The current state of the customer account.
        synonyms:
          - state
          - condition
          - account_status
        sample_values:
          - "active"
      - name: BRANCH_ID
        expr: BRANCH_ID
        data_type: VARCHAR
        description: Unique identifier for the branch.
        synonyms:
          - branch_code
          - location_id
          - office_id
    time_dimensions:
      - name: ACCOUNT_OPEN_DATE
        expr: ACCOUNT_OPEN_DATE
        data_type: DATE
        description: Date when the customer account was opened.
        synonyms:
          - account_creation_date
          - account_start_date

  - name: LOAN_APPLICATIONS
    base_table:
      database: BANKING_DB
      schema: AUTO_LOANS
      table: LOAN_APPLICATIONS
    primary_key:
      columns:
        - APPLICATION_ID
    dimensions:
      - name: APPLICATION_ID
        expr: APPLICATION_ID
        data_type: NUMBER
        description: Unique identifier for each loan application.
        synonyms:
          - app_id
          - application_number
          - request_id
      - name: CUSTOMER_ID
        expr: CUSTOMER_ID
        data_type: NUMBER
        description: Unique identifier for the customer who submitted the application.
        synonyms:
          - client_id
          - customer_number
      - name: CHANNEL
        expr: CHANNEL
        data_type: VARCHAR
        description: The channel through which the loan application was submitted.
        synonyms:
          - medium
          - platform
          - source
          - application_channel
        sample_values:
          - "Dealer"
          - "Online"
          - "Branch"
      - name: PRODUCT
        expr: PRODUCT
        data_type: VARCHAR
        description: The type of loan product being applied for.
        synonyms:
          - item
          - loan_type
          - financial_product
        sample_values:
          - "New Auto"
          - "Used Auto"
          - "Refinance"
      - name: STATUS
        expr: STATUS
        data_type: VARCHAR
        description: The current state of the loan application.
        synonyms:
          - state
          - condition
          - outcome
          - result
        sample_values:
          - "Approved"
          - "Denied"
          - "Pending"
      - name: REASON_CODE
        expr: REASON_CODE
        data_type: VARCHAR
        description: The reason why the loan application was approved or rejected.
        synonyms:
          - decision_reason
          - rejection_code
          - approval_code
        sample_values:
          - "CreditScore"
    time_dimensions:
      - name: SUBMITTED_AT
        expr: SUBMITTED_AT
        data_type: TIMESTAMP_NTZ
        description: Date and time when the loan application was submitted.
        synonyms:
          - submission_date
          - application_date
          - received_at
      - name: DECISION_AT
        expr: DECISION_AT
        data_type: TIMESTAMP_NTZ
        description: The date and time when a decision was made on the application.
        synonyms:
          - decision_made_at
          - decision_date
          - approved_at
    facts:
      - name: AMOUNT_REQUESTED
        expr: AMOUNT_REQUESTED
        data_type: NUMBER
        description: The amount of money that the applicant is requesting to borrow.
        synonyms:
          - loan_amount
          - requested_loan
          - amount_applied
          - loan_value
          - requested_funds
          - applied_amount
      - name: TERM_MONTHS
        expr: TERM_MONTHS
        data_type: NUMBER
        description: The number of months over which the loan will be repaid.
        synonyms:
          - loan_duration
          - loan_term
          - loan_length
          - repayment_period
          - loan_tenure
          - months_to_repay
      - name: INTEREST_RATE_OFFERED
        expr: INTEREST_RATE_OFFERED
        data_type: NUMBER
        description: The interest rate offered to the borrower as part of the loan application.
        synonyms:
          - interest_rate_quote
          - offered_apr
          - quoted_interest_rate
          - proposed_interest_rate
          - offered_rate

  - name: LOANS
    base_table:
      database: BANKING_DB
      schema: AUTO_LOANS
      table: LOANS
    primary_key:
      columns:
        - LOAN_ID
    dimensions:
      - name: LOAN_ID
        expr: LOAN_ID
        data_type: NUMBER
        description: Unique identifier for each loan.
        synonyms:
          - loan_number
          - loan_identifier
          - loan_key
      - name: CUSTOMER_ID
        expr: CUSTOMER_ID
        data_type: NUMBER
        description: Unique identifier for the customer who borrowed the loan.
        synonyms:
          - client_id
          - customer_number
          - borrower_id
      - name: APPLICATION_ID
        expr: APPLICATION_ID
        data_type: NUMBER
        description: Unique identifier for a loan application.
        synonyms:
          - app_id
          - loan_app_id
          - application_number
      - name: ACCOUNT_ID
        expr: ACCOUNT_ID
        data_type: NUMBER
        description: Unique identifier for a customer account.
        synonyms:
          - account_number
          - account_identifier
      - name: LOAN_STATUS
        expr: LOAN_STATUS
        data_type: VARCHAR
        description: The current status of the loan. Use 'active' for active loans.
        synonyms:
          - loan_condition
          - loan_state
          - loan_phase
        sample_values:
          - "active"
          - "PaidOff"
          - "ChargedOff"
    time_dimensions:
      - name: ORIGINATION_DATE
        expr: ORIGINATION_DATE
        data_type: DATE
        description: The date on which the loan was originated.
        synonyms:
          - start_date
          - loan_initiation_date
          - loan_creation_date
      - name: MATURITY_DATE
        expr: MATURITY_DATE
        data_type: DATE
        description: The date on which the loan is scheduled to be fully repaid.
        synonyms:
          - due_date
          - expiration_date
          - end_date
    facts:
      - name: PRINCIPAL
        expr: PRINCIPAL
        data_type: NUMBER
        description: The principal amount borrowed by a customer.
        synonyms:
          - initial_amount
          - loan_amount
          - face_value
          - original_loan_amount
          - initial_investment
          - capital_sum
      - name: INTEREST_RATE
        expr: INTEREST_RATE
        data_type: NUMBER
        description: The interest rate charged on a loan, expressed as a percentage.
        synonyms:
          - interest_percentage
          - annual_percentage_rate
          - apr
          - rate_of_interest
          - finance_rate
          - loan_rate
      - name: TERM_MONTHS
        expr: TERM_MONTHS
        data_type: NUMBER
        description: The number of months over which a loan is to be repaid.
        synonyms:
          - loan_duration
          - loan_term
          - loan_length
          - repayment_period
          - loan_tenure
          - months_to_maturity

  - name: PAYMENTS
    base_table:
      database: BANKING_DB
      schema: AUTO_LOANS
      table: PAYMENTS
    primary_key:
      columns:
        - PAYMENT_ID
    dimensions:
      - name: PAYMENT_ID
        expr: PAYMENT_ID
        data_type: NUMBER
        description: Unique identifier for each payment transaction.
        synonyms:
          - payment_key
          - transaction_id
          - payment_reference
      - name: LOAN_ID
        expr: LOAN_ID
        data_type: NUMBER
        description: Unique identifier for a loan.
        synonyms:
          - loan_number
          - loan_reference
      - name: CUSTOMER_ID
        expr: CUSTOMER_ID
        data_type: NUMBER
        description: Unique identifier for the customer who made the payment.
        synonyms:
          - client_id
          - customer_number
      - name: PAYMENT_STATUS
        expr: PAYMENT_STATUS
        data_type: VARCHAR
        description: The status of a payment (OnTime, Late, Missed).
        synonyms:
          - payment_state
          - payment_condition
          - transaction_status
        sample_values:
          - "OnTime"
          - "Late"
          - "Missed"
    time_dimensions:
      - name: PAYMENT_DATE
        expr: PAYMENT_DATE
        data_type: DATE
        description: Date on which the payment was made.
        synonyms:
          - payment_timestamp
          - transaction_date
          - date_paid
    facts:
      - name: AMOUNT_DUE
        expr: AMOUNT_DUE
        data_type: NUMBER
        description: The amount of payment due from a customer.
        synonyms:
          - outstanding_balance
          - amount_owing
          - amount_payable
          - payment_due_amount
          - due_amount
          - payable_amount
      - name: AMOUNT_PAID
        expr: AMOUNT_PAID
        data_type: NUMBER
        description: The amount of payment made by a customer.
        synonyms:
          - payment_amount
          - paid_amount
          - amount_settled
          - payment_made
          - settled_amount
          - paid_sum
      - name: PRINCIPAL_COMPONENT
        expr: PRINCIPAL_COMPONENT
        data_type: NUMBER
        description: The principal component of a payment.
        synonyms:
          - principal_amount
          - capital_component
          - loan_principal
          - main_payment
          - core_payment
      - name: INTEREST_COMPONENT
        expr: INTEREST_COMPONENT
        data_type: NUMBER
        description: The amount of interest paid on a loan.
        synonyms:
          - interest_amount
          - interest_payment
          - interest_portion
          - interest_charge
          - finance_charge
      - name: LATE_FEE
        expr: LATE_FEE
        data_type: NUMBER
        description: The amount charged to a customer for making a payment after the due date.
        synonyms:
          - late_charge
          - overdue_fee
          - penalty_amount
          - late_payment_fee
          - additional_fee
          - surcharge
      - name: PAST_DUE_DAYS
        expr: PAST_DUE_DAYS
        data_type: NUMBER
        description: The number of days a payment is past its due date.
        synonyms:
          - overdue_days
          - days_overdue
          - days_past_due
          - delinquency_days
          - days_in_arrears

  - name: VEHICLES
    base_table:
      database: BANKING_DB
      schema: AUTO_LOANS
      table: VEHICLES
    primary_key:
      columns:
        - VEHICLE_ID
    dimensions:
      - name: VEHICLE_ID
        expr: VEHICLE_ID
        data_type: NUMBER
        description: Unique identifier for each vehicle.
        synonyms:
          - vehicle_key
          - vehicle_identifier
          - vehicle_number
      - name: LOAN_ID
        expr: LOAN_ID
        data_type: NUMBER
        description: Unique identifier for a loan associated with a vehicle.
        synonyms:
          - loan_number
          - financing_id
      - name: VIN
        expr: VIN
        data_type: VARCHAR
        description: Unique Vehicle Identification Number.
        synonyms:
          - vehicle_identification_number
          - vehicle_id_number
          - chassis_number
      - name: MAKE
        expr: MAKE
        data_type: VARCHAR
        description: The make of the vehicle.
        synonyms:
          - manufacturer
          - brand
          - vehicle_brand
        sample_values:
          - "Ford"
          - "Toyota"
          - "Honda"
          - "Tesla"
          - "Hyundai"
      - name: MODEL
        expr: MODEL
        data_type: VARCHAR
        description: The vehicle model.
        synonyms:
          - car_model
          - vehicle_type
      - name: DEALER_ID
        expr: DEALER_ID
        data_type: VARCHAR
        description: Unique identifier for the dealership.
        synonyms:
          - dealer_code
          - supplier_id
          - vendor_id
    facts:
      - name: MODEL_YEAR
        expr: MODEL_YEAR
        data_type: NUMBER
        description: The model year of the vehicle.
        synonyms:
          - vehicle_year
          - car_year
          - production_year
          - manufacture_year
      - name: MSRP
        expr: MSRP
        data_type: NUMBER
        description: The MSRP of each vehicle.
        synonyms:
          - Manufacturer Suggested Retail Price
          - Sticker Price
          - List Price
          - Base Price
      - name: PURCHASE_PRICE
        expr: PURCHASE_PRICE
        data_type: NUMBER
        description: The purchase price of a vehicle.
        synonyms:
          - buy_price
          - sale_price
          - purchase_cost
          - acquisition_price
          - vehicle_cost
      - name: MILEAGE_AT_PURCHASE
        expr: MILEAGE_AT_PURCHASE
        data_type: NUMBER
        description: The total mileage of the vehicle at the time of purchase.
        synonyms:
          - odometer_reading_at_purchase
          - initial_mileage
          - purchase_odometer
          - starting_mileage

relationships:
  - name: Accounts_to_Customers
    left_table: CUSTOMER_ACCOUNTS
    relationship_columns:
      - left_column: CUSTOMER_ID
        right_column: CUSTOMER_ID
    right_table: CUSTOMERS
    join_type: inner
    relationship_type: many_to_one
  - name: Loans_to_Accounts
    left_table: LOANS
    relationship_columns:
      - left_column: ACCOUNT_ID
        right_column: ACCOUNT_ID
    right_table: CUSTOMER_ACCOUNTS
    join_type: inner
    relationship_type: many_to_one
  - name: Loans_to_Applications
    left_table: LOANS
    relationship_columns:
      - left_column: APPLICATION_ID
        right_column: APPLICATION_ID
    right_table: LOAN_APPLICATIONS
    join_type: inner
    relationship_type: many_to_one
  - name: Applications_to_Customers
    left_table: LOAN_APPLICATIONS
    relationship_columns:
      - left_column: CUSTOMER_ID
        right_column: CUSTOMER_ID
    right_table: CUSTOMERS
    join_type: inner
    relationship_type: many_to_one
  - name: Payments_to_Loans
    left_table: PAYMENTS
    relationship_columns:
      - left_column: LOAN_ID
        right_column: LOAN_ID
    right_table: LOANS
    join_type: inner
    relationship_type: many_to_one
  - name: Vehicles_to_Loans
    left_table: VEHICLES
    relationship_columns:
      - left_column: LOAN_ID
        right_column: LOAN_ID
    right_table: LOANS
    join_type: inner
    relationship_type: many_to_one
$$
);

-- ============================================================
-- SECTION 8: CREDIT SEMANTIC VIEW (YAML-based)
-- ============================================================
CALL SYSTEM$CREATE_SEMANTIC_VIEW_FROM_YAML(
  'BANKING_DB.CREDIT',
  $$
name: CREDIT_SEMANTIC_VIEW
tables:
  - name: CREDIT_CARDS
    base_table:
      database: BANKING_DB
      schema: CREDIT
      table: CREDIT_CARDS
    primary_key:
      columns:
        - CARD_ID
    dimensions:
      - name: CARD_ID
        expr: CARD_ID
        data_type: NUMBER
        description: Unique identifier for a credit card.
        synonyms:
          - card_number
          - card_identifier
      - name: CUSTOMER_ID
        expr: CUSTOMER_ID
        data_type: NUMBER
        description: Unique identifier for the customer.
        synonyms:
          - client_id
          - customer_number
      - name: ACCOUNT_ID
        expr: ACCOUNT_ID
        data_type: NUMBER
        description: Unique identifier for an account.
        synonyms:
          - account_number
      - name: APPLICATION_ID
        expr: APPLICATION_ID
        data_type: NUMBER
        description: Unique identifier for an application.
        synonyms:
          - app_id
          - application_number
      - name: CARD_NUMBER_TOKEN
        expr: CARD_NUMBER_TOKEN
        data_type: VARCHAR
        description: A tokenized card number.
        synonyms:
          - masked_card_number
          - tokenized_card_number
      - name: CARD_PRODUCT
        expr: CARD_PRODUCT
        data_type: VARCHAR
        description: The type of credit card product.
        synonyms:
          - card_type
          - card_category
        sample_values:
          - "CashBack"
          - "Travel"
          - "Platinum"
      - name: STATUS
        expr: STATUS
        data_type: VARCHAR
        description: The current state of the credit card. Use 'active' for active cards.
        synonyms:
          - state
          - condition
          - card_state
        sample_values:
          - "active"
    time_dimensions:
      - name: OPEN_DATE
        expr: OPEN_DATE
        data_type: DATE
        description: Date when the card was opened.
        synonyms:
          - activation_date
          - start_date
    facts:
      - name: CREDIT_LIMIT
        expr: CREDIT_LIMIT
        data_type: NUMBER
        description: The maximum amount of credit available.
        synonyms:
          - available_credit
          - credit_ceiling
          - max_credit
      - name: CURRENT_BALANCE
        expr: CURRENT_BALANCE
        data_type: NUMBER
        description: The current outstanding balance.
        synonyms:
          - outstanding_balance
          - current_amount
          - balance_due
      - name: APR
        expr: APR
        data_type: NUMBER
        description: Annual Percentage Rate of the credit card.
        synonyms:
          - annual_percentage_rate
          - interest_rate

  - name: CREDIT_CARD_APPLICATIONS
    base_table:
      database: BANKING_DB
      schema: CREDIT
      table: CREDIT_CARD_APPLICATIONS
    primary_key:
      columns:
        - CC_APPLICATION_ID
    dimensions:
      - name: CC_APPLICATION_ID
        expr: CC_APPLICATION_ID
        data_type: NUMBER
        description: Unique identifier for each credit card application.
        synonyms:
          - application_id
          - credit_card_app_id
      - name: CUSTOMER_ID
        expr: CUSTOMER_ID
        data_type: NUMBER
        description: Unique identifier for the customer.
        synonyms:
          - client_id
          - customer_number
      - name: CHANNEL
        expr: CHANNEL
        data_type: VARCHAR
        description: The channel through which the application was submitted.
        synonyms:
          - medium
          - platform
          - application_channel
        sample_values:
          - "Online"
          - "Branch"
          - "Partner"
      - name: CARD_PRODUCT
        expr: CARD_PRODUCT
        data_type: VARCHAR
        description: The type of credit card product applied for.
        synonyms:
          - card_type
          - credit_card_type
        sample_values:
          - "CashBack"
          - "Travel"
          - "Platinum"
      - name: STATUS
        expr: STATUS
        data_type: VARCHAR
        description: The current status of the application.
        synonyms:
          - state
          - condition
          - outcome
        sample_values:
          - "Approved"
          - "Denied"
      - name: REASON_CODE
        expr: REASON_CODE
        data_type: VARCHAR
        description: The reason for the decision.
        synonyms:
          - decision_reason
          - rejection_code
        sample_values:
          - "CreditScore"
    time_dimensions:
      - name: SUBMITTED_AT
        expr: SUBMITTED_AT
        data_type: TIMESTAMP_NTZ
        description: Date and time when the application was submitted.
        synonyms:
          - submission_timestamp
          - application_date
      - name: DECISION_AT
        expr: DECISION_AT
        data_type: TIMESTAMP_NTZ
        description: The date and time of the decision.
        synonyms:
          - decision_made_at
          - decision_date
    facts:
      - name: CREDIT_LIMIT_REQUESTED
        expr: CREDIT_LIMIT_REQUESTED
        data_type: NUMBER
        description: The amount of credit the applicant is requesting.
        synonyms:
          - requested_credit_amount
          - credit_request
      - name: APR_OFFERED
        expr: APR_OFFERED
        data_type: NUMBER
        description: The APR offered to the customer.
        synonyms:
          - interest_rate_offered
          - offered_apr

  - name: CARD_TRANSACTIONS
    base_table:
      database: BANKING_DB
      schema: CREDIT
      table: CARD_TRANSACTIONS
    primary_key:
      columns:
        - TRANSACTION_ID
    dimensions:
      - name: TRANSACTION_ID
        expr: TRANSACTION_ID
        data_type: NUMBER
        description: Unique identifier for each transaction.
        synonyms:
          - transaction_number
          - transaction_code
      - name: CARD_ID
        expr: CARD_ID
        data_type: NUMBER
        description: Unique identifier for a card.
        synonyms:
          - card_number
          - payment_card_id
      - name: CUSTOMER_ID
        expr: CUSTOMER_ID
        data_type: NUMBER
        description: Unique identifier for the customer.
        synonyms:
          - client_id
          - user_id
          - cardholder_id
      - name: MERCHANT_ID
        expr: MERCHANT_ID
        data_type: NUMBER
        description: Unique identifier for the merchant.
        synonyms:
          - seller_id
          - vendor_id
          - retailer_id
      - name: CURRENCY
        expr: CURRENCY
        data_type: VARCHAR
        description: The currency of the transaction.
        synonyms:
          - money_unit
          - denomination
        sample_values:
          - "USD"
      - name: CATEGORY
        expr: CATEGORY
        data_type: VARCHAR
        description: The category of the transaction.
        synonyms:
          - type
          - classification
        sample_values:
          - "Grocery"
          - "Dining"
          - "Travel"
          - "Electronics"
          - "Fuel"
      - name: CHANNEL
        expr: CHANNEL
        data_type: VARCHAR
        description: The channel through which the transaction was made.
        synonyms:
          - medium
          - platform
          - transaction_channel
        sample_values:
          - "POS"
          - "ECOM"
      - name: STATUS
        expr: STATUS
        data_type: VARCHAR
        description: The status of the transaction.
        synonyms:
          - state
          - condition
        sample_values:
          - "Posted"
          - "Authorized"
          - "Reversed"
          - "Disputed"
    time_dimensions:
      - name: AUTH_TIMESTAMP
        expr: AUTH_TIMESTAMP
        data_type: TIMESTAMP_NTZ
        description: The date and time of authorization.
        synonyms:
          - auth_date
          - authorization_time
      - name: POST_DATE
        expr: POST_DATE
        data_type: DATE
        description: Date when the transaction was posted.
        synonyms:
          - posting_date
          - transaction_date
    facts:
      - name: AMOUNT
        expr: AMOUNT
        data_type: NUMBER
        description: The amount of the transaction.
        synonyms:
          - cost
          - price
          - total
          - value
          - transaction_value

  - name: CARD_STATEMENTS
    base_table:
      database: BANKING_DB
      schema: CREDIT
      table: CARD_STATEMENTS
    primary_key:
      columns:
        - STATEMENT_ID
    dimensions:
      - name: STATEMENT_ID
        expr: STATEMENT_ID
        data_type: NUMBER
        description: Unique identifier for a statement.
        synonyms:
          - statement_number
          - invoice_id
      - name: CARD_ID
        expr: CARD_ID
        data_type: NUMBER
        description: Unique identifier for a card.
        synonyms:
          - card_number
          - account_id
    time_dimensions:
      - name: STATEMENT_PERIOD_START
        expr: STATEMENT_PERIOD_START
        data_type: DATE
        description: The start date of the statement period.
        synonyms:
          - start_date
          - billing_cycle_start
      - name: STATEMENT_PERIOD_END
        expr: STATEMENT_PERIOD_END
        data_type: DATE
        description: The end date of the statement period.
        synonyms:
          - statement_period_close
          - billing_cycle_end
      - name: DUE_DATE
        expr: DUE_DATE
        data_type: DATE
        description: The date by which payment is due.
        synonyms:
          - payment_due_date
          - payment_deadline
    facts:
      - name: STATEMENT_BALANCE
        expr: STATEMENT_BALANCE
        data_type: NUMBER
        description: The current balance of the card account.
        synonyms:
          - outstanding_balance
          - current_balance
          - statement_total
      - name: MIN_PAYMENT_DUE
        expr: MIN_PAYMENT_DUE
        data_type: NUMBER
        description: The minimum payment due on the credit card account.
        synonyms:
          - minimum_payment_required
          - minimum_due
          - lowest_payment

  - name: CARD_PAYMENTS
    base_table:
      database: BANKING_DB
      schema: CREDIT
      table: CARD_PAYMENTS
    primary_key:
      columns:
        - CARD_PAYMENT_ID
    dimensions:
      - name: CARD_PAYMENT_ID
        expr: CARD_PAYMENT_ID
        data_type: NUMBER
        description: Unique identifier for a card payment.
        synonyms:
          - payment_id
      - name: CARD_ID
        expr: CARD_ID
        data_type: NUMBER
        description: Unique identifier for a card.
        synonyms:
          - card_number
          - card_identifier
      - name: CUSTOMER_ID
        expr: CUSTOMER_ID
        data_type: NUMBER
        description: Unique identifier for the customer.
        synonyms:
          - client_id
          - account_holder_id
      - name: STATEMENT_ID
        expr: STATEMENT_ID
        data_type: NUMBER
        description: Unique identifier for a statement.
        synonyms:
          - invoice_id
          - billing_id
      - name: METHOD
        expr: METHOD
        data_type: VARCHAR
        description: The payment method used.
        synonyms:
          - payment_method
          - payment_type
        sample_values:
          - "ACH"
          - "Debit"
      - name: STATUS
        expr: STATUS
        data_type: VARCHAR
        description: The status of the card payment.
        synonyms:
          - state
          - condition
        sample_values:
          - "Received"
          - "Returned"
    time_dimensions:
      - name: PAYMENT_DATE
        expr: PAYMENT_DATE
        data_type: DATE
        description: Date on which the payment was made.
        synonyms:
          - transaction_date
          - payment_timestamp
    facts:
      - name: AMOUNT
        expr: AMOUNT
        data_type: NUMBER
        description: The amount of each payment made by card.
        synonyms:
          - cost
          - price
          - total
          - payment_value
          - charge

  - name: MERCHANTS
    base_table:
      database: BANKING_DB
      schema: CREDIT
      table: MERCHANTS
    primary_key:
      columns:
        - MERCHANT_ID
    dimensions:
      - name: MERCHANT_ID
        expr: MERCHANT_ID
        data_type: NUMBER
        description: Unique identifier for a merchant.
        synonyms:
          - seller_id
          - vendor_id
      - name: MERCHANT_NAME
        expr: MERCHANT_NAME
        data_type: VARCHAR
        description: The name of the merchant.
        synonyms:
          - merchant_title
          - business_name
      - name: MCC
        expr: MCC
        data_type: VARCHAR
        description: Merchant Category Code.
        synonyms:
          - merchant_category_code
          - merchant_type
      - name: CITY
        expr: CITY
        data_type: VARCHAR
        description: The city where the merchant is located.
        synonyms:
          - town
          - municipality
      - name: STATE
        expr: STATE
        data_type: VARCHAR
        description: The state where the merchant is located.
        synonyms:
          - province
          - region
      - name: COUNTRY
        expr: COUNTRY
        data_type: VARCHAR
        description: The country where the merchant is located.
        synonyms:
          - nation
          - land

relationships:
  - name: Transactions_to_Cards
    left_table: CARD_TRANSACTIONS
    relationship_columns:
      - left_column: CARD_ID
        right_column: CARD_ID
    right_table: CREDIT_CARDS
    join_type: inner
    relationship_type: many_to_one
  - name: Transactions_to_Merchants
    left_table: CARD_TRANSACTIONS
    relationship_columns:
      - left_column: MERCHANT_ID
        right_column: MERCHANT_ID
    right_table: MERCHANTS
    join_type: inner
    relationship_type: many_to_one
  - name: Statements_to_Cards
    left_table: CARD_STATEMENTS
    relationship_columns:
      - left_column: CARD_ID
        right_column: CARD_ID
    right_table: CREDIT_CARDS
    join_type: inner
    relationship_type: many_to_one
  - name: Payments_to_Cards
    left_table: CARD_PAYMENTS
    relationship_columns:
      - left_column: CARD_ID
        right_column: CARD_ID
    right_table: CREDIT_CARDS
    join_type: inner
    relationship_type: many_to_one
  - name: Payments_to_Statements
    left_table: CARD_PAYMENTS
    relationship_columns:
      - left_column: STATEMENT_ID
        right_column: STATEMENT_ID
    right_table: CARD_STATEMENTS
    join_type: inner
    relationship_type: many_to_one
  - name: Cards_to_Applications
    left_table: CREDIT_CARDS
    relationship_columns:
      - left_column: APPLICATION_ID
        right_column: CC_APPLICATION_ID
    right_table: CREDIT_CARD_APPLICATIONS
    join_type: inner
    relationship_type: many_to_one
  - name: Cards_to_Customers
    left_table: CREDIT_CARDS
    relationship_columns:
      - left_column: CUSTOMER_ID
        right_column: CUSTOMER_ID
    right_table: CUSTOMERS
    join_type: inner
    relationship_type: many_to_one
$$
);

-- ============================================================
-- SECTION 9: CREATE AGENT
-- ============================================================
CREATE OR REPLACE SCHEMA BANKING_DB.AGENTS;

CREATE OR REPLACE AGENT BANKING_DB.AGENTS.CONSUMER_BANK_AGENT
  COMMENT = 'Multi-LOB banking agent for auto loans and credit card analytics'
  PROFILE = '{"display_name": "Consumer Bank Agent", "avatar": "bank", "color": "blue"}'
  FROM SPECIFICATION
$$
models:
  orchestration: auto

instructions:
  response: |
    Ask 1 clarifying question when intent is ambiguous.
    Default time range to last 12 months if not specified.
    Include a brief executive summary before results.
    Format currency with $ and thousands separators.
    Format percentages with 2 decimals.
  orchestration: |
    ## TOOL SELECTION GUIDE
    
    ### Single-Tool Queries
    - **Auto_CA ONLY**: auto loans, loan applications, loan payments, vehicles, VIN, 
      dealer, principal, interest rate, term months, origination date, maturity date,
      loan status, past due days, late fees
    - **Credit_CA ONLY**: credit cards, card applications, card transactions, merchants,
      card statements, card payments, credit limit, APR, current balance, MCC codes,
      card product, transaction category
    
    ### Multi-Tool Queries (Use BOTH tools)
    - Cross-portfolio: "customers with both loans and cards", "total exposure"
    - Risk analysis across products: "delinquent on both", "missed payments across products"
    - Customer 360: "all products for customer X", "relationship summary"
    - Combined metrics: "total outstanding = principal + card balance"
    
    ## SHARED DIMENSION: CUSTOMER_ID
    Both semantic views share CUSTOMER_ID as the join key. When combining results:
    1. Query Auto_CA for loan data grouped by CUSTOMER_ID
    2. Query Credit_CA for card data grouped by CUSTOMER_ID  
    3. Join results on CUSTOMER_ID in your response
    
    ## CRITICAL: EXACT STATUS VALUES (case-sensitive!)
    
    ### Auto Loans (Auto_CA)
    | Table | Field | Exact Values |
    |-------|-------|--------------|
    | LOANS | LOAN_STATUS | 'active' (lowercase only!) |
    | LOAN_APPLICATIONS | STATUS | 'Approved', 'Denied', 'Pending' |
    | PAYMENTS | PAYMENT_STATUS | 'OnTime', 'Late', 'Missed' |
    | CUSTOMER_ACCOUNTS | STATUS | 'active' |
    
    ### Credit Cards (Credit_CA)  
    | Table | Field | Exact Values |
    |-------|-------|--------------|
    | CREDIT_CARDS | STATUS | 'active' (lowercase only!) |
    | CREDIT_CARD_APPLICATIONS | STATUS | 'Approved', 'Denied' |
    | CARD_TRANSACTIONS | STATUS | 'Posted', 'Authorized', 'Reversed', 'Disputed' |
    | CARD_PAYMENTS | STATUS | 'Received', 'Returned'
    
    ## CUSTOMER SEGMENTS
    CUSTOMERS.SEGMENT values: 'Prime', 'Near-Prime', 'Subprime'
    
    ## CHANNELS
    - Loan channels: 'Dealer', 'Online', 'Branch'
    - Card application channels: 'Online', 'Branch', 'Partner'
    - Transaction channels: 'POS', 'ECOM'
    
    ## CARD PRODUCTS
    CARD_PRODUCT values: 'CashBack', 'Travel', 'Platinum'
    
    ## LOAN PRODUCTS  
    PRODUCT values: 'New Auto', 'Used Auto', 'Refinance'
    
    ## TRANSACTION CATEGORIES
    CATEGORY values: 'Grocery', 'Dining', 'Travel', 'Electronics', 'Fuel'
  sample_questions:
    - question: "Total loans and total principal by month for the last 12 months"
    - question: "Show customers with late or missed payments"
    - question: "What is the average interest rate by customer segment?"
    - question: "Active cards, average credit limit, and average APR by product"
    - question: "Show transaction volume by merchant category"
    - question: "Which customers have returned payments?"
    - question: "Customers with both an active auto loan and an active credit card"
    - question: "Total exposure per customer (loan principal + card balance)"

tools:
  - tool_spec:
      type: cortex_analyst_text_to_sql
      name: Auto_CA
      description: "Auto Loans Cortex Analyst - Query customers, loans, applications, payments, and vehicles."
  - tool_spec:
      type: cortex_analyst_text_to_sql
      name: Credit_CA
      description: "Credit Card Cortex Analyst - Query credit card applications, cards, transactions, statements, and payments."

tool_resources:
  Auto_CA:
    semantic_view: "BANKING_DB.AUTO_LOANS.AUTO_LOANS_SEMANTIC_VIEW"
    execution_environment:
      type: warehouse
      warehouse: BANKING_WH
      query_timeout: 30
  Credit_CA:
    semantic_view: "BANKING_DB.CREDIT.CREDIT_SEMANTIC_VIEW"
    execution_environment:
      type: warehouse
      warehouse: BANKING_WH
      query_timeout: 30
$$;

-- ============================================================
-- SECTION 10: ADD AGENT TO SNOWFLAKE INTELLIGENCE
-- ============================================================
CREATE SNOWFLAKE INTELLIGENCE IF NOT EXISTS SNOWFLAKE_INTELLIGENCE_OBJECT_DEFAULT;
GRANT USAGE ON SNOWFLAKE INTELLIGENCE SNOWFLAKE_INTELLIGENCE_OBJECT_DEFAULT TO ROLE BANKING_ROLE;

ALTER SNOWFLAKE INTELLIGENCE SNOWFLAKE_INTELLIGENCE_OBJECT_DEFAULT 
  ADD AGENT BANKING_DB.AGENTS.CONSUMER_BANK_AGENT;

-- ============================================================
-- VERIFICATION
-- ============================================================
SHOW AGENTS IN SCHEMA BANKING_DB.AGENTS;
SHOW SEMANTIC VIEWS IN DATABASE BANKING_DB;

-- ============================================================
-- TEARDOWN (commented out - run manually to clean up)
-- ============================================================
-- USE ROLE ACCOUNTADMIN;
-- DROP DATABASE IF EXISTS BANKING_DB;
-- DROP WAREHOUSE IF EXISTS BANKING_WH;
-- DROP ROLE IF EXISTS BANKING_ROLE;
