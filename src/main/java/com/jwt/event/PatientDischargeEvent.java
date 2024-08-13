package com.jwt.event;

import lombok.*;
import org.springframework.context.ApplicationEvent;

import javax.persistence.Entity;


@Getter
@Setter
public class PatientDischargeEvent extends ApplicationEvent {
    private String patientId;
    private String patientName;
    public PatientDischargeEvent(Object source,String patientId,String patientName) {
        super(source);
        this.patientId=patientId;
        this.patientName=patientName;
    }
}
