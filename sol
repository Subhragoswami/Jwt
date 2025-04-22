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




@ExtendWith(MockitoExtension.class)
class AlertDaoTest {

    @InjectMocks
    private AlertDao alertDao;

    @Mock
    private AlertManagementRepository alertManagementRepository;

    @Mock
    private AlertMapper alertMapper;

    @BeforeEach
    void setUp() {
        // If AlertDao has constructor injection, use constructor + field injection instead
    }

    @Test
    void testReturnLatest50UnreadAlertDescriptions_whenNonUserRole_thenNoNullPointerException() {
        String mId = "someMerchantId";
        Pageable pageable = PageRequest.of(0, 50, Sort.by(Sort.Direction.DESC, "createdAt"));

        // Mock static method
        try (MockedStatic<EPayIdentityUtil> identityUtilMock = mockStatic(EPayIdentityUtil.class)) {

            // Mock user principal
            UserPrincipal mockPrincipal = mock(UserPrincipal.class);
            identityUtilMock.when(EPayIdentityUtil::getUserPrincipal).thenReturn(mockPrincipal);
            when(mockPrincipal.getUserRole()).thenReturn(Collections.singletonList("ROLE_ADMIN")); // non-user

            // Mock repository method (non-user path)
            Page<AlertManagement> page = new PageImpl<>(Collections.emptyList());
            when(alertManagementRepository.findUnreadAlertsByMId(eq(mId), any(Pageable.class))).thenReturn(page);

            // Mock mapper conversion
            when(alertMapper.alertManagementEntityToResponse(anyList()))
                .thenReturn(Collections.emptyList());

            // Call the method under test
            Page<AlertManagementResponse> result = alertDao.getUnreadAlerts(mId);

            // Assertions
            assertNotNull(result);
            assertEquals(0, result.getTotalElements());
        }
    }
}