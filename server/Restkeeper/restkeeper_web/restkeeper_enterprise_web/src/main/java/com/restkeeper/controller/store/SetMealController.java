package com.restkeeper.controller.store;/*
 *@author 周欢
 *@version 1.0
 */

import com.google.common.collect.Lists;
import com.restkeeper.constants.SystemCode;
import com.restkeeper.exception.BussinessException;
import com.restkeeper.response.vo.PageVO;
import com.restkeeper.store.entity.SetMeal;
import com.restkeeper.store.entity.SetMealDish;
import com.restkeeper.store.service.ISetMealService;
import com.restkeeper.vo.store.SaleStatusVO;
import com.restkeeper.vo.store.SetMealDishVO;
import com.restkeeper.vo.store.SetMealVO;
import io.swagger.annotations.Api;
import io.swagger.annotations.ApiOperation;
import lombok.extern.slf4j.Slf4j;
import org.apache.dubbo.config.annotation.Reference;
import org.springframework.beans.BeanUtils;
import org.springframework.web.bind.annotation.*;

import java.util.ArrayList;
import java.util.List;

@Slf4j
@Api(tags = {"套餐管理"})
@RestController
@RequestMapping("/setMeal")
public class SetMealController {

    @Reference(version = "1.0.0",check = false)
    private ISetMealService setMealService;

    @ApiOperation("套餐分页查询")
    @GetMapping("/queryPage/{page}/{pageSize}")
    public PageVO<SetMeal> queryPage(@PathVariable("page") Integer page,
                                     @PathVariable("pageSize") Integer pageSize,
                                     @RequestParam(value="name",required=false) String name){
        return new PageVO<>(setMealService.queryPage(page, pageSize, name));
    }

    /**
     * 添加套餐
     * @param
     */
    @ApiOperation(value = "添加套餐")
    @PostMapping("/add")
    public boolean add(@RequestBody SetMealVO setMealVO)  {
        SetMeal setMeal = new SetMeal();
        BeanUtils.copyProperties(setMealVO,setMeal);
        setMeal.setDishList(null);

        List<SetMealDish> setMealDishList = Lists.newArrayList();

        if(setMealVO.getDishList() != null && setMealVO.getDishList().size()>0){
            setMealVO.getDishList().forEach(d->{
                SetMealDish setMealDish = new SetMealDish();
                setMealDish.setIndex(0);
                setMealDish.setDishName(d.getDishName());
                setMealDish.setDishCopies(d.getCopies());
                setMealDish.setDishPrice(d.getPrice());
                setMealDish.setDishId(d.getDishId());
                setMealDishList.add(setMealDish);
            });
        }

        return setMealService.add(setMeal,setMealDishList);
    }

    @GetMapping("/{id}")
    @ApiOperation(value = "根据id获取套餐信息")
    public SetMealVO getDish(@PathVariable String id){

        SetMeal setMeal = setMealService.getById(id);
        if(setMeal==null){
            throw new BussinessException("套餐不存在");
        }
        SetMealVO setMealVo=new SetMealVO();
        BeanUtils.copyProperties(setMeal, setMealVo);
        //口味列表
        List<SetMealDish> setMealDishList = setMeal.getDishList();
        List<SetMealDishVO> setMealDishVOList=new ArrayList<>();
        for (SetMealDish setMealDish : setMealDishList) {
            SetMealDishVO setMealDishVO =new SetMealDishVO();
            setMealDishVO.setDishId(setMealDish.getDishId());
            setMealDishVO.setDishName(setMealDish.getDishName());
            setMealDishVO.setCopies(setMealDish.getDishCopies());
            setMealDishVO.setPrice(setMealDish.getDishPrice());
            setMealDishVOList.add(setMealDishVO);
        }

        setMealVo.setDishList(setMealDishVOList);
        return  setMealVo;
    }

    @PutMapping("/update")
    @ApiOperation(value = "修改套餐信息")
    public boolean update(@RequestBody SetMealVO setMealVo){
        SetMeal setMeal = setMealService.getById(setMealVo.getId());
        BeanUtils.copyProperties(setMealVo,setMeal);
        setMeal.setDishList(null);

        List<SetMealDish> setMealDishList = Lists.newArrayList();
        if(setMealVo.getDishList() != null){
            setMealVo.getDishList().forEach(d->{
                SetMealDish setMealDish = new SetMealDish();
                setMealDish.setIndex(0);
                setMealDish.setDishCopies(d.getCopies());
                setMealDish.setDishId(d.getDishId());
                setMealDish.setDishName(d.getDishName());
                setMealDishList.add(setMealDish);
            });
        }
        return setMealService.update(setMeal,setMealDishList);
    }

    /**
     * 设置售卖状态
     * @param saleStateVO
     * @return
     */
    @ApiOperation(value = "套餐停/起售")
    @PutMapping("/updateStatus")
    public boolean updateStatus(@RequestBody SaleStatusVO saleStateVO){
        if(SystemCode.FORBIDDEN==saleStateVO.getStatus()){
            return setMealService.forbiddenSetMeals(saleStateVO.getIds());
        }
        if(SystemCode.ENABLED==saleStateVO.getStatus()){
            return setMealService.enableSetMeals(saleStateVO.getIds());
        }
        return false;
    }

    /**
     * 删除套餐
     * @param
     * @return
     */
    @ApiOperation(value = "删除套餐")
    @DeleteMapping("/delete")
    public boolean delete(@RequestBody SaleStatusVO saleStateVO){
        return setMealService.removeByIds(saleStateVO.getIds());
    }

}
