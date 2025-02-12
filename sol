private static List<FileModel> getFileModels(List<Map<String, Object>> gstInvoiceData) {
    List<FileModel> fileModels = new ArrayList<>();

    for (Map<String, Object> gstData : gstInvoiceData) {
        Map<String, Object> dataMap = (Map<String, Object>) gstData.get("map");

        // Extract headers and rows
        List<String> headers = (List<String>) dataMap.get("headers");
        List<List<Object>> rows = (List<List<Object>>) dataMap.get("rows");

        // Create CSVFileModel for each report month
        CSVFileModel fileModel = CSVFileModel.builder()
                .headers(headers)
                .fileData(rows)
                .build();

        // Set reportMonth
        fileModel.setReportMonth((String) gstData.get("report"));

        fileModels.add(fileModel);
    }

    return fileModels;
}





private static String generateCSV(List<String> headers, List<List<Object>> objects) {
    StringBuilder csvContent = new StringBuilder();

    // Append headers
    csvContent.append(String.join(",", headers)).append("\n");

    // Append each row, ensuring no extra comma
    for (List<Object> rowData : objects) {
        String row = rowData.stream()
                .map(data -> ObjectUtils.isNotEmpty(data) ? data.toString() : StringUtils.EMPTY)
                .collect(Collectors.joining(",")); // Join without adding an extra comma
        csvContent.append(row).append("\n"); // Append row with newline
    }

    return csvContent.toString();
}