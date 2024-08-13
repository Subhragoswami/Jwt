package com.jwt.handler;

import com.jwt.event.PatientDischargeEvent;
import lombok.extern.slf4j.Slf4j;
import org.springframework.context.event.EventListener;
import org.springframework.scheduling.annotation.Async;
import org.springframework.stereotype.Component;

@Component
@Slf4j
public class BillingServiceHandler {
    @EventListener
    @Async
    public void processBill(PatientDischargeEvent patientDischargeEvent) {
        log.info("Billing Service: Finalizing bill for patient "
                + patientDischargeEvent.getPatientId() + " : " + Thread.currentThread().getName());
    }
}
