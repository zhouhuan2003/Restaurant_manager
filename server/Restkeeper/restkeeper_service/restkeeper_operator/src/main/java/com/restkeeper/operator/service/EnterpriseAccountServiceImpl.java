package com.restkeeper.operator.service;/*
 *@author 周欢
 *@version 1.0
 */

import com.alibaba.fastjson.JSON;
import com.alibaba.fastjson.JSONObject;
import com.baomidou.mybatisplus.core.conditions.query.QueryWrapper;
import com.baomidou.mybatisplus.core.metadata.IPage;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.google.common.collect.Maps;
import com.restkeeper.constants.SystemCode;
import com.restkeeper.operator.config.RabbitMQConfig;
import com.restkeeper.operator.entity.EnterpriseAccount;
import com.restkeeper.operator.mapper.EnterpriseAccountMapper;
import com.restkeeper.sms.SmsObject;
import com.restkeeper.utils.*;
import org.apache.commons.codec.digest.Md5Crypt;
import org.apache.commons.lang.RandomStringUtils;
import org.apache.commons.lang.StringUtils;
import org.apache.dubbo.config.annotation.Service;
import org.springframework.amqp.rabbit.core.RabbitTemplate;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.cloud.context.config.annotation.RefreshScope;
import org.springframework.transaction.annotation.Transactional;

import java.io.IOException;
import java.util.HashMap;
import java.util.Map;

@Service(version = "1.0.0",protocol = "dubbo")
@RefreshScope
public class EnterpriseAccountServiceImpl extends ServiceImpl<EnterpriseAccountMapper,EnterpriseAccount> implements EnterpriseAccountService {

    @Autowired
    private RabbitTemplate rabbitTemplate;

    @Value("${sms.operator.signName}")
    private String signName;

    @Value("${sms.operator.templateCode}")
    private String templateCode;

    @Value("${gateway.secret}")
    private String secret;

    //消息发生
    private void sendMessage(String email,String phone,String shopId,String pwd){
        SmsObject smsObject = new SmsObject();
        smsObject.setEmail(email);
//        smsObject.setSignName(signName);
//        smsObject.setTemplateCode(templateCode);
//        JSONObject jsonObject = new JSONObject();
//        jsonObject.put("shopId",shopId);
//        jsonObject.put("pwd",pwd);
//        smsObject.setTemplateJsonParam(jsonObject.toJSONString());
        smsObject.setTemplateJsonParam("集团创建/修改成功，您的登录账户为手机号:"+phone+"，商铺id为:"+shopId+"，密码为:"+pwd);
        rabbitTemplate.convertAndSend(RabbitMQConfig.ACCOUNT_QUEUE, JSON.toJSONString(smsObject));
    }

    /**
     * 按照企业名称进行模糊查询并分页
     * @param pageNum
     * @param pageSize
     * @param enterpriseName
     * @return
     */
    @Override
    public IPage<EnterpriseAccount> queryPageByName(int pageNum, int pageSize, String enterpriseName) {
        Page<EnterpriseAccount> page = new Page<>(pageNum, pageSize);
        QueryWrapper<EnterpriseAccount> queryWrapper = null;
        if(StringUtils.isNotEmpty(enterpriseName)){
            queryWrapper = new QueryWrapper<>();
            queryWrapper.like("enterprise_name",enterpriseName);
        }
        return this.page(page,queryWrapper);
    }

    /**
     * 增加账号
     * @param enterpriseAccount
     * @return
     */
    @Override
    @Transactional
    public boolean add(EnterpriseAccount enterpriseAccount) {
        boolean flag=true;
        try {
            //账号，密码特殊处理
            String shopId=getShopId();
            enterpriseAccount.setShopId(shopId);

            //生成密码
            String pwd=RandomStringUtils.randomNumeric(6);
            enterpriseAccount.setPassword(Md5Crypt.md5Crypt(pwd.getBytes()));
            //保存
            this.save(enterpriseAccount);

            //发送消息
            sendMessage(enterpriseAccount.getEmail(),enterpriseAccount.getPhone(),shopId,pwd);
        }catch (Exception e){
            flag=false;
            throw e;
        }
        return flag;
    }

    /**
     * 账号的还原
     * @param id
     * @return
     */
    @Override
    @Transactional
    public boolean recovery(String id) {
        return this.getBaseMapper().recovery(id);
    }

    /**
     * 重置密码
     * @param id
     * @param password
     * @return
     */
    @Override
    @Transactional
    public boolean restPwd(String id, String password) {
        boolean flag=true;
        try {
            //查询原有的账号信息
            EnterpriseAccount enterpriseAccount = this.getById(id);
            if(enterpriseAccount==null){
                return false;
            }
            String newPwd;
            if(StringUtils.isNotEmpty(password)){
                //自定义密码
                newPwd =password;
            }else {
                newPwd=RandomStringUtils.randomNumeric(6);
            }
            enterpriseAccount.setPassword(Md5Crypt.md5Crypt(newPwd.getBytes()));
            this.updateById(enterpriseAccount);

            //发送消息
            sendMessage(enterpriseAccount.getEmail(),enterpriseAccount.getPhone(),enterpriseAccount.getShopId(),newPwd);
        }catch (Exception e){
            e.printStackTrace();
            flag=false;
            throw e;
        }
        return flag;
    }

    //登录
    @Override
    public Result login(String shopId, String phone, String loginPass) {
        Result result = new Result();

        //参数校验
        if(!StringUtils.isNotEmpty(shopId)){
            result.setStatus(ResultCode.error);
            result.setDesc("商户号未输入");
            return result;
        }
        if(!StringUtils.isNotEmpty(phone)){
            result.setStatus(ResultCode.error);
            result.setDesc("手机号未输入");
            return result;
        }
        if(!StringUtils.isNotEmpty(loginPass)){
            result.setStatus(ResultCode.error);
            result.setDesc("密未输入");
            return result;
        }

        //查询用户信息
        QueryWrapper<EnterpriseAccount> queryWrapper = new QueryWrapper<>();
        queryWrapper.lambda().eq(EnterpriseAccount::getPhone,phone)
                .eq(EnterpriseAccount::getShopId,shopId);
        //未禁用的状态
        queryWrapper.lambda().notIn(EnterpriseAccount::getStatus, AccountStatus.Forbidden.getStatus());
        EnterpriseAccount enterpriseAccount = this.getOne(queryWrapper);
        if(enterpriseAccount==null){
            result.setStatus(ResultCode.error);
            result.setDesc("账号不存在");
            return result;
        }
        //密码的校验
        String salts = MD5CryptUtil.getSalts(enterpriseAccount.getPassword());
        if(!Md5Crypt.md5Crypt(loginPass.getBytes(),salts).equals(enterpriseAccount.getPassword())){
            result.setStatus(ResultCode.error);
            result.setDesc("密码不正确");
            return result;
        }
        //令牌的生成
        Map<String ,Object> tokenInfo= Maps.newHashMap();
        tokenInfo.put("shopId",enterpriseAccount.getShopId());
        tokenInfo.put("loginName",enterpriseAccount.getEnterpriseName());
        tokenInfo.put("loginType", SystemCode.USER_TYPE_SHOP);
        String token=null;
        try {
            token=JWTUtil.createJWTByObj(tokenInfo,secret);
        } catch (IOException e) {
            e.printStackTrace();
            log.error("加密失败："+e.getMessage());
            result.setStatus(ResultCode.error);
            result.setDesc("生成令牌失败");
            return result;
        }
        result.setStatus(ResultCode.success);
        result.setDesc("ok");
        result.setData(enterpriseAccount);
        result.setToken(token);
        return result;
    }

    //获取shopId
    private String getShopId() {
        //随机的8位数字
        String shopId= RandomStringUtils.randomNumeric(8);

        //店铺校验
        EnterpriseAccount enterpriseAccount = this.getOne(new QueryWrapper<EnterpriseAccount>().eq("shop_id", shopId));
        if (enterpriseAccount!=null){
            this.getShopId();
        }
        return shopId;
    }
}
