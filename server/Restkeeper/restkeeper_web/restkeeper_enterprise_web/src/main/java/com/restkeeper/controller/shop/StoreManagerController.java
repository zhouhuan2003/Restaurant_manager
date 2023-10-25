package com.restkeeper.controller.shop;/*
 *@author 周欢
 *@version 1.0
 */

import com.restkeeper.response.vo.PageVO;
import com.restkeeper.shop.entity.StoreManager;
import com.restkeeper.shop.service.IStoreManagerService;
import com.restkeeper.vo.shop.StoreManagerVO;
import io.swagger.annotations.Api;
import io.swagger.annotations.ApiImplicitParam;
import io.swagger.annotations.ApiImplicitParams;
import io.swagger.annotations.ApiOperation;
import lombok.extern.slf4j.Slf4j;
import org.apache.dubbo.config.annotation.Reference;
import org.springframework.web.bind.annotation.*;

@RestController
@Slf4j
@RequestMapping("/storeManger")
@Api(tags = {"门店管理员接口"})
public class StoreManagerController {

    @Reference(version = "1.0.0",check = false)
    private IStoreManagerService storeManagerService;

    @ApiOperation(value = "查询分页数据")
    @ApiImplicitParams({
            @ApiImplicitParam(paramType = "path", name = "page", value = "当前页码", required = false, dataType = "Integer"),
            @ApiImplicitParam(paramType = "path", name = "pageSize", value = "分大小", required = false, dataType = "Integer"),
            @ApiImplicitParam(paramType = "query", name = "name", value = "店长姓名", required = false, dataType = "String") })
    @PostMapping(value = "/pageList/{page}/{pageSize}")
    public PageVO<StoreManager> findListByPage(@PathVariable int page,
                                               @PathVariable int pageSize,
                                               @RequestParam(required = false) String name) {
        return new PageVO<StoreManager>(storeManagerService.queryPageByCriteria(page,pageSize,name));
    }

    //根据id获取店长
    @ApiOperation(value = "根据id获取店长")
    @GetMapping("/get/{id}")
    public StoreManager getById(@PathVariable String id){
        return storeManagerService.getById(id);
    }


    /**
     * 添加店长
     */
    @ApiOperation(value = "添加店长")
    @PostMapping(value = "/add")
    public boolean add(@RequestBody StoreManagerVO storeManagerVO) {
        return  storeManagerService.addStoreManager(
                storeManagerVO.getName(),
                storeManagerVO.getEmail(),
                storeManagerVO.getPhone(),
                storeManagerVO.getStoreIds());
    }

    /**
     * 门店管理员修改接口
     */
    @ApiOperation(value = "更新数据")
    @PutMapping(value = "/update")
    public boolean update(@RequestBody StoreManagerVO storeManagerVO) {
        return storeManagerService.updateStoreManager(
                storeManagerVO.getStoreManagerId(),
                storeManagerVO.getName(),
                storeManagerVO.getEmail(),
                storeManagerVO.getPhone(),
                storeManagerVO.getStoreIds());
    }


    /**
     * 删除门店管理员
     */
    @ApiOperation(value = "删除数据")
    @DeleteMapping(value = "/del/{id}")
    public boolean delete(@PathVariable String id) {
        return storeManagerService.deleteStoreManager(id);
    }

    /**
     * 停用
     */
    @ApiOperation(value = "门店管理员停用")
    @PutMapping(value = "/pause/{id}/{status}")
    public boolean pause(@PathVariable String id,@PathVariable int status) {
        return storeManagerService.pauseStoreManager(id,status);
    }
}
