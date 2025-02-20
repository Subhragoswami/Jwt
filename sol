
import com.epay.merchant.dto.AlertManagementDto;
import com.epay.merchant.dto.AlertMasterDto;
import com.epay.merchant.dto.ReportAlertDto;
import com.epay.merchant.entity.AlertManagement;
import com.epay.merchant.entity.AlertMaster;
import com.epay.merchant.mapper.AlertMapper;
import com.epay.merchant.model.response.AlertManagementResponse;
import com.epay.merchant.repository.AlertManagementRepository;
import com.epay.merchant.repository.AlertMasterRepository;
import com.epay.merchant.util.MerchantConstant;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.Mockito;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Sort;

import java.util.Collections;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
public class AlertDaoTest {

    @InjectMocks
    private AlertDao alertDao;

    @Mock
    private AlertMasterRepository alertMasterRepository;

    @Mock
    private AlertManagementRepository alertManagementRepository;

    @Mock
    private AlertMapper alertMapper;

    private AlertManagement alertManagement;
    private AlertMaster alertMaster;

    @BeforeEach
    void setUp() {
        alertManagement = new AlertManagement();
        alertManagement.setId(UUID.randomUUID());
        alertManagement.setMId("merchant123");
        alertManagement.setAlertId(UUID.randomUUID());
        alertManagement.setViewed(false);

        alertMaster = new AlertMaster();
        alertMaster.setId(UUID.randomUUID());
        alertMaster.setName("Test Alert");
    }

    @Test
    void testGetLatest50UnreadAlertDescription() {
        when(alertManagementRepository.findAlertsByMId(anyString(), any(PageRequest.class)))
                .thenReturn(Collections.singletonList(alertManagement));
        when(alertMapper.alertManagementEntityToResponse(anyList()))
                .thenReturn(Collections.singletonList(new AlertManagementResponse()));

        List<AlertManagementResponse> result = alertDao.getLatest50UnreadAlertDescription("merchant123");
        assertNotNull(result);
        assertFalse(result.isEmpty());
    }

    @Test
    void testUpdateViewStatus() {
        doNothing().when(alertManagementRepository).updateAlertViewStatus(anyString(), anyLong());
        alertDao.updateViewStatus("merchant123", 12345L);
        verify(alertManagementRepository, times(1)).updateAlertViewStatus("merchant123", 12345L);
    }

    @Test
    void testSaveAllToAlertManagement() {
        List<AlertManagementDto> alertManagementDtos = Collections.singletonList(new AlertManagementDto());
        when(alertMapper.mapDtoListToEntityList(alertManagementDtos)).thenReturn(Collections.singletonList(alertManagement));
        doNothing().when(alertManagementRepository).saveAll(anyList());

        alertDao.saveAllToAlertManagement(alertManagementDtos);
        verify(alertManagementRepository, times(1)).saveAll(anyList());
    }

    @Test
    void testFindAllAlertByName() {
        when(alertMasterRepository.findAllByName(anyString())).thenReturn(Collections.singletonList(alertMaster));
        when(alertMapper.mapAlertMasterEntityListToDtoList(anyList())).thenReturn(Collections.singletonList(new AlertMasterDto()));

        List<AlertMasterDto> result = alertDao.findAllAlertByName("Test Alert");
        assertNotNull(result);
        assertFalse(result.isEmpty());
    }

    @Test
    void testGenerateAlertForReport() {
        when(alertMasterRepository.findByName(MerchantConstant.REPORT_GENERATION)).thenReturn(Optional.of(alertMaster));
        doNothing().when(alertManagementRepository).save(any(AlertManagement.class));

        ReportAlertDto reportAlertDto = new ReportAlertDto("merchant123", "Test Report");
        alertDao.generateAlertForReport(reportAlertDto);

        verify(alertManagementRepository, times(1)).save(any(AlertManagement.class));
    }
}
