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













private byte[] fileToByteArray(File file) {
    try {
        // Validate and normalize paths
        String tempDirConfig = merchantConfig.getTempDir();
        if (tempDirConfig == null || tempDirConfig.trim().isEmpty()) {
            throw new IllegalStateException("Temporary directory is not configured!");
        }

        Path tempDir = Paths.get(tempDirConfig).normalize().toAbsolutePath();
        Path resolvedPath = tempDir.resolve(file.getName()).normalize();

        // Ensure the file is within the secure directory
        if (!resolvedPath.startsWith(tempDir)) {
            throw new SecurityException("Unauthorized file access detected: " + resolvedPath);
        }

        // Read file safely using Files API
        try (InputStream fis = Files.newInputStream(resolvedPath);
             ByteArrayOutputStream byteArrayOutputStream = new ByteArrayOutputStream()) {

            byte[] buffer = new byte[1024];
            int bytesRead;
            while ((bytesRead = fis.read(buffer)) != -1) {
                byteArrayOutputStream.write(buffer, 0, bytesRead);
            }

            logger.debug("File successfully converted to byte array: {}", file.getName());
            return byteArrayOutputStream.toByteArray();
        }

    } catch (IOException e) {
        logger.error("Error reading file to byte array securely: {}", file.getName(), e);
        throw new MerchantException(ErrorConstants.GENERATION_ERROR_CODE,
                MessageFormat.format(ErrorConstants.GENERATION_ERROR_MESSAGE, file.getName()));
    }
}














private File createTempFile(UUID requestId) {
    try {
        // Ensure temp directory is properly configured
        String tempDirConfig = merchantConfig.getTempDir();
        if (tempDirConfig == null || tempDirConfig.trim().isEmpty()) {
            throw new IllegalStateException("Temporary directory is not configured!");
        }

        Path tempDir = Paths.get(tempDirConfig).normalize().toAbsolutePath();
        if (!Files.exists(tempDir)) {
            Files.createDirectories(tempDir); // Ensure directory exists
        }

        // Use SecureRandom for unpredictable file names
        SecureRandom random = new SecureRandom();
        String randomSuffix = Long.toHexString(random.nextLong());

        Path tempFilePath = Files.createTempFile(tempDir, "speech_" + randomSuffix + "_", ".wav").normalize();

        // Validate that tempFilePath is inside tempDir (prevent path traversal attacks)
        if (!tempFilePath.startsWith(tempDir)) {
            throw new SecurityException("Unauthorized temp file path detected: " + tempFilePath);
        }

        // Set restrictive permissions (only for Unix/Linux)
        try {
            Files.setPosixFilePermissions(tempFilePath, PosixFilePermissions.fromString("rw-------"));
        } catch (UnsupportedOperationException ignored) {
            // Ignore if running on Windows
        }

        logger.debug("Temporary file securely created: {}", tempFilePath);
        return tempFilePath.toFile();

    } catch (IOException e) {
        logger.error("Failed to create secure temp file for requestId: {}", requestId, e);
        return null;
    }
}