package com.jwt.services;

import com.jwt.event.PatientDischargeEvent;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.ApplicationEventPublisher;
import org.springframework.stereotype.Service;

@Service
@Slf4j
public class PatientDischargeService {

    @Autowired
    private  ApplicationEventPublisher eventPublisher;


    public String dischargePatient(String patientId, String patientName) {

        log.info("patient discharge process initiated {} ", patientName);
        //publish an event
        eventPublisher.publishEvent(new PatientDischargeEvent(this, patientId, patientName));

        log.info("patient discharge process completed {} ", patientName);
        return "Patient " + patientName + " with ID " + patientId + " discharged successfully!";
    }
}
