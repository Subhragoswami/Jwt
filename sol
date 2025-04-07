when(alertDao.getLatestAlertDescription(
    eq("MID123"),
    eq(false),
    eq(PageRequest.of(DEFAULT_PAGE_NUMBER, DEFAULT_ALERT_PAGE_SIZE, Sort.by(Sort.Direction.DESC, "createdAt")))
)).thenReturn(List.of(new AlertManagementResponse()));
