package com.restKeeper;/*
 *@author 周欢
 *@version 1.0
 */

import com.alibaba.druid.sql.ast.SQLExpr;
import com.alibaba.druid.sql.ast.expr.SQLQueryExpr;
import com.alibaba.druid.sql.dialect.mysql.ast.statement.MySqlSelectQueryBlock;
import com.alibaba.druid.sql.parser.SQLExprParser;
import org.apache.http.HttpHost;
import org.elasticsearch.action.search.SearchRequest;
import org.elasticsearch.action.search.SearchResponse;
import org.elasticsearch.client.RequestOptions;
import org.elasticsearch.client.RestClient;
import org.elasticsearch.client.RestHighLevelClient;
import org.elasticsearch.common.unit.Fuzziness;
import org.elasticsearch.index.query.*;
import org.elasticsearch.search.SearchHits;
import org.elasticsearch.search.builder.SearchSourceBuilder;
import org.elasticsearch.search.sort.SortOrder;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.nlpcn.es4sql.domain.Where;
import org.nlpcn.es4sql.exception.SqlParseException;
import org.nlpcn.es4sql.parse.ElasticSqlExprParser;
import org.nlpcn.es4sql.parse.SqlParser;
import org.nlpcn.es4sql.parse.WhereParser;
import org.nlpcn.es4sql.query.maker.QueryMaker;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.context.junit4.SpringRunner;

import java.io.IOException;
import java.io.StringReader;

@SpringBootTest
@RunWith(SpringRunner.class)
public class test {


    @Test
    public void testMatchAll() throws IOException {
        RestHighLevelClient restHighLevelClient = new RestHighLevelClient(RestClient.builder(new HttpHost("192.168.150.135",9200,"http")));

        //1.创建 SearchRequest搜索请求
        SearchRequest searchRequest = new SearchRequest();
        searchRequest.indices("dish");//指定要查询的索引

        //2.创建 SearchSourceBuilder条件构造。builder模式这里就先不简写了
        //2.创建 SearchSourceBuilder条件构造。
        SearchSourceBuilder searchSourceBuilder = new SearchSourceBuilder();

        BoolQueryBuilder boolQueryBuilder = QueryBuilders.boolQuery();
//        BoolQueryBuilder boolQueryBuilder = null;

        searchSourceBuilder.query(QueryBuilders.matchAllQuery());
//
//        TermQueryBuilder termQuery = QueryBuilders.termQuery("store_id", "1639437749018578945");
//        TermQueryBuilder termQuery1 = QueryBuilders.termQuery("shop_id", "01854018");
        WildcardQueryBuilder termQuery3 = QueryBuilders.wildcardQuery("code", "*te*");

        //Fuzzy 查找
//        FuzzyQueryBuilder fuzzyQueryBuilder = QueryBuilders.fuzzyQuery("code", "KAOSH").fuzziness(Fuzziness.AUTO);
//        boolQueryBuilder.must(termQuery);
//        boolQueryBuilder.must(termQuery1);
        boolQueryBuilder.must(termQuery3);
        searchSourceBuilder.query(boolQueryBuilder);
//        searchSourceBuilder.query(QueryBuilders.multiMatchQuery("code","KA"));
        //设置分页
        searchSourceBuilder.from(0);
        searchSourceBuilder.size(2);
//
//        //年龄倒序
//        searchSourceBuilder.sort("last_update_time", SortOrder.DESC);
//        try {
//            SqlParser sqlParser = new SqlParser();
//            String sql="select * from dish where 1=1 and code.keyword like '%te%' and is_deleted=0 and shop_id='01854018' and store_id ='1639437749018578945' order by last_update_time desc";
//            SQLExprParser parser = new ElasticSqlExprParser(sql);
//            SQLQueryExpr sqlQueryExpr = (SQLQueryExpr) parser.expr();
//            MySqlSelectQueryBlock query = (MySqlSelectQueryBlock) sqlQueryExpr.getSubQuery().getQuery();
//
//            WhereParser whereParser = new WhereParser(sqlParser,query);
//            Where where = whereParser.findWhere();
//            boolQueryBuilder = QueryMaker.explan(where);
//        } catch (SqlParseException e) {
//            e.printStackTrace();
//        }
//        searchSourceBuilder.query(boolQueryBuilder);

        //3.将 SearchSourceBuilder 添加到 SearchRequest中
        searchRequest.source(searchSourceBuilder);

        //4.执行查询
        SearchResponse searchResponse = restHighLevelClient.search(searchRequest, RequestOptions.DEFAULT);

        //5.解析查询结果
        System.out.println(searchResponse);
        System.out.println("花费的时长：" + searchResponse.getTook());

        SearchHits hits = searchResponse.getHits();
        System.out.println(hits.getTotalHits());
        System.out.println("符合条件的总文档数量：" + hits.getTotalHits().value);
        hits.forEach(p -> System.out.println("文档原生信息：" + p.getSourceAsString()));
    }

}
