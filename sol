public ReportingResponse<String> generateMerchantGstInvoice(String mId, List<String> reportMonths, HttpServletResponse response) {
    try {
        log.info("Fetching GST Invoice Data for mId: {} and reportMonths: {}", mId, reportMonths);
        invoiceValidator.validateRequestMonths(reportMonths);

        List<Map<String, Object>> gstInvoiceData = invoiceDao.getGstInvoiceData(mId, reportMonths);

        if (CollectionUtils.isNotEmpty(gstInvoiceData)) {
            log.info("Fetched {} records for GST Invoice", gstInvoiceData.size());

            List<FileModel> fileModels = new ArrayList<>();

            for (Map<String, Object> csvData : gstInvoiceData) {
                Map<String, Object> dataMap = (Map<String, Object>) csvData.get("map");
                List<String> gstHeaders = (List<String>) dataMap.get("headers");
                List<List<Object>> fileData = (List<List<Object>>) dataMap.get("rows");
                String reportMonth = (String) csvData.get("report"); // Extract the month

                if (CollectionUtils.isNotEmpty(fileData)) {
                    FileModel fileModel = fileGeneratorService.buildFileModel(
                        ReportFormat.CSV, gstHeaders, fileData, Map.of("headers", gstHeaders, "rows", fileData)
                    );
                    fileModel.setReportMonth(reportMonth);
                    fileModels.add(fileModel);
                }
            }

            if (fileModels.isEmpty()) {
                log.warn("No valid data found to generate GST Invoice files for MID: {}", mId);
                return ReportingResponse.<String>builder().data(List.of("No Data Found")).status(ReportingConstant.RESPONSE_SUCCESS).build();
            }

            // Generate ZIP with multiple CSVs
            fileGeneratorService.generateZipFile(response, ReportFormat.CSV, Report.GST_INVOICE, mId, fileModels);
        } else {
            log.warn("No GST Invoice Data found for MID: {} and reportMonths: {}", mId, reportMonths);
            return ReportingResponse.<String>builder().data(List.of("No Data Found")).status(ReportingConstant.RESPONSE_SUCCESS).build();
        }
    } catch (ValidationException e) {
        log.error("Validation error while generating GST Invoice for MID: {} and reportMonths: {}. Error: {}", mId, reportMonths, e.getMessage());
        throw e;
    } catch (Exception e) {
        log.error("Unexpected error while generating GST Invoice for MID: {} and reportMonths: {}. Error: {}", mId, reportMonths, e.getMessage());
        throw new ReportingException(ErrorConstants.GENERATION_ERROR_CODE, "Error generating GST invoice report.");
    }
    return ReportingResponse.<String>builder().data(List.of("Success")).status(ReportingConstant.RESPONSE_SUCCESS).build();
}


private void buildReport(String mId, List<String> reportMonths, List<Map<String, Object>> gstInvoiceData, HttpServletResponse response) {
    log.info("Building GST Invoice Report for MID: {} and Report months: {}", mId, reportMonths);

    List<FileModel> fileModels = new ArrayList<>();

    for (Map<String, Object> csvData : gstInvoiceData) {
        Map<String, Object> dataMap = (Map<String, Object>) csvData.get("map");
        List<String> gstHeaders = (List<String>) dataMap.get("headers");
        List<List<Object>> fileData = (List<List<Object>>) dataMap.get("rows");
        String reportMonth = (String) csvData.get("report");

        if (CollectionUtils.isNotEmpty(fileData)) {
            FileModel fileModel = fileGeneratorService.buildFileModel(
                ReportFormat.CSV, gstHeaders, fileData, Map.of("headers", gstHeaders, "rows", fileData)
            );
            fileModel.setReportMonth(reportMonth);
            fileModels.add(fileModel);
        }
    }

    if (fileModels.isEmpty()) {
        log.warn("No valid data found to generate GST Invoice files for MID: {}", mId);
        return;
    }

    // Generate ZIP with multiple CSVs
    fileGeneratorService.generateZipFile(response, ReportFormat.CSV, Report.GST_INVOICE, mId, fileModels);
}












private ByteArrayOutputStream generateZipFileContent(ReportFormat reportFormat, Report report, String mId, List<FileModel> fileModels) throws IOException {
    log.debug("Generating ZIP file for report: {} with format: {}", report.getName(), reportFormat.name());
    ByteArrayOutputStream byteArrayOutputStream = new ByteArrayOutputStream();
    
    // Create a single ZipOutputStream for all entries
    try (ZipOutputStream zos = new ZipOutputStream(byteArrayOutputStream)) {
        for (FileModel fileModel : fileModels) {
            ReportFile reportFile = fileGenerator.generateFile(reportFormat, report, mId, fileModel);
            String zipEntryName = getZipFileName(reportFormat, report, fileModel);
            ZipEntry zipEntry = new ZipEntry(zipEntryName);
            zos.putNextEntry(zipEntry);
            zos.write(reportFile.getContent());
            zos.closeEntry();
        }
        zos.finish();
    }
    
    log.debug("ZIP file generation completed for report: {}", report.getName());
    return byteArrayOutputStream;
}





public void generateZipFile(HttpServletResponse response, ReportFormat reportFormat, Report report, String mId, List<FileModel> fileModels) {
    log.info("Starting ZIP file generation for report: {} and merchant ID: {}", report.getName(), mId);
    try {
        ByteArrayOutputStream byteArrayOutputStream = generateZipFileContent(reportFormat, report, mId, fileModels);
        response.setContentType("application/zip");
        response.setHeader(HttpHeaders.CONTENT_DISPOSITION, 
            StringEscapeUtils.escapeJava("attachment;filename=" + mId + "_" + report.getName() + ".zip"));
        response.setContentLength(byteArrayOutputStream.size());
        response.getOutputStream().write(byteArrayOutputStream.toByteArray());
        response.getOutputStream().flush();
        log.info("ZIP file successfully generated and sent to the response.");
    } catch (Exception e) {
        log.error("Error occurred during ZIP file generation: {}", e.getMessage());
        throw new ReportingException(ErrorConstants.FILE_GENERATION_ERROR_CODE, 
            MessageFormat.format(ErrorConstants.FILE_GENERATION_ERROR_MESSAGE, "zip", e.getMessage()));
    }
}
