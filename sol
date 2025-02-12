public ReportingResponse<String> generateMerchantGstInvoice(String mId, List<String> reportDate, HttpServletResponse response) {
    try {
        log.info("Fetching GST Invoice Data for mId: {} and reportDate: {}", mId, reportDate);
        mIdValidator.validatedActiveMId(mId);

        List<Map<String, Object>> gstInvoiceData = invoiceDao.getGstInvoiceData(mId, reportDate);
        
        if (CollectionUtils.isEmpty(gstInvoiceData)) {
            log.warn("No GST Invoice Data found for MID: {} and reportDate: {}", mId, reportDate);
            return ReportingResponse.<String>builder()
                    .data(List.of("No Data Found"))
                    .status(ReportingConstant.RESPONSE_SUCCESS)
                    .build();
        }

        List<FileModel> fileModels = getFileModels(gstInvoiceData);
        log.info("Fetched {} records for GST Invoice", gstInvoiceData.size());

        // Extract headers and rows in a single pass
        List<String> gstHeaders = (List<String>) gstInvoiceData.getFirst().get("map").get("headers");
        List<List<Object>> fileData = gstInvoiceData.stream()
                .flatMap(csvData -> ((List<List<Object>>) csvData.get("map").get("rows")).stream())
                .collect(Collectors.toList());

        buildReport(mId, reportDate, gstHeaders, fileData, fileModels, response);

    } catch (Exception e) {
        log.error("Unexpected error while generating GST Invoice for MID: {} and reportDate: {}. Error: {}", 
                  mId, reportDate, e.getMessage());
        throw new ReportingException(ErrorConstants.GENERATION_ERROR_CODE, "Error generating GST invoice report.");
    }

    return ReportingResponse.<String>builder()
            .data(List.of("Success"))
            .status(ReportingConstant.RESPONSE_SUCCESS)
            .build();
}

private void buildReport(String mId, List<String> reportDate, List<String> header, List<List<Object>> fileData, 
                         List<FileModel> fileModels, HttpServletResponse response) {
    log.info("Building GST Invoice Report for MID: {} and Report Date: {}", mId, reportDate);

    FileModel fileModel = fileGeneratorService.buildFileModel(
            ReportFormat.CSV, header, fileData, Map.of("headers", header, "rows", fileData)
    );
    fileModel.setReportMonth(fileModels.getFirst().getReportMonth());

    log.info("File model created, generating file for GST Invoice.");

    if (fileData.size() > 1) {
        fileGeneratorService.generateZipFile(response, ReportFormat.CSV, Report.GST_INVOICE, mId, List.of(fileModel));
    } else {
        fileGeneratorService.downloadFile(response, ReportFormat.CSV, Report.GST_INVOICE, mId, fileModel);
    }
}
