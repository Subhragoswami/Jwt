when(alertDao.getLatestAlertDescription(
    eq("MID123"),
    eq(false),
    eq(PageRequest.of(DEFAULT_PAGE_NUMBER, DEFAULT_ALERT_PAGE_SIZE, Sort.by(Sort.Direction.DESC, "createdAt")))
)).thenReturn(List.of(new AlertManagementResponse()));




@Test
void testReturnAlertsByMId() {
    // Arrange
    String mId = "MID123";
    int DEFAULT_PAGE_NUMBER = 0;
    int DEFAULT_ALERT_PAGE_SIZE = 50;
    AlertManagementResponse alert = new AlertManagementResponse();
    PageRequest pageRequest = PageRequest.of(DEFAULT_PAGE_NUMBER, DEFAULT_ALERT_PAGE_SIZE, Sort.by(Sort.Direction.DESC, "createdAt"));

    when(alertDao.getLatestAlertDescription(eq(mId), eq(false), eq(pageRequest)))
        .thenReturn(List.of(alert));

    // Act
    MerchantResponse<AlertManagementResponse> response = alertService.getUnreadAlertsByMId(mId);

    // Assert
    assertEquals(RESPONSE_SUCCESS, response.getStatus());
    assertEquals(1, response.getTotal());
    verify(alertDao, times(1)).getLatestAlertDescription(eq(mId), eq(false), eq(pageRequest));
}