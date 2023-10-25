package com.restkeeper.shop;/*
 *@author 周欢
 *@version 1.0
 */

import com.restkeeper.shop.service.IStoreManagerService;
import com.restkeeper.utils.Result;
import org.apache.dubbo.config.annotation.Reference;
import org.junit.Test;

public class StoreManagerServiceImplTest extends  BaseTest {

    @Reference(version = "1.0.0", check=false)
    private IStoreManagerService storeManagerService;

    @Test
    public  void testlogin(){
        Result result= storeManagerService.login("01854018","15663692227","admin");
        System.out.println(result);
    }
}
