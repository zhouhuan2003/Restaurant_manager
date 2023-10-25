package com.restkeeper.store.service;

import com.baomidou.mybatisplus.core.conditions.query.QueryWrapper;
import com.baomidou.mybatisplus.core.conditions.update.UpdateWrapper;
import com.baomidou.mybatisplus.core.metadata.IPage;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.restkeeper.constants.SystemCode;
import com.restkeeper.exception.BussinessException;
import com.restkeeper.store.entity.Dish;
import com.restkeeper.store.entity.DishFlavor;
import com.restkeeper.store.entity.SetMeal;
import com.restkeeper.store.entity.SetMealDish;
import com.restkeeper.store.mapper.DishMapper;
import org.apache.commons.lang.StringUtils;
import org.apache.dubbo.config.annotation.Service;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

@org.springframework.stereotype.Service("dishService")
@Service(version = "1.0.0",protocol = "dubbo")
public class DishServiceImpl extends ServiceImpl<DishMapper, Dish> implements IDishService {

    @Autowired
    @Qualifier("dishMapper")
    private DishMapper dishMapper;

    @Autowired
    @Qualifier("dishFlavorService")
    private IDishFlavorService dishFlavorService;

    @Autowired
    @Qualifier("setMealDishService")
    private ISetMealDishService setMealDishService;

    @Autowired
    @Qualifier("setMealService")
    private ISetMealService setMealService;

    @Override
    public IPage<Dish> queryPage(int pageNum, int pageSize, String name) {
        Page<Dish> page = new Page<>(pageNum, pageSize);
        QueryWrapper<Dish> queryWrapper = new QueryWrapper<>();
        if(StringUtils.isNotEmpty(name)){
            queryWrapper.lambda().like(Dish::getName,name);
        }
        return this.page(page, queryWrapper);
    }

    @Override
    @Transactional
    public boolean save(Dish dish, List<DishFlavor> dishFlavorList) {

        try {
            //保存菜品
            this.save(dish);

            //保存口味
            dishFlavorList.forEach((dishFlavor)->{
                dishFlavor.setDishId(dish.getId());
            });
            dishFlavorService.saveBatch(dishFlavorList);

            return true;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    @Override
    @Transactional
    public boolean update(Dish dish, List<DishFlavor> dishFlavorList) {

        try {
            //修改菜品基础信息
            this.updateById(dish);

            //删除原有的口味列表
            QueryWrapper<DishFlavor> queryWrapper = new QueryWrapper<>();
            queryWrapper.lambda().eq(DishFlavor::getDishId,dish.getId());
            dishFlavorService.remove(queryWrapper);

            //新增口味列表信息
            dishFlavorList.forEach((dishFlavor)->{
                dishFlavor.setDishId(dish.getId());
            });
            dishFlavorService.saveBatch(dishFlavorList);

            return true;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }

    }

    @Override
    public List<Map<String, Object>> findEnableDishListInfo(String categoryId, String name) {

        QueryWrapper<Dish> queryWrapper = new QueryWrapper<>();
        queryWrapper.lambda().select(Dish::getId,Dish::getName,Dish::getStatus,Dish::getPrice);

        if (StringUtils.isNotEmpty(categoryId)){
            queryWrapper.lambda().eq(Dish::getCategoryId,categoryId);
        }

        if (StringUtils.isNotEmpty(name)){
            queryWrapper.lambda().eq(Dish::getName,name);
        }

        queryWrapper.lambda().eq(Dish::getStatus, SystemCode.ENABLED);

        return this.listMaps(queryWrapper);
    }

    @Override
    public Dish findDishCategoryById(String dishId) {
        return dishMapper.findDishCategoryByDishId(dishId);
    }

    @Override
    @Transactional
    public boolean forbiddenDishes(List<String> ids) {

        try {
            if (ids == null || ids.isEmpty()){
                throw new BussinessException("没有需要禁售的菜品");
            }

            //批量修改菜品为停售状态
            UpdateWrapper<Dish> updateWrapper = new UpdateWrapper<>();
            updateWrapper.lambda().set(Dish::getStatus,SystemCode.FORBIDDEN).in(Dish::getId,ids);
            this.update(updateWrapper);

            //判断是否存在关联的套餐
            //基于流运算的方式获取套餐id集合
            QueryWrapper<SetMealDish> queryWrapper = new QueryWrapper<>();
            queryWrapper.select("DISTINCT setmeal_id").lambda().in(SetMealDish::getDishId,ids);
            List<SetMealDish> setMealDishList = setMealDishService.list(queryWrapper);
            List<String> setMealIds = setMealDishList.stream().map(d -> d.getSetMealId()).collect(Collectors.toList());
            if (setMealIds != null && !setMealIds.isEmpty()){
                //修改关联套餐为停售状态
                UpdateWrapper<SetMeal> updateWrapper1 = new UpdateWrapper<>();
                updateWrapper1.lambda().set(SetMeal::getStatus,SystemCode.FORBIDDEN).in(SetMeal::getId,setMealIds);
                setMealService.update(updateWrapper1);
            }

            return true;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }

    }

    @Override
    @Transactional
    public boolean enableDishes(List<String> ids) {
        if(ids==null || ids.isEmpty()){
            throw new BussinessException("没有需要启售的菜品");
        }
        //批量修改菜品为启售状态
        UpdateWrapper<Dish> updateWrapper = new UpdateWrapper<>();
        updateWrapper.lambda().set(Dish::getStatus,SystemCode.ENABLED).in(Dish::getId,ids);
        return this.update(updateWrapper);
    }

    @Override
    @Transactional
    public boolean deleteDishes(List<String> ids) {
        if(ids == null|| ids.isEmpty()) {
            throw new BussinessException("没有需要删除的菜品");
        }
        //先停售相关套餐
        QueryWrapper<SetMealDish> queryWrapper = new QueryWrapper<>();
        queryWrapper.select("DISTINCT setmeal_id").lambda().in(SetMealDish::getDishId,ids);
        //stream 集合运算获取套餐集合
        List<String> setMealIds= setMealDishService.list(queryWrapper).stream().map(d->d.getSetMealId()).collect(Collectors.toList());
        //停售套餐
        if(setMealIds!=null && setMealIds.size()>0){
            UpdateWrapper<SetMeal> updateWrapper =new UpdateWrapper<>();
            updateWrapper.lambda().set(SetMeal::getStatus,SystemCode.FORBIDDEN).in(SetMeal::getId,setMealIds);
            setMealService.update(updateWrapper);
        }
        //最后批量逻辑删除菜品
        return this.removeByIds(ids);
    }

    @Override
    public IPage<Dish> queryByCategory(String categoryId, long page, long pageSize) {
        Page<Dish> dishPage = new Page<>(page,pageSize);
        QueryWrapper<Dish> dishQueryWrapper = new QueryWrapper<>();
        dishQueryWrapper.lambda().eq(Dish::getCategoryId,categoryId);
        return this.page(dishPage,dishQueryWrapper);
    }

    @Override
    public String getDishImageById(String id) {
        return this.baseMapper.getImageById(id);
    }
}
