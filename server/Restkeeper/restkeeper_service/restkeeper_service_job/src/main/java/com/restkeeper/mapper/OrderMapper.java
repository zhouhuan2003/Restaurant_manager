package com.restkeeper.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.restkeeper.entity.OrderEntity;
import org.apache.ibatis.annotations.Mapper;

@Mapper
public interface OrderMapper extends BaseMapper<OrderEntity> {
}
