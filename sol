public List<GstReport> getMerchantGstInvoice(String mId, List<String> reportMonths, int limit, int offset) {
    SqlParameterSource parameters = new MapSqlParameterSource(Map.of(
        ReportingConstant.MID, mId,
        ReportingConstant.REPORT_MONTHS, reportMonths,
        "limit", limit,
        "offset", offset
    ));
    return namedParameterJdbcTemplate.query(InvoiceQueries.JDBC_GST_INVOICE_PAGINATED, parameters, new BeanPropertyRowMapper<>(GstReport.class));
}

public static final String JDBC_GST_INVOICE_PAGINATED = """
    SELECT TRANSACTION_NUMBER AS transactionNumber,
           TO_CHAR(transaction_date, 'DD-MM-YY') as transactionDate,
           TO_CHAR(transaction_date, 'Mon-YYYY') as transactionMonth,
           CASE WHEN MERCHANT_GST_CHARGED > 0 THEN MERCHANT_GST_CHARGED ELSE NULL END AS gstCharged
    FROM view_gst_invoice
    WHERE MID = :mId
    AND TO_CHAR(transaction_date, 'Mon-YYYY') IN (:reportMonth)
    ORDER BY transaction_date DESC
    LIMIT :limit OFFSET :offset
""";



public List<Map<String, Object>> getGstInvoiceData(String mId, List<String> reportMonths) {
    log.info("Fetching GST Invoice Data for MerchantId: {} and reportMonths {}", mId, reportMonths);

    List<Map<String, Object>> allCsvFiles = new ArrayList<>();
    int limit = 500000; // 5 lakh records
    int offset = 0;
    int fileIndex = 1;

    while (true) {
        List<GstReport> merchantGstData = invoiceRepository.getMerchantGstInvoice(mId, reportMonths, limit, offset);
        if (CollectionUtils.isEmpty(merchantGstData)) {
            break; // Exit loop if no more data
        }

        Map<String, List<GstReport>> gstDataMonthBy = convertInvoiceGstMonthWise(merchantGstData);

        for (Map.Entry<String, List<GstReport>> entry : gstDataMonthBy.entrySet()) {
            String reportMonth = entry.getKey();
            Map<String, Object> csvData = createCSVTemplate(Report.GST_INVOICE, reportMonth + "_" + fileIndex, entry.getValue());
            allCsvFiles.add(csvData);
            fileIndex++;
        }

        offset += limit; // Move to the next batch
    }

    log.info("Returning processed GST Invoice data with {} CSV files", allCsvFiles.size());
    return allCsvFiles;
}

public List<Map<String, Object>> getGstInvoiceData(String mId, List<String> reportMonths) {
    log.info("Fetching GST Invoice Data for MerchantId: {} and reportMonths {}", mId, reportMonths);

    List<Map<String, Object>> allCsvFiles = new ArrayList<>();
    int limit = 500000; // 5 lakh records
    int offset = 0;
    int fileIndex = 1;

    while (true) {
        List<GstReport> merchantGstData = invoiceRepository.getMerchantGstInvoice(mId, reportMonths, limit, offset);
        if (CollectionUtils.isEmpty(merchantGstData)) {
            break; // Exit loop if no more data
        }

        Map<String, List<GstReport>> gstDataMonthBy = convertInvoiceGstMonthWise(merchantGstData);

        for (Map.Entry<String, List<GstReport>> entry : gstDataMonthBy.entrySet()) {
            String reportMonth = entry.getKey();
            Map<String, Object> csvData = createCSVTemplate(Report.GST_INVOICE, reportMonth + "_" + fileIndex, entry.getValue());
            allCsvFiles.add(csvData);
            fileIndex++;
        }

        offset += limit; // Move to the next batch
    }

    log.info("Returning processed GST Invoice data with {} CSV files", allCsvFiles.size());
    return allCsvFiles;
}

private void buildReport(String mId, List<String> reportMonths, List<Map<String, Object>> gstInvoiceData, HttpServletResponse response) {
    log.info("Building GST Invoice Report for MID: {} and Report months: {}", mId, reportMonths);
    List<FileModel> fileModels = new ArrayList<>();

    for (Map<String, Object> csvData : gstInvoiceData) {
        Map<String, Object> dataMap = (Map<String, Object>) csvData.get("map");
        List<String> gstHeaders = (List<String>) dataMap.get("headers");
        List<List<Object>> fileData = (List<List<Object>>) dataMap.get("rows");
        String reportMonth = (String) csvData.get("report"); // Extract the month with index

        if (CollectionUtils.isNotEmpty(fileData)) {
            FileModel fileModel = fileGeneratorService.buildFileModel(
                ReportFormat.CSV, gstHeaders, fileData, Map.of("headers", gstHeaders, "rows", fileData)
            );
            fileModel.setReportMonth(reportMonth);
            fileModels.add(fileModel);
        }
    }

    fileGeneratorService.generateZipFile(response, ReportFormat.CSV, Report.GST_INVOICE, mId, fileModels);
}









private ByteArrayOutputStream generateZipFile(ReportFormat reportFormat, Report report, String mId, List<FileModel> fileModels) throws IOException {
    log.debug("Generating ZIP file for report: {} with format: {}", report.getName(), reportFormat.name());
    ByteArrayOutputStream byteArrayOutputStream = new ByteArrayOutputStream();
    
    try (ZipOutputStream zos = new ZipOutputStream(byteArrayOutputStream)) {  // Open once
        for (FileModel fileModel : fileModels) {
            ReportFile reportFile = fileGenerator.generateFile(reportFormat, report, mId, fileModel);
            ZipEntry zipEntry = new ZipEntry(getZipFileName(reportFormat, report, fileModel));
            zos.putNextEntry(zipEntry);
            zos.write(reportFile.getContent());
            zos.closeEntry();
        }
    }

    log.debug("ZIP file generation completed for report: {}", report.getName());
    return byteArrayOutputStream;
}



public void generateZipFile(HttpServletResponse response, ReportFormat reportFormat, Report report, String mId, List<FileModel> fileModels) {
    log.info("Starting ZIP file generation for report: {} and merchant ID: {}", report.getName(), mId);
    try {
        ByteArrayOutputStream byteArrayOutputStream = generateZipFile(reportFormat, report, mId, fileModels);
        
        // Set response headers
        setHeader(response, "application/zip", mId + "_" + report.getName() + ".zip");
        response.setContentLength(byteArrayOutputStream.size());

        // Write to response
        try (ServletOutputStream outputStream = response.getOutputStream()) {
            outputStream.write(byteArrayOutputStream.toByteArray());
            outputStream.flush();
        }

        log.info("ZIP file successfully generated and sent to the response.");
    } catch (Exception e) {
        log.error("Error occurred during zip file generation: {}", e.getMessage());
        throw new ReportingException(ErrorConstants.FILE_GENERATION_ERROR_CODE,
                MessageFormat.format(ErrorConstants.FILE_GENERATION_ERROR_MESSAGE, "zip", e.getMessage()));
    }
}
