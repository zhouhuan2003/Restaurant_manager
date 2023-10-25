package com.restkeeper.store.service;/*
 *@author 周欢
 *@version 1.0
 */

import com.baomidou.mybatisplus.extension.service.IService;
import com.restkeeper.store.entity.Dish;
import com.restkeeper.store.entity.SetMealDish;

import java.util.List;

public interface ISetMealDishService extends IService<SetMealDish> {

    List<Dish> getAllDishBySetMealId(String setMealId);


    Integer getDishCopiesInSetMeal(String dishId, String setMealId);
}
