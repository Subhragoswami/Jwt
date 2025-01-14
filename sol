CREATE TABLE MERCHANT_BANK_ACCOUNT (
    ID RAW(16) DEFAULT SYS_GUID() PRIMARY KEY,
    MID VARCHAR2(100) NOT NULL,
    ACCOUNT_HOLDER_NAME VARCHAR2(100) NOT NULL,
    ACCOUNT_UNIQUE_IDENTIFIER VARCHAR2(30) UNIQUE NOT NULL,
    ACCOUNT_TYPE VARCHAR2(30) NOT NULL,
    ACCOUNT_NUMBER VARCHAR2(200) UNIQUE NOT NULL,
    BANK_NAME VARCHAR2(100) NOT NULL,
    BRANCH_NAME VARCHAR2(100) NOT NULL,
    IFSC_CODE VARCHAR2(20) NOT NULL,
    IS_APPROVED NUMBER(1) DEFAULT 0,
    IS_PRIMARY NUMBER(1)DEFAULT 0,
    APPROVED_REJECTED_BY VARCHAR2(100),
    REJECTED_REASON VARCHAR2(200),
    APPROVED_REJECTED_ON NUMBER,
    STATUS VARCHAR2(30) NOT NULL,
    CREATED_AT NUMBER NOT NULL,
    CREATED_BY VARCHAR2(50) NOT NULL,
    UPDATED_BY VARCHAR2(50) NOT NULL,
    UPDATED_AT NUMBER NOT NULL,
    CONSTRAINT FK_MERCHANT_BANK_ACCOUNT_MID  FOREIGN KEY (MID) REFERENCES MERCHANT_INFO(MID) -- Foreign Key to `MERCHANT Info` table
);


INSERT INTO MERCHANT_BANK_ACCOUNT (
    MID,
    ACCOUNT_HOLDER_NAME,
    ACCOUNT_UNIQUE_IDENTIFIER,
    ACCOUNT_TYPE,
    ACCOUNT_NUMBER,
    BANK_NAME,
    BRANCH_NAME,
    IFSC_CODE,
    IS_APPROVED,
    IS_PRIMARY,
    APPROVED_REJECTED_BY,
    REJECTED_REASON,
    APPROVED_REJECTED_ON,
    STATUS,
    CREATED_AT,
    CREATED_BY,
    UPDATED_BY,
    UPDATED_AT
) VALUES (
    'MID1234567890',
    'John Doe',
    'UID1234567890',
    'Savings',
    '1234567890123456',
    'Bank of Example',
    'Example Branch',
    'EXAMPL000123',
    0,
    0,
    NULL,
    NULL,
    NULL,
    'Active',
    1673728396,
    'admin',
    'admin',
    1673728396
);
