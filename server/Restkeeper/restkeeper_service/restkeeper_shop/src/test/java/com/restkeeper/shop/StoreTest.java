package com.restkeeper.shop;

import com.baomidou.mybatisplus.core.metadata.IPage;
import com.restkeeper.constants.SystemCode;
import com.restkeeper.shop.dto.StoreDTO;
import com.restkeeper.shop.entity.Store;
import com.restkeeper.shop.service.IStoreService;
import org.apache.dubbo.config.annotation.Reference;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.annotation.Rollback;
import org.springframework.test.context.junit4.SpringRunner;

import java.util.List;

@SpringBootTest
@RunWith(SpringRunner.class)
public class StoreTest extends BaseTest{

    @Reference(version = "1.0.0",check = false)
    private IStoreService storeService;

    @Test
    @Rollback(false)
    public void saveTest(){
        Store store = new Store();
        store.setBrandId("test2");
        store.setStoreName("测试2");
        store.setProvince("北京2");
        store.setCity("昌平区2");
        store.setArea("金燕龙大厦2");
        store.setAddress("北京 昌平区 金燕龙大厦2");
        storeService.save(store);
    }

    @Test
    public void queryTest(){
        for (int i = 0; i < 3; i++) {
            Store store = storeService.getById("1639435532630900738");
            System.out.println(store);
        }
    }

    @Test
    public void queryPage(){
        IPage<Store> result = storeService.queryPageByName(1, 10, "门");

        List<Store> storeList = result.getRecords();

        System.out.println(storeList);
    }

    @Test
    @Rollback(false)
    public void disableStore(){

        Store store = storeService.getById("1639435532630900738");
        store.setStatus(SystemCode.FORBIDDEN);

        storeService.updateById(store);
    }


    @Test
    public void listAllProvince(){
        List<String> allProvince = storeService.getAllProvince();
        System.out.println(allProvince);
    }

    @Test
    public void getStoreByProvince(){
        List<StoreDTO> storeDTO = storeService.getStoreByProvince("all");
        System.out.println(storeDTO);
    }
}
