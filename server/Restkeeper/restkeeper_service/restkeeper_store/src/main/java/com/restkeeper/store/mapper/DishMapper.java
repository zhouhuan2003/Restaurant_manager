package com.restkeeper.store.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.baomidou.mybatisplus.core.metadata.IPage;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.restkeeper.redis.MybatisRedisCache;
import com.restkeeper.store.entity.Dish;
import io.swagger.models.auth.In;
import org.apache.ibatis.annotations.*;

import java.util.List;

@Mapper
//@CacheNamespace(implementation= MybatisRedisCache.class,eviction=MybatisRedisCache.class)
public interface DishMapper extends BaseMapper<Dish>{

    @Select(value="select * from t_dish where category_id=#{dishCategoryId} and is_deleted=0 order by last_update_time desc")
    public List<Dish> selectDishByCategory(@Param("dishCategoryId") String dishCategoryId);

    Dish findDishCategoryByDishId(@Param("id") String dishId);

    String getImageById(@Param("id")String id);

}
