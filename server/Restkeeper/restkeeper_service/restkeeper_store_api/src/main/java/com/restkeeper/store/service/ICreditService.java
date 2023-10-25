package com.restkeeper.store.service;

import com.baomidou.mybatisplus.core.metadata.IPage;
import com.baomidou.mybatisplus.extension.service.IService;
import com.restkeeper.store.entity.Credit;
import com.restkeeper.store.entity.CreditCompanyUser;

import java.util.List;

public interface ICreditService extends IService<Credit> {

    //添加挂账
    boolean add(Credit credit, List<CreditCompanyUser> users);

    //
    IPage<Credit> queryPage(int page, int size, String username);


    Credit queryById(String id);

    boolean updateInfo(Credit credit, List<CreditCompanyUser> users);
}
