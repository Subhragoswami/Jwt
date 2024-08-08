package com.jwt.model.response;

import com.fasterxml.jackson.annotation.JsonInclude;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;

import java.util.List;
import java.util.UUID;

@AllArgsConstructor
@Data
@Builder
@JsonInclude(JsonInclude.Include.NON_NULL)
public class ResponseDto<T> {
    private Integer status;
    private List<T> data;
    private Long count;
    private Long total;
    private List<ErrorDto> errors;

    @Override
    public String toString() {
        return "ResponseDto{" +
                "status=" + status +
                ", data=" + data +
                ", count=" + count +
                ", total=" + total +
                ", errors=" + errors +
                '}';
    }
}
