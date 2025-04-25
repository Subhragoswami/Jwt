/**
 * Merges only the non-null fields from the update request into the existing report schedule entity.
 *
 * For each field in the update request:
 * - If it is non-null, it overrides the corresponding field in the entity.
 * - If it is null, the existing field value is retained.
 *
 * Uses Optional.ofNullable(...).ifPresent(...) to perform null-checks and conditional assignments.
 *
 * @param reportScheduleManagement The existing report schedule entity to update.
 * @param request The update request object that may contain new values.
 */
private void mergeNonNullFields(ReportScheduleManagement reportScheduleManagement, ReportScheduleManagementUpdateRequest request) {
    Optional.ofNullable(request.getFormat()).ifPresent(reportScheduleManagement::setFormat);
    Optional.ofNullable(request.getFrequency()).ifPresent(reportScheduleManagement::setFrequency);
    Optional.ofNullable(request.getScheduleExecutionTime()).ifPresent(reportScheduleManagement::setScheduleExecutionTime);
    Optional.ofNullable(request.getScheduleExecutionDate()).ifPresent(reportScheduleManagement::setScheduleExecutionDate);
}




public static Pair<LocalDate, LocalDate> calculateReportDateRange(String reportDuration, LocalDate executionDate) {
    ReportDuration durationEnum = ReportDuration.fromString(reportDuration);
    return durationEnum.calculateRange(executionDate);
}



public enum ReportDuration {
    YESTERDAY(1),
    LAST_7_DAYS(7),
    LAST_30_DAYS(30),
    LAST_90_DAYS(90),
    CURRENT_MONTH(0),
    PREVIOUS_MONTH(0); // Special handling for this

    private final int days;

    ReportDuration(int days) {
        this.days = days;
    }

    public Pair<LocalDate, LocalDate> calculateRange(LocalDate executionDate) {
        return switch (this) {
            case YESTERDAY, LAST_7_DAYS, LAST_30_DAYS, LAST_90_DAYS ->
                    Pair.of(executionDate.minusDays(days), executionDate);

            case CURRENT_MONTH ->
                    Pair.of(executionDate.withDayOfMonth(1), executionDate);

            case PREVIOUS_MONTH -> {
                LocalDate firstDay = executionDate.minusMonths(1).withDayOfMonth(1);
                LocalDate lastDay = executionDate.withDayOfMonth(1);
                yield Pair.of(firstDay, lastDay);
            }
        };
    }

    public static ReportDuration fromString(String duration) {
        return Arrays.stream(values())
                .filter(d -> d.name().equalsIgnoreCase(duration))
                .findFirst()
                .orElseThrow(() -> new IllegalArgumentException("Invalid report duration: " + duration));
    }
}
