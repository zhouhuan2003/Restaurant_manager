package com.restkeeper.dubbo;/*
 *@author 周欢
 *@version 1.0
 */

import com.restkeeper.tenant.TenantContext;
import lombok.extern.slf4j.Slf4j;
import org.apache.dubbo.common.extension.Activate;
import org.apache.dubbo.rpc.*;

@Activate
@Slf4j
public class DubboConsumerContextFilter implements Filter {

    @Override
    public Result invoke(Invoker<?> invoker, Invocation invocation) throws RpcException {

        /*log.info("shopId------------"+RpcContext.getContext().getAttachment("shopId"));

        log.info("ThreadName---------"+Thread.currentThread().getName());*/

        //从自定义的上下文中对象中取到令牌的相关信息，然后给他存入到RpcContext
        RpcContext.getContext().setAttachment("shopId",TenantContext.getShopId());

        RpcContext.getContext().setAttachment("loginUserId", TenantContext.getLoginUserId());

        RpcContext.getContext().setAttachment("loginUserName", TenantContext.getLoginUserName());

        RpcContext.getContext().setAttachment("storeId", TenantContext.getStoreId());
        return invoker.invoke(invocation);
    }
}
