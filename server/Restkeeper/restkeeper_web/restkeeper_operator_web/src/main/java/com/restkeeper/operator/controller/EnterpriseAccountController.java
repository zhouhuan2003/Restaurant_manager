package com.restkeeper.operator.controller;/*
 *@author 周欢
 *@version 1.0
 */

import com.restkeeper.operator.entity.EnterpriseAccount;
import com.restkeeper.operator.service.EnterpriseAccountService;
import com.restkeeper.operator.vo.AddEnterpriseAccountVO;
import com.restkeeper.operator.vo.ResetPwdVO;
import com.restkeeper.operator.vo.UpdateEnterpriseAccountVO;
import com.restkeeper.response.vo.PageVO;
import com.restkeeper.utils.AccountStatus;
import com.restkeeper.utils.Result;
import com.restkeeper.utils.ResultCode;
import io.swagger.annotations.Api;
import io.swagger.annotations.ApiOperation;
import org.apache.dubbo.config.annotation.Reference;
import org.springframework.beans.BeanUtils;
import org.springframework.cloud.context.config.annotation.RefreshScope;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDateTime;

@Api(tags = "企业账号管理")
@RestController
@RequestMapping("/enterprise")
@RefreshScope
public class EnterpriseAccountController {

    @Reference(version = "1.0.0",check = false)
    private EnterpriseAccountService enterpriseAccountService;

    @ApiOperation("查询企业账号列表")
    @GetMapping("/pageList/{page}/{pageSize}")
    public PageVO<EnterpriseAccount> findListByPage(@PathVariable("page")int page,
                                                    @PathVariable("pageSize")int pageSize,
                                                    @RequestParam(value = "enterpriseName",required = false)String enterpriseName){
        return new PageVO<EnterpriseAccount>(enterpriseAccountService.queryPageByName(page,pageSize,enterpriseName));
    }

    @ApiOperation("新增账号")
    @PostMapping("/add")
    public boolean add(@RequestBody AddEnterpriseAccountVO addEnterpriseAccountVO){
        //bean拷贝
        EnterpriseAccount enterpriseAccount = new EnterpriseAccount();
        BeanUtils.copyProperties(addEnterpriseAccountVO,enterpriseAccount);

        //设置时间
        LocalDateTime now = LocalDateTime.now();
        enterpriseAccount.setApplicationTime(now);
        //设置过期时间
        LocalDateTime expireTime=null;
        if(addEnterpriseAccountVO.getStatus()==0){
            //试用账号
            expireTime=now.plusDays(7);
        }
        if(addEnterpriseAccountVO.getStatus()==1){
            //设置到期时间
            expireTime=now.plusDays(addEnterpriseAccountVO.getValidityDay());
        }
        if(expireTime!=null){
            enterpriseAccount.setExpireTime(expireTime);
        }else {
            throw new RuntimeException("账号类型信息设置有误");
        }
        return enterpriseAccountService.add(enterpriseAccount);
    }

    //根据id查询账号信息
    @ApiOperation("账号查询")
    @GetMapping("/getById/{id}")
    public EnterpriseAccount getById(@PathVariable("id")String id){
        EnterpriseAccount account = enterpriseAccountService.getById(id);
        LocalDateTime expireTime = account.getExpireTime();
        LocalDateTime applicationTime = account.getApplicationTime();
        int validityDay=(int)(expireTime.toLocalDate().toEpochDay()-applicationTime.toLocalDate().toEpochDay());
        account.setValidityDay(validityDay);
        return account;
    }

    //账号修改
    @ApiOperation("账号编辑")
    @PutMapping("/update")
    public Result update(@RequestBody UpdateEnterpriseAccountVO updateEnterpriseAccountVO){
        Result result = new Result();

        //查询原有企业id
        EnterpriseAccount enterpriseAccount = enterpriseAccountService.getById(updateEnterpriseAccountVO.getEnterpriseId());
        if(enterpriseAccount==null){
            result.setStatus(ResultCode.error);
            result.setDesc("修改账号不存在");
            return result;
        }

        //修改用户状态信息
        if(updateEnterpriseAccountVO.getStatus()!=null){
            //正式期不能修改为正式期
            if(updateEnterpriseAccountVO.getStatus()==0&&enterpriseAccount.getStatus()==1){
                result.setStatus(ResultCode.error);
                result.setDesc("不能将正式期的账号修改为试用期");
                return result;
            }

            //试用修改正式
            if(updateEnterpriseAccountVO.getStatus()==1 && enterpriseAccount.getStatus()==0){
                //到期时间
                LocalDateTime localDateTime = LocalDateTime.now();
                //
                LocalDateTime expireTime = localDateTime.plusDays(updateEnterpriseAccountVO.getValidityDay());
                enterpriseAccount.setApplicationTime(localDateTime);
                enterpriseAccount.setExpireTime(expireTime);

                //正式添加延期
                if(updateEnterpriseAccountVO.getStatus()==1 && enterpriseAccount.getStatus()==1){
                    LocalDateTime localDateTime1 = LocalDateTime.now();
                    //设置到期时间
                    LocalDateTime localDateTime2 = localDateTime1.plusDays(updateEnterpriseAccountVO.getValidityDay());
                    enterpriseAccount.setExpireTime(localDateTime2);
                }
            }
        }
        //其他字段，bean拷贝
        BeanUtils.copyProperties(updateEnterpriseAccountVO,enterpriseAccount);
        boolean flag = enterpriseAccountService.updateById(enterpriseAccount);
        if (flag){
            //修改成功
            result.setStatus(ResultCode.success);
            result.setDesc("修改成功");
            return result;
        }else {
            result.setStatus(ResultCode.error);
            result.setDesc("修改失败");
            return result;
        }
    }

    //账号删除
    @ApiOperation("账号删除")
    @DeleteMapping("/deleteById/{id}")
    public boolean deleteById(@PathVariable("id")String id){
        return enterpriseAccountService.removeById(id);
    }

    //账号还原
    @ApiOperation("账号还原")
    @PutMapping("/recovery/{id}")
    public boolean recovery(@PathVariable("id") String id){
        return enterpriseAccountService.recovery(id);
    }

    //账号禁用
    @ApiOperation("账号禁用")
    @PutMapping("/forbidden/{id}")
    public boolean forbidden(@PathVariable("id") String id){
        //查询原有的账户
        EnterpriseAccount enterpriseAccount = enterpriseAccountService.getById(id);
        enterpriseAccount.setStatus(AccountStatus.Forbidden.getStatus());
        return enterpriseAccountService.updateById(enterpriseAccount);
    }

    //账号禁用
    @ApiOperation("账号启用")
    @PutMapping("/enable/{id}")
    public boolean open(@PathVariable("id") String id){
        //查询原有的账户
        EnterpriseAccount enterpriseAccount = enterpriseAccountService.getById(id);
        enterpriseAccount.setStatus(AccountStatus.Official.getStatus());
        return enterpriseAccountService.updateById(enterpriseAccount);
    }



    //重置密码
    @ApiOperation("重置密码")
    @PutMapping("/restPwd")
    public boolean restPwd(@RequestBody ResetPwdVO resetPwdVO){
        return enterpriseAccountService.restPwd(resetPwdVO.getId(),resetPwdVO.getPwd());
    }
}
