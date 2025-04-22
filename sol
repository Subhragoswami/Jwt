@ExtendWith(MockitoExtension.class)
class AlertDaoTest {

    @InjectMocks
    private AlertDao alertDao;

    @Mock
    private AlertManagementRepository alertManagementRepository;

    @Mock
    private AlertMapper alertMapper;

    @Mock
    private EPayPrincipal mockPrincipal;

    @Test
    void testReturnLatest50UnreadAlertDescriptions_whenNonUserRole_thenNoNullPointerException() {
        String mId = "someMerchantId";

        // Mock static method
        try (MockedStatic<EPayIdentityUtil> identityUtilMock = mockStatic(EPayIdentityUtil.class)) {
            
            // Stub static call
            identityUtilMock.when(EPayIdentityUtil::getUserPrincipal).thenReturn(mockPrincipal);
            when(mockPrincipal.getUserRole()).thenReturn(List.of("ADMIN")); // non-user role
            
            // Mock repository method for non-user role
            Page<AlertManagement> page = new PageImpl<>(Collections.emptyList());
            when(alertManagementRepository.findUnreadAlertsByMId(eq(mId), any(Pageable.class))).thenReturn(page);
            
            // Mock mapper
            when(alertMapper.alertManagementEntityToResponse(anyList()))
                    .thenReturn(Collections.emptyList());

            // Act
            Page<AlertManagementResponse> result = alertDao.getUnreadAlerts(mId);

            // Assert
            assertNotNull(result);
            assertEquals(0, result.getTotalElements());
        }
    }
}
