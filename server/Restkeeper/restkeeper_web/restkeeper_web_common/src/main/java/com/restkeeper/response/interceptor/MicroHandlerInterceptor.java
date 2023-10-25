package com.restkeeper.response.interceptor;/*
 *@author 周欢
 *@version 1.0
 */

import com.restkeeper.tenant.TenantContext;
import io.micrometer.core.lang.Nullable;
import lombok.extern.slf4j.Slf4j;
import org.springframework.web.servlet.HandlerInterceptor;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.util.HashMap;
import java.util.Map;

@Slf4j
public class MicroHandlerInterceptor implements HandlerInterceptor {

    /**
     * 请求方法执行之前
     * 返回true则通过
     * @param request
     * @param response
     * @param handler
     * @return
     */
    @Override
    public boolean preHandle(HttpServletRequest request, HttpServletResponse response, Object handler) {
        Map<String,Object> map =new HashMap<>();
        map.put("shopId",request.getHeader("shopId"));
        map.put("storeId",request.getHeader("storeId"));
        map.put("tableId",request.getHeader("tableId"));
        TenantContext.addAttachments(map);
        return true;
    }

    @Override
    public void afterCompletion(HttpServletRequest request, HttpServletResponse response, Object handler,
                                @Nullable Exception ex) throws Exception {
        TenantContext.clear();
    }

}
