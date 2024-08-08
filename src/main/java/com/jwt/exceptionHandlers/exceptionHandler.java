package com.jwt.exceptionHandlers;

import com.jwt.exceptions.CustomException;
import com.jwt.model.response.ErrorDto;
import com.jwt.model.response.ResponseDto;
import org.springframework.http.ResponseEntity;
import org.springframework.util.CollectionUtils;
import org.springframework.web.bind.annotation.ControllerAdvice;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.servlet.mvc.method.annotation.ResponseEntityExceptionHandler;

import java.util.List;

@ControllerAdvice
public class exceptionHandler extends ResponseEntityExceptionHandler {

    @ExceptionHandler(CustomException.class)
    public ResponseEntity<Object> handleValidationException(CustomException ex) {
        if(CollectionUtils.isEmpty(ex.getErrorMessages())) {
            ErrorDto errorDto = ErrorDto.builder()
                    .errorCode(ex.getErrorCode())
                    .errorMessage(ex.getErrorMessage())
                    .build();
            return generateResponseWithErrors(List.of(errorDto));
        }
        return generateResponseWithErrors(ex.getErrorMessages());
    }
    private ResponseEntity<Object> generateResponseWithErrors(List<ErrorDto> errors) {
        return ResponseEntity.ok().body(
                ResponseDto.builder()
                        .status(0)
                        .errors(errors)
                        .build());
    }
}
