package com.restkeeper.controller;/*
 *@author 周欢
 *@version 1.0
 */

import cn.hutool.http.HttpUtil;
import cn.hutool.json.JSONObject;
import cn.hutool.json.JSONUtil;
import io.swagger.annotations.Api;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@Api(tags = {"微信小程序登录接口"})
public class WeixingLoginController {

    @Value("${wx.appId}")
    private String appId;
    @Value("${wx.secret}")
    private String secret;
    @RequestMapping("/user/getOpenId")
    public String getWxOpenId(String code){
        String authUrl="https://api.weixin.qq.com/sns/jscode2session?grant_type=authorization_code";
        authUrl=authUrl+"&appid="+appId+"&secret="+secret+"&js_code="+code;
        String s = HttpUtil.get(authUrl);
        JSONObject jsonObject = JSONUtil.parseObj(s);
        return jsonObject.getStr("openid");
    }
}
