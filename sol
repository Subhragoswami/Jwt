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
