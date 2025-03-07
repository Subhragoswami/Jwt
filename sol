@Query("""
    SELECT k FROM KmsManagement k 
    WHERE k.mId = :mId 
    ORDER BY 
        CASE 
            WHEN k.status = :status THEN 1
            ELSE 2
        END, 
        k.createdAt DESC
""")
Page<KmsManagement> findBymIdOrderByCreatedAtDesc(
    @Param("mId") String mId,
    @Param("status") KeyStatus status,
    Pageable pageable
);


import com.hazelcast.core.HazelcastInstance;
import com.hazelcast.map.IMap;
import com.hazelcast.query.Predicates;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.Mockito;
import org.mockito.junit.jupiter.MockitoExtension;

import java.util.Collections;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
class HazelcastServiceTest {

    @InjectMocks
    private HazelcastService hazelcastService;

    @Mock
    private HazelcastInstance hazelcastInstance;

    @Mock
    private IMap<String, Object> mockMap;

    @Mock
    private IMap<String, HazelcastJsonValue> jsonMockMap;

    private static final String MAP_NAME = "testMap";
    private static final String KEY = "testKey";
    private static final String JSON_STRING = "{\"name\":\"Test\"}";

    @BeforeEach
    void setUp() {
        when(hazelcastInstance.getMap(MAP_NAME)).thenReturn(mockMap);
        when(hazelcastInstance.getMap(MAP_NAME)).thenReturn(jsonMockMap);
    }

    @Test
    void testAddDataToCache_Success() throws HazelcastException {
        CacheableEntity entity = CacheableEntity.builder()
                .mapName(MAP_NAME)
                .key(KEY)
                .cacheableEntityData(mock(EPayCachebleData.class))
                .build();

        String response = hazelcastService.addDataToCache(entity, hazelcastInstance);

        verify(mockMap, times(1)).put(KEY, entity.getCacheableEntityData());
        assertEquals(HazelcastConstants.DATA_ADDED, response);
    }

    @Test
    void testAddDataToCache_NullPointerException() {
        CacheableEntity entity = CacheableEntity.builder().mapName(null).key(KEY).build();

        Exception exception = assertThrows(HazelcastException.class, () -> {
            hazelcastService.addDataToCache(entity, hazelcastInstance);
        });

        assertEquals(HazelcastConstants.HAZELCAST_1001_MSG, exception.getMessage());
    }

    @Test
    void testGetDataByKey_Success() throws HazelcastException {
        when(mockMap.get(KEY)).thenReturn(mock(EPayCachebleData.class));

        CacheableEntity entity = hazelcastService.getDataByKey(MAP_NAME, KEY, hazelcastInstance);

        assertNotNull(entity);
        assertEquals(KEY, entity.getKey());
        assertEquals(MAP_NAME, entity.getMapName());
    }

    @Test
    void testGetDataByKey_NullPointerException() {
        when(mockMap.get(KEY)).thenReturn(null);

        Exception exception = assertThrows(HazelcastException.class, () -> {
            hazelcastService.getDataByKey(MAP_NAME, KEY, hazelcastInstance);
        });

        assertEquals(HazelcastConstants.HAZELCAST_1002_MSG, exception.getMessage());
    }

    @Test
    void testGetDataBySql_Success() throws HazelcastException {
        when(mockMap.values(Predicates.sql("age > 30"))).thenReturn(Collections.emptyList());

        CacheableEntity entity = hazelcastService.getDataBySql(MAP_NAME, "age > 30", hazelcastInstance);

        assertNotNull(entity);
        assertEquals(MAP_NAME, entity.getMapName());
    }

    @Test
    void testSaveDataByJsonObject_Success() throws HazelcastException {
        when(hazelcastInstance.getMap(MAP_NAME)).thenReturn(jsonMockMap);

        String response = hazelcastService.saveDataByJsonObject(MAP_NAME, KEY, JSON_STRING, hazelcastInstance);

        verify(jsonMockMap, times(1)).put(KEY, new HazelcastJsonValue(JSON_STRING));
        assertEquals(HazelcastConstants.DATA_ADDED, response);
    }

    @Test
    void testRemoveData_Success() throws HazelcastException {
        String response = hazelcastService.removeData(MAP_NAME, KEY, hazelcastInstance);

        verify(jsonMockMap, times(1)).remove(KEY);
        assertEquals(HazelcastConstants.DATA_REMOVED, response);
    }

    @Test
    void testUpdateData_Success() throws HazelcastException {
        CacheableEntity entity = CacheableEntity.builder()
                .mapName(MAP_NAME)
                .key(KEY)
                .cacheableEntityData(mock(EPayCachebleData.class))
                .build();

        String response = hazelcastService.updateData(entity, hazelcastInstance);

        verify(mockMap, times(1)).put(KEY, entity.getCacheableEntityData());
        assertEquals(HazelcastConstants.DATA_UPDATE, response);
    }

    @Test
    void testUpdateJsonData_Success() throws HazelcastException {
        when(hazelcastInstance.getMap(MAP_NAME)).thenReturn(jsonMockMap);

        String response = hazelcastService.updateJsonData(MAP_NAME, KEY, JSON_STRING, hazelcastInstance);

        verify(jsonMockMap, times(1)).put(KEY, new HazelcastJsonValue(JSON_STRING));
        assertEquals(HazelcastConstants.DATA_UPDATE, response);
    }
}