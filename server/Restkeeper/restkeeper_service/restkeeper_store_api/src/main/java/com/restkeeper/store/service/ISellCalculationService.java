package com.restkeeper.store.service;

import com.baomidou.mybatisplus.extension.service.IService;
import com.restkeeper.store.entity.SellCalculation;

public interface ISellCalculationService extends IService<SellCalculation> {

    /**
     * 获取估清数目
     * @param dishId
     * @return
     */
    Integer getRemainderCount(String dishId);

    //扣减沽清
    void decrease(String dishId, Integer dishNumber);

    void add(String dishId, int dishNum);

    void plusDish(String dishId);

    void reduceDish(String dishId);
}
