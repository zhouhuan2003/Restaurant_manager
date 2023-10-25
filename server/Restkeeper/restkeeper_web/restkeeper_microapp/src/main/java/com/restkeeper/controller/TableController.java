package com.restkeeper.controller;/*
 *@author 周欢
 *@version 1.0
 */

import com.alibaba.fastjson.JSON;
import com.restkeeper.constants.SystemCode;
import com.restkeeper.exception.BussinessException;
import com.restkeeper.shop.entity.Store;
import com.restkeeper.shop.service.IBrandService;
import com.restkeeper.shop.service.IStoreService;
import com.restkeeper.store.entity.Table;
import com.restkeeper.store.service.ITableService;
import com.restkeeper.tenant.TenantContext;
import com.restkeeper.vo.DishShopCartVO;
import com.restkeeper.vo.ShopCartVO;
import com.restkeeper.vo.TableVO;
import io.swagger.annotations.Api;
import io.swagger.annotations.ApiOperation;
import org.apache.dubbo.config.annotation.Reference;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.redis.core.StringRedisTemplate;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.ArrayList;
import java.util.List;

@RestController
@Api(tags = {"桌台相关接口"})
@RequestMapping("/table")
public class TableController{
    @Reference(version = "1.0.0",check = false)
    private ITableService tableService;
    @Reference(version = "1.0.0",check = false)
    private IStoreService storeService;
    @Reference(version = "1.0.0",check = false)
    private IBrandService brandService;

    @Autowired
    private StringRedisTemplate redisTemplate;

    /**
     * 获取桌台状态
     * @param tableId
     * @return
     */
    @ApiOperation("获取桌台状态")
    @GetMapping("/tableStatus/{shopId}/{storeId}/{tableId}")
    public TableVO getTableState(@PathVariable String shopId, @PathVariable String storeId, @PathVariable String tableId){
        TenantContext.addAttachment("shopId",shopId);
        TenantContext.addAttachment("storeId",storeId);
        Table table = tableService.getById(tableId);
        if(table.getStatus() == SystemCode.TABLE_STATUS_LOCKED){
            throw new BussinessException("该桌已被预定，请联系服务员更换其他桌台。");
        }
        Store store = storeService.getById(storeId);
        String brandLogo = brandService.getById(store.getBrandId()).getLogo();
        TableVO tableVO = new TableVO();
        tableVO.setTableId(tableId);
        tableVO.setBrandLogo(brandLogo);
        tableVO.setOpened(table.getStatus() == 1);
        tableVO.setTableName(table.getTableName());

        return tableVO;
    }

    /**
     * 开桌逻辑
     * @param tableId
     * @return
     */
    @ApiOperation("开桌")
    @RequestMapping("/open/{tableId}/{seatNumber}")
    public boolean open(@PathVariable String tableId,@PathVariable Integer seatNumber){
        Table table = tableService.getById(tableId);
        if(table.getStatus() == SystemCode.TABLE_STATUS_LOCKED){
            throw new BussinessException("该桌已被预定，请联系服务员更换其他桌台");
        }
        table.setStatus(SystemCode.TABLE_STATUS_OPENED);
        table.setTableSeatNumber(seatNumber);
        tableService.updateById(table);
        String key = SystemCode.MIRCO_APP_SHOP_CART_PREFIX + tableId;
        ShopCartVO shopCartVO = new ShopCartVO();
        shopCartVO.setSeatNumber(seatNumber);
        shopCartVO.setTableId(tableId);
        List<DishShopCartVO> dishList = new ArrayList<>();
        shopCartVO.setDishList(dishList);

        redisTemplate.opsForValue().set(key, JSON.toJSONString(shopCartVO));

        return true;
    }
}
