package com.jwt.model.request;

import com.fasterxml.jackson.annotation.JsonInclude;
import lombok.*;

@AllArgsConstructor
@Getter
@Setter
@Builder
@NoArgsConstructor
@JsonInclude(JsonInclude.Include.NON_NULL)
public class PatientDischargeRequest {
    private String patientId;
    private String patientName;
}
