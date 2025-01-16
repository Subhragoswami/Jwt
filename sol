 public static Long calculateDateByFrequency(Frequency frequency, String time){
        DateTimeFormatter formatter = DateTimeFormatter.ofPattern("h:mm a");
        LocalTime reqTime = LocalTime.parse(time.trim().toLowerCase(Locale.ROOT), formatter);

        LocalDateTime now = LocalDateTime.now();
        LocalDateTime nextDateTime;
        switch (frequency){
            case Frequency.DAILY -> nextDateTime = now.toLocalTime().isAfter(reqTime)
                    ? LocalDateTime.of(now.toLocalDate().plusDays(1), reqTime)
                    : LocalDateTime.of(now.toLocalDate(), reqTime);
            case Frequency.MONTHLY -> nextDateTime = now.toLocalTime().isAfter(reqTime)
                    ? LocalDateTime.of(now.toLocalDate().plusMonths(1).withDayOfMonth(30), reqTime)
                    : LocalDateTime.of(now.toLocalDate().withDayOfMonth(30), reqTime);
            case Frequency.YEARLY -> nextDateTime = now.toLocalTime().isAfter(reqTime)
                    ? LocalDateTime.of(now.toLocalDate().plusYears(1).withDayOfYear(1), reqTime)
                    : LocalDateTime.of(now.toLocalDate().withDayOfYear(1), reqTime);
            default -> throw new IllegalArgumentException("Invalid Frequency :"+frequency);
        }
        return nextDateTime.atZone(ZoneId.systemDefault()).toInstant().toEpochMilli();
    }




public static Long calculateDateByFrequency(Frequency frequency, Long timeInMillis) {
    // Convert long to LocalTime
    LocalDateTime inputDateTime = Instant.ofEpochMilli(timeInMillis)
            .atZone(ZoneId.systemDefault())
            .toLocalDateTime();
    LocalTime reqTime = inputDateTime.toLocalTime();

    LocalDateTime now = LocalDateTime.now();
    LocalDateTime nextDateTime;

    switch (frequency) {
        case DAILY -> nextDateTime = now.toLocalTime().isAfter(reqTime)
                ? LocalDateTime.of(now.toLocalDate().plusDays(1), reqTime)
                : LocalDateTime.of(now.toLocalDate(), reqTime);
        case MONTHLY -> nextDateTime = now.toLocalTime().isAfter(reqTime)
                ? LocalDateTime.of(now.toLocalDate().plusMonths(1).withDayOfMonth(
                    Math.min(now.toLocalDate().plusMonths(1).lengthOfMonth(), 30)), reqTime)
                : LocalDateTime.of(now.toLocalDate().withDayOfMonth(
                    Math.min(now.toLocalDate().lengthOfMonth(), 30)), reqTime);
        case YEARLY -> nextDateTime = now.toLocalTime().isAfter(reqTime)
                ? LocalDateTime.of(now.toLocalDate().plusYears(1).withDayOfYear(1), reqTime)
                : LocalDateTime.of(now.toLocalDate().withDayOfYear(1), reqTime);
        default -> throw new IllegalArgumentException("Invalid Frequency: " + frequency);
    }

    return nextDateTime.atZone(ZoneId.systemDefault()).toInstant().toEpochMilli();
}