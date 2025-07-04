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




public ReportFile generateZipFile(ReportFormat reportFormat, Report report, String mId, List<FileModel> fileModels) {
    logger.info("Generating ZIP file for report: {} with format: {}", report.getName(), reportFormat.name());
    try (ByteArrayOutputStream byteArrayOutputStream = new ByteArrayOutputStream();
         ZipOutputStream zos = new ZipOutputStream(byteArrayOutputStream)) {

        for (FileModel fileModel : fileModels) {
            ReportFile reportFile = generateFile(reportFormat, report, mId, fileModel);
            String zipEntryName = getZipFileName(reportFormat, report, fileModel);

            logger.debug("Adding file to ZIP: {}", zipEntryName);
            ZipEntry zipEntry = new ZipEntry(zipEntryName);
            zos.putNextEntry(zipEntry);

            byte[] content = reportFile.getContent();
            if (content != null && content.length > 0) {
                zos.write(content);
            } else {
                logger.warn("Skipping empty file: {}", zipEntryName);
            }
            zos.closeEntry();
        }
        zos.finish();

        String zipFileName = String.format("%s_%s_%s.zip", mId, report.getName(), System.currentTimeMillis());
        return new ReportFile(zipFileName, byteArrayOutputStream.toByteArray());
    } catch (IOException e) {
        logger.error("Error generating ZIP file: {}", e.getMessage(), e);
        throw new ReportingException(ErrorConstants.FILE_GENERATION_ERROR_CODE, 
            MessageFormat.format(ErrorConstants.FILE_GENERATION_ERROR_MESSAGE, "zip", e.getMessage()));
    }
}




public void generateZipFile(HttpServletResponse response, ReportFormat reportFormat, Report report, String mId, List<FileModel> fileModels) {
    logger.info("Starting ZIP file generation for HTTP response for report: {} and merchant ID: {}", report.getName(), mId);
    ReportFile zipReportFile = generateZipFile(reportFormat, report, mId, fileModels);
    try {
        setHeader(response, "application/zip", zipReportFile.getName());
        response.setContentLength(zipReportFile.getContent().length);
        response.getOutputStream().write(zipReportFile.getContent());
        response.getOutputStream().flush();
        logger.info("ZIP file successfully streamed to response.");
    } catch (IOException e) {
        logger.error("Error streaming ZIP file to response: {}", e.getMessage(), e);
        throw new ReportingException(ErrorConstants.FILE_GENERATION_ERROR_CODE, 
            MessageFormat.format(ErrorConstants.FILE_GENERATION_ERROR_MESSAGE, "zip", e.getMessage()));
    }
}
