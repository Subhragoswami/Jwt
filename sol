    @Transient
    @Schema(name = "mId", example = "MID6")
    private String mId;
    @Schema(name = "aggregatorId", example = "SBIEPAY")
    private String aggregatorId;
    @Schema(name = "type", description = "Valid HelpSupportType are PHONE_NUMBER, EMAIL", example = "EMAIL")
    private HelpSupportType type;
    @Schema(name = "value", example = "test@gmail.com")
    private List<String> value;
    private boolean status;
