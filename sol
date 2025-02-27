    @Transient
    @Schema(name = "mId", example = "MID6")
    private String mId;
    @Schema(name = "aggregatorId", example = "SBIEPAY")
    private String aggregatorId;
    @Schema(name = "type", description = "Valid HelpSupportType are PHONE_NUMBER, EMAIL", example = "EMAIL")
    private HelpSupportType type;
    @Schema(name = "value", example = "test@gmail.com")
    private List<String> value;
    private boolean status;

--liquibase formatted sql
--changeset Hrishikesh:1

CREATE TABLE HELP_SUPPORT_TEAM (
    ID RAW(16) DEFAULT SYS_GUID() PRIMARY KEY,
    MID VARCHAR2(50 CHAR),
    AGGREGATOR_ID	VARCHAR2(50 CHAR),
    TYPE	VARCHAR2(20 CHAR),
    VALUE	VARCHAR2(320 CHAR),
    STATUS	VARCHAR2(20 CHAR),
    CREATED_BY	VARCHAR2(50 CHAR),
    CREATED_AT	NUMBER,
    UPDATED_BY	VARCHAR2(50 CHAR),
    UPDATED_AT	NUMBER
);

CREATE INDEX IDX_HELP_SUPPORT_TEAM_MID ON HELP_SUPPORT_TEAM(MID);
CREATE INDEX IDX_TYPE ON HELP_SUPPORT_TEAM(TYPE);

INSERT INTO HELP_SUPPORT_TEAM(TYPE, VALUE, STATUS, CREATED_BY, CREATED_AT)
VALUES('PHONE_NUMBER', '+91-22-20876156', 'Active', 'SBI ePay',
(SELECT ROUND(((TRUNC(SYSTIMESTAMP,'MI')-DATE '1970-01-01') * 24 * 60 * 60) + EXTRACT (SECOND FROM SYSTIMESTAMP), 3)*1000 FROM DUAL));

INSERT INTO HELP_SUPPORT_TEAM(TYPE, VALUE, STATUS, CREATED_BY, CREATED_AT)
VALUES('EMAIL', 'support.sbiepay@sbi.co.in', 'Active', 'SBI ePay',
(SELECT ROUND(((TRUNC(SYSTIMESTAMP,'MI')-DATE '1970-01-01') * 24 * 60 * 60) + EXTRACT (SECOND FROM SYSTIMESTAMP), 3)*1000 FROM DUAL));

commit;
