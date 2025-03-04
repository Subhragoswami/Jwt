import jakarta.validation.Constraint;
import jakarta.validation.Payload;
import java.lang.annotation.*;

@Documented
@Constraint(validatedBy = EnumValidator.class)
@Target({ ElementType.FIELD, ElementType.PARAMETER })
@Retention(RetentionPolicy.RUNTIME)
public @interface ValidEnum {
    Class<? extends Enum<?>> enumClass();
    String message() default "Invalid value. Allowed values: {enumClass}";
    Class<?>[] groups() default {};
    Class<? extends Payload>[] payload() default {};
}



import jakarta.validation.ConstraintValidator;
import jakarta.validation.ConstraintValidatorContext;
import java.util.Arrays;

public class EnumValidator implements ConstraintValidator<ValidEnum, String> {
    private Enum<?>[] enumValues;

    @Override
    public void initialize(ValidEnum annotation) {
        enumValues = annotation.enumClass().getEnumConstants();
    }

    @Override
    public boolean isValid(String value, ConstraintValidatorContext context) {
        if (value == null) {
            return false; // Null is not allowed
        }
        return Arrays.stream(enumValues)
                     .anyMatch(enumValue -> enumValue.name().equals(value));
    }
}