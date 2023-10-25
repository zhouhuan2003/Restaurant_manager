package com.restkeeper.store.service;/*
 *@author 周欢
 *@version 1.0
 */

import com.baomidou.mybatisplus.core.conditions.query.QueryWrapper;
import com.baomidou.mybatisplus.core.conditions.update.UpdateWrapper;
import com.baomidou.mybatisplus.core.metadata.IPage;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.restkeeper.exception.BussinessException;
import com.restkeeper.store.entity.Dish;
import com.restkeeper.store.entity.DishCategory;
import com.restkeeper.store.entity.SetMeal;
import com.restkeeper.store.mapper.DishCategoryMapper;
import org.apache.dubbo.config.annotation.Service;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.stereotype.Component;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.Map;

@Component
@Service(version = "1.0.0",protocol = "dubbo")
public class DishCategoryServiceImpl extends ServiceImpl<DishCategoryMapper, DishCategory> implements IDishCategoryService {

    @Autowired
    @Qualifier("dishService")
    private IDishService dishService;

    @Autowired
    @Qualifier("setMealService")
    private ISetMealService setMealService;

    @Override
    @Transactional
    public boolean add(String name,int type) {
        checkNameExist(name);
        DishCategory dishCategory = new DishCategory();
        dishCategory.setName(name);
        //默认排序0
        dishCategory.setTorder(0);
        dishCategory.setType(type);
        return this.save(dishCategory);
    }

    @Override
    public boolean update(String id, String categoryName) {
        checkNameExist(categoryName);
        UpdateWrapper<DishCategory> uw = new UpdateWrapper<>();
        uw.lambda()
                .eq(DishCategory::getCategoryId,id)
                .set(DishCategory::getName,categoryName);
        return this.update(uw);
    }

    @Override
    public IPage<DishCategory> queryPage(int pageNum, int pageSize) {
        IPage<DishCategory> page = new Page<>(pageNum,pageSize);
        QueryWrapper<DishCategory> qw = new QueryWrapper<>();
        qw.lambda()
                .orderByDesc(DishCategory::getLastUpdateTime);
        return this.page(page);
    }

    @Override
    public List<Map<String, Object>> findCategoryList(Integer type) {
        QueryWrapper<DishCategory> queryWrapper = new QueryWrapper<>();
        if (type != null){
            queryWrapper.lambda().eq(DishCategory::getType,type);
        }
        queryWrapper.lambda().select(DishCategory::getCategoryId,DishCategory::getName);
        return this.listMaps(queryWrapper);
    }

    @Override
    @Transactional(rollbackFor = {Exception.class})
    public boolean delete(String id) {
        DishCategory dishCategory= this.getById(id);
        if(dishCategory==null){
            throw new BussinessException("分类不存在");
        }
        //删除的分类是菜品
        if(dishCategory.getType()==1) {
            QueryWrapper<Dish> qw = new QueryWrapper<>();
            qw.lambda()
                    .eq(Dish::getCategoryId,id);
            int categoryDishCount= dishService.count(qw);
            if (categoryDishCount > 0) {
                throw new BussinessException("该分类下已有菜品，不能删除");
            }
        }
        if(dishCategory.getType()==2){
            QueryWrapper<SetMeal> qw = new QueryWrapper<>();
            qw.lambda()
                    .eq(SetMeal::getCategoryId,id);
            long categorySetmealCount= setMealService.count(qw);
            if(categorySetmealCount>0){
                throw new BussinessException("该分类下已有套餐，不能删除");
            }
        }
        //如果中间不出异常，说明分类下面不存在菜品和套餐，可以直接删除分类
        return this.removeById(id);
    }

    @Override
    public List<DishCategory> getAllCategory() {
        QueryWrapper<DishCategory> queryWrapper = new QueryWrapper<>();
        queryWrapper
                .lambda()
                .orderByAsc(DishCategory::getType);

        return this.list(queryWrapper);
    }


    private void checkNameExist(String name) {
        QueryWrapper<DishCategory> queryWrapper = new QueryWrapper<>();
        queryWrapper.lambda().select(DishCategory::getCategoryId).eq(DishCategory::getName,name);
        Integer count = this.getBaseMapper().selectCount(queryWrapper);

        if (count>0) throw new BussinessException("该分类名称已存在");
    }
}