package com.restkeeper.controller;/*
 *@author 周欢
 *@version 1.0
 */


import com.baomidou.mybatisplus.core.metadata.IPage;
import com.google.common.collect.Lists;
import com.restkeeper.constants.SystemCode;
import com.restkeeper.response.vo.PageVO;
import com.restkeeper.store.entity.Table;
import com.restkeeper.store.entity.TableLog;
import com.restkeeper.store.service.ITableAreaService;
import com.restkeeper.store.service.ITableLogService;
import com.restkeeper.store.service.ITableService;
import com.restkeeper.vo.TablePanelVO;
import com.restkeeper.vo.TableVO;
import io.swagger.annotations.Api;
import io.swagger.annotations.ApiImplicitParam;
import io.swagger.annotations.ApiImplicitParams;
import io.swagger.annotations.ApiOperation;
import org.apache.dubbo.config.annotation.Reference;
import org.springframework.web.bind.annotation.*;

import java.text.SimpleDateFormat;
import java.time.format.DateTimeFormatter;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/table")
@Api(tags = {"收银端区域桌台接口"})
public class TableController {

    @Reference(version = "1.0.0",check = false)
    private ITableAreaService tableAreaService;

    @Reference(version = "1.0.0",check = false)
    private ITableLogService tableLogService;

    @Reference(version = "1.0.0",check = false)
    private ITableService tableService;


    @ApiOperation(value = "区域列表接口")
    @GetMapping("/listTableArea")
    public List<Map<String,Object>> list(){
        return tableAreaService.listTableArea();
    }

    @ApiOperation(value = "根据id获取桌台信息")
    @GetMapping("/get/{tableId}")
    public TableVO getTable(@PathVariable String tableId){
        TableVO tableVO = new TableVO();
        Table table = tableService.selectTableById(tableId);
        tableVO.setTableId(table.getTableId());
        tableVO.setTableName(table.getTableName());
        tableVO.setSeatNumber(table.getTableSeatNumber());
        tableVO.setStatus(table.getStatus());
        //如果是开桌状态
        if (table.getStatus() == SystemCode.TABLE_STATUS_OPENED){
            //从tableLog中获取就餐人数和时间
            TableLog tableLog = tableLogService.getOpenTableLog(table.getTableId());
            if(tableLog!=null){
//                tableVO.setCreateTime(dfDate.format(tableLog.getCreateTime()));
                tableVO.setUserNumbers(tableLog.getUserNumbers());
            }
        }
        return tableVO;
    }

    @ApiOperation(value = "开桌")
    @PutMapping("/openTable/{tableId}/{numbers}")
    public boolean openTable(@PathVariable String tableId, @PathVariable Integer numbers){
        TableLog tableLog =new TableLog();
        tableLog.setTableId(tableId);
        tableLog.setUserNumbers(numbers);
        return tableLogService.openTable(tableLog);
    }

    @ApiOperation(value = "桌台面板")
    @ApiImplicitParams({
            @ApiImplicitParam(paramType = "path", name = "areaId", value = "区域Id", required = true, dataType = "String"),
            @ApiImplicitParam(paramType = "path", name = "page", value = "页码", required = true, dataType = "Integer"),
            @ApiImplicitParam(paramType = "path", name = "pageSize", value = "每页数量", required = true, dataType = "Integer")})
    @GetMapping("/search/{areaId}/{page}/{pageSize}")
    public TablePanelVO queryByArea(@PathVariable String areaId, @PathVariable int page, @PathVariable int pageSize){

        TablePanelVO tablePanelVO = new TablePanelVO();

        //桌台统计信息
        tablePanelVO.setFreeNumbers(tableService.countTableByStatus(areaId, SystemCode.TABLE_STATUS_FREE));
        tablePanelVO.setLockedNumbers(tableService.countTableByStatus(areaId,SystemCode.TABLE_STATUS_LOCKED));
        tablePanelVO.setOpenedNumbers(tableService.countTableByStatus(areaId,SystemCode.TABLE_STATUS_OPENED));

        //桌台面板详情，支持分页
        IPage<Table> pageInfo =tableService.queryPageByAreaId(areaId, page, pageSize);
        List<TableVO> tableVOList = Lists.newArrayList();
        pageInfo.getRecords().forEach(d->{
            TableVO tableVO = new TableVO();
            tableVO.setTableId(d.getTableId());
            tableVO.setTableName(d.getTableName());
            tableVO.setSeatNumber(d.getTableSeatNumber());
            tableVO.setStatus(d.getStatus());
            DateTimeFormatter dfDate = DateTimeFormatter.ofPattern("HH:mm:ss");
            //如果是开桌状态
            if (d.getStatus() == SystemCode.TABLE_STATUS_OPENED){
                //从tableLog中获取就餐人数和时间
                TableLog tableLog = tableLogService.getOpenTableLog(d.getTableId());
                if(tableLog!=null){
                    tableVO.setCreateTime(dfDate.format(tableLog.getCreateTime()));
                    tableVO.setUserNumbers(tableLog.getUserNumbers());
                }
            }
            tableVOList.add(tableVO);
        });
        PageVO<TableVO> pageVO = new PageVO<>(pageInfo,tableVOList);
        tablePanelVO.setTablePage(pageVO);

        return tablePanelVO;
    }
}