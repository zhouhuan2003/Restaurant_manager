package com.restkeeper.aop;/*
 *@author 周欢
 *@version 1.0
 */

import java.lang.annotation.*;

@Documented
@Retention(RetentionPolicy.RUNTIME)
@Target(ElementType.METHOD)
public @interface TenantAnnotation {

}
