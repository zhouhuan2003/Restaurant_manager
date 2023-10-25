package com.restkeeper.store.service;

import com.baomidou.mybatisplus.core.metadata.IPage;
import com.baomidou.mybatisplus.extension.service.IService;
import com.restkeeper.store.entity.TableArea;

import java.util.List;
import java.util.Map;

public interface ITableAreaService extends IService<TableArea> {


    boolean add(TableArea tableArea);

    //区域列表
    List<Map<String, Object>> listTableArea();

    IPage<TableArea> queryPageArea(int page, int pageSize);

    boolean removeAreaById(String id);
}
