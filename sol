public Page<AlertManagementResponse> getLatestAlertsPage(String mId, Pageable pageable) {
    Page<AlertManagement> alertManagementPage = alertManagementRepository.findByMId(mId, pageable);
    List<String> userRoles = EPayIdentityUtil.getUserPrincipal().getUserRole();

    List<AlertManagement> filteredAlerts = alertManagementPage.toList();
    if (checkIsUserRole(userRoles)) {
        List<AlertMasterDto> accountExpiryAlerts = findAllAlertByName(ACCOUNT_EXPIRY);
        filteredAlerts = filterAlertsForUserRole(filteredAlerts, collectAlertMasterId(accountExpiryAlerts));
    }

    List<AlertManagementResponse> responses = alertMapper.alertManagementEntityToResponse(filteredAlerts);
    return new PageImpl<>(responses, pageable, alertManagementPage.getTotalElements());
}






/**
 * Retrieves all alerts for a given merchant ID (mId), with pagination.
 *
 * @param mId The merchant ID for which the alerts are to be fetched.
 * @param pageable Pageable object for pagination settings.
 * @return A page of AlertManagementResponse objects representing all alerts for the given merchant ID.
 */
public Page<AlertManagementResponse> getAllAlerts(String mId, Pageable pageable) {
    return getLatestAlertDescription(mId, true, pageable);
}

/**
 * Retrieves only unread alerts for a given merchant ID (mId), with pagination.
 *
 * @param mId The merchant ID for which the unread alerts are to be fetched.
 * @param pageable Pageable object for pagination settings.
 * @return A page of AlertManagementResponse objects representing unread alerts for the given merchant ID.
 */
public Page<AlertManagementResponse> getUnreadAlerts(String mId, Pageable pageable) {
    return getLatestAlertDescription(mId, false, pageable);
}