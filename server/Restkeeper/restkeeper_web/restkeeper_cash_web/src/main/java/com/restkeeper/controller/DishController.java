package com.restkeeper.controller;/*
 *@author 周欢
 *@version 1.0
 */

import com.google.common.collect.Lists;
import com.restkeeper.entity.DishEs;
import com.restkeeper.entity.SearchResult;
import com.restkeeper.response.vo.PageVO;
import com.restkeeper.service.IDishSearchService;
import com.restkeeper.store.service.ISellCalculationService;
import com.restkeeper.vo.DishPanelVO;
import io.swagger.annotations.Api;
import io.swagger.annotations.ApiOperation;
import org.apache.dubbo.config.annotation.Reference;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@Api(tags = {"菜品搜索相关接口"})
@RestController
@RequestMapping("/dish")
public class DishController {

    @Reference(version = "1.0.0",check = false)
    private IDishSearchService dishSearchService;

    @Reference(version = "1.0.0",check = false)
    private ISellCalculationService sellCalculationService;

    @ApiOperation(value = "查询所有的菜品")
    @GetMapping("/list/{page}/{pageSize}")
    public PageVO<DishPanelVO> searchList(@RequestParam(value = "name",required = false)String name,
                                          @RequestParam(value = "categoryId",required = false)String categoryId,
                                          @PathVariable int page,
                                          @PathVariable int pageSize){
        SearchResult<DishEs> searchResult= dishSearchService.searchList(name,categoryId,page,pageSize);
        return objectResult(searchResult, page, pageSize);
    }


    @ApiOperation(value = "根据菜品编号查询")
    @GetMapping("/queryByCode/{code}/{page}/{pageSize}")
    public PageVO<DishPanelVO> searchByCode(@PathVariable String code,
                                            @PathVariable int page,
                                            @PathVariable int pageSize) {

        SearchResult<DishEs> searchResult = dishSearchService.searchDishByCode(code, page, pageSize);

        return objectResult(searchResult, page, pageSize);
    }

    @ApiOperation(value = "根据商品码和类型值查询信息")
    @GetMapping("/searchByCodeAndType/{code}/{type}/{page}/{pageSize}")
    public PageVO<DishPanelVO> searchByCodeAndType(@PathVariable String code,
                                            @PathVariable String type,
                                            @PathVariable int page,
                                            @PathVariable int pageSize) {


        SearchResult<DishEs> searchResult = dishSearchService.searchAllByCode(code,type, page, pageSize);

        return objectResult(searchResult, page, pageSize);
    }

    @ApiOperation(value = "根据商品名查询")
    @GetMapping("/searchDishByName/{name}/{type}/{page}/{pageSize}")
    public PageVO<DishPanelVO> searchDishByName(@PathVariable String name,
                                                   @PathVariable String type,
                                                   @PathVariable int page,
                                                   @PathVariable int pageSize) {

        SearchResult<DishEs> searchResult = dishSearchService.searchDishByName(name,type, page, pageSize);

        return objectResult(searchResult, page, pageSize);
    }

    //封装重复代码
    private PageVO<DishPanelVO> objectResult(SearchResult<DishEs> searchResult,int page,int pageSize){
        PageVO<DishPanelVO> pageResult = new PageVO<>();
        pageResult.setCounts(searchResult.getTotal());
        pageResult.setPage(page);
        long pageCount =searchResult.getTotal()%pageSize==0?searchResult.getTotal()/pageSize:searchResult.getTotal()/pageSize+1;
        pageResult.setPages(pageCount);

        List<DishPanelVO> dishVOList = Lists.newArrayList();
        searchResult.getRecords().forEach(es->{

            DishPanelVO dishPanelVO = new DishPanelVO();
            dishPanelVO.setType(es.getType());
            dishPanelVO.setDishId(es.getId());
            dishPanelVO.setDishName(es.getDishName());
            dishPanelVO.setPrice(es.getPrice());
            dishPanelVO.setImage(es.getImage());
            dishPanelVO.setRemainder(sellCalculationService.getRemainderCount(es.getId()));

            dishVOList.add(dishPanelVO);
        });
        pageResult.setItems(dishVOList);
        return pageResult;
    }
}
