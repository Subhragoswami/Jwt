import com.fasterxml.jackson.core.JsonFactory;
import com.fasterxml.jackson.core.JsonParser;
import com.fasterxml.jackson.core.JsonToken;
import jakarta.servlet.*;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.springframework.stereotype.Component;
import org.springframework.web.util.ContentCachingRequestWrapper;

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
            ContentCachingRequestWrapper wrappedRequest = new ContentCachingRequestWrapper(httpRequest);

            // Read request body from cached content
            String requestBody = new String(wrappedRequest.getContentAsByteArray(), wrappedRequest.getCharacterEncoding());

            if (hasDuplicateKeys(requestBody)) {
                httpResponse.sendError(HttpServletResponse.SC_BAD_REQUEST, "Duplicate keys found in JSON request");
                return; // Stop request processing
            }

            chain.doFilter(wrappedRequest, response); // Continue with wrapped request
            return;
        }

        chain.doFilter(request, response); // Continue request processing if not JSON
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
