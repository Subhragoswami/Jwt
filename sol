public List<Map<String, Object>> getGstInvoiceData(String mId, List<String> reportDates) {
    log.info("Fetching GST Invoice Data for MerchantId: {} and reportDates {}", mId, reportDates);
    
    // Fetch merchant GST data
    List<GstReport> merchantGstData = invoiceRepository.getMerchantGstInvoice(mId, reportDates);

    // Convert data to month-wise structure
    Map<String, List<GstReport>> gstDataMonthBy = convertInvoiceGstMonthWise(merchantGstData);
    log.info("Returning processed GST Invoice data for {} months. Fetched {} records", gstDataMonthBy.size(), merchantGstData.size());

    // Transform data using createCSVTemplate before returning
    return gstDataMonthBy.entrySet().stream()
            .map(entry -> createCSVTemplate(Report.GST_INVOICE, entry.getKey(), entry.getValue()))
            .collect(Collectors.toList());
}




public ReportingResponse<String> generateMerchantGstInvoice(String mId, List<String> reportDate, HttpServletResponse response) {
    try {
        log.info("Fetching GST Invoice Data for mId: {} and reportDate: {}", mId, reportDate);

        // Fetch processed CSV data (already structured using createCSVTemplate)
        List<Map<String, Object>> gstInvoiceData = invoiceDao.getGstInvoiceData(mId, reportDate);

        if (CollectionUtils.isNotEmpty(gstInvoiceData)) {
            log.info("Fetched {} records for GST Invoice", gstInvoiceData.size());

            // Extract headers and rows from structured data
            for (Map<String, Object> csvData : gstInvoiceData) {
                Map<String, Object> dataMap = (Map<String, Object>) csvData.get("map");
                List<String> gstHeaders = (List<String>) dataMap.get("headers");
                List<List<Object>> fileData = (List<List<Object>>) dataMap.get("rows");

                // Build report for each month
                buildReport(mId, reportDate, gstHeaders, fileData, response);
            }
        } else {
            log.warn("No GST Invoice Data found for MID: {} and reportDate: {}", mId, reportDate);
            return ReportingResponse.<String>builder()
                    .data(List.of("No Data Found"))
                    .status(ReportingConstant.RESPONSE_SUCCESS)
                    .build();
        }
    } catch (Exception e) {
        log.error("Unexpected error while generating GST Invoice for MID: {} and reportDate: {}. Error: {}", mId, reportDate, e.getMessage());
        throw new ReportingException(ErrorConstants.GENERATION_ERROR_CODE, "Error generating GST invoice report.");
    }

    return ReportingResponse.<String>builder()
            .data(List.of("Success"))
            .status(ReportingConstant.RESPONSE_SUCCESS)
            .build();
}