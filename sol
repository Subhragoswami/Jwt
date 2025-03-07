lenient().when(hazelcastInstance.<String, HazelcastJsonValue>getMap(MAP_NAME)).thenReturn(jsonMockMap);


private IMap<String, HazelcastJsonValue> jsonMockMap = mock(new TypeLiteral<IMap<String, HazelcastJsonValue>>() {});

@Mock
private IMap<String, HazelcastJsonValue> jsonMockMap;

private IMap<String, HazelcastJsonValue> jsonMockMap = mock(IMap.class);