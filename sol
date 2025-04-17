@Test
void testIsValidMerchantUserExists_ValidUser() {
    String userName = "testuser";
    List<UserStatus> statuses = List.of(UserStatus.ACTIVE);

    when(merchantUserDao.existsByUserNameOrEmailOrMobilePhoneAndStatus(userName, userName, userName, statuses))
        .thenReturn(true);

    boolean result = otpManagementDao.isValidMerchantUserExists(userName, statuses);

    assertTrue(result);
    verify(merchantUserDao).existsByUserNameOrEmailOrMobilePhoneAndStatus(userName, userName, userName, statuses);
}
