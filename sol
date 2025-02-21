public void generateZipFile(HttpServletResponse response, ReportFormat reportFormat, Report report, String mId, List<FileModel> fileModels) {
    log.info("Starting ZIP file generation for report: {} and merchant ID: {}", report.getName(), mId);
    try {
        ByteArrayOutputStream byteArrayOutputStream = generateZipFileContent(reportFormat, report, mId, fileModels);
        setHeader(response, "application/zip", mId + "_" + report.getName() + ".zip");
        response.setContentLength(byteArrayOutputStream.size());
        response.getOutputStream().write(byteArrayOutputStream.toByteArray());
        response.getOutputStream().flush();
        log.info("ZIP file successfully generated and sent to the response.");
    } catch (Exception e) {
        log.error("Error occurred during zipFileGenerator: {}", e.getMessage());
        throw new ReportingException(ErrorConstants.FILE_GENERATION_ERROR_CODE, "Error generating ZIP file.");
    }
}

private ByteArrayOutputStream generateZipFileContent(ReportFormat reportFormat, Report report, String mId, List<FileModel> fileModels) throws IOException {
    ByteArrayOutputStream byteArrayOutputStream = new ByteArrayOutputStream();
    try (ZipOutputStream zos = new ZipOutputStream(byteArrayOutputStream)) {
        for (FileModel fileModel : fileModels) {
            ReportFile reportFile = fileGenerator.generateFile(reportFormat, report, mId, fileModel);
            ZipEntry zipEntry = new ZipEntry(fileModel.getFileName());
            zos.putNextEntry(zipEntry);
            zos.write(reportFile.getContent());
            zos.closeEntry();
        }
    }
    return byteArrayOutputStream;
}



private List<FileModel> buildReport(String mId, String reportMonth, List<Map<String, Object>> gstInvoiceData, int fileIndex) {
    log.info("Building GST Invoice Report for MID: {} and month: {}", mId, reportMonth);
    List<FileModel> fileModels = new ArrayList<>();

    for (Map<String, Object> csvData : gstInvoiceData) {
        Map<String, Object> dataMap = (Map<String, Object>) csvData.get("map");
        List<String> gstHeaders = (List<String>) dataMap.get("headers");
        List<List<Object>> fileData = (List<List<Object>>) dataMap.get("rows");

        if (CollectionUtils.isNotEmpty(fileData)) {
            String fileName = reportMonth + "_GST_REPORT_" + fileIndex + ".csv";
            FileModel fileModel = fileGeneratorService.buildFileModel(
                    ReportFormat.CSV, gstHeaders, fileData, Map.of("headers", gstHeaders, "rows", fileData)
            );
            fileModel.setFileName(fileName);
            fileModels.add(fileModel);
            fileIndex++;
        }
    }
    return fileModels;
}


public ReportingResponse<String> generateMerchantGstInvoice(String mId, List<String> reportMonths, HttpServletResponse response) {
    try {
        log.info("Fetching GST Invoice Data for mId: {} and reportMonths: {}", mId, reportMonths);
        mIdValidator.validateActiveMId(mId);
        invoiceValidator.validateRequestMonths(reportMonths);

        List<FileModel> allFileModels = new ArrayList<>();

        for (String reportMonth : reportMonths) {
            log.info("Processing GST Invoice Data for month: {}", reportMonth);
            int offset = 0;
            int batchSize = 500000; // Fetch 5 lakh records per batch
            int fileIndex = 1;

            while (true) {
                List<GstReport> merchantGstData = invoiceRepository.getMerchantGstInvoice(mId, reportMonth, offset, batchSize);
                if (CollectionUtils.isEmpty(merchantGstData)) {
                    break; // Stop when no more records are available
                }

                // Convert data for CSV generation
                Map<String, List<GstReport>> gstDataMonthBy = convertInvoiceGstMonthWise(merchantGstData);
                List<Map<String, Object>> gstInvoiceData = gstDataMonthBy.entrySet().stream()
                        .map(entry -> createCSVTemplate(Report.GST_INVOICE, entry.getKey(), entry.getValue()))
                        .toList();

                // Generate CSV files
                List<FileModel> fileModels = buildReport(mId, reportMonth, gstInvoiceData, fileIndex);
                allFileModels.addAll(fileModels);
                
                // Increment file index for naming (e.g., _1, _2, etc.)
                fileIndex += fileModels.size();
                offset += batchSize;
            }
        }

        if (CollectionUtils.isNotEmpty(allFileModels)) {
            generateZipFile(response, ReportFormat.CSV, Report.GST_INVOICE, mId, allFileModels);
        } else {
            return ReportingResponse.<String>builder()
                    .data(List.of("No Data Found"))
                    .status(ReportingConstant.RESPONSE_SUCCESS)
                    .build();
        }
    } catch (ValidationException e) {
        log.error("Validation error while generating GST Invoice for MID: {} and reportMonths: {}. Error: {}", mId, reportMonths, e.getMessage());
        throw e;
    } catch (Exception e) {
        log.error("Unexpected error while generating GST Invoice for MID: {} and reportMonths: {}. Error: {}", mId, reportMonths, e.getMessage());
        throw new ReportingException(ErrorConstants.GENERATION_ERROR_CODE, "Error generating GST invoice report.");
    }

    return ReportingResponse.<String>builder()
            .data(List.of("Success"))
            .status(ReportingConstant.RESPONSE_SUCCESS)
            .build();
}
