public List<Map<String, Object>> getGstInvoiceData(String mId, List<String> reportMonths) {
    log.info("Fetching GST Invoice Data for MerchantId: {} and reportMonths {}", mId, reportMonths);
    List<Map<String, Object>> allData = new ArrayList<>();

    for (String reportMonth : reportMonths) {
        int offset = 0;
        int batchSize = 500000; // 5 Lakh

        while (true) {
            List<GstReport> merchantGstData = invoiceRepository.getMerchantGstInvoice(mId, reportMonth, offset, batchSize);
            if (CollectionUtils.isEmpty(merchantGstData)) {
                break; // Stop when no more records are available
            }

            Map<String, List<GstReport>> gstDataMonthBy = convertInvoiceGstMonthWise(merchantGstData);
            allData.addAll(gstDataMonthBy.entrySet().stream()
                .map(entry -> createCSVTemplate(Report.GST_INVOICE, entry.getKey(), entry.getValue()))
                .toList());

            offset += batchSize; // Move to the next batch
        }
    }

    return allData;
}


private List<FileModel> buildReport(String mId, String reportMonth, List<Map<String, Object>> gstInvoiceData) {
    log.info("Building GST Invoice Report for MID: {} and month: {}", mId, reportMonth);
    List<FileModel> fileModels = new ArrayList<>();
    int fileIndex = 1;

    for (Map<String, Object> csvData : gstInvoiceData) {
        Map<String, Object> dataMap = (Map<String, Object>) csvData.get("map");
        List<String> gstHeaders = (List<String>) dataMap.get("headers");
        List<List<Object>> fileData = (List<List<Object>>) dataMap.get("rows");

        if (CollectionUtils.isNotEmpty(fileData)) {
            FileModel fileModel = fileGeneratorService.buildFileModel(
                ReportFormat.CSV, gstHeaders, fileData, Map.of("headers", gstHeaders, "rows", fileData)
            );
            fileModel.setFileName(reportMonth + "_GST_REPORT_" + fileIndex + ".csv");
            fileModels.add(fileModel);
            fileIndex++;
        }
    }
    return fileModels;
}



public void generateZipFile(HttpServletResponse response, ReportFormat reportFormat, Report report, String mId, List<FileModel> fileModels) {
    log.info("Starting ZIP file generation for report: {} and merchant ID: {}", report.getName(), mId);
    try {
        ByteArrayOutputStream byteArrayOutputStream = generateZipFile(reportFormat, report, mId, fileModels);

        setHeader(response, "application/zip", mId + "_" + report.getName() + ".zip");
        response.setContentLength(byteArrayOutputStream.size());
        response.getOutputStream().write(byteArrayOutputStream.toByteArray());
        response.getOutputStream().flush();
        log.info("ZIP file successfully generated and sent to the response.");
    } catch (Exception e) {
        log.error("Error occurred during zipFileGenerator : {}", e.getMessage());
        throw new ReportingException(ErrorConstants.FILE_GENERATION_ERROR_CODE, MessageFormat.format(ErrorConstants.FILE_GENERATION_ERROR_MESSAGE, "zip", e.getMessage()));
    }
}


