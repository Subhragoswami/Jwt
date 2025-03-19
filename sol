--liquibase formatted sql
--changeset Hrishikesh:2

UPDATE MENU_INFO 
SET NAME = 'Account & Settings' 
WHERE CODE = 'ACC_SETTING';
