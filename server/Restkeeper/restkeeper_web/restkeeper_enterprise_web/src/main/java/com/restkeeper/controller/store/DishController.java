package com.restkeeper.controller.store;/*
 *@author 周欢
 *@version 1.0
 */

import com.baomidou.mybatisplus.core.conditions.query.QueryWrapper;
import com.restkeeper.constants.SystemCode;
import com.restkeeper.exception.BussinessException;
import com.restkeeper.response.vo.PageVO;
import com.restkeeper.store.entity.Dish;
import com.restkeeper.store.entity.DishFlavor;
import com.restkeeper.store.service.IDishFlavorService;
import com.restkeeper.store.service.IDishService;
import com.restkeeper.vo.store.DishFlavorVO;
import com.restkeeper.vo.store.DishVO;
import com.restkeeper.vo.store.SaleStatusVO;
import io.jsonwebtoken.lang.Collections;
import io.swagger.annotations.Api;
import io.swagger.annotations.ApiOperation;
import lombok.extern.slf4j.Slf4j;
import org.apache.commons.lang.StringUtils;
import org.apache.dubbo.config.annotation.Reference;
import org.springframework.beans.BeanUtils;
import org.springframework.web.bind.annotation.*;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;
import java.util.Map;

@Slf4j
@Api(tags = { "菜品管理" })
@RestController
@RequestMapping("/dish")
public class DishController {

    @Reference(version = "1.0.0",check = false)
    private IDishService dishService;

    @Reference(version = "1.0.0",check = false)
    private IDishFlavorService dishFlavorService;

    @ApiOperation(value = "菜品分页列表")
    @GetMapping("/pageList/{page}/{pageSize}")
    public PageVO<Dish> pageList(@PathVariable("page")int page,
                                 @PathVariable("pageSize")int pageSize,
                                 @RequestParam(value = "name",required = false)String name){
        return new PageVO<>(dishService.queryPage(page,pageSize,name));
    }

    @ApiOperation(value = "添加菜品")
    @PostMapping("/add")
    public boolean add(@RequestBody DishVO dishVO){
        //设置菜品
        Dish dish = new Dish();
        BeanUtils.copyProperties(dishVO, dish);

        //设置口味
        List<DishFlavor> dishFlavorList=setDishFlavors(dishVO);
        return dishService.save(dish,dishFlavorList);
    }

    @GetMapping("/{id}")
    @ApiOperation(value = "根据id获取菜品信息")
    public DishVO getDish(@PathVariable String id){
        Dish dish = dishService.getById(id);
        if(dish==null){
            throw new BussinessException("菜品不存在");
        }
        DishVO dishVo =new DishVO();
        BeanUtils.copyProperties(dish, dishVo);
        //口味列表
        List<DishFlavorVO> dishFlavorVOList=new ArrayList<>();
        List<DishFlavor> dishFlavorList = dish.getFlavorList();
        for (DishFlavor flavor : dishFlavorList) {
            DishFlavorVO dishFlavorVO= new DishFlavorVO();
            dishFlavorVO.setFlavor(flavor.getFlavorName());
            String flavorValue = flavor.getFlavorValue();
            //处理字符串数组
            String quflavorValue=flavorValue.substring(flavorValue.indexOf("[")+1,flavorValue.indexOf("]"));
            if(StringUtils.isNotEmpty(quflavorValue)){
                String[] flavor_array= quflavorValue.split(",");
                dishFlavorVO.setFlavorData(Arrays.asList(flavor_array));
            }
            dishFlavorVOList.add(dishFlavorVO);
        }
        dishVo.setDishFlavors(dishFlavorVOList);
        return  dishVo;
    }

    @ApiOperation(value = "修改菜品")
    @PutMapping("/update")
    public boolean update(@RequestBody DishVO dishVO){

        Dish dish = dishService.getById(dishVO.getId());
        BeanUtils.copyProperties(dishVO, dish);

        //设置口味
        List<DishFlavor> flavorList = setDishFlavors(dishVO);
        return dishService.update(dish,flavorList);
    }

    //设置口味
    private List<DishFlavor> setDishFlavors(DishVO dishVO) {
        List<DishFlavorVO> dishFlavorsVO = dishVO.getDishFlavors();
        List<DishFlavor> flavorList = new ArrayList<DishFlavor>();
        for (DishFlavorVO dishFlavorVO : dishFlavorsVO) {
            DishFlavor dishFlavor = new DishFlavor();
            dishFlavor.setFlavorName(dishFlavorVO.getFlavor());
            dishFlavor.setFlavorValue(dishFlavorVO.getFlavorData().toString());
            flavorList.add(dishFlavor);
        }
        return flavorList;
    }

    @ApiOperation(value = "查询口味列表")
    @GetMapping("/flavorList")
    public List<DishFlavorVO> getFlavorList(){
        List<DishFlavorVO> dishFlavorVOList=new ArrayList<>();

//        List<DishFlavor> dishFlavorList = dishFlavorService.selectList();
//        for (DishFlavor flavor : dishFlavorList) {
//            DishFlavorVO dishFlavorVO= new DishFlavorVO();
//            dishFlavorVO.setFlavor(flavor.getFlavorName());
//            String flavorValue = flavor.getFlavorValue();
//            //处理字符串数组
//            String quflavorValue=flavorValue.substring(flavorValue.indexOf("[")+1,flavorValue.indexOf("]"));
//            if(StringUtils.isNotEmpty(quflavorValue)){
//                String[] flavor_array= quflavorValue.split(",");
//                dishFlavorVO.setFlavorData(Arrays.asList(flavor_array));
//            }
//            dishFlavorVOList.add(dishFlavorVO);
//        }
        DishFlavorVO dishFlavorVO = new DishFlavorVO();
        dishFlavorVO.setFlavor("甜味");
        String[] a={"无糖","少糖","半糖","多糖","全糖"};
        dishFlavorVO.setFlavorData(Arrays.asList(a));

        DishFlavorVO dishFlavorVO1 = new DishFlavorVO();
        dishFlavorVO1.setFlavor("温度");
        String[] b={"热饮","常温","去冰","少冰","多冰"};
        dishFlavorVO1.setFlavorData(Arrays.asList(b));

        DishFlavorVO dishFlavorVO2 = new DishFlavorVO();
        dishFlavorVO2.setFlavor("忌口");
        String[] c={"不要葱","不要蒜 ","不要香菜","不要辣 "};
        dishFlavorVO2.setFlavorData(Arrays.asList(c));

        DishFlavorVO dishFlavorVO3 = new DishFlavorVO();
        dishFlavorVO3.setFlavor("辣度");
        String[] d={"不辣 ","微辣","中辣","重辣"};
        dishFlavorVO3.setFlavorData(Arrays.asList(d));

        dishFlavorVOList.add(dishFlavorVO);
        dishFlavorVOList.add(dishFlavorVO1);
        dishFlavorVOList.add(dishFlavorVO2);
        dishFlavorVOList.add(dishFlavorVO3);
        return dishFlavorVOList;
    }


    @ApiOperation(value = "查询可用的菜品列表")
    @GetMapping("/findEnableDishList/{categoryId}")
    public List<Map<String,Object>> findEnableDishList(@PathVariable String categoryId,
                                                       @RequestParam(value="name",required=false) String name){
        return dishService.findEnableDishListInfo(categoryId, name);
    }

    /**
     * 设置菜品售卖状态
     * @param saleStateVO
     * status; // 0 停售 1 启售
     * @return
     */
    @ApiOperation(value = "设置菜品售卖状态")
    @PutMapping("/updateStatus")
    public boolean updateSaleStatus(@RequestBody SaleStatusVO saleStateVO) {
        if (SystemCode.FORBIDDEN == saleStateVO.getStatus()) {
            return dishService.forbiddenDishes(saleStateVO.getIds());
        } else if (SystemCode.ENABLED == saleStateVO.getStatus()) {
            return dishService.enableDishes(saleStateVO.getIds());
        }
        return false;
    }

    /**
     * 删除菜品
     * @param
     * @return
     */
    @ApiOperation(value = "删除")
    @DeleteMapping("/delete")
    public boolean delete(@RequestBody SaleStatusVO saleStateVO){
        return dishService.deleteDishes(saleStateVO.getIds());
    }
}
