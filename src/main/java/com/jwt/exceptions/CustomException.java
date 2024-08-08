package com.jwt.exceptions;

import com.jwt.model.response.ErrorDto;
import lombok.Getter;

import java.util.List;


@Getter
public class CustomException extends RuntimeException{
    private String errorCode;
    private String errorMessage;
    private List<ErrorDto> errorMessages;

    public CustomException(String errorCode, String errorMessage) {
        this.errorCode = errorCode;
        this.errorMessage = errorMessage;
    }

    public CustomException(List<ErrorDto> errorMessages) {
        this.errorMessages = errorMessages;
    }
}
