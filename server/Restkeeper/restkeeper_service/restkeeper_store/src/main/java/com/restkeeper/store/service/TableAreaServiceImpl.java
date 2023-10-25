package com.restkeeper.store.service;

import com.baomidou.mybatisplus.core.conditions.query.QueryWrapper;
import com.baomidou.mybatisplus.core.metadata.IPage;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.restkeeper.exception.BussinessException;
import com.restkeeper.store.entity.Table;
import com.restkeeper.store.entity.TableArea;
import com.restkeeper.store.mapper.TableAreaMapper;
import org.apache.dubbo.config.annotation.Service;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.Map;

@org.springframework.stereotype.Service("tableAreaService")
@Service(version = "1.0.0",protocol = "dubbo")
public class TableAreaServiceImpl extends ServiceImpl<TableAreaMapper, TableArea> implements ITableAreaService {

    @Autowired
    @Qualifier("tableService")
    private ITableService tableService;

    @Override
    @Transactional
    public boolean add(TableArea tableArea) {

        //区域名称防重
        checkNameExist(tableArea.getAreaName());

        return this.save(tableArea);
    }

    private void checkNameExist(String tableAreaName) {
        QueryWrapper<TableArea> queryWrapper = new QueryWrapper<>();
        queryWrapper.lambda().select(TableArea::getAreaId).eq(TableArea::getAreaName,tableAreaName);
        Integer count = this.baseMapper.selectCount(queryWrapper);
        if (count > 0) throw new BussinessException("该区域已存在");
    }

    @Override
    public List<Map<String, Object>> listTableArea() {
        QueryWrapper<TableArea> queryWrapper = new QueryWrapper<>();
        queryWrapper.lambda().select(TableArea::getAreaId,TableArea::getAreaName).orderByDesc(TableArea::getIndexNumber);
        return this.listMaps(queryWrapper);
    }

    @Override
    public IPage<TableArea> queryPageArea(int page, int pageSize) {
        return this.page(new Page<TableArea>(page,pageSize));
    }

    @Override
    public boolean removeAreaById(String id) {
        tableService.remove(new QueryWrapper<Table>().lambda().eq(Table::getAreaId,id));
        return this.removeById(id);
    }
}
