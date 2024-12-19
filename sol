    @GetMapping("/users/{mid}")
    @Operation(summary = "share the all users info for that merchant.", description = "share the all users info for that merchant.")
    public MerchantResponse<MerchantUserResponse> getAllUser(@PathVariable String mid,
                                                             @PageableDefault Pageable pageable) {
        log.info("Received request to get userList based on mid: {}", mid);
        return adminService.getAllUser(mid, pageable);


Query Parameters


        
      
page: (Integer) Optional. The page number for pagination. Defaults to 0 if not provided. 

        
      
size: (Integer) Optional. The size of the page. Default value is 50, with a minimum value of 50 and a maximum value of 100 (configured in application properties). 
