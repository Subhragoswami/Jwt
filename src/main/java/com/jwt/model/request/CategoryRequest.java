package com.jwt.model.request;

import com.fasterxml.jackson.annotation.JsonInclude;
import lombok.*;

import java.util.UUID;

@AllArgsConstructor
@Getter
@Setter
@Builder
@NoArgsConstructor
@JsonInclude(JsonInclude.Include.NON_NULL)
public class CategoryRequest {
    private String categoryTitle;
    private String categoryDescription;
    private UUID userId;
}
