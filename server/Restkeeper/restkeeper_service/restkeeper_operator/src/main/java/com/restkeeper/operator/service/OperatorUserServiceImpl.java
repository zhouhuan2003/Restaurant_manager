package com.restkeeper.operator.service;

import com.baomidou.mybatisplus.core.conditions.query.QueryWrapper;
import com.baomidou.mybatisplus.core.metadata.IPage;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.google.common.collect.Maps;
import com.restkeeper.operator.entity.OperatorUser;
import com.restkeeper.operator.mapper.OperatorUserMapper;
import com.restkeeper.utils.JWTUtil;
import com.restkeeper.utils.MD5CryptUtil;
import com.restkeeper.utils.Result;
import com.restkeeper.utils.ResultCode;
import org.apache.commons.codec.digest.Md5Crypt;
import org.apache.dubbo.config.annotation.Service;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.cloud.context.config.annotation.RefreshScope;
import org.springframework.util.StringUtils;

import java.io.IOException;
import java.util.HashMap;
import java.util.Map;

//@Service("operatorUserService")
@Service(version = "1.0.0",protocol = "dubbo")
/**
 * dubbo中支持的协议
 * dubbo 默认
 * rmi
 * hessian
 * http
 * webservice
 * thrift
 * memcached
 * redis
 */
@RefreshScope
public class OperatorUserServiceImpl extends ServiceImpl<OperatorUserMapper, OperatorUser> implements IOperatorUserService{
    @Value("${gateway.secret}")
    private String secret;

    @Override
    public IPage<OperatorUser> queryPateByName(int pageNum, int pageSize, String name) {
        Page<OperatorUser> page = new Page<>(pageNum, pageSize);
        QueryWrapper<OperatorUser> queryWrapper=null;
        if(!StringUtils.isEmpty(name)){
            queryWrapper = new QueryWrapper<>();
            queryWrapper.like("loginname",name);
        }
        return this.page(page,queryWrapper);
    }

    @Override
    public Result login(String loginName, String loginPass) {
        Result result = new Result();

        //参数的校验
        if(StringUtils.isEmpty(loginName)){
            result.setStatus(ResultCode.error);
            result.setDesc("用户名为空");
            return result;
        }

        if(StringUtils.isEmpty(loginPass)){
            result.setStatus(ResultCode.error);
            result.setDesc("密码为空");
            return result;
        }

        //查询用户是否存在
        OperatorUser operatorUser = this.getOne(new QueryWrapper<OperatorUser>().eq("loginname", loginName));
        if(operatorUser==null){
            result.setStatus(ResultCode.error);
            result.setDesc("用户不存在");
            return result;
        }

        //密码校验
        String salts = MD5CryptUtil.getSalts(operatorUser.getLoginpass());
        if(!Md5Crypt.md5Crypt(loginPass.getBytes(),salts).equals(operatorUser.getLoginpass())){
            result.setStatus(ResultCode.error);
            result.setDesc("密码不正确");
            return result;
        }

        //生成jwt令牌
        Map<String,Object> tokenInfo= Maps.newHashMap();
        tokenInfo.put("loginName", operatorUser.getLoginname());

        String token=null;

        try {
            token= JWTUtil.createJWTByObj(tokenInfo,secret);
        } catch (IOException e) {
            e.printStackTrace();
            result.setStatus(ResultCode.error);
            result.setData("生成令牌失败");
            return result;
        }

        result.setStatus(ResultCode.success);
        result.setDesc("ok");
        result.setData(operatorUser);
        result.setToken(token);
        return result;
    }
}
