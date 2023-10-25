package com.restkeeper.store.service;/*
 *@author 周欢
 *@version 1.0
 */

import com.baomidou.mybatisplus.core.metadata.IPage;
import com.baomidou.mybatisplus.extension.service.IService;
import com.restkeeper.store.entity.DishCategory;

import java.util.List;
import java.util.Map;

public interface IDishCategoryService extends IService<DishCategory> {

    //新增分类
    boolean add(String name, int type);

    //修改
    boolean update(String id, String categoryName);

    //分类分页列表
    IPage<DishCategory> queryPage(int pageNum, int pageSize);

    /**
     * 根据分类获取下拉列表
     * @param type
     * @return
     */
    List<Map<String,Object>> findCategoryList(Integer type);


    /**
     * 分类删除及校验
     * @param id
     * @return
     */
    boolean delete(String id);

    List<DishCategory> getAllCategory();
}
