package com.restkeeper.controller.store;/*
 *@author 周欢
 *@version 1.0
 */

import com.alibaba.excel.EasyExcel;
import com.baomidou.mybatisplus.core.metadata.IPage;
import com.google.common.collect.Lists;
import com.restkeeper.constants.SystemCode;
import com.restkeeper.exception.BussinessException;
import com.restkeeper.response.vo.PageVO;
import com.restkeeper.store.entity.Credit;
import com.restkeeper.store.entity.CreditCompanyUser;
import com.restkeeper.store.entity.CreditLogs;
import com.restkeeper.store.entity.CreditRepayment;
import com.restkeeper.store.service.ICreditLogService;
import com.restkeeper.store.service.ICreditRepaymentService;
import com.restkeeper.store.service.ICreditService;
import com.restkeeper.utils.BeanListUtils;
import com.restkeeper.vo.store.CreditLogExcelVO;
import com.restkeeper.vo.store.CreditRepaymentVO;
import com.restkeeper.vo.store.CreditVO;
import io.swagger.annotations.Api;
import io.swagger.annotations.ApiOperation;
import lombok.extern.slf4j.Slf4j;
import org.apache.dubbo.config.annotation.Reference;
import org.springframework.beans.BeanUtils;
import org.springframework.web.bind.annotation.*;

import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.net.URLClassLoader;
import java.net.URLEncoder;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.ZoneId;
import java.time.format.DateTimeFormatter;
import java.util.Date;
import java.util.List;
import java.util.stream.Collectors;

@Slf4j
@Api(tags = { "挂账管理" })
@RestController
@RequestMapping("/credit")
public class CreditController {

    @Reference(version = "1.0.0",check = false)
    private ICreditService creditService;

    @Reference(version = "1.0.0",check = false)
    private ICreditLogService creditLogService;

    @Reference(version = "1.0.0", check=false)
    private ICreditRepaymentService creditRepaymentService;

    @ApiOperation(value = "新增挂账单位")
    @PostMapping("/add")
    public boolean add(@RequestBody CreditVO creditvo) {

        //CreditVO->转化成 Credit
        Credit credit = new Credit();
        BeanUtils.copyProperties(creditvo,credit,"users");
        if (creditvo.getUsers()!=null && !creditvo.getUsers().isEmpty()){
            //type=公司
            // List<CreditCompanyUserVO> 转换成 List<CreditCompanyUser>
            List<CreditCompanyUser> companyUsers = Lists.newArrayList();
            creditvo.getUsers().forEach(d->{

                CreditCompanyUser creditCompany = new CreditCompanyUser();
                BeanUtils.copyProperties(d,creditCompany);
                companyUsers.add(creditCompany);
            });
            return creditService.add(credit,companyUsers);
        }
        //个人
        return creditService.add(credit,null);
    }

    /**
     * 支持挂账人模糊搜索
     * @param name
     * @param page
     * @param pageSize
     * @return
     */
    @ApiOperation(value = "挂账管理列表")
    @GetMapping("/pageList/{page}/{pageSize}")
    public PageVO<CreditVO> pageList(@RequestParam(value = "name", required = false) String name, @PathVariable int page, @PathVariable int pageSize){

        IPage<Credit> creditIPage = creditService.queryPage(page, pageSize, name);

        List<CreditVO> voList = Lists.newArrayList();
        try {
            voList = BeanListUtils.copy(creditIPage.getRecords(),CreditVO.class);
        } catch (Exception e) {
            throw new BussinessException("集合转换出错");
        }

        return new PageVO<CreditVO>(creditIPage,voList);
    }

    @ApiOperation(value = "根据id获取挂账详情")
    @GetMapping("/{id}")
    public CreditVO getCredit(@PathVariable String id){
        CreditVO creditVO =new CreditVO();
        Credit credit = creditService.queryById(id);
        BeanUtils.copyProperties(credit,creditVO);
        return creditVO;
    }

    @ApiOperation(value = "修改挂账")
    @PutMapping("/update/{id}")
    public boolean updateCredit(@PathVariable String id,@RequestBody CreditVO creditvo) {
        //CreditVO->转化成 Credit
        Credit credit = creditService.queryById(id);
        BeanUtils.copyProperties(creditvo,credit,"users");
        credit.setCreditId(id);
        if (creditvo.getUsers()!=null && !creditvo.getUsers().isEmpty()){

            // List<CreditCompanyUserVO> 转换成 List<CreditCompanyUser>
            List<CreditCompanyUser> companyUsers = Lists.newArrayList();
            creditvo.getUsers().forEach(d->{

                CreditCompanyUser creditCompany = new CreditCompanyUser();
                BeanUtils.copyProperties(d,creditCompany);
                companyUsers.add(creditCompany);
            });
            return creditService.updateInfo(credit,companyUsers);
        }

        return creditService.updateInfo(credit,null);
    }

    /**
     * 挂账明细列表
     * @param creditId
     * @param page
     * @param pageSize
     * @return
     */
    @ApiOperation(value = "挂账订单明细列表")
    @GetMapping("/creditLog/{page}/{pageSize}/{creditId}")
    public PageVO<CreditLogs> getCreditLogPageList(@PathVariable(value = "creditId") String creditId,
                                                   @PathVariable int page,
                                                   @PathVariable int pageSize,
                                                   @RequestParam(value = "start",required = false)String start,
                                                   @RequestParam(value = "end",required = false)String end){
        return new PageVO<CreditLogs>(creditLogService.queryPage(creditId,page,pageSize,start,end));
    }


    /**
     * 时间格式 2020-08-04T10:11:30  ISO-8601 格式
     * @param response
     * @throws
     */
    @GetMapping( "/export/{creditId}/{start}/{end}")
    public void export(HttpServletResponse response, @PathVariable(value = "creditId") String creditId, @PathVariable(value = "start") String start, @PathVariable(value = "end") String end) throws IOException {
        LocalDateTime startTime = LocalDate.parse(start, DateTimeFormatter.ofPattern("yyyy-MM-dd")).atStartOfDay();
        LocalDateTime endTime = LocalDate.parse(end,DateTimeFormatter.ofPattern("yyyy-MM-dd")).atStartOfDay();

        if(startTime.isAfter(endTime)){
            throw  new BussinessException("结束时间不能比开始时间小");
        }
        List<CreditLogExcelVO> data = creditLogService
                .list(creditId,startTime,endTime)
                .stream()
                .map(c->{
                    CreditLogExcelVO orderVO = new CreditLogExcelVO();
                    orderVO.setCreditAmount(c.getCreditAmount());
                    orderVO.setDateTime(Date.from( c.getLastUpdateTime().atZone( ZoneId.systemDefault()).toInstant()));
                    orderVO.setOrderAmount(c.getOrderAmount());
                    orderVO.setRevenueAmount(c.getReceivedAmount());
                    orderVO.setUserName(c.getUserName());
                    orderVO.setOrderId(c.getOrderId());
                    if(c.getType()== SystemCode.CREDIT_TYPE_COMPANY){
                        orderVO.setCreditType("企业");
                    }else {
                        orderVO.setCreditType("个人");
                    }
                    return orderVO;
                }).collect(Collectors.toList());
        response.setContentType("application/vnd.ms-excel");
        response.setCharacterEncoding("utf-8");
        String fileName = URLEncoder.encode("订单详情", "UTF-8");
        response.setHeader("Content-disposition", "attachment;filename="+fileName+".xlsx");
        EasyExcel.write(response.getOutputStream(), CreditLogExcelVO.class).sheet("模板").doWrite(data);
    }

    @ApiOperation(value = "还款")
    @PostMapping("/repayment")
    public boolean repayment(@RequestBody CreditRepaymentVO creditRepaymentVo){
        CreditRepayment creditRepayment =new CreditRepayment();
        BeanUtils.copyProperties(creditRepaymentVo,creditRepayment);
        return creditRepaymentService.repayment(creditRepayment);
    }

    @ApiOperation(value = "修改挂账状态")
    @PutMapping("/update/status/{id}/{status}")
    public boolean updateStatus(@PathVariable String id,
                                @PathVariable int status){
        Credit credit = new Credit();
        credit.setCreditId(id);
        credit.setStatus(status);
        return creditService.updateById(credit);
    }

    @ApiOperation(value = "删除挂账")
    @DeleteMapping("/{id}")
    public boolean del(@PathVariable String id){
        return creditService.removeById(id);
    }
}