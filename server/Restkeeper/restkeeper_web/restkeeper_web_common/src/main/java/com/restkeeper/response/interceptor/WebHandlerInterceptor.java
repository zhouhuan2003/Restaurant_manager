package com.restkeeper.response.interceptor;/*
 *@author 周欢
 *@version 1.0
 */

import com.restkeeper.tenant.TenantContext;
import com.restkeeper.utils.JWTUtil;
import lombok.extern.slf4j.Slf4j;
import org.apache.commons.lang.StringUtils;
import org.apache.dubbo.rpc.RpcContext;
import org.springframework.stereotype.Component;
import org.springframework.web.servlet.HandlerInterceptor;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.Map;

@Slf4j
@Component
public class WebHandlerInterceptor implements HandlerInterceptor {

    //handler执行之前
    @Override
    public boolean preHandle(HttpServletRequest request, HttpServletResponse response, Object handler) throws Exception {

        String tokenInfo = request.getHeader("Authorization");

        if (StringUtils.isNotEmpty(tokenInfo)) {
            try {
                Map<String, Object> tokenMap = JWTUtil.decode(tokenInfo);

//                String shopId = (String) tokenMap.get("shopId");
//                RpcContext.getContext().setAttachment("shopId", shopId);
                //将令牌Map放入自定义的上下文对象中
                TenantContext.addAttachments(tokenMap);

            } catch (IOException e) {
                log.error("解析token出错");
                e.printStackTrace();
            }
        }
        return true;
    }
}