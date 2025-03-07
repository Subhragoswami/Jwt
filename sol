@Mock
private HazelcastInstance hazelcastInstance;

@Mock
private IMap<String, Object> mockMap;

@BeforeEach
void setUp() {
    when(hazelcastInstance.<String, Object>getMap(MAP_NAME)).thenReturn(mockMap);
}

@Test
void testAddDataToCache_Success() throws HazelcastException {
    EPayCachebleData mockData = mock(EPayCachebleData.class);
    CacheableEntity entity = CacheableEntity.builder()
            .mapName(MAP_NAME)
            .key(KEY)
            .cacheableEntityData(mockData)  // Ensure mock data is used
            .build();

    // Call the method under test
    String response = hazelcastService.addDataToCache(entity, hazelcastInstance);

    // Verify the interaction
    verify(mockMap, times(1)).put(KEY, mockData);
    assertEquals(HazelcastConstants.DATA_ADDED, response);
}
