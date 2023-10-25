package com.restkeeper.operator;

import com.restkeeper.operator.entity.OperatorUser;
import com.restkeeper.operator.service.IOperatorUserService;
import org.apache.commons.codec.digest.Md5Crypt;
import org.apache.dubbo.config.annotation.Reference;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.annotation.Rollback;
import org.springframework.test.context.junit4.SpringRunner;

import java.util.Collection;
import java.util.HashMap;
import java.util.Set;

@SpringBootTest
@RunWith(SpringRunner.class)
public class OperatorUserTest {

    @Reference(version = "1.0.0",check = false)
    private IOperatorUserService operatorUserService;

    //新增用户
    @Test
    @Rollback(false)
    public void addTest(){
        OperatorUser operatorUser = new OperatorUser();
        operatorUser.setLoginname("zh");
        String crypt = Md5Crypt.md5Crypt("123456".getBytes());
        operatorUser.setLoginpass(crypt);
        operatorUserService.save(operatorUser);
    }

    @Test
    public void test(){
        HashMap<String, Object> map = new HashMap<>();
        map.put("1",1);
        map.put("2","test");
        Set<String> strings = map.keySet();
        for (String string : strings) {
            if(map.get(string)==null || map.get(string).equals("")){
                //为空或者”“
            }
        }

    }
}
