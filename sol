public List<Map<String, Object>> getGstInvoiceData(String mId, List<String> reportMonths) {
    log.info("Fetching GST Invoice Data for MerchantId: {} and reportMonths {}", mId, reportMonths);

    // Fetch data in parallel
    List<GstReport> merchantGstData = reportMonths.parallelStream()
            .map(month -> invoiceRepository.getMerchantGstInvoice(mId, month))
            .filter(Objects::nonNull) // Avoid null results
            .flatMap(List::stream) // Flatten lists if repository returns a List<GstReport>
            .collect(Collectors.toList());

    // Convert to month-wise grouping
    Map<String, List<GstReport>> gstDataMonthBy = convertInvoiceGstMonthWise(merchantGstData);

    log.info("Returning processed GST Invoice data for {} months. Fetched {} records", gstDataMonthBy.size(), merchantGstData.size());

    // Process and create CSV templates
    return gstDataMonthBy.entrySet()
            .parallelStream()
            .map(entry -> createCSVTemplate(Report.GST_INVOICE, entry.getKey(), entry.getValue()))
            .toList();
}
