package com.restkeeper;/*
 *@author 周欢
 *@version 1.0
 */

import com.restkeeper.service.IReportPayService;
import com.restkeeper.service.OrderHistoryService;
import com.restkeeper.service.ReportDishService;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.annotation.Rollback;
import org.springframework.test.context.junit4.SpringRunner;

@SpringBootTest
@RunWith(SpringRunner.class)
public class ReportDishTest {

    @Autowired
    private IReportPayService reportPayService;

    @Autowired
    private ReportDishService reportDishService;

    @Autowired
    private OrderHistoryService orderHistoryService;

    @Test
    @Rollback(false)
    public void generate(){
        reportPayService.generateData();
    }

    @Test
    @Rollback(false)
    public void generate1(){
        reportDishService.generateData();
    }

    @Test
    @Rollback(false)
    public void generate2(){
        orderHistoryService.exportToHistory();
    }
}
