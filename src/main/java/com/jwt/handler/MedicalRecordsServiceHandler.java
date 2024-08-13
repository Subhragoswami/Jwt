package com.jwt.handler;

import com.jwt.event.PatientDischargeEvent;
import lombok.extern.slf4j.Slf4j;
import org.springframework.context.event.EventListener;
import org.springframework.scheduling.annotation.Async;
import org.springframework.stereotype.Component;

@Component
@Slf4j
public class MedicalRecordsServiceHandler {

    @Async
    @EventListener
    public void updatePatientHistory(PatientDischargeEvent event) {
        log.info("Medical Records Service: Updating records for patient "
                + event.getPatientId() + " : " + Thread.currentThread().getName());
    }
}
