package com.restkeeper.service;

import com.baomidou.mybatisplus.extension.service.IService;

import com.restkeeper.entity.ReportPay;

import java.time.LocalDate;
import java.util.List;

public interface IReportPayService extends IService<ReportPay> {

    void generateData();
}
