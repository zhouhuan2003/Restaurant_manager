package com.restkeeper.controller.store;/*
 *@author 周欢
 *@version 1.0
 */

import com.restkeeper.response.vo.PageVO;
import com.restkeeper.shop.entity.StoreManager;
import com.restkeeper.store.entity.Staff;
import com.restkeeper.store.service.IStaffService;
import io.swagger.annotations.Api;
import io.swagger.annotations.ApiImplicitParam;
import io.swagger.annotations.ApiImplicitParams;
import io.swagger.annotations.ApiOperation;
import lombok.extern.slf4j.Slf4j;
import org.apache.dubbo.config.annotation.Reference;
import org.springframework.web.bind.annotation.*;

@Slf4j
@Api(tags = {"员工管理"})
@RestController
@RequestMapping("/staff")
public class StaffController {

    @Reference(version = "1.0.0", check=false)
    private IStaffService staffService;

    /**
     * 新增员工
     */
    @ApiOperation(value = "新增或修改员工")
    @PostMapping(value = "/add")
    public boolean add(@RequestBody Staff staff){
        return staffService.addStaff(staff);
    }

    //查询员工列表
    @ApiOperation(value = "查询员工分页信息")
    @ApiImplicitParams({
            @ApiImplicitParam(paramType = "path", name = "page", value = "当前页码", required = false, dataType = "Integer"),
            @ApiImplicitParam(paramType = "path", name = "pageSize", value = "分大小", required = false, dataType = "Integer"),
            @ApiImplicitParam(paramType = "query", name = "name", value = "店员姓名", required = false, dataType = "String") })
    @GetMapping("/pageList/{page}/{pageSize}")
    public PageVO<Staff> getList(@PathVariable("page")int page,
                                 @PathVariable("pageSize")int pageSize,
                                 @RequestParam(value = "name",required = false)String name){
        return new PageVO<Staff>(staffService.queryPageByCriteria(page,pageSize,name));
    }

    //根据id查询
    @ApiOperation(value = "根据id查询")
    @GetMapping("/get/{id}")
    public Staff get(@PathVariable("id")String id){
        return staffService.getById(id);
    }

    //禁用，启用员工
    @ApiOperation(value ="禁用，启用员工")
    @PutMapping("/editStatus/{id}")
    public boolean editStatus(@PathVariable("id")String id){
        Staff staff = staffService.getById(id);
        if(staff.getStatus()==0){
            staff.setStatus(1);
        }else {
            staff.setStatus(0);
        }

        return staffService.updateById(staff);
    }

    //删除员工
    @ApiOperation(value = "删除员工")
    @DeleteMapping("/del/{id}")
    public boolean del(@PathVariable("id")String id){
        return staffService.removeById(id);
    }

}