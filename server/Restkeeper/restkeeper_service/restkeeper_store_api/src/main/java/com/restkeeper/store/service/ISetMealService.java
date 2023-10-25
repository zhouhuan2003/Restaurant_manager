package com.restkeeper.store.service;/*
 *@author 周欢
 *@version 1.0
 */

import com.baomidou.mybatisplus.core.metadata.IPage;
import com.baomidou.mybatisplus.extension.service.IService;
import com.restkeeper.store.entity.SetMeal;
import com.restkeeper.store.entity.SetMealDish;

import java.util.List;

public interface ISetMealService extends IService<SetMeal> {

    IPage<SetMeal> queryPage(int pageNum, int pageSize, String name);

    boolean add(SetMeal setmeal, List<SetMealDish> setMealDishes);

    boolean update(SetMeal setMeal, List<SetMealDish> setMealDishes);

    /**
     * 批量停售
     * @param ids
     * @return
     */
    public boolean forbiddenSetMeals(List<String> ids);

    /**
     * 批量启售
     * @param ids
     * @return
     */
    public boolean enableSetMeals(List<String> ids);

    IPage<SetMeal> queryByCategory(String categoryId, long page, long pageSize);
}
