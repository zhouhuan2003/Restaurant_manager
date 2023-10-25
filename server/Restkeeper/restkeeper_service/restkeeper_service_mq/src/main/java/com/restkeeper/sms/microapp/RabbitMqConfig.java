package com.restkeeper.sms.microapp;/*
 *@author 周欢
 *@version 1.0
 */


import com.restkeeper.constants.SystemCode;
import org.springframework.amqp.core.TopicExchange;
import org.springframework.context.annotation.Bean;
import org.springframework.stereotype.Component;

@Component
public class RabbitMqConfig{
    /**
     * 定义H5点餐交换机
     * @return
     */
    @Bean
    public TopicExchange vendoutExchange(){
        return new TopicExchange(SystemCode.MICROSOFT_EXCHANGE_NAME,true,false);
    }
}
