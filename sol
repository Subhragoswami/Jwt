@Test
void testValidateLogoCreateEmptyFile_ShouldThrowValidationException() {
    // Given: an empty MultipartFile and isUpdateCall = false (i.e. create call)
    MultipartFile logoFile = new MockMultipartFile("logo", "ABC.png", LOGO_FILE_TYPES[0], new byte[]{});

    // When: validateLogo is called
    ValidationException exception = assertThrows(ValidationException.class, 
        () -> themeValidator.validateLogo(logoFile, false));

    // Then: a validation exception should be thrown with expected message
    assertEquals("Logo File is mandatory.", exception.getErrorMessages().getFirst().getErrorMessage());
}
