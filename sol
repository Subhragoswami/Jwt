import org.joda.time.DateTime;
import org.joda.time.format.DateTimeFormat;
import org.joda.time.format.DateTimeFormatter;
import java.time.LocalDate;

public class ReportScheduleTimeUtils {

    public static Long calculateNextExecutionTime(Frequency frequency, String time, String generationDate) {
        DateTime currentDateTime = DateTime.now();

        DateTimeFormatter timeFormatter = DateTimeFormat.forPattern("h:mm a");
        DateTime parsedTime = timeFormatter.parseDateTime(time);

        DateTime nextDate;
        if (frequency == Frequency.DAILY) {
            nextDate = currentDateTime.plusDays(1);
        } else if (frequency == Frequency.MONTHLY) {
            int day = Integer.parseInt(generationDate);
            DateTime nextMonth = currentDateTime.plusMonths(1);
            int maxDay = nextMonth.dayOfMonth().getMaximumValue();
            nextDate = nextMonth.withDayOfMonth(Math.min(day, maxDay));
        } else {
            throw new IllegalArgumentException("Invalid frequency: " + frequency);
        }

        return nextDate.withHourOfDay(parsedTime.getHourOfDay())
                       .withMinuteOfHour(parsedTime.getMinuteOfHour())
                       .withSecondOfMinute(0)
                       .withMillisOfSecond(0)
                       .getMillis();
    }

    public static Pair<LocalDate, LocalDate> calculateReportDateRange(String reportDuration, LocalDate executionDate) {
        return switch (reportDuration.toUpperCase()) {
            case "YESTERDAY" -> Pair.of(executionDate.minusDays(1), executionDate.minusDays(1));
            case "LAST_7_DAYS" -> Pair.of(executionDate.minusDays(7), executionDate.minusDays(1));
            case "LAST_30_DAYS" -> Pair.of(executionDate.minusDays(30), executionDate.minusDays(1));
            case "LAST_90_DAYS" -> Pair.of(executionDate.minusDays(90), executionDate.minusDays(1));
            case "CURRENT_MONTH" -> Pair.of(executionDate.withDayOfMonth(1), executionDate.minusDays(1));
            case "PREVIOUS_MONTH" -> {
                LocalDate firstDay = executionDate.minusMonths(1).withDayOfMonth(1);
                LocalDate lastDay = executionDate.withDayOfMonth(1).minusDays(1);
                yield Pair.of(firstDay, lastDay);
            }
            default -> throw new IllegalArgumentException("Invalid report duration: " + reportDuration);
        };
    }
}



public void save(ReportScheduleManagementDto dto) {
    log.info("Saving new report schedule for report: {}", dto.getReport());

    UUID reportId = reportMasterDao.getReportIdByName(dto.getReport());
    dto.setReportId(reportId);
    dto.setStatus(ReportScheduledStatus.TO_BE_START);

    Long nextExecutionTime = ReportScheduleTimeUtils.calculateNextExecutionTime(
        dto.getFrequency(),
        dto.getScheduleExecutionTime(),
        dto.getGenerationDate()
    );
    dto.setNextScheduleExecutionTime(nextExecutionTime);

    ReportScheduleManagement entity = mapper.mapDtoToEntity(dto);
    reportScheduleManagementRepository.save(entity);

    log.info("Report schedule saved successfully with ID: {}", entity.getId());
}




LocalDate executionDate = new DateTime(dto.getNextScheduleExecutionTime()).toLocalDate();
Pair<LocalDate, LocalDate> dateRange = ReportScheduleTimeUtils.calculateReportDateRange(dto.getReportDuration(), executionDate);
log.info("Report data will cover: {} to {}", dateRange.getLeft(), dateRange.getRight());
