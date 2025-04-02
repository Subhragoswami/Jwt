--liquibase formatted sql
--changeset Hrishikesh:2

UPDATE ALERT_MASTER 
SET DESCRIPTION = 'Bank Account {0} on {1} is {2}.'
WHERE NAME = 'Bank Account';
