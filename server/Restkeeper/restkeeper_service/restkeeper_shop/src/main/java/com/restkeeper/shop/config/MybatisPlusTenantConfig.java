package com.restkeeper.shop.config;/*
 *@author 周欢
 *@version 1.0
 */

import com.baomidou.mybatisplus.extension.plugins.PaginationInterceptor;
import com.baomidou.mybatisplus.extension.plugins.tenant.TenantHandler;
import com.baomidou.mybatisplus.extension.plugins.tenant.TenantSqlParser;
import com.google.common.collect.Lists;
import net.sf.jsqlparser.expression.Expression;
import net.sf.jsqlparser.expression.StringValue;
import org.apache.dubbo.rpc.RpcContext;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

import java.util.List;

@Configuration
public class MybatisPlusTenantConfig {

    private static final String SYSTEM_TENANT_ID = "shop_id";
    private static final List<String> IGNORE_TENANT_TABLES = Lists.newArrayList("");

    @Bean
    public PaginationInterceptor paginationInterceptor() {
        System.out.println("paginationInterceptor---");
        PaginationInterceptor paginationInterceptor = new PaginationInterceptor();
        // SQL解析处理拦截：增加租户处理回调。
        TenantSqlParser tenantSqlParser = new TenantSqlParser()
                .setTenantHandler(new TenantHandler() {
                    //设置租户id
                    @Override
                    public Expression getTenantId(boolean where) {
                        // 暂时写死，用于测试
//                        String shopId = "test";
                        String shopId = RpcContext.getContext().getAttachment("shopId");
                        if (null == shopId) {
                            throw new RuntimeException("#1129 getCurrentProviderId error.");
                        }
                        return new StringValue(shopId);
                    }

                    //设置租户id所对应的表字段
                    @Override
                    public String getTenantIdColumn() {
                        return SYSTEM_TENANT_ID;
                    }

                    //表级过滤器
                    @Override
                    public boolean doTableFilter(String tableName) {
                        // 忽略掉一些表：如租户表（provider）本身不需要执行这样的处理。
                        return IGNORE_TENANT_TABLES.stream().anyMatch((e) -> e.equalsIgnoreCase(tableName));
                    }
                });
        paginationInterceptor.setSqlParserList( Lists.newArrayList(tenantSqlParser));
        return paginationInterceptor;
    }
}