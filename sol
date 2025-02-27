@Test
void testGetHelpSupports() {
    String mId = "testMId";

    // Create active HelpSupport entry
    HelpSupport activeSupport = new HelpSupport();
    activeSupport.setMId(mId);
    activeSupport.setType(HelpSupportType.EMAIL);
    activeSupport.setStatus(STATUS_ACTIVE);

    // Create default HelpSupport entry (without mId)
    HelpSupport defaultSupport = new HelpSupport();
    defaultSupport.setMId(null);
    defaultSupport.setType(HelpSupportType.EMAIL);
    defaultSupport.setStatus(STATUS_ACTIVE);

    // Lists returned by repository
    List<HelpSupport> activeSupports = List.of(activeSupport);
    List<HelpSupport> missingDefaultSupport = List.of(defaultSupport);

    // Create DTOs for mapping
    HelpSupportDto activeDto = new HelpSupportDto();
    activeDto.setType(HelpSupportType.EMAIL);
    HelpSupportDto defaultDto = new HelpSupportDto();
    defaultDto.setType(HelpSupportType.EMAIL);

    // Mock repository calls
    when(helpSupportRepository.findBymIdAndStatus(mId, STATUS_ACTIVE)).thenReturn(activeSupports);
    when(helpSupportRepository.findBymIdIsNullAndStatusAndType(STATUS_ACTIVE, HelpSupportType.EMAIL))
            .thenReturn(missingDefaultSupport);

    // Mock mapper
    when(helpSupportMapper.mapEntityListToDtoList(any())).thenReturn(List.of(activeDto, defaultDto));

    // Execute method
    List<HelpSupportDto> result = helpSupportDao.getHelpSupports(mId);

    // Validate results
    assertNotNull(result);
    assertEquals(2, result.size());
    assertEquals(HelpSupportType.EMAIL, result.get(0).getType());
    assertEquals(HelpSupportType.EMAIL, result.get(1).getType());

    // Verify mock interactions
    verify(helpSupportRepository, times(1)).findBymIdAndStatus(mId, STATUS_ACTIVE);
    verify(helpSupportRepository, times(1)).findBymIdIsNullAndStatusAndType(STATUS_ACTIVE, HelpSupportType.EMAIL);
    verify(helpSupportMapper, times(1)).mapEntityListToDtoList(any());
}






@Test
void testGetHelpSupports() {
    String mId = "testMId";

    // Create active HelpSupport entry
    HelpSupport activeSupport = new HelpSupport();
    activeSupport.setMId(mId);
    activeSupport.setType(HelpSupportType.EMAIL);
    activeSupport.setStatus(STATUS_ACTIVE);

    // Create default HelpSupport entry (without mId)
    HelpSupport defaultSupport = new HelpSupport();
    defaultSupport.setMId(null);
    defaultSupport.setType(HelpSupportType.EMAIL);
    defaultSupport.setStatus(STATUS_ACTIVE);

    // Use mutable lists
    List<HelpSupport> activeSupports = new ArrayList<>(List.of(activeSupport));
    List<HelpSupport> missingDefaultSupport = new ArrayList<>(List.of(defaultSupport));

    // Create DTOs for mapping
    HelpSupportDto activeDto = new HelpSupportDto();
    activeDto.setType(HelpSupportType.EMAIL);
    HelpSupportDto defaultDto = new HelpSupportDto();
    defaultDto.setType(HelpSupportType.EMAIL);

    // Mock repository calls
    when(helpSupportRepository.findBymIdAndStatus(mId, STATUS_ACTIVE)).thenReturn(activeSupports);
    when(helpSupportRepository.findBymIdIsNullAndStatusAndType(STATUS_ACTIVE, HelpSupportType.EMAIL))
            .thenReturn(missingDefaultSupport);

    // Mock mapper
    when(helpSupportMapper.mapEntityListToDtoList(any())).thenReturn(List.of(activeDto, defaultDto));

    // Execute method
    List<HelpSupportDto> result = helpSupportDao.getHelpSupports(mId);

    // Validate results
    assertNotNull(result);
    assertEquals(2, result.size());
    assertEquals(HelpSupportType.EMAIL, result.get(0).getType());
    assertEquals(HelpSupportType.EMAIL, result.get(1).getType());

    // Verify mock interactions
    verify(helpSupportRepository, times(1)).findBymIdAndStatus(mId, STATUS_ACTIVE);
    verify(helpSupportRepository, times(1)).findBymIdIsNullAndStatusAndType(STATUS_ACTIVE, HelpSupportType.EMAIL);
    verify(helpSupportMapper, times(1)).mapEntityListToDtoList(any());
}
