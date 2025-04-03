package com.epay.kms.validation;

import javax.validation.Constraint;
import javax.validation.Payload;
import java.lang.annotation.ElementType;
import java.lang.annotation.Retention;
import java.lang.annotation.RetentionPolicy;
import java.lang.annotation.Target;

@Constraint(validatedBy = NoLeadingTrailingSpacesValidator.class)
@Target({ ElementType.FIELD, ElementType.PARAMETER })
@Retention(RetentionPolicy.RUNTIME)
public @interface NoLeadingTrailingSpaces {
    String message() default "Field contains leading, trailing, or multiple consecutive spaces.";
    Class<?>[] groups() default {};
    Class<? extends Payload>[] payload() default {};
}


package com.epay.kms.validation;

import org.apache.commons.lang3.StringUtils;

import javax.validation.ConstraintValidator;
import javax.validation.ConstraintValidatorContext;

public class NoLeadingTrailingSpacesValidator implements ConstraintValidator<NoLeadingTrailingSpaces, String> {

    @Override
    public boolean isValid(String value, ConstraintValidatorContext context) {
        if (StringUtils.isEmpty(value)) {
            return true;  // Accepting empty strings or null, handle this as per your requirement
        }
        
        boolean hasLeadingOrTrailingSpaces = !value.equals(value.trim());
        boolean hasConsecutiveSpaces = value.contains("  ");  // Checks for multiple consecutive spaces
        
        return !(hasLeadingOrTrailingSpaces || hasConsecutiveSpaces);
    }
}


import com.epay.kms.validation.NoLeadingTrailingSpaces;

public class MyRequestDto {

    @NoLeadingTrailingSpaces(message = "Name field contains leading, trailing, or multiple consecutive spaces.")
    private String name;

    // getters and setters
}



@ExceptionHandler(MethodArgumentNotValidException.class)
protected ResponseEntity<Object> handleValidationException(MethodArgumentNotValidException ex) {
    logger.error("Error in handleValidationException with message: {}", ex.getMessage());
    List<ErrorDto> errors = new ArrayList<>();

    ex.getBindingResult().getFieldErrors().forEach(fieldError -> addErrorDto(errors, fieldError));
    
    return ResponseEntity.status(HttpStatus.BAD_REQUEST)
                         .body(KMSResponse.builder().status(RESPONSE_FAILURE).errors(errors).build());
}
