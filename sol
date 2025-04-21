private Page<AlertManagementResponse> getLatestAlertDescription(String mId, boolean getAll, Pageable pageable) {
    // Get user roles
    List<String> userRoles = List.of("USER"); // Replace with actual user role fetching logic
    boolean isUser = checkIsUserRole(userRoles);

    Page<AlertManagement> alertManagementList;

    if (isUser) {
        // Get excluded alert IDs (e.g., ACCOUNT_EXPIRY)
        List<AlertMasterDto> accountExpiryAlerts = findAllAlertByName(ACCOUNT_EXPIRY);
        List<UUID> excludedAlertIds = collectAlertMasterId(accountExpiryAlerts);

        // Fetch filtered alerts with pagination
        alertManagementList = alertManagementRepository.findFilteredAlertsForUser(mId, excludedAlertIds, pageable);
    } else {
        // Fetch alerts normally
        alertManagementList = getAll
                ? alertManagementRepository.findByMId(mId, pageable)
                : alertManagementRepository.findUnreadAlertsByMId(mId, pageable);
    }

    List<AlertManagementResponse> responses = alertMapper.alertManagementEntityToResponse(alertManagementList.getContent());
    return new PageImpl<>(responses, pageable, alertManagementList.getTotalElements());
}





Page<AlertManagement> findByMId(String mId, Pageable pageable);
Page<AlertManagement> findUnreadAlertsByMId(String mId, Pageable pageable);



@Query("SELECT a FROM AlertManagement a WHERE a.mId = :mId AND a.alertId NOT IN :excludedAlertIds")
Page<AlertManagement> findFilteredAlertsForUser(@Param("mId") String mId,
                                                @Param("excludedAlertIds") List<UUID> excludedAlertIds,
                                                Pageable pageable);
