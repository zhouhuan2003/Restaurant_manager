package com.restkeeper.store.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.restkeeper.redis.MybatisRedisCache;
import com.restkeeper.store.entity.DishCategory;
import org.apache.ibatis.annotations.CacheNamespace;
import org.apache.ibatis.annotations.Select;

/**
 * <p>
 * 菜品及套餐分类 Mapper 接口
 * </p>
 */
//@CacheNamespace(implementation= MybatisRedisCache.class,eviction=MybatisRedisCache.class)
public interface DishCategoryMapper extends BaseMapper<DishCategory> {

    @Select("select * from t_category where category_id=#{id}")
    DishCategory selectById(String id);
}
