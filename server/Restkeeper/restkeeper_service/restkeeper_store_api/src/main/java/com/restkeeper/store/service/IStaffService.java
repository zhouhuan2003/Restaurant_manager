package com.restkeeper.store.service;

import com.baomidou.mybatisplus.core.metadata.IPage;
import com.baomidou.mybatisplus.extension.service.IService;
import com.restkeeper.store.entity.Staff;
import com.restkeeper.utils.Result;

public interface IStaffService extends IService<Staff> {

    /**
     * 添加员工
     * @param staff
     * @return
     */
    boolean addStaff(Staff staff);

    //登录
    Result login(String shopId, String loginName, String loginPass);

    //分页
    IPage<Staff> queryPageByCriteria(int page, int pageSize, String name);
}
