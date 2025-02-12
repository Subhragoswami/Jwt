<!DOCTYPE html>
<html lang="en" xmlns:th="http://www.thymeleaf.org">
<head>
    <meta charset="UTF-8"></meta>
    <title>Report</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            margin: 11px;
        }
        .header {
            text-align: center;
            margin-bottom: 40px;
        }
        h1 {
            color: cadetblue;
        }
        table, th, td {
            border: 1px solid black;
            border-collapse: collapse;
        }
        .center {
          margin-left: auto;
          margin-right: auto;
        }
    </style>
</head>
<body>
<div class="header">
    <h1>Report</h1>
</div>
<table class="center">
    <!-- Check if map and headers exist -->
    <tr th:if="${map != null and map.headers != null}" th:each="header : ${map.headers}">
        <td>
            <span th:text="${header} ?: 'N/A'"></span>  <!-- Handle null values -->
        </td>
    </tr>
    
    <!-- Check if map and rows exist -->
    <tr th:if="${map != null and map.rows != null}" th:each="row : ${map.rows}">
        <td th:each="cell : ${row}">
            <span th:text="${cell} ?: 'N/A'"></span>  <!-- Handle null values -->
        </td>
    </tr>
</table>
</body>
</html>






protected String getPdfContent(Map<String, Object> input, String template) {
    log.debug("Rendering PDF with input: {}", input);

    if (input == null || !input.containsKey("map")) {
        log.error("Input data for PDF generation is missing the 'map' key.");
        throw new ReportingException(ErrorConstants.FILE_GENERATION_ERROR_CODE, "Invalid data structure for PDF template.");
    }

    Context context = new Context();
    context.setVariables(input); // Ensure Thymeleaf gets the correct variables

    return templateEngine.process(template, context);
}


public static Map<String, Object> createPdfTemplate(Report report, String reportDate, List<GstReport> gstReports) {
    log.info("Creating PDF template input for report: {} on date: {}", report.getName(), reportDate);

    // Define headers
    List<String> headers = Arrays.asList(
            "Transaction Number", "GST", "GST Charged", "GST Of", "Narration", "Date", "Report"
    );

    // Populate rows
    List<List<Object>> rows = new ArrayList<>();
    for (GstReport gstReport : gstReports) {
        List<Object> row = Arrays.asList(
                gstReport.getTransactionNumber(),
                ReportingConstant.GST_PERCENTAGE,
                gstReport.getGstCharged(),
                ReportingConstant.GST_OF,
                ReportingConstant.NARRATION,
                gstReport.getTransactionDate(),
                reportDate
        );
        rows.add(row);
    }

    // Create data map
    Map<String, Object> dataMap = new HashMap<>();
    dataMap.put("headers", headers);
    dataMap.put("rows", rows);

    // Ensure "map" exists in input
    Map<String, Object> input = new HashMap<>();
    input.put("map", dataMap);

    log.debug("Generated PDF template input: {}", input); // Added logging

    return input;
}
