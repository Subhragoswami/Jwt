@Mock
private HazelcastInstance hazelcastInstance;

@Mock
private IMap<String, Object> mockMap;

@Mock
private IMap<String, HazelcastJsonValue> jsonMockMap;

@BeforeEach
void setUp() {
    when(hazelcastInstance.<String, Object>getMap(MAP_NAME)).thenReturn(mockMap);
    when(hazelcastInstance.<String, HazelcastJsonValue>getMap(MAP_NAME)).thenReturn(jsonMockMap);
}
