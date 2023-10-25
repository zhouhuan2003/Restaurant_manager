package com.restkeeper.store.service;/*
 *@author 周欢
 *@version 1.0
 */

import com.baomidou.mybatisplus.core.conditions.query.QueryWrapper;
import com.baomidou.mybatisplus.extension.service.IService;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.restkeeper.store.entity.DishFlavor;
import com.restkeeper.store.mapper.DishFlavorMapper;
import org.apache.dubbo.config.annotation.Service;
import org.apache.ibatis.annotations.Mapper;
import org.springframework.beans.factory.annotation.Autowired;

import java.util.List;

@org.springframework.stereotype.Service("dishFlavorService")
@Service(version = "1.0.0",protocol = "dubbo")
public class DishFlavorServiceImpl extends ServiceImpl<DishFlavorMapper, DishFlavor> implements IDishFlavorService {

    @Autowired
    private DishFlavorMapper dishFlavorMapper;

    @Override
    public List<DishFlavor> selectList() {
//        QueryWrapper<DishFlavor> queryWrapper = new QueryWrapper<>();
//        queryWrapper.lambda().orderByDesc(DishFlavor::getFlavorValue).groupBy(DishFlavor::getFlavorName);
        return this.list();
    }

    @Override
    public List<DishFlavor> getFlavor(String dishId) {
        return dishFlavorMapper.selectFlavors(dishId);
    }
}
