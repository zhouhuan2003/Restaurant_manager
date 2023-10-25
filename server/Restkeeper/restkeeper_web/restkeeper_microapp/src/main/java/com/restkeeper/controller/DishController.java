package com.restkeeper.controller;/*
 *@author 周欢
 *@version 1.0
 */

import com.baomidou.mybatisplus.core.metadata.IPage;
import com.restkeeper.exception.BussinessException;
import com.restkeeper.response.vo.PageVO;
import com.restkeeper.service.IDishSearchService;
import com.restkeeper.store.entity.Dish;
import com.restkeeper.store.entity.DishFlavor;
import com.restkeeper.store.entity.SetMeal;
import com.restkeeper.store.entity.SetMealDish;
import com.restkeeper.store.service.*;
import com.restkeeper.vo.DishCategoryVO;
import com.restkeeper.vo.DishFlavorVO;
import com.restkeeper.vo.DishVO;
import io.swagger.annotations.Api;
import io.swagger.annotations.ApiOperation;
import org.apache.commons.lang.StringUtils;
import org.apache.dubbo.config.annotation.Reference;
import org.springframework.web.bind.annotation.*;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

@Api(tags = {"菜品搜索相关接口"})
@RestController
@RequestMapping("/dish")
public class DishController {

    @Reference(version = "1.0.0", check=false)
    private IDishService dishService;

    @Reference(version = "1.0.0", check=false)
    private ISetMealService setMealService;

    @Reference(version = "1.0.0",check = false)
    IDishCategoryService dishCategoryService;

    @Reference(version = "1.0.0",check = false)
    ISetMealDishService setMealDishService;

    @Reference(version = "1.0.0", check=false)
    private IDishSearchService dishSearchService;

    @Reference(version = "1.0.0", check=false)
    private IRemarkService remarkService;

    @Reference(version = "1.0.0", check=false)
    private IDishFlavorService dishFlavorService;

    @Reference(version = "1.0.0",check = false)
    private ISellCalculationService sellCalculationService;

    /**
     * 获取套餐和产品分类类别
     * @return
     */
    @ApiOperation("获取套餐和产品分类类别")
    @GetMapping("/category")
    public List<DishCategoryVO> getCategory(){
        return  dishCategoryService
                .getAllCategory()
                .stream()
                .map(d->{
                    DishCategoryVO vo = new DishCategoryVO();
                    vo.setCategoryId(d.getCategoryId());
                    vo.setName(d.getName());
                    vo.setType(d.getType());

                    return vo;
                })
                .collect(Collectors.toList());
    }
    /**
     * 查询可用的菜品列表
     */
    @ApiOperation("查询可用的菜品列表")
    @GetMapping("/findEnableDishList/{categoryId}")
    public List<Map<String,Object>> findEnableDishList(@PathVariable String categoryId,
                                                       @RequestParam(value = "name",defaultValue = "") String name){
        return dishService.findEnableDishListInfo(categoryId, name);
    }

    //分页获取
    @ApiOperation("分页获取")
    @GetMapping("/dishPageList/{categoryId}/{type}/{page}/{pageSize}")
    public PageVO<DishVO> getDishByCategory(@PathVariable String categoryId,
                                            @PathVariable int type,
                                            @PathVariable long page,
                                            @PathVariable long pageSize){
        PageVO<DishVO> result = new PageVO<>();
        if(type == 1){
            IPage<Dish> dishPage = dishService.queryByCategory(categoryId,page,pageSize);
            result.setPages(dishPage.getPages());
            result.setPage(dishPage.getCurrent());
            result.setPagesize(dishPage.getSize());
            result.setCounts(dishPage.getTotal());
            result.setItems(dishPage
                    .getRecords()
                    .stream()
                    .map(d->{
                        DishVO dishVO = new DishVO();
                        dishVO.setDishId(d.getId());
                        dishVO.setDishName(d.getName());
                        dishVO.setPrice(d.getPrice());
                        dishVO.setType(1);
                        dishVO.setDesc(d.getDescription());
                        dishVO.setImageUrl(d.getImage());
                        dishVO.setRemainder(sellCalculationService.getRemainderCount(d.getId()));
                        return  dishVO;
                    }).collect(Collectors.toList())
            );
            return result;
        }else if(type == 2){
            IPage<SetMeal> dishPage = setMealService.queryByCategory(categoryId,page,pageSize);
            result.setPages(dishPage.getPages());
            result.setPage(dishPage.getCurrent());
            result.setPagesize(dishPage.getSize());
            result.setCounts(dishPage.getTotal());
            result.setItems(dishPage
                    .getRecords()
                    .stream()
                    .map(s->{
                        DishVO dishVO = new DishVO();
                        dishVO.setDishId(s.getId());
                        dishVO.setDishName(s.getName());
                        dishVO.setPrice(s.getPrice());
                        dishVO.setType(2);
                        dishVO.setDesc(s.getDescription());
                        dishVO.setImageUrl(s.getImage());
                        dishVO.setRemainder(sellCalculationService.getRemainderCount(s.getId()));
                        dishVO.setSetMealDishList(s.getDishList().stream().map(s1->{
                            SetMealDish setMealDish = new SetMealDish();
                            setMealDish.setDishId(s1.getId());
                            setMealDish.setDishName(s1.getDishName());
                            setMealDish.setDishPrice(s1.getDishPrice());
//                            setMealDish.(dishService.getDishById(s1.getId()).getImage());
                            setMealDish.setImage(dishService.getDishImageById(s1.getDishId()));
                            return setMealDish;
                        }).collect(Collectors.toList()));
                        return  dishVO;
                    }).collect(Collectors.toList())
            );
            return result;
        }
        throw new BussinessException("请选择正确的分类");
    }

    /**
     * 根据菜品id获取口味信息
     */
    @ApiOperation("根据菜品id获取口味信息")
    @GetMapping("/flavor/{dishId}")
    public List<DishFlavorVO> dishFlavor(@PathVariable String dishId){
        List<DishFlavor> dishFlavors= dishFlavorService.getFlavor(dishId);
        List<DishFlavorVO> dishFlavorVOList =new ArrayList<>();
        dishFlavors.forEach(d->{
            DishFlavorVO dishFlavorVO=new DishFlavorVO();
            dishFlavorVO.setFlavor(d.getFlavorName());
            String flavorValue = d.getFlavorValue();
            String remarkValue_substring=flavorValue.substring(flavorValue.indexOf("[")+1,flavorValue.indexOf("]"));
            if(StringUtils.isNotEmpty(remarkValue_substring)){
                String[] flavor_array= remarkValue_substring.split(",");
                dishFlavorVO.setFlavorData(Arrays.asList(flavor_array));
            }
            dishFlavorVOList.add(dishFlavorVO);
        });
        return dishFlavorVOList;
    }

//    @ApiOperation("根据套餐id查询详情")
//    @GetMapping("/getSetMealDish/{id}")
//    public List<SetMealDish> getSetMealDish(@PathVariable("id")String id){
//        setMealDishService
//    }
}



