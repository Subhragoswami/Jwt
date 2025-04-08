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
