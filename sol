  public void generateReReport(){
        List<ReportManagementDto> reportManagementDto = reportManagementDao.getReportManagementByStatus();
        reportManagementDto.stream().map(reportManagement -> generateReport(reportManagement.getReportId()));
    }
