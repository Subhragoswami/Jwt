import org.apache.commons.codec.binary.Base64;
import java.nio.file.Files;
import java.nio.file.Paths;
import java.util.Base64;
import java.util.Optional;
import java.util.UUID;

public class CaptchaService {
    private static final Logger logger = LoggerFactory.getLogger(CaptchaService.class);

    public String generateCaptchaAudio(String captchaText, UUID requestId) {
        logger.info("Started generateCaptchaAudio for requestId: {}", requestId);

        return Optional.ofNullable(captchaText)
                .map(text -> {
                    byte[] audioData = VoiceCaptchaUtil.generateAudioCaptcha(text, requestId);
                    
                    // Log the generated byte array length
                    logger.info("Generated audio data length: {} for requestId: {}", 
                                audioData != null ? audioData.length : 0, requestId);

                    // Write audio data to a temporary file for manual testing
                    if (audioData != null && audioData.length > 0) {
                        try {
                            Files.write(Paths.get("test_audio.wav"), audioData);
                            logger.info("Audio file written: test_audio.wav for requestId: {}", requestId);
                        } catch (Exception e) {
                            logger.error("Failed to write audio file for requestId: {}", requestId, e);
                        }
                    } else {
                        logger.warn("Generated empty audio data for requestId: {}", requestId);
                    }

                    return audioData;
                })
                .map(data -> encodeToBase64(data, requestId))
                .orElseGet(() -> {
                    logger.warn("Captcha text is null for requestId: {}", requestId);
                    return "";
                });
    }

    /**
     * Encodes a byte array to a Base64 string using Java 8 Streams.
     *
     * @param data      The byte array to encode.
     * @param requestId The request ID for logging.
     * @return The Base64-encoded string.
     */
    private String encodeToBase64(byte[] data, UUID requestId) {
        return Optional.ofNullable(data)
                .filter(d -> d.length > 0)
                .map(d -> {
                    logger.info("Encoding {} bytes to Base64 for requestId: {}", d.length, requestId);
                    
                    // Standard Java Base64 Encoding
                    String base64Encoded = Base64.getEncoder().encodeToString(d);

                    // Alternative: Apache Commons Codec (uncomment if needed)
                    // String base64Encoded = Base64.encodeBase64String(d);

                    return base64Encoded;
                })
                .orElseGet(() -> {
                    logger.warn("Empty byte array for requestId: {}", requestId);
                    return "";
                });
    }
}










import org.apache.commons.codec.binary.Base64;
import java.nio.file.Files;
import java.nio.file.Paths;
import java.util.Base64;
import java.util.Optional;
import java.util.UUID;

public class CaptchaService {
    private static final Logger logger = LoggerFactory.getLogger(CaptchaService.class);

    public MerchantResponse<CaptchaResponse> generateCaptcha(CaptchaRequest captchaRequest) {
        logger.info("generate captcha for RequestId: {}", captchaRequest.getRequestId());
        return saveCaptcha(captchaRequest, false);
    }

    public MerchantResponse<CaptchaResponse> regenerateCaptcha(CaptchaRequest captchaRequest) {
        logger.info("regenerate captcha for RequestId: {}", captchaRequest.getRequestId());
        captchaValidator.regenerateValidator(captchaRequest);
        return saveCaptcha(captchaRequest, true);
    }

    private String generateCaptchaImage(String captchaText) {
        logger.info("Generated captcha text: {}", captchaText);
        BufferedImage image = captchaProducer.createImage(captchaText);
        return MerchantUtil.convertImageToBase64(image, "Captcha");
    }

    private MerchantResponse<CaptchaResponse> saveCaptcha(CaptchaRequest captchaRequest, boolean retry) {
        RequestType requestType = RequestType.getRequestType(captchaRequest.getRequestType());

        // Step 2: Generate Captcha Text
        String captchaText = captchaProducer.createText();

        // Step 3: Generate Captcha Image and convert into Base64
        String base64Image = generateCaptchaImage(captchaText);
        String base64Audio = generateCaptchaAudio(captchaText, captchaRequest.getRequestId());

        // Step 4: Save the Captcha into DB
        CaptchaDto captchaDto = captchaDao.save(captchaText, captchaRequest.getRequestId(), requestType, retry);

        logger.info("Captcha generation completed for RequestId: {}", captchaRequest.getRequestId());

        return MerchantResponse.<CaptchaResponse>builder()
                .data(List.of(captchaMapper.mapCaptchaDtoToCaptchaResponse(captchaDto, base64Image, base64Audio)))
                .status(RESPONSE_SUCCESS)
                .build();
    }

    public String generateCaptchaAudio(String captchaText, UUID requestId) {
        logger.info("Started generateAudioCaptcha for requestId: {}", requestId);

        return Optional.ofNullable(captchaText)
                .map(text -> {
                    byte[] audioData = VoiceCaptchaUtil.generateAudioCaptcha(text, requestId);

                    // Log the generated byte array length
                    logger.info("Generated audio data length: {} for requestId: {}", 
                                audioData != null ? audioData.length : 0, requestId);

                    // Write audio data to a temporary file for manual testing
                    if (audioData != null && audioData.length > 0) {
                        try {
                            Files.write(Paths.get("test_audio.wav"), audioData);
                            logger.info("Audio file written: test_audio.wav for RequestId: {}", requestId);
                        } catch (Exception e) {
                            logger.error("Failed to write audio file for RequestId: {}", requestId, e);
                        }
                    } else {
                        logger.warn("Generated empty audio data for RequestId: {}", requestId);
                    }

                    return audioData;
                })
                .map(data -> encodeToBase64(data, requestId))
                .orElseGet(() -> {
                    logger.warn("Captcha text is null for RequestId: {}", requestId);
                    return "";
                });
    }

    private String encodeToBase64(byte[] data, UUID requestId) {
        return Optional.ofNullable(data)
                .filter(d -> d.length > 0)
                .map(d -> {
                    logger.info("Encoding {} bytes to Base64 for RequestId: {}", d.length, requestId);

                    // Standard Java Base64 Encoding
                    String base64Encoded = Base64.getEncoder().encodeToString(d);

                    // Alternative: Apache Commons Codec (uncomment if needed)
                    // String base64Encoded = Base64.encodeBase64String(d);

                    return base64Encoded;
                })
                .orElseGet(() -> {
                    logger.warn("Empty byte array for RequestId: {}", requestId);
                    return "";
                });
    }
}





public static byte[] generateAudioCaptcha(String text, UUID requestId) {
    String uniqueFileName = "speech_" + System.currentTimeMillis() + "_" + requestId;
    File tempFile = null;

    try {
        tempFile = File.createTempFile(uniqueFileName, ".wav");
        tempFile.deleteOnExit();

        Voice voice = VoiceManager.getInstance().getVoice(VOICE_NAME);
        if (voice == null) {
            logger.error("Voice '{}' not found. Returning empty byte array.", VOICE_NAME);
            return new byte[0];
        }

        voice.allocate();

        // Ensure AudioPlayer creates a valid .wav file
        File finalTempFile = tempFile;
        try (SingleFileAudioPlayer audioPlayer = new SingleFileAudioPlayer(
                finalTempFile.getAbsolutePath().replace(".wav", ""), AudioFileFormat.Type.WAVE)) {

            voice.setAudioPlayer(audioPlayer);
            voice.setRate(100);
            voice.setPitch(75);
            voice.speak(text);
            voice.deallocate();
            audioPlayer.close();
        }

        // Log and check if the file was successfully created
        if (!tempFile.exists() || tempFile.length() == 0) {
            logger.error("Generated audio file is empty or missing for requestId: {}", requestId);
            return new byte[0];
        }
        
        logger.info("Audio file generated successfully. Size: {} bytes for requestId: {}", tempFile.length(), requestId);
        return fileToByteArray(tempFile);

    } catch (Exception e) {
        logger.error("Error generating speech audio for requestId: {}", requestId, e);
        throw new MerchantException(ErrorConstants.GENERATION_ERROR_CODE,
                MessageFormat.format(ErrorConstants.GENERATION_ERROR_MESSAGE, requestId));

    } finally {
        if (tempFile != null && tempFile.exists()) {
            if (tempFile.delete()) {
                logger.info("Temporary file deleted: {}", tempFile.getAbsolutePath());
            } else {
                logger.warn("Failed to delete temporary file: {}", tempFile.getAbsolutePath());
            }
        }
    }
}


private static byte[] fileToByteArray(File file) {
    try (FileInputStream fis = new FileInputStream(file);
         ByteArrayOutputStream byteArrayOutputStream = new ByteArrayOutputStream()) {

        byte[] buffer = new byte[1024];
        int bytesRead;
        while ((bytesRead = fis.read(buffer)) != -1) {
            byteArrayOutputStream.write(buffer, 0, bytesRead);
        }

        return byteArrayOutputStream.toByteArray();

    } catch (IOException e) {
        logger.error("Error reading file to byte array: {}", file.getAbsolutePath(), e);
        throw new MerchantException(ErrorConstants.GENERATION_ERROR_CODE,
                MessageFormat.format(ErrorConstants.GENERATION_ERROR_MESSAGE, file.getName()));
    }
}


private String encodeToBase64(byte[] data, UUID requestId) {
    return Optional.ofNullable(data)
            .filter(d -> d.length > 0)
            .map(d -> {
                logger.info("Encoding {} bytes to Base64 for requestId: {}", d.length, requestId);
                return Base64.getEncoder().encodeToString(d);
            })
            .orElseGet(() -> {
                logger.warn("Empty byte array for requestId: {}", requestId);
                return "";
            });
}