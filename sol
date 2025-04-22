@Mock
private AlertManagementRepository alertManagementRepository;

@Test
public void testReturnLatest50UnreadAlertDescriptions() {
    // Prepare mock data
    List<AlertManagement> alertList = new ArrayList<>(); // Add sample AlertManagement objects if needed
    Page<AlertManagement> page = new PageImpl<>(alertList);

    // Setup mock behavior
    when(alertManagementRepository.findUnreadAlertsByMId(anyString(), any(Pageable.class)))
        .thenReturn(page);

    // Now call the method under test
    Page<AlertManagementResponse> result = alertDao.getUnreadAlerts("someMerchantId");

    // Assert results (example)
    assertNotNull(result);
    assertEquals(0, result.getTotalElements()); // or whatever is expected
}
