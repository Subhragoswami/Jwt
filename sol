import com.fasterxml.jackson.databind.DeserializationFeature;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.http.converter.json.Jackson2ObjectMapperBuilder;

@Configuration
public class JacksonConfig {

    @Bean
    public Jackson2ObjectMapperBuilderCustomizer jacksonCustomizer() {
        return builder -> builder.featuresToEnable(DeserializationFeature.FAIL_ON_READING_DUP_TREE_KEY);
    }
}


import com.fasterxml.jackson.core.JsonFactory;
import com.fasterxml.jackson.core.JsonParser;
import com.fasterxml.jackson.core.JsonToken;
import jakarta.servlet.*;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.springframework.stereotype.Component;

import java.io.BufferedReader;
import java.io.IOException;
import java.util.HashSet;
import java.util.Set;

@Component
public class DuplicateKeyValidationFilter implements Filter {

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain) throws IOException, ServletException {
        HttpServletRequest httpRequest = (HttpServletRequest) request;
        HttpServletResponse httpResponse = (HttpServletResponse) response;

        // Only process JSON requests
        if (httpRequest.getContentType() != null && httpRequest.getContentType().contains("application/json")) {
            StringBuilder requestBody = new StringBuilder();
            try (BufferedReader reader = httpRequest.getReader()) {
                String line;
                while ((line = reader.readLine()) != null) {
                    requestBody.append(line);
                }
            }

            if (hasDuplicateKeys(requestBody.toString())) {
                httpResponse.sendError(HttpServletResponse.SC_BAD_REQUEST, "Duplicate keys found in JSON request");
                return; // Stop request processing
            }
        }

        chain.doFilter(request, response); // Continue request processing if no duplicates
    }

    private boolean hasDuplicateKeys(String json) throws IOException {
        Set<String> keys = new HashSet<>();
        JsonFactory factory = new JsonFactory();
        try (JsonParser parser = factory.createParser(json)) {
            while (parser.nextToken() != JsonToken.END_OBJECT) {
                if (parser.getCurrentToken() == JsonToken.FIELD_NAME) {
                    String fieldName = parser.getCurrentName();
                    if (!keys.add(fieldName)) {
                        return true; // Duplicate key detected
                    }
                }
            }
        }
        return false;
    }
}