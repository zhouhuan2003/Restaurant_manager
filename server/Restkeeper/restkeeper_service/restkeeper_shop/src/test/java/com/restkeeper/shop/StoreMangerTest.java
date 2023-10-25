package com.restkeeper.shop;/*
 *@author 周欢
 *@version 1.0
 */

import com.restkeeper.shop.service.IStoreManagerService;
import com.restkeeper.shop.service.IStoreService;
import org.apache.dubbo.config.annotation.Reference;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.annotation.Rollback;
import org.springframework.test.context.junit4.SpringRunner;

import java.util.ArrayList;
import java.util.List;

@SpringBootTest
@RunWith(SpringRunner.class)
public class StoreMangerTest extends BaseTest{

    @Reference(version = "1.0.0",check = false)
    private IStoreManagerService storeManagerService;


    @Test
    @Rollback(false)
    public void add(){
        List<String> storeIds = new ArrayList<>();
        storeIds.add("1639435532630900738");
        storeManagerService.addStoreManager("lisi","2035231980@qq.com","13203050639",storeIds);
    }


    @Test
    @Rollback(false)
    public void updateStoreManager(){
        List<String> storeIds = new ArrayList<>();
        storeIds.add("1205130634214969345");
        storeIds.add("1206476527887405057");
        storeIds.add("1206216301732823041");
        storeManagerService.updateStoreManager("1639515899882827778","203523198@qq.com","test","18810973345",storeIds);
    }

    @Test
    @Rollback(false)
    public void deleteStoreManager(){
//        storeManagerService.deleteStoreManager("1639515899882827778");
    }

    @Test
    @Rollback(false)
    public void pauseStoreManager(){
//        storeManagerService.pauseStoreManager("1639515899882827778");
    }
}
