package com.jwt.handler;

import com.jwt.event.PatientDischargeEvent;
import lombok.extern.slf4j.Slf4j;
import org.springframework.context.event.EventListener;
import org.springframework.scheduling.annotation.Async;
import org.springframework.stereotype.Component;

@Component
@Slf4j
public class HousekeepingServiceHandler {
    @Async
    @EventListener
    public void cleanAndAssign(PatientDischargeEvent event) {
        log.info("Housekeeping Service: Preparing room for next patient after discharge of "
                + event.getPatientName() + " : " + Thread.currentThread().getName());
    }
}
