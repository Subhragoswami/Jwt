public class AlertManagement extends AuditEntity {
    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;
    private UUID alertId;
    @Column(name = "MID")
    private String mId;
    private String description;
    private boolean isViewed;

}

 @Query("SELECT a FROM AlertManagement a WHERE a.isViewed = false AND a.mId = :mId")
    List<String> findLatestAlertDescriptions(Pageable pageable, @Param("mId") String mId);
