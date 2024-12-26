package pi.com.calendarservice.config;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Component;
import org.springframework.web.servlet.HandlerInterceptor;
import pi.com.calendarservice.util.TokenExtractor;

@Component
public class TokenValidationInterceptor implements HandlerInterceptor {

    @Override
    public boolean preHandle(HttpServletRequest request, HttpServletResponse response, Object handler) throws Exception {
        String accessTokenHeader = request.getHeader("Authorization");
        System.out.println("Access token header: " + accessTokenHeader);
//        System.out.println("Access token header: " + accessTokenHeader);
        String accessToken = TokenExtractor.extractToken(accessTokenHeader);
        System.out.println("Access token: " + accessToken);
        if (accessToken == null) {
            System.out.println("Access token is null");
            response.setStatus(HttpStatus.UNAUTHORIZED.value());
            return false;
        }
        // Set the access token in the request attributes for later use in controller methods
        request.setAttribute("accessToken", accessToken);
        return true;
    }

}
