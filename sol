@BeforeEach
void setUp() {
    when(hazelcastInstance.<String, Object>getMap(any())).thenReturn(mockMap);
}


@Test
void testAddDataToCache_NullPointerException() {
    CacheableEntity entity = CacheableEntity.builder().mapName(null).key(KEY).build();

    Exception exception = assertThrows(HazelcastException.class, () -> {
        hazelcastService.addDataToCache(entity, hazelcastInstance);
    });

    assertEquals(HazelcastConstants.HAZELCAST_1001_MSG, exception.getMessage());
}



@BeforeEach
void setUp() {
    lenient().when(hazelcastInstance.<String, Object>getMap(MAP_NAME)).thenReturn(mockMap);
}