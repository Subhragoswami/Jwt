-- Step 1: Add a temporary column without NOT NULL
ALTER TABLE THEME ADD LOGO_TEMP CLOB;

-- Step 2: Copy data from old column
UPDATE THEME SET LOGO_TEMP = LOGO;

-- Step 3: Drop old column
ALTER TABLE THEME DROP COLUMN LOGO;

-- Step 4: Rename temp column to original name
ALTER TABLE THEME RENAME COLUMN LOGO_TEMP TO LOGO;
