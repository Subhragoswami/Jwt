@Query("""
    SELECT k FROM KmsManagement k 
    WHERE k.mId = :mId 
    ORDER BY 
        CASE 
            WHEN k.status = :status THEN 1
            ELSE 2
        END, 
        k.createdAt DESC
""")
Page<KmsManagement> findByMIdWithPriorityStatus(
    @Param("mId") String mId,
    @Param("status") KeyStatus status,
    Pageable pageable
);
