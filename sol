@Test
void testIsMerchantExistByMId() {
    String mId = "MID123";
    when(merchantRepo.existsBymIdAndStatus(mId, MerchantStatus.ACTIVE.name())).thenReturn(true);

    boolean exists = adminDao.isMerchantExistByMId(mId);

    assertEquals(true, exists);
}

@Test
void testIsMerchantUserExist() {
    when(merchantUserDao.existsByUserNameOrEmailOrMobilePhoneAndStatus("user", "email", "phone", UserStatus.ACTIVE))
            .thenReturn(true);

    boolean exists = adminDao.isMerchantUserExist("user", "email", "phone");

    assertEquals(true, exists);
}

@Test
void testIsMerchantUserExistWithRoles() {
    when(merchantUserDao.existsByUserNameOrEmailOrMobilePhoneAndRoles("user", List.of("ROLE_ADMIN")))
            .thenReturn(true);

    boolean exists = adminDao.isMerchantUserExistWithRoles("user", List.of("ROLE_ADMIN"));

    assertEquals(true, exists);
}

@Test
void testIsMerchantUserExistWithRolesById() {
    UUID userId = UUID.randomUUID();
    when(merchantUserDao.existsByUserIdAndRoles(userId, List.of("ROLE_USER"))).thenReturn(true);

    boolean exists = adminDao.isMerchantUserExistWithRoles(userId, List.of("ROLE_USER"));

    assertEquals(true, exists);
}


@Test
void testFindMappedEntityMIds() {
    List<String> mIds = List.of("MID1", "MID2");
    when(merchantEntityGroupRepository.findExistingMIds(mIds)).thenReturn(mIds);

    List<String> result = adminDao.findMappedEntityMIds(mIds);

    assertEquals(mIds, result);
}

@Test
void testFindInvalidsMIds() {
    List<String> allMIds = List.of("MID1", "MID2", "MID3");
    List<String> activeMIds = List.of("MID1", "MID2");
    when(merchantRepo.findActiveMIds(allMIds)).thenReturn(activeMIds);

    List<String> invalidMIds = adminDao.findInvalidsMIds(allMIds);

    assertEquals(List.of("MID3"), invalidMIds);
}

@Test
void testIsEntityIdPresent() {
    String entityId = "ENTITY123";
    when(merchantEntityGroupRepository.existsByEntityId(entityId)).thenReturn(true);

    boolean exists = adminDao.isEntityIdPresent(entityId);

    assertEquals(true, exists);
}

@Test
void testSaveMerchantEntityGroup() {
    MerchantEntityGroupDto dto = new MerchantEntityGroupDto();
    dto.setEntityId("ENTITY123");
    dto.setMIds(List.of("MID1", "MID2"));

    MerchantEntityGroup group1 = new MerchantEntityGroup("ENTITY123", "MID1");
    MerchantEntityGroup group2 = new MerchantEntityGroup("ENTITY123", "MID2");

    when(merchantEntityGroupRepository.saveAll(Mockito.anyList())).thenReturn(List.of(group1, group2));

    MerchantEntityGroupDto result = adminDao.saveMerchantEntityGroup(dto);

    assertEquals(dto, result);
}

@Test
void testUpdateUserRole() {
    UUID userId = UUID.randomUUID();
    String userName = "user123";
    String entityId = "ENTITY123";

    adminDao.updateUserRole(userId, userName, entityId);

    Mockito.verify(merchantUserDao, Mockito.times(1)).updateMerchantUserRole(userId, userName, entityId);
}


@Test
void testSaveFooterRequest() {
    FotterRequest request = new FotterRequest();
    FooterDto dto = new FooterDto("LABEL1", "VALUE1");
    request.setFooterLabels(List.of(dto));

    Footer footer = new Footer();
    footer.setLabel("LABEL1");
    footer.setValue("VALUE1");

    when(footerRepository.findByLabel("LABEL1")).thenReturn(Optional.of(footer));
    when(footerRepository.save(footer)).thenReturn(footer);

    adminDao.saveFooterRequest(request);

    Mockito.verify(footerRepository, Mockito.times(1)).save(footer);
}
