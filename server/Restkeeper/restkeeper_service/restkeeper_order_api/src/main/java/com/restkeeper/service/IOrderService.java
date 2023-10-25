package com.restkeeper.service;

import com.baomidou.mybatisplus.extension.service.IService;
import com.restkeeper.dto.*;
import com.restkeeper.entity.OrderEntity;

import java.time.LocalDate;
import java.util.List;

public interface IOrderService extends IService<OrderEntity> {

    //下单
    String addOrder(OrderEntity orderEntity);

    /**
     * 退菜
     * @param detailDTO
     * @return
     */
    public boolean returnDish(DetailDTO detailDTO);

    /**
     * 结账
     * @param orderEntity
     * @return
     */
    boolean pay(OrderEntity orderEntity);
    /**
     * 挂账
     * @param orderEntity
     * @param creditDTO
     * @return
     */
    boolean pay(OrderEntity orderEntity, CreditDTO creditDTO);

    //换台
    boolean changeTable(String orderId,String targetTableId);

    //获取当日销售汇总的总数据
    CurrentAmountCollectDTO getCurrentCollect(LocalDate start, LocalDate end);

    /**
     * 统计24小时销售数据
     * @param start
     * @param end
     * @param type 统计类型 1:销售额;2:销售数量
     * @return
     */
    List<CurrentHourCollectDTO> getCurrentHourCollect(LocalDate start, LocalDate end, Integer type);

    //获取收款方式构成汇总数据
    List<PayTypeCollectDTO> getPayTypeCollect(LocalDate start, LocalDate end);

    //优惠金额汇总
    PrivilegeDTO getPrivilegeCollect(LocalDate start,LocalDate end);

    String addMicroOrder(OrderEntity orderEntity);
}
