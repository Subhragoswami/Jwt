@NotBlank(message = MANDATORY_FIELD)
private String generationDate; // "1" to "28", only required if frequency is MONTHLY

@NotBlank(message = MANDATORY_FIELD)
private String reportDuration; // e.g., "YESTERDAY", "LAST_7_DAYS", etc.

private String generationDate;
private String reportDuration;

@Column(name = "GENERATION_DATE")
private String generationDate;

@Column(name = "REPORT_DURATION")
private String reportDuration;


LocalDate nextExecutionDate = ReportDateRangeCalculator.getNextExecutionDate(
    reportScheduleManagementDto.getFrequency(),
    reportScheduleManagementDto.getScheduleExecutionTime(),
    reportScheduleManagementDto.getGenerationDate()
);

reportScheduleManagementDto.setNextScheduleExecutionTime(
    nextExecutionDate.atTime(LocalTime.parse(reportScheduleManagementDto.getScheduleExecutionTime(), DateTimeFormatter.ofPattern("h:mm a")))
                    .atZone(ZoneId.systemDefault()).toInstant().toEpochMilli()
);



public class ReportDateRangeCalculator {

    public static Pair<LocalDate, LocalDate> calculateRange(String reportDuration, LocalDate runDate) {
        return switch (reportDuration.toUpperCase()) {
            case "YESTERDAY" -> Pair.of(runDate.minusDays(1), runDate.minusDays(1));
            case "LAST_7_DAYS" -> Pair.of(runDate.minusDays(7), runDate.minusDays(1));
            case "LAST_30_DAYS" -> Pair.of(runDate.minusDays(30), runDate.minusDays(1));
            case "LAST_90_DAYS" -> Pair.of(runDate.minusDays(90), runDate.minusDays(1));
            case "CURRENT_MONTH" -> Pair.of(runDate.withDayOfMonth(1), runDate.minusDays(1));
            case "PREVIOUS_MONTH" -> {
                LocalDate firstDay = runDate.minusMonths(1).withDayOfMonth(1);
                LocalDate lastDay = runDate.withDayOfMonth(1).minusDays(1);
                yield Pair.of(firstDay, lastDay);
            }
            default -> throw new IllegalArgumentException("Invalid report duration: " + reportDuration);
        };
    }

    public static LocalDate getNextExecutionDate(Frequency frequency, String time, String generationDate) {
        LocalDate today = LocalDate.now();
        return switch (frequency) {
            case DAILY -> today.plusDays(1);
            case MONTHLY -> {
                int day = Integer.parseInt(generationDate);
                LocalDate nextMonth = today.plusMonths(1);
                yield nextMonth.withDayOfMonth(Math.min(day, nextMonth.lengthOfMonth()));
            }
            default -> throw new IllegalArgumentException("Invalid frequency: " + frequency);
        };
    }
}
