package com.restkeeper.controller.store;/*
 *@author 周欢
 *@version 1.0
 */

import com.restkeeper.response.vo.PageVO;
import com.restkeeper.store.entity.DishCategory;
import com.restkeeper.store.service.IDishCategoryService;
import com.restkeeper.vo.store.AddDishCategoryVO;
import io.swagger.annotations.Api;
import io.swagger.annotations.ApiImplicitParam;
import io.swagger.annotations.ApiImplicitParams;
import io.swagger.annotations.ApiOperation;
import lombok.extern.slf4j.Slf4j;
import org.apache.dubbo.config.annotation.Reference;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

@Slf4j
@Api(tags = { "分类管理" })
@RestController
@RequestMapping("/dishCategory")
public class DishCategoryController {

    @Reference(version = "1.0.0",check = false)
    private IDishCategoryService dishCategoryService;


    @ApiOperation(value = "添加分类")
    @PostMapping("/add")
    public boolean add(@RequestBody AddDishCategoryVO addDishCategoryVO){
        return dishCategoryService.add(addDishCategoryVO.getCategoryName(),addDishCategoryVO.getType());
    }

    @ApiOperation(value = "修改分类")
    @PutMapping("/update/{id}")
    public boolean update(@PathVariable String id, @RequestParam(name="categoryName") String categoryName){
        return dishCategoryService.update(id, categoryName);
    }

    @ApiOperation(value = "分页列表")
    @ApiImplicitParams({
            @ApiImplicitParam(paramType = "path", name = "page", value = "当前页码", required = true, dataType = "Integer"),
            @ApiImplicitParam(paramType = "path", name = "pageSize", value = "分页大小", required = true, dataType = "Integer")})
    @GetMapping("/pageList/{page}/{pageSize}")
    public PageVO<DishCategory> findByPage(@PathVariable Integer page, @PathVariable Integer pageSize){
        return new PageVO<>(dishCategoryService.queryPage(page,pageSize));
    }


    /**
     * 菜品，套餐分类下拉列表使用
     * 1 菜品 2 套餐
     * @return
     */
    @ApiOperation(value = "根据分类查询分页列表")
    @GetMapping("/type/{type}")
    public List<Map<String,Object>> getByType(@PathVariable Integer type){
        return dishCategoryService.findCategoryList(type);
    }


    @ApiOperation(value = "删除分类")
    @DeleteMapping("/delete/{id}")
    public boolean delete(@PathVariable String id){
        return dishCategoryService.delete(id);
    }
}