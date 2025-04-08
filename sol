@Test
void testReturnLatest50UnreadAlertDescriptions() {
    AlertManagement alert = new AlertManagement(); // mock or real object
    List<AlertManagement> alertList = List.of(alert);
    Page<AlertManagement> alertPage = new PageImpl<>(alertList);

    when(alertManagementRepository.findUnreadAlertsByMId(eq("MID123"), any(PageRequest.class)))
        .thenReturn(alertPage);

    when(alertMapper.alertManagementEntityToResponse(anyList()))
        .thenReturn(List.of(new AlertManagementResponse()));

    // Mock user role behavior
    SecurityContextHolder.getContext().setAuthentication(mock(Authentication.class));
    when(SecurityContextHolder.getContext().getAuthentication().getPrincipal())
        .thenReturn(mockPrincipal);
    when(EPayIdentityUtil.getUserPrincipal().getUserRole())
        .thenReturn(List.of("USER"));

    List<AlertManagementResponse> response = alertDao.getUnreadAlerts("MID123").toList();
    
    assertNotNull(response);
    assertEquals(1, response.size());
    verify(alertManagementRepository, times(1)).findUnreadAlertsByMId(eq("MID123"), any(PageRequest.class));
}
