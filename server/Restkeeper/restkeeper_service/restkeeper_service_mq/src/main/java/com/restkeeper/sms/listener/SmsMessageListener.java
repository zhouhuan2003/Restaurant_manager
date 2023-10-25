package com.restkeeper.sms.listener;/*
 *@author 周欢
 *@version 1.0
 */

import com.alibaba.alicloud.sms.ISmsService;
import com.alibaba.fastjson.JSON;
import com.aliyuncs.dysmsapi.model.v20170525.SendSmsRequest;
import com.aliyuncs.dysmsapi.model.v20170525.SendSmsResponse;
import com.aliyuncs.exceptions.ClientException;
import com.restkeeper.constants.SystemCode;
import com.restkeeper.sms.SmsObject;
import lombok.extern.slf4j.Slf4j;
import org.springframework.amqp.rabbit.annotation.RabbitListener;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

import javax.mail.Authenticator;
import javax.mail.MessagingException;
import javax.mail.Session;
import javax.mail.Transport;
import javax.mail.internet.InternetAddress;
import javax.mail.internet.MimeMessage;
import java.util.Properties;

@Component
@Slf4j
public class SmsMessageListener {

    @Autowired
    private ISmsService iSmsService;

    @RabbitListener(queues = SystemCode.SMS_ACCOUNT_QUEUE)
    public void getAccountMessage(String message){
        log.info("发送短信监听类接收到消息："+message);

        //转换参数
        SmsObject smsObject = JSON.parseObject(message, SmsObject.class);

        //基于SMS组件进行短信发送
//        SendSmsResponse sendSmsResponse=this.sendSms(smsObject.getPhoneNumber(),smsObject.getSignName(),smsObject.getTemplateCode(),smsObject.getTemplateJsonParam());

        //基于邮箱进行短信发送
        sendSmsByEmail(smsObject.getEmail(),smsObject.getTemplateJsonParam());
    }

    //发生手机短信
    private SendSmsResponse sendSms(String phoneNumber, String signName, String templateCode, String templateJsonParam) {
        SendSmsRequest request = new SendSmsRequest();
        request.setPhoneNumbers(phoneNumber);
        request.setSignName(signName);
        request.setTemplateCode(templateCode);
        request.setTemplateParam(templateJsonParam);

        SendSmsResponse response;

        try {
            response=iSmsService.sendSmsRequest(request);
        } catch (ClientException e) {
            e.printStackTrace();
            response=new SendSmsResponse();
        }
        return response;
    }

    //邮箱发送
    private void sendSmsByEmail(String recipientEmail,String date){
        String userName="13203050639@163.com";//登录名
        String password="VRVDEICNNALSUTYA";//登陆密码

        //smtp服务器
        Properties pros=new Properties();
        pros.put("mail.smtp.host", "smtp.163.com");//主机名
        pros.put("mail.smtp.port", "25");//主机端口号
        pros.put("mail.smtp.auth", "true");//是否需要用户认证
        pros.put("mail.smtp.starttls.enable", "true");//启用TLS加密
        //创建会话
        Session session=Session.getInstance(pros,new Authenticator(){
            @Override
            protected javax.mail.PasswordAuthentication getPasswordAuthentication(){
                return new javax.mail.PasswordAuthentication(userName, password);
            }
        });
        System.out.println(session);
        //设置debug模式便于调试
        session.setDebug(true);

        MimeMessage message=new MimeMessage(session);
        try {
            //邮件标题
            message.setSubject("餐掌柜");
            //邮件内容(文本)
            message.setText(date,"utf-8");
            //设置发送方地址
            message.setFrom(new InternetAddress("13203050639@163.com"));
            //设置收件方地址
            message.setRecipient(MimeMessage.RecipientType.TO,new InternetAddress(recipientEmail));
            //发送
            Transport.send(message);
        } catch (MessagingException e) {
            e.printStackTrace();
        }
    }
}
