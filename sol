@Test
void testChangePasswordValidationExceptionWithMandatoryErrorCode() {
    PasswordChangeRequest request = new PasswordChangeRequest();
    request.setUserName("testUser");
    request.setOldPassword("encryptedOldPwd");
    request.setNewPassword("encryptedNewPwd");
    request.setConfirmPassword("encryptedNewPwd");

    ErrorDto mandatoryError = new ErrorDto(MANDATORY_ERROR_CODE, "Mandatory field missing");
    ValidationException validationException = new ValidationException(List.of(mandatoryError));

    // Mock passwordValidator to throw ValidationException
    doThrow(validationException).when(passwordValidator).validateChangePassword(any());

    ValidationException thrown = assertThrows(
            ValidationException.class,
            () -> passwordService.changePassword(request)
    );

    assertEquals(validationException, thrown);
    verify(passwordManagementDao, never()).saveAudit(anyString(), any(), anyBoolean(), anyString());
}


@Test
void testChangePasswordValidationExceptionWithoutMandatoryErrorCode() {
    PasswordChangeRequest request = new PasswordChangeRequest();
    request.setUserName("testUser");
    request.setOldPassword("encryptedOldPwd");
    request.setNewPassword("encryptedNewPwd");
    request.setConfirmPassword("encryptedNewPwd");

    ErrorDto nonMandatoryError = new ErrorDto("SOME_OTHER_ERROR_CODE", "Invalid password format");
    ValidationException validationException = new ValidationException(List.of(nonMandatoryError));

    // Mock passwordValidator to throw ValidationException
    doThrow(validationException).when(passwordValidator).validateChangePassword(any());

    ValidationException thrown = assertThrows(
            ValidationException.class,
            () -> passwordService.changePassword(request)
    );

    assertEquals(validationException, thrown);
    // verify handlePasswordFailure is called
    verify(passwordManagementDao).saveAudit(eq("testUser"), eq(RequestType.CHANGE_PASSWORD), eq(false), anyString());
}
