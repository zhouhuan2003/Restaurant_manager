package com.restkeeper.service;

import com.restkeeper.entity.DishEs;
import com.restkeeper.entity.SearchResult;

public interface IDishSearchService {

    //根据商品码和类型值查询信息
    SearchResult<DishEs> searchAllByCode(String code, String type, int pageNum, int pageSize);
    //根据商品码查询信息
    SearchResult<DishEs> searchDishByCode(String code, int pageNum, int pageSize);
    //根据商品名查询
    SearchResult<DishEs> searchDishByName(String name,String type,int pageNum,int pageSize);
    //查询所有的菜品
    SearchResult<DishEs> searchList(String name,String categoryId,int page, int pageSize);
}
