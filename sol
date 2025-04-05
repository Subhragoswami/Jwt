@Override
protected ResponseEntity<Object> handleHttpMessageNotReadable(
        HttpMessageNotReadableException ex,
        HttpHeaders headers,
        HttpStatusCode status,
        WebRequest request) {
    logger.error("Error in handleEnumConversionException with message: {}", ex.getMessage());
    ErrorDto errorDto = ErrorDto.builder()
            .errorCode(JSON_ERROR_CODE)
            .errorMessage(MessageFormat.format(JSON_ERROR_MESSAGE, REQUEST_BODY))
            .build();
    return ResponseEntity.status(HttpStatus.CONFLICT)
            .body(MerchantResponse.builder().status(RESPONSE_FAILURE).errors(List.of(errorDto)).build());
}
