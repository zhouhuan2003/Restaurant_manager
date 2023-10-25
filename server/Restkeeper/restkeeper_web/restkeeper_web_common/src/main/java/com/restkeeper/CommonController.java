package com.restkeeper;/*
 *@author 周欢
 *@version 1.0
 */

import com.restkeeper.utils.PinyinUtil;
import com.restkeeper.utils.Result;
import com.restkeeper.utils.ResultCode;
import io.swagger.annotations.Api;
import io.swagger.annotations.ApiImplicitParam;
import io.swagger.annotations.ApiOperation;
import lombok.extern.slf4j.Slf4j;
import net.sourceforge.pinyin4j.format.exception.BadHanyuPinyinOutputFormatCombination;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@Slf4j
@RestController
@RequestMapping("/common")
@Api(tags = { "通用接口" })
public class CommonController{


    @GetMapping("/toHanyuPinyin/{chineseLanguage}")
    @ApiOperation(value = "中文转换汉语拼音")
    @ApiImplicitParam(paramType="path", name = "chineseLanguage", value = "汉语拼音", required = true, dataType = "String")
    public Result toHanyuPinyin(@PathVariable String chineseLanguage) throws BadHanyuPinyinOutputFormatCombination {
        Result result = new Result();
        result.setStatus(ResultCode.success);
        result.setDesc("ok");
        result.setData(PinyinUtil.toHanyuPinyin(chineseLanguage));
        return  result;
    }
}
