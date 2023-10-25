package com.restkeeper;/*
 *@author 周欢
 *@version 1.0
 */

import org.springframework.data.redis.core.RedisTemplate;
import org.springframework.data.redis.support.atomic.RedisAtomicLong;

import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.concurrent.TimeUnit;


public class SequenceUtils {

    static final int DEFAULT_LENGTH = 4;

    /**
     *
     * @param key 多租户下key =storeId
     * @return
     */
    public static String getSequence(String key) {

        LocalDateTime now = LocalDateTime.now();
        DateTimeFormatter dateTimeFormatter = DateTimeFormatter.ofPattern("yyyyMMdd");
        String date = dateTimeFormatter.format(now);


        //每个门店每天一个新的流水号
        Long seq=getIncrementNum(date+key);
        String str = String.valueOf(seq);
        int len = str.length();
        if (len >= DEFAULT_LENGTH) {// 取决于业务规模,应该不会到达4
            return str;
        }
        int rest = DEFAULT_LENGTH - len;
        StringBuilder sb = new StringBuilder();
        for (int i = 0; i < rest; i++) {
            sb.append('0');
        }
        sb.append(str);
        return date+sb.toString();
    }


    private static Long getIncrementNum(String key) {
        RedisTemplate<String, Object> redisTemplate = (RedisTemplate<String, Object>) SpringUtil.getBeanByName("redisTemplate");
        RedisAtomicLong entityIdCounter = new RedisAtomicLong(key,redisTemplate.getConnectionFactory());
        Long counter = entityIdCounter.incrementAndGet();
        if ((null == counter || counter.longValue() == 1)) {// 初始设置过期时间
            System.out.println("设置过期时间为1天!");
            entityIdCounter.expire(1, TimeUnit.DAYS);// 单位天
        }
        return counter;
    }

    /**
     * 自定义流水
     * @param prefix
     * @return
     */
    public static String getSequenceWithPrefix(String prefix) {
        Long seq=getIncrementNum(prefix);
        String str = String.valueOf(seq);
        int len = str.length();
        if (len >= DEFAULT_LENGTH) {// 取决于业务规模,应该不会到达4
            return str;
        }
        int rest = DEFAULT_LENGTH - len;
        StringBuilder sb = new StringBuilder();
        for (int i = 0; i < rest; i++) {
            sb.append('0');
        }
        sb.append(str);
        return prefix+sb.toString();
    }
}
