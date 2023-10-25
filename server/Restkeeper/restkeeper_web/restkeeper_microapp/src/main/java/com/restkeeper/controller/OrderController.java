package com.restkeeper.controller;/*
 *@author 周欢
 *@version 1.0
 */

import com.alibaba.fastjson.JSON;
import com.google.common.collect.Lists;
import com.restkeeper.SequenceUtils;
import com.restkeeper.constants.SystemCode;
import com.restkeeper.dto.PayType;
import com.restkeeper.entity.OrderDetailEntity;
import com.restkeeper.entity.OrderEntity;
import com.restkeeper.exception.BussinessException;
import com.restkeeper.lock.CalculationBusinessLock;
import com.restkeeper.service.IOrderService;
import com.restkeeper.store.entity.Table;
import com.restkeeper.store.service.ISellCalculationService;
import com.restkeeper.store.service.ITableService;
import com.restkeeper.vo.DishRequestVO;
import com.restkeeper.vo.DishShopCartVO;
import com.restkeeper.vo.ShopCartVO;
import io.swagger.annotations.Api;
import io.swagger.annotations.ApiOperation;
import lombok.extern.slf4j.Slf4j;
import org.apache.commons.lang.StringUtils;
import org.apache.dubbo.config.annotation.Reference;
import org.springframework.amqp.core.Message;
import org.springframework.amqp.core.MessageDeliveryMode;
import org.springframework.amqp.core.MessageProperties;
import org.springframework.amqp.rabbit.core.RabbitTemplate;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.redis.core.StringRedisTemplate;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;
import java.util.Optional;
import java.util.prefs.BackingStoreException;

@Slf4j
@RestController
@Api(tags = {"订单相关接口"})
@RequestMapping("/order")
public class OrderController{

    @Autowired
    private StringRedisTemplate redisTemplate;

    @Reference(version = "1.0.0",check = false)
    private ISellCalculationService sellCalculationService;

    @Reference(version = "1.0.0",check = false)
    private ITableService tableService;

    @Reference(version = "1.0.0",check = false)
    private IOrderService orderService;

    @ApiOperation("加菜")
    @PostMapping("/addDish")
    public boolean addDish(@RequestBody DishRequestVO dishRequestVO){

        //沽清
        if (dishRequestVO.getDishNumber() == 1){
            //加菜
            sellCalculationService.plusDish(dishRequestVO.getDishId());
        }else if (dishRequestVO.getDishNumber() == -1){
            //减菜
            sellCalculationService.reduceDish(dishRequestVO.getDishId());
        }else {
            throw new BussinessException("参数不合法");
        }

        //获取购物车
        ShopCartVO shopCartVO = getShopCartVO(dishRequestVO.getTableId());


        //判断菜品在购物车中是否存在
        DishShopCartVO dishShopCartVO = null;
        if (shopCartVO.getDishList() != null && shopCartVO.getDishList().size()>0){
            dishShopCartVO = shopCartVO.getDishList().stream().filter(d->d.getId().equals(dishRequestVO.getDishId())).findFirst().orElse(null);
//            for (DishShopCartVO cartVO : shopCartVO.getDishList()) {
//                if(cartVO.getId().equals(dishRequestVO.getDishId())){
//                    dishShopCartVO=cartVO;
//                }
//            }
        }

        //封装购物车菜品信息
        if (dishShopCartVO != null){
            dishShopCartVO.setNumber(dishShopCartVO.getNumber()+dishRequestVO.getDishNumber());
        }else {
            dishShopCartVO = new DishShopCartVO();
            dishShopCartVO.setNumber(dishRequestVO.getDishNumber());
            dishShopCartVO.setId(dishRequestVO.getDishId());
            dishShopCartVO.setPrice(dishRequestVO.getPrice());
            dishShopCartVO.setName(dishRequestVO.getDishName());
            dishShopCartVO.setImage(dishRequestVO.getImageUrl());
            dishShopCartVO.setFlavorRemark(dishRequestVO.getFlavorRemark());

            if(dishRequestVO.getType() == SystemCode.DISH_TYPE_MORMAL){
                dishShopCartVO.setType(SystemCode.DISH_TYPE_MORMAL);
            }else if(dishRequestVO.getType() == SystemCode.DISH_TYPE_SETMEAL){
                dishShopCartVO.setType(SystemCode.DISH_TYPE_SETMEAL);
            }
            shopCartVO.getDishList().add(dishShopCartVO);
        }

        //更新缓存中的购物车信息
        String key = SystemCode.MIRCO_APP_SHOP_CART_PREFIX + dishRequestVO.getTableId();
        String json = JSON.toJSONString(shopCartVO);
        redisTemplate.opsForValue().set(key,json);
        //通过mq推送消息到客户端
        sendToMQ(dishRequestVO.getTableId(),json);
        return true;
    }

    /**
     * 减菜业务
     * @param dishId
     * @return
     */
    @ApiOperation("减菜")
    @PostMapping("/decreaseDish/{tableId}/{dishId}")
    public boolean decreaseDish(@PathVariable String tableId,@PathVariable String dishId){
        ShopCartVO shopCartVO = getShopCartVO(tableId);
        Optional<DishShopCartVO> dishShopCartVO = shopCartVO.getDishList().stream().filter(d->d.getId().equals(dishId)).findFirst();
        if (!dishShopCartVO.isPresent()) return true;
        shopCartVO.getDishList().remove(dishShopCartVO.get());
        String key = SystemCode.MIRCO_APP_SHOP_CART_PREFIX + tableId;
        String json = JSON.toJSONString(shopCartVO);
        redisTemplate.opsForValue().set(key,json);
        //通过mq推送消息到客户端
        sendToMQ(tableId,json);

        return true;

    }

    private ShopCartVO getShopCartVO(String tableId) {
        String key = SystemCode.MIRCO_APP_SHOP_CART_PREFIX + tableId;
        String cartJson = redisTemplate.opsForValue().get(key);
        ShopCartVO shopCartVO = null;
        if (StringUtils.isEmpty(cartJson)){
            shopCartVO = new ShopCartVO();
            List<DishShopCartVO> dishList = Lists.newArrayList();
            shopCartVO.setDishList(dishList);
        }else {
            shopCartVO = JSON.parseObject(cartJson,ShopCartVO.class);
        }
        return shopCartVO;
    }

    /**
     * 获取购物车信息
     * @param tableId
     * @return
     */
    @ApiOperation("获取购物车信息")
    @GetMapping("/shopCart/{tableId}")
    public ShopCartVO getshopCart(@PathVariable String tableId){
        return getShopCartVO(tableId);
    }

    @Autowired
    private RabbitTemplate rabbitTemplate;

    private void sendToMQ(String tableId,String jsonMsg){
        try {
            MessageProperties msgProp = new MessageProperties();
            msgProp.setContentType(MessageProperties.CONTENT_TYPE_JSON);
            msgProp.setDeliveryMode(MessageDeliveryMode.PERSISTENT);
            Message message = new Message(jsonMsg.getBytes("UTF-8"),msgProp);
            rabbitTemplate.send(SystemCode.MICROSOFT_EXCHANGE_NAME,tableId,message);
        } catch (Exception e) {
            log.error("发送点餐消息失败",e);
        }
    }

    @Autowired
    private CalculationBusinessLock calculationBusinessLock;

    /**
     * 支付
     * @param tableId
     * @return 返回
     */
    @ApiOperation("支付")
    @RequestMapping("/pay/{tableId}/{jsCode}")
    public String pay(@PathVariable String tableId, @PathVariable String jsCode){

        String key = SystemCode.MIRCO_APP_SHOP_CART_PREFIX + tableId;
        String json = redisTemplate.opsForValue().get(key);
        ShopCartVO shopCartVO = JSON.parseObject(json, ShopCartVO.class);
        if(shopCartVO == null){
            throw new BussinessException("购物车不能为空！");
        }
        if(shopCartVO.getDishList() == null){
            throw new BussinessException("该桌没有点餐");
        }
        boolean lockSucess = calculationBusinessLock.lock(SystemCode.MICRO_APP_LOCK_PREFIX+tableId,10);
        if(!lockSucess)
            throw new BussinessException("该桌有人正在支付");

        Table table = tableService.getById(tableId);
        OrderEntity orderEntity = new OrderEntity();

        orderEntity.setPayType(PayType.WeiXin.getValue());
        orderEntity.setPayStatus(SystemCode.ORDER_STATUS_NOTPAY);
        orderEntity.setTableId(tableId);
        String flowCode = SequenceUtils.getSequence(table.getStoreId());
        orderEntity.setOrderNumber(flowCode);
        orderEntity.setTableId(table.getTableId());
        orderEntity.setPayStatus(SystemCode.ORDER_STATUS_NOTPAY);
        orderEntity.setCreateTime(LocalDateTime.now());
        orderEntity.setOrderSource(SystemCode.ORDER_SOURCE_APP);
        orderEntity.setPersonNumbers(shopCartVO.getSeatNumber());

        List<OrderDetailEntity> orderDetails =new ArrayList<>();

        shopCartVO.getDishList().forEach(d->{
            OrderDetailEntity orderDetailEntity =new OrderDetailEntity();
            orderDetailEntity.setTableId(tableId);
            orderDetailEntity.setDishPrice(d.getPrice());
            orderDetailEntity.setDetailStatus(1);
            orderDetailEntity.setDishName(d.getName());
            orderDetailEntity.setDishType(d.getType());
            orderDetailEntity.setDishAmount(d.getNumber()*d.getPrice());
            orderDetailEntity.setDishId(d.getId());
            orderDetailEntity.setDishNumber(d.getNumber());
            if(d.getFlavorRemark() != null)
                orderDetailEntity.setFlavorRemark(d.getFlavorRemark().toString());
            orderDetails.add(orderDetailEntity);
        });
        orderEntity.setTotalAmount(orderDetails.stream().mapToInt(OrderDetailEntity::getDishAmount).sum());
        orderEntity.setOrderDetails(orderDetails);
        String orderId = orderService.addMicroOrder(orderEntity);

        //todo: 发起支付

        return "";

    }
}
