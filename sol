private byte[] fileToByteArray(File file) {
    try {
        // Validate and normalize paths
        String tempDirConfig = merchantConfig.getTempDir();
        if (tempDirConfig == null || tempDirConfig.trim().isEmpty()) {
            throw new IllegalStateException("Temporary directory is not configured!");
        }

        Path tempDir = Paths.get(tempDirConfig).normalize().toAbsolutePath();
        Path filePath = file.toPath().normalize().toAbsolutePath();

        // Ensure the file is within the secure directory
        if (!filePath.startsWith(tempDir)) {
            throw new SecurityException("Unauthorized file access detected: " + filePath);
        }

        // Read file safely
        try (FileInputStream fis = new FileInputStream(file);
             ByteArrayOutputStream byteArrayOutputStream = new ByteArrayOutputStream()) {

            byte[] buffer = new byte[1024];
            int bytesRead;
            while ((bytesRead = fis.read(buffer)) != -1) {
                byteArrayOutputStream.write(buffer, 0, bytesRead);
            }

            logger.debug("File successfully converted to byte array: {}", filePath);
            return byteArrayOutputStream.toByteArray();
        }

    } catch (IOException e) {
        logger.error("Error reading file to byte array securely: {}", file.getAbsolutePath(), e);
        throw new MerchantException(ErrorConstants.GENERATION_ERROR_CODE,
                MessageFormat.format(ErrorConstants.GENERATION_ERROR_MESSAGE, file.getName()));
    }
}
