 public ReportingResponse<String> generateMerchantGstInvoice(String mId, List<String> reportMonth, HttpServletResponse response) {
        try {
            log.info("Fetching GST Invoice Data for mId: {} and reportMonth: {}", mId, reportMonth);
            invoiceValidator.isValidMonthYear(reportMonth);
            //mIdValidator.validatedActiveMId(mId);
            List<Map<String, Object>> gstInvoiceData = invoiceDao.getGstInvoiceData(mId, reportMonth);
            if (CollectionUtils.isNotEmpty(gstInvoiceData)) {
                List<FileModel> fileModels = getFileModels(gstInvoiceData);
                log.info("Fetched {} records for GST Invoice", gstInvoiceData.size());
                List<String> gstHeaders = null;
                List<List<Object>> fileData = new ArrayList<>();
                for (Map<String, Object> csvData : gstInvoiceData) {
                    Map<String, Object> dataMap = (Map<String, Object>) csvData.get("map");
                    gstHeaders = (List<String>) dataMap.get("headers");
                    fileData.addAll((List<List<Object>>) dataMap.get("rows"));
                }
                buildReport(mId, reportMonth, gstHeaders, fileData, fileModels, response);
            } else {
                log.warn("No GST Invoice Data found for MID: {} and reportMonth: {}", mId, reportMonth);
                return ReportingResponse.<String>builder().data(List.of("No Data Found")).status(ReportingConstant.RESPONSE_SUCCESS).build();
            }
        } catch (Exception e) {
            log.error("Unexpected error while generating GST Invoice for MID: {} and reportMonth: {}. Error: {}", mId, reportMonth, e.getMessage());
            throw new ReportingException(ErrorConstants.GENERATION_ERROR_CODE, "Error generating GST invoice report.");
        }
        return ReportingResponse.<String>builder().data(List.of("Success")).status(ReportingConstant.RESPONSE_SUCCESS).build();
    }

public class InvoiceValidator extends BaseValidator {
    private static final DateTimeFormatter FORMATTER = DateTimeFormatter.ofPattern("MMM-yyyy", Locale.ENGLISH);

    public void isValidMonthYear(List<String> date) {
        for (String d : date) {
            try {
                YearMonth.parse(d, FORMATTER);
            } catch (DateTimeParseException e) {
                errorDtoList.add(ErrorDto.builder().errorCode(ErrorConstants.NOT_FOUND_ERROR_CODE).errorMessage(ErrorConstants.REPORT_NOT_AVAILABLE).build());
                throwIfErrors();
            }
        }
    }

}


here it's not throwing REPORT_NOT_AVAILABLE it's throwing Error generating GST invoice report.
