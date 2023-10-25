package com.restkeeper.operator.service;/*
 *@author 周欢
 *@version 1.0
 */

import com.baomidou.mybatisplus.core.metadata.IPage;
import com.baomidou.mybatisplus.extension.service.IService;
import com.restkeeper.operator.entity.EnterpriseAccount;
import com.restkeeper.utils.Result;

public interface EnterpriseAccountService extends IService<EnterpriseAccount> {

    //数据分页查询（安装企业名称进行模糊查询)
    IPage<EnterpriseAccount> queryPageByName(int pageNum,int pageSize,String enterpriseName);

    //添加账号
    boolean add(EnterpriseAccount enterpriseAccount);

    //账号还原
    boolean recovery(String id);

    //重置密码
    boolean restPwd(String id,String password);

    //登录
    Result login(String shopId,String phone,String loginPass);
}
