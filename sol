package com.epay.kms.validation;

import org.apache.commons.lang3.StringUtils;

import javax.validation.ConstraintValidator;
import javax.validation.ConstraintValidatorContext;

public class NoLeadingTrailingSpacesValidator implements ConstraintValidator<NoLeadingTrailingSpaces, String> {

    private String errorCode;

    @Override
    public void initialize(NoLeadingTrailingSpaces constraintAnnotation) {
        this.errorCode = constraintAnnotation.errorCode();  // Retrieve errorCode from annotation
    }

    @Override
    public boolean isValid(String value, ConstraintValidatorContext context) {
        if (StringUtils.isEmpty(value)) {
            return true;
        }
        
        boolean hasLeadingOrTrailingSpaces = !value.equals(value.trim());
        boolean hasConsecutiveSpaces = value.contains("  ");
        
        if (hasLeadingOrTrailingSpaces || hasConsecutiveSpaces) {
            // Add custom error code to the context message if needed
            context.disableDefaultConstraintViolation();
            context.buildConstraintViolationWithTemplate(errorCode)
                   .addConstraintViolation();
            return false;
        }
        
        return true;
    }
}
