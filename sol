public void validateRequestMonths(List<String> dates) {
    errorDtoList = new ArrayList<>();
    YearMonth currentMonth = YearMonth.now();

    for (String d : dates) {
        try {
            YearMonth yearMonth = YearMonth.parse(d, FORMATTER);

            // Validate future date
            if (yearMonth.isAfter(currentMonth)) {
                errorDtoList.add(ErrorDto.builder()
                        .errorCode(ErrorConstants.INVALID_REQUEST_DATE_CODE)
                        .errorMessage(ErrorConstants.INVALID_REQUEST_DATE_MESSAGE)
                        .build());
            }

            // Validate year range
            int year = yearMonth.getYear();
            if (year < 1900 || year > currentMonth.getYear()) { // you can adjust the lower bound
                errorDtoList.add(ErrorDto.builder()
                        .errorCode(ErrorConstants.INVALID_YEAR_CODE)
                        .errorMessage(ErrorConstants.INVALID_YEAR_MESSAGE)
                        .build());
            }

        } catch (DateTimeParseException e) {
            errorDtoList.add(ErrorDto.builder()
                    .errorCode(ErrorConstants.DATE_FORMAT_ERROR_CODE)
                    .errorMessage(MessageFormat.format(ErrorConstants.DATE_FORMAT_ERROR_MESSAGE, "MMM-yyyy"))
                    .build());
        }
    }

    throwIfErrors();
}




public void validateRequestMonths(List<String> dates) {
    errorDtoList = new ArrayList<>();
    YearMonth currentMonth = YearMonth.now();

    for (String d : dates) {
        try {
            YearMonth yearMonth = YearMonth.parse(d, FORMATTER);
            int year = yearMonth.getYear();

            // Validate year range (adjust lower bound as needed)
            if (year < 1900 || year > currentMonth.getYear()) {
                errorDtoList.add(ErrorDto.builder()
                        .errorCode(ErrorConstants.INVALID_YEAR_CODE)
                        .errorMessage(ErrorConstants.INVALID_YEAR_MESSAGE)
                        .build());
                continue;
            }

            // Validate future month only if year is the current year
            if (year == currentMonth.getYear() && yearMonth.getMonthValue() > currentMonth.getMonthValue()) {
                errorDtoList.add(ErrorDto.builder()
                        .errorCode(ErrorConstants.INVALID_REQUEST_DATE_CODE)
                        .errorMessage(ErrorConstants.INVALID_REQUEST_DATE_MESSAGE)
                        .build());
            }

        } catch (DateTimeParseException e) {
            errorDtoList.add(ErrorDto.builder()
                    .errorCode(ErrorConstants.DATE_FORMAT_ERROR_CODE)
                    .errorMessage(MessageFormat.format(ErrorConstants.DATE_FORMAT_ERROR_MESSAGE, "MMM-yyyy"))
                    .build());
        }
    }

    throwIfErrors();
}
