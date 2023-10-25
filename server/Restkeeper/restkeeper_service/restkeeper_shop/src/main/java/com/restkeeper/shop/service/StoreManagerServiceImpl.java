package com.restkeeper.shop.service;

import com.alibaba.fastjson.JSON;
import com.alibaba.fastjson.JSONObject;
import com.baomidou.mybatisplus.core.conditions.query.QueryWrapper;
import com.baomidou.mybatisplus.core.conditions.update.UpdateWrapper;
import com.baomidou.mybatisplus.core.metadata.IPage;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.google.common.collect.Maps;
import com.restkeeper.constants.SystemCode;
import com.restkeeper.shop.entity.Store;
import com.restkeeper.shop.entity.StoreManager;
import com.restkeeper.shop.mapper.StoreManagerMapper;
import com.restkeeper.sms.SmsObject;
import com.restkeeper.utils.JWTUtil;
import com.restkeeper.utils.MD5CryptUtil;
import com.restkeeper.utils.Result;
import com.restkeeper.utils.ResultCode;
import org.apache.commons.codec.digest.Md5Crypt;
import org.apache.commons.lang.RandomStringUtils;
import org.apache.commons.lang.StringUtils;
import org.apache.dubbo.config.annotation.Service;
import org.apache.dubbo.rpc.RpcContext;
import org.springframework.amqp.rabbit.core.RabbitTemplate;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.transaction.annotation.Transactional;

import java.io.IOException;
import java.util.List;
import java.util.Map;

@Service(version = "1.0.0",protocol = "dubbo")
public class StoreManagerServiceImpl extends ServiceImpl<StoreManagerMapper, StoreManager> implements IStoreManagerService {

    @Value("${gateway.secret}")
    private String secret;

    @Autowired
    @Qualifier("storeService")
    private IStoreService storeService;


    @Override
    public IPage<StoreManager> queryPageByCriteria(int pageNo, int pageSize, String criteria) {
        IPage<StoreManager> page = new Page<>(pageNo,pageSize);

        QueryWrapper<StoreManager> queryWrapper = new QueryWrapper<>();
        if (StringUtils.isNotEmpty(criteria)){
            queryWrapper.lambda().eq(StoreManager::getStoreManagerPhone,criteria).or().eq(StoreManager::getStoreManagerName,criteria);
        }
        return this.page(page,queryWrapper);
    }

    @Override
    @Transactional
    public boolean addStoreManager(String name,String email, String phone, List<String> storeIds) {
        boolean flag = true;
        try {

            //新增店长信息
            StoreManager manager = new StoreManager();
            manager.setStoreManagerName(name);
            manager.setStoreManagerEmail(email);
            manager.setStoreManagerPhone(phone);
            String pwd = RandomStringUtils.randomNumeric(8);
//            String pwd="123456";
            manager.setPassword(Md5Crypt.md5Crypt(pwd.getBytes()));
            this.save(manager);

            //修改store，一个门店只能一个管理员
            String storeManagerId = manager.getStoreManagerId();
            UpdateWrapper<Store> updateWrapper = new UpdateWrapper<Store>();
            updateWrapper.lambda().in(Store::getStoreId,storeIds).set(Store::getStoreManagerId,storeManagerId);
            flag = storeService.update(updateWrapper);
            if(flag){
                String shopId = RpcContext.getContext().getAttachment("shopId");
                sendMessage(email,phone,shopId,pwd);
            }
        }catch (Exception ex){
            flag = false;
            throw ex;
        }
        return flag;
    }


    //逻辑删除
    @Override
    @Transactional
    public boolean deleteStoreManager(String storeManagerId) {

        //逻辑删除
        this.removeById(storeManagerId);

        //去除与门店的关联关系
        UpdateWrapper<Store> updateWrapper = new UpdateWrapper<>();
        updateWrapper.lambda().set(Store::getStoreManagerId,null).eq(Store::getStoreManagerId,storeManagerId);
        return storeService.update(updateWrapper);
    }

    //暂停、启用
    @Override
    @Transactional
    public boolean pauseStoreManager(String storeManagerId,int status) {
        UpdateWrapper<StoreManager> updateWrapper = new UpdateWrapper<>();
        if(status==1){
            updateWrapper.lambda().set(StoreManager::getStatus,SystemCode.FORBIDDEN).eq(StoreManager::getStoreManagerId,storeManagerId);
        }else {
            updateWrapper.lambda().set(StoreManager::getStatus,SystemCode.ENABLED).eq(StoreManager::getStoreManagerId,storeManagerId);
        }

        return this.update(updateWrapper);
    }

    @Override
    public Result login(String shopId, String phone, String loginPass) {

        Result result = new Result();

        //参数校验
        if (StringUtils.isEmpty(shopId)){
            result.setStatus(ResultCode.error);
            result.setDesc("商铺号为空");
            return result;
        }
        if (StringUtils.isEmpty(phone)){
            result.setStatus(ResultCode.error);
            result.setDesc("手机号为空");
            return result;
        }
        if (StringUtils.isEmpty(loginPass)){
            result.setStatus(ResultCode.error);
            result.setDesc("密码为空");
            return result;
        }

        //查询门店管理员信息
        QueryWrapper<StoreManager> queryWrapper = new QueryWrapper<>();
        queryWrapper.lambda().eq(StoreManager::getStoreManagerPhone,phone)
                .eq(StoreManager::getShopId,shopId);

        RpcContext.getContext().setAttachment("shopId",shopId);

        StoreManager storeManager = this.getOne(queryWrapper);
        if (storeManager == null){
            result.setStatus(ResultCode.error);
            result.setDesc("门店管理员不存在");
            return result;
        }
        //获取被关联的门店信息
        List<Store> stores = storeManager.getStores();
        if (stores == null || stores.isEmpty()){
            result.setStatus(ResultCode.error);
            result.setDesc("没有门店信息");
            return result;
        }
        Store store = stores.get(0);

        //密码校验
        String salts = MD5CryptUtil.getSalts(storeManager.getPassword());
        if (!Md5Crypt.md5Crypt(loginPass.getBytes(),salts).equals(storeManager.getPassword())){
            result.setStatus(ResultCode.error);
            result.setDesc("密码错误");
            return result;
        }

        //令牌生成
        Map<String,Object> tokenMap = Maps.newHashMap();
        tokenMap.put("shopId",shopId);
        tokenMap.put("storeId",store.getStoreId());
        tokenMap.put("loginUserId",storeManager.getStoreManagerId());
        tokenMap.put("loginUserName", storeManager.getStoreManagerName());
        tokenMap.put("userType",SystemCode.USER_TYPE_STORE_MANAGER); //门店管理员用户
        String tokenInfo = "";
        try {
            tokenInfo = JWTUtil.createJWTByObj(tokenMap,secret);
        } catch (IOException e) {
            e.printStackTrace();
            result.setStatus(ResultCode.error);
            result.setDesc("令牌生成失败");
            return result;
        }

        result.setStatus(ResultCode.success);
        result.setDesc("ok");
        result.setData(storeManager);
        result.setToken(tokenInfo);
        return result;
    }


    @Override
    @Transactional
    public boolean updateStoreManager(String storeManagerId,String email, String name, String phone, List<String> storeIds) {
        boolean flag = true;
        try{
            //查询管理员信息
            StoreManager storeManager = this.getById(storeManagerId);

            //修改管理员信息
            if(!StringUtils.isEmpty(name)) {
                storeManager.setStoreManagerName(name);
            }
            if(!StringUtils.isEmpty(phone)) {
                storeManager.setStoreManagerPhone(phone);
            }
            this.updateById(storeManager);

            //去除原有管理员与门店关联关系
            UpdateWrapper<Store> updateWrapper_pre = new UpdateWrapper<>();
            updateWrapper_pre.lambda().set(Store::getStoreManagerId,null).eq(Store::getStoreManagerId,storeManagerId);
            storeService.update(updateWrapper_pre);

            //重建管理员与门店关联关系
            UpdateWrapper<Store> updateWrapper_new = new UpdateWrapper<>();
            updateWrapper_new.lambda().in(Store::getStoreId,storeIds).set(Store::getStoreManagerId,storeManagerId);
            storeService.update(updateWrapper_new);

        }catch (Exception e){
            log.error(e.getMessage());
            flag =false;

        }
        return flag;
    }

    @Value("${sms.operator.signName}")
    private String signName;

    @Value("${sms.operator.templateCode}")
    private String templateCode;

    @Autowired
    private RabbitTemplate rabbitTemplate;

    //发送短信
    private void sendMessage(String email,String phone, String shopId, String pwd) {
        SmsObject smsObject = new SmsObject();
        smsObject.setEmail(email);
//        smsObject.setSignName(signName);
//        smsObject.setSignName(templateCode);
//        JSONObject jsonObject = new JSONObject();
//        jsonObject.put("shopId",shopId);
//        jsonObject.put("password", pwd);
        smsObject.setTemplateJsonParam("店长您好，您的登录账户为手机号:"+phone+"，商铺id为:"+shopId+"，密码为:"+pwd);
        rabbitTemplate.convertAndSend(SystemCode.SMS_ACCOUNT_QUEUE, JSON.toJSONString(smsObject));
    }
}
