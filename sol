
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageImpl;
import org.springframework.data.domain.Pageable;
import org.springframework.jdbc.core.BeanPropertyRowMapper;
import org.springframework.jdbc.core.namedparam.MapSqlParameterSource;
import org.springframework.jdbc.core.namedparam.NamedParameterJdbcTemplate;
import org.springframework.dao.EmptyResultDataAccessException;

import java.util.List;

public Page<RecentTransactionReport> getRecentTransactionSummaryDailyOrMonthly(String mId, RecentTransactionRequest recentTransactionRequest, Pageable pageable) {
    try {
        String sql = TransactionDashboardQueries.JDBC_DAILY_RECENT_TRANSACTION;
        if (Frequency.MONTHLY.name().equalsIgnoreCase(recentTransactionRequest.getFrequency())) {
            sql = TransactionDashboardQueries.JDBC_MONTHLY_RECENT_TRANSACTION;
        }

        // Fetch total count for pagination
        String countSql = "SELECT COUNT(*) FROM (" + sql + ") AS temp"; // Wrapping in a subquery

        MapSqlParameterSource parameters = new MapSqlParameterSource();
        parameters.addValue("mId", mId);
        parameters.addValue("fromDate", recentTransactionRequest.getFromDate());
        parameters.addValue("toDate", recentTransactionRequest.getToDate());
        parameters.addValue("first", pageable.getPageSize());
        parameters.addValue("offset", pageable.getPageNumber() * pageable.getPageSize());

        // Fetch paginated results
        List<RecentTransactionReport> transactionList = namedParameterJdbcTemplate.query(
            sql, parameters, new BeanPropertyRowMapper<>(RecentTransactionReport.class)
        );

        // Get total count
        Long totalCount = namedParameterJdbcTemplate.queryForObject(countSql, parameters, Long.class);

        return new PageImpl<>(transactionList, pageable, totalCount != null ? totalCount : 0);

    } catch (EmptyResultDataAccessException e) {
        throw new ReportingException(ErrorConstants.NOT_FOUND_ERROR_CODE, 
            MessageFormat.format(ErrorConstants.NOT_FOUND_ERROR_MESSAGE, "TRANSACTION"));
    }
}