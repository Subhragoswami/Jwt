package com.jwt.controller;

import com.jwt.model.request.PatientDischargeRequest;
import com.jwt.services.PatientDischargeService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@Slf4j
@RequiredArgsConstructor
@RequestMapping("/discharge")
public class DischargeProcessController {
    private final PatientDischargeService patientDischargeService;
    @PostMapping("/process")
    public String dischargePatient(@RequestBody PatientDischargeRequest request) {
        return patientDischargeService.dischargePatient(request.getPatientId(), request.getPatientName());
    }
}
