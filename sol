INSERT INTO REPORT_SCHEDULE_MANAGEMENT (
    ID, 
    REPORTID, 
    MID, 
    FREQUENCY, 
    FORMAT, 
    SCHEDULEEXECUTIONTIME, 
    NEXTSCHEDULEEXECUTIONTIME, 
    LASTSCHEDULEEXECUTIONTIME, 
    REMARKS, 
    STATUS
) 
VALUES (
    SYS_GUID(),                          -- Generates a random UUID in Oracle
    SYS_GUID(),                          -- Dummy UUID for reportId
    'MID123456',                         -- Dummy MID
    'DAILY',                             -- Assuming Frequency is an ENUM with values like DAILY, WEEKLY, etc.
    'CSV',                               -- Assuming ReportFormat is an ENUM with values like CSV, PDF, etc.
    '10:00 AM',                          -- Dummy execution time as a String
    1672531200000,                       -- Dummy timestamp (in milliseconds) for next schedule execution time
    1672444800000,                       -- Dummy timestamp (in milliseconds) for last schedule execution time
    'Initial setup remarks',             -- Dummy remarks
    'SCHEDULED'                          -- Assuming ReportScheduledStatus is an ENUM with values like SCHEDULED, COMPLETED, FAILED, etc.
);
