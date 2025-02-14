import java.time.YearMonth;
import java.time.format.DateTimeFormatter;
import java.time.format.DateTimeParseException;
import java.util.List;
import java.util.Locale;
import java.util.Map;
import java.util.stream.Collectors;

public class DateValidator {
    private static final DateTimeFormatter FORMATTER = DateTimeFormatter.ofPattern("MMM-yyyy", Locale.ENGLISH);

    public static Map<String, String> validateAndConvertDateList(List<String> dateList) {
        // Validate & Convert Dates
        Map<String, String> dateMap = dateList.stream()
                .collect(Collectors.toMap(
                        date -> date, // Original date
                        DateValidator::convertToYearMonthFormat, // Converted format
                        (existing, replacement) -> existing // Handle duplicates if any
                ));

        // Find invalid dates
        List<String> invalidDates = dateMap.entrySet().stream()
                .filter(entry -> entry.getValue() == null) // If conversion failed
                .map(Map.Entry::getKey)
                .collect(Collectors.toList());

        if (!invalidDates.isEmpty()) {
            throw new IllegalArgumentException("Invalid date formats: " + invalidDates + ". Expected format: Mon-YYYY (e.g., Feb-2025)");
        }

        return dateMap; // Return valid converted dates
    }

    private static String convertToYearMonthFormat(String date) {
        try {
            return YearMonth.parse(date, FORMATTER).toString(); // Converts to "YYYY-MM"
        } catch (DateTimeParseException e) {
            return null; // Mark as invalid
        }
    }

    public static void main(String[] args) {
        List<String> dates = List.of("Feb-2025", "Mar-2024", "2025-Feb", "Apr-2023");

        try {
            Map<String, String> convertedDates = validateAndConvertDateList(dates);
            System.out.println("Valid Dates (Original -> Converted): " + convertedDates);
        } catch (IllegalArgumentException e) {
            System.err.println(e.getMessage());
        }
    }
}
