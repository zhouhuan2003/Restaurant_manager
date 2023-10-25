package com.restkeeper.store.service;/*
 *@author 周欢
 *@version 1.0
 */

import com.baomidou.mybatisplus.extension.service.IService;
import com.restkeeper.store.entity.DishFlavor;

import java.util.List;

public interface IDishFlavorService extends IService<DishFlavor> {

    List<DishFlavor> selectList();

    List<DishFlavor> getFlavor(String dishId);
}
