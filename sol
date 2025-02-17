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
