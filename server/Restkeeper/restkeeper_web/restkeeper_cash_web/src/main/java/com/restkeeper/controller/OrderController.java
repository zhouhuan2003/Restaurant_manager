package com.restkeeper.controller;/*
 *@author 周欢
 *@version 1.0
 */

import com.google.common.collect.Lists;
import com.restkeeper.SequenceUtils;
import com.restkeeper.constants.OrderPayType;
import com.restkeeper.constants.SystemCode;
import com.restkeeper.dto.CreditDTO;
import com.restkeeper.dto.DetailDTO;
import com.restkeeper.entity.OrderDetailEntity;
import com.restkeeper.entity.OrderEntity;
import com.restkeeper.entity.ReverseOrder;
import com.restkeeper.service.IOrderService;
import com.restkeeper.service.IReverseOrderService;
import com.restkeeper.store.entity.Dish;
import com.restkeeper.store.entity.DishCategory;
import com.restkeeper.store.service.IDishCategoryService;
import com.restkeeper.store.service.IDishService;
import com.restkeeper.store.service.ISetMealService;
import com.restkeeper.store.service.ITableService;
import com.restkeeper.tenant.TenantContext;
import com.restkeeper.utils.Result;
import com.restkeeper.utils.ResultCode;
import com.restkeeper.vo.OrderDetailVO;
import com.restkeeper.vo.OrderVO;
import com.restkeeper.vo.PayVO;
import io.swagger.annotations.Api;
import io.swagger.annotations.ApiOperation;
import org.apache.commons.lang.StringUtils;
import org.apache.dubbo.config.annotation.Reference;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

@Api(tags = {"订单接口"})
@RestController
@RequestMapping("/order")
public class OrderController {

    @Reference(version = "1.0.0",check = false)
    private IOrderService orderService;

    @Reference(version = "1.0.0",check = false)
    private IDishService dishService;

    @Reference(version = "1.0.0",check = false)
    private IDishCategoryService dishCategoryService;

    @Reference(version = "1.0.0",check = false)
    private ISetMealService setMealService;

    @Reference(version = "1.0.0",check = false)
    private IReverseOrderService reverseOrderService;

    @Reference(version = "1.0.0",check = false)
    private ITableService tableService;

    @ApiOperation("下单")
    @PostMapping("/add")
    public Result addOrder(@RequestBody OrderVO orderVO){

        OrderEntity orderEntity = new OrderEntity();

        orderEntity.setTableId(orderVO.getTableId());
        orderEntity.setPayStatus(SystemCode.ORDER_STATUS_NOTPAY);
        orderEntity.setOperatorName(TenantContext.getLoginUserName());
        orderEntity.setOrderSource(SystemCode.ORDER_SOURCE_STORE);
        orderEntity.setTotalAmount(orderVO.getTotalAmount());
        orderEntity.setPersonNumbers(orderVO.getPersonNumbers());
        orderEntity.setOrderRemark(orderVO.getOrderRemark());
        orderEntity.setCreateTime(LocalDateTime.now());


        List<OrderDetailEntity> orderDetails = Lists.newArrayList();

        orderVO.getDishes().forEach(dishVO->{

            OrderDetailEntity orderDetailEntity = new OrderDetailEntity();

            orderDetailEntity.setDishName(dishVO.getDishName());
            orderDetailEntity.setDishType(dishVO.getType());
            orderDetailEntity.setDishId(dishVO.getDishId());
            orderDetailEntity.setDishAmount(dishVO.getDishNumber()*dishVO.getPrice());
            orderDetailEntity.setDishNumber(dishVO.getDishNumber());
            if(dishVO.getFlavorList()!=null){
                orderDetailEntity.setFlavorRemark(dishVO.getFlavorList().toString());
            }
            orderDetailEntity.setTableId(orderVO.getTableId());
            orderDetailEntity.setDishPrice(dishVO.getPrice());
            DishCategory dishCategory = null;
            if (orderDetailEntity.getDishType() == 1){
                dishCategory = dishService.findDishCategoryById(dishVO.getDishId()).getDishCategory();
            }else{
                dishCategory = setMealService.getById(dishVO.getDishId()).getCategory();
            }

            if (dishCategory!=null){
                orderDetailEntity.setDishCategoryName(dishCategory.getName());
            }
            orderDetails.add(orderDetailEntity);
        });
        orderEntity.setOrderDetails(orderDetails);


        String orderId = orderService.addOrder(orderEntity);

        Result result = new Result();
        result.setStatus(ResultCode.success);
        result.setData(orderId);
        return result;
    }

    @ApiOperation("加菜")
    @PostMapping("/plusDish/orderId/{orderId}")
    public Result orderPlusDish(@PathVariable String orderId, @RequestBody List<OrderDetailVO> details){

        OrderEntity orderEntity = orderService.getById(orderId);

        List<OrderDetailEntity> orderDetailEntities =new ArrayList<>();

        int amount = 0;

        for (OrderDetailVO detail : details) {
            OrderDetailEntity orderDetailEntity = new OrderDetailEntity();

            orderDetailEntity.setOrderId(orderEntity.getOrderId());
            orderDetailEntity.setOrderNumber(SequenceUtils.getSequenceWithPrefix(orderEntity.getOrderNumber()));
            orderDetailEntity.setTableId(orderEntity.getTableId());
            orderDetailEntity.setDetailStatus(detail.getStatus());
            orderDetailEntity.setPresentRemark(detail.getDishRemark());
            orderDetailEntity.setDishId(detail.getDishId());
            orderDetailEntity.setDishType(detail.getType());
            orderDetailEntity.setDishName(detail.getDishName());
            orderDetailEntity.setDishPrice(detail.getPrice());
            orderDetailEntity.setDishNumber(detail.getDishNumber());
            orderDetailEntity.setDishAmount(detail.getDishNumber()*detail.getPrice());
            orderDetailEntity.setDishRemark(detail.getDishRemark());
            orderDetailEntity.setFlavorRemark(detail.getFlavorList().toString());
            Dish dish = dishService.getById(detail.getDishId());
            DishCategory category = dishCategoryService.getById(dish.getCategoryId());
            if(category!=null){
                orderDetailEntity.setDishCategoryName(category.getName());
            }

            //当前加菜总金额
            amount+=orderDetailEntity.getDishAmount();

            orderDetailEntities.add(orderDetailEntity);
        }

        orderEntity.setOrderDetails(orderDetailEntities);
        orderEntity.setTotalAmount(orderEntity.getTotalAmount()+amount);

        Result result = new Result();
        result.setStatus(ResultCode.success);
        orderId = orderService.addOrder(orderEntity);
        result.setData(orderId);
        return result;
    }

    /**
     * 退菜
     * @param detailId
     * @param remarks
     * @return
     */
    @ApiOperation("退菜")
    @PostMapping("/returnDish/{detailId}")
    public boolean returnDish(@PathVariable String detailId, @RequestBody List<String> remarks){
        DetailDTO detailDTO = new DetailDTO();
        detailDTO.setRemarks(remarks);
        detailDTO.setDetailId(detailId);
        return  orderService.returnDish(detailDTO);
    }

    /**
     * 结账
     * @param payVO
     * @return
     */
    @ApiOperation("结账")
    @PostMapping("/pay/orderId/{orderId}")
    public boolean pay(@PathVariable String orderId, @RequestBody PayVO payVO){
        OrderEntity orderEntity= orderService.getById(orderId);
        orderEntity.setPayAmount(payVO.getPayAmount());
        orderEntity.setSmallAmount(payVO.getSmallAmount());
        orderEntity.setPayStatus(SystemCode.ORDER_STATUS_PAYED);
        orderEntity.setPayType(payVO.getPayType());
        //如果挂账
        if (payVO.getPayType() == OrderPayType.CREDIT.getType()){
            CreditDTO creditDTO =new CreditDTO();
            creditDTO.setCreditId(payVO.getCreditId());
            creditDTO.setCreditAmount(payVO.getCreditAmount());
            creditDTO.setCreditUserName(payVO.getCreditUserName());
            return orderService.pay(orderEntity,creditDTO);
        }
        return orderService.pay(orderEntity);
    }

    /**
     * 换桌
     * @param orderId
     * @param targetTableId
     * @return
     */
    @ApiOperation("换桌")
    @GetMapping("/changeTable/{orderId}/{targetTableId}")
    public boolean changeTable(@PathVariable String orderId,@PathVariable String targetTableId){
        return orderService.changeTable(orderId,targetTableId);
    }


    /**
     * 反结账
     * @param orderId 反结账订单
     * @param remarks 反结账原因
     * @return
     */
    @ApiOperation("反结账")
    @PostMapping("/reverse/{orderId}")
    public boolean reverse(@PathVariable String orderId, @RequestBody  List<String> remarks){
        ReverseOrder reverseOrder=new ReverseOrder();
        reverseOrder.setOrderId(orderId);
        reverseOrder.setRemark(remarks.toString());
        return reverseOrderService.reverse(reverseOrder);
    }
}
