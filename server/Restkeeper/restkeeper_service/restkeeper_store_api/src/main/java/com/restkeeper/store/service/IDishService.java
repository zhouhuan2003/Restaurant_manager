package com.restkeeper.store.service;/*
 *@author 周欢
 *@version 1.0
 */

import com.baomidou.mybatisplus.core.metadata.IPage;
import com.baomidou.mybatisplus.extension.service.IService;
import com.restkeeper.store.entity.Dish;
import com.restkeeper.store.entity.DishCategory;
import com.restkeeper.store.entity.DishFlavor;

import javax.swing.*;
import java.util.List;
import java.util.Map;

public interface IDishService extends IService<Dish> {

    //分页列表
    //分类分页列表
    IPage<Dish> queryPage(int pageNum, int pageSize,String name);

    //添加菜品
    boolean save(Dish dish, List<DishFlavor> flavorList);

    //修改商品
    boolean update(Dish dish, List<DishFlavor> flavorList);

    //根据分类信息与菜品名称查询菜品列表
    List<Map<String,Object>> findEnableDishListInfo(String categoryId, String name);

    //查询商品的分类信息
    Dish findDishCategoryById(String dishId);

    /**
     * 停售
     * @param ids
     * @return
     */
    boolean forbiddenDishes(List<String> ids);


    /**
     * 启售
     * @param ids
     * @return
     */
    boolean enableDishes(List<String> ids);


    boolean deleteDishes(List<String> ids);

    IPage<Dish> queryByCategory(String categoryId, long page, long pageSize);

    String getDishImageById(String id);
}
