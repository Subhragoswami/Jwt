private void buildReport(UUID reportManagementId, ReportManagementDto reportManagementDto, List<String> header, List<List<Object>> fileData) {
    log.info("Building report for ReportManagementId: {} and format: {}", reportManagementId, reportManagementDto.getFormat());

    if (fileData.size() > 10000) {
        log.info("fileData exceeds 10,000 rows. Splitting and generating ZIP file.");
        List<FileModel> fileModels = new ArrayList<>();
        int chunkSize = 10000;
        int part = 1;

        for (int i = 0; i < fileData.size(); i += chunkSize) {
            List<List<Object>> chunk = fileData.subList(i, Math.min(i + chunkSize, fileData.size()));
            FileModel fileModel = fileGeneratorService.buildFileModel(
                    reportManagementDto.getFormat(),
                    header,
                    chunk,
                    Map.of("headers", header, "rows", chunk)
            );
            fileModel.setFileName(String.format("%s_part_%d.%s",
                    reportManagementDto.getReport().getName(),
                    part++,
                    reportManagementDto.getFormat().name().toLowerCase()));
            fileModels.add(fileModel);
        }

        // Generate ZIP file and upload to S3
        ReportFile zipReportFile = fileGeneratorService.generateZipFile(
                reportManagementDto.getFormat(),
                reportManagementDto.getReport(),
                reportManagementDto.getMId(),
                fileModels
        );
        String s3FileName = s3Service.uploadFile(zipReportFile.getName(), zipReportFile.getContent());

        reportManagementDao.updateStatusAndFilePath(reportManagementId, ReportStatus.GENERATED, s3FileName);
        publishReportGenerationAlert(reportManagementDto);
        log.info("ZIP report generated and uploaded to S3 for ReportManagementId: {}", reportManagementId);

    } else {
        // Existing single-file logic
        FileModel fileModel = fileGeneratorService.buildFileModel(
                reportManagementDto.getFormat(), header, fileData, 
                Map.of("headers", header, "rows", fileData)
        );
        ReportFile reportFile = fileGeneratorService.generateFile(
                reportManagementDto.getFormat(),
                reportManagementDto.getReport(),
                reportManagementDto.getMId(),
                fileModel
        );
        String s3FileName = s3Service.uploadFile(reportFile.getName(), reportFile.getContent());
        reportManagementDao.updateStatusAndFilePath(reportManagementId, ReportStatus.GENERATED, s3FileName);
        publishReportGenerationAlert(reportManagementDto);
        log.info("Single report generated and uploaded to S3 for ReportManagementId: {}", reportManagementId);
    }
}

