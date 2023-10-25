<template>
  <div class="dashboard-container">
    <div class="topLable">
      <div class="tit">统计时间：00：00 - 24：00</div>
    </div>
    <div class="container">
      <div class="topDataBox">
        <div class="box nowData">
          <div class="icon">
            <img
              src="@/assets/icons/xiangmujine@2x.png"
              width="45"
              height="43"
              alt=""
            />
          </div>
          <div class="item">
            <div>实收金额</div>
            <div>{{amountData.payTotal}}元</div>
            <!-- <div>较前一日</div> -->
          </div>
        </div>
        <div class="box noData">
          <div class="icon">
            <img src="@/assets/icons/jine_m-2@2x.png" width="50" alt="" />
          </div>
          <div class="item">
            <div>未收金额</div>
            <div>{{amountData.noPayTotal}}元</div>
            <!-- <div>较前一日</div> -->
          </div>
        </div>
        <div class="box member">
          <div class="icon">
            <img src="@/assets/icons/renshu@2x.png" width="46" alt="" />
          </div>
          <div class="item">
            <div>就餐总人数</div>
            <div>{{amountData.currentPerson+amountData.totalPerson}}人</div>
            <!-- <div>较前一日</div> -->
          </div>
        </div>
      </div>
      <div class="memberChart">
        <div class="topButBox">
          <span :class="{ butAct:active==1  }" @click="activeChange(1)">按金额</span>
          <span :class="{ butAct:active==2  }" @click="activeChange(2)">按单数</span>
        </div>
        <Basic id="line" :chartData="BasicData" title="时段销售趋势" />
      </div>
    </div>
    <div class="container">
      <div class="chartBox">
        <div class="memberChart">
          <div class="topButBox">
          <span :class="{ butAct:active1==1  }" @click="activeChange1(1)">按金额</span>
          <span :class="{ butAct:active1==2  }" @click="activeChange1(2)">按单数</span>
        </div>
          <BarChart :chartData="CategoryData.dataList" title="菜品分类占比" />
        </div>
        <div>
          <MixedChart :chartData="CurrentDishRankData" title="菜单销售排行" />
        </div>
      </div>
    </div>
    <div class="container">
      <div class="chartBox">
        <div>
          <BarChart id="bar" :chartData="PayTypeData.dataList" title="店内收款构成" />
        </div>
        <div class="itemList">
          <div class="title">优惠指标</div>
          <div class="item topLab">
            <span>优惠合计</span><span>{{privilegeData.total}}元</span>
          </div>
          <div class="item" v-for="(item,index) in privilegeData.dataList" :key="index">
            <span>{{item.name}}</span><span>{{item.value}}元</span><span>{{item.percent=='NaN'? '0%': item.percent}}</span>
          </div>
          <!-- <div class="item">
            <span>赠菜</span><span>190元</span><span>20%</span>
          </div>
          <div class="item">
            <span>抹零</span><span>190元</span><span>20%</span>
          </div> -->
        </div>
      </div>
    </div>
  </div>
</template>

<script lang="ts" setup>
import Line from "@/components/Charts/Line.vue";
import Basic from "@/components/Charts/Basic.vue";
import BarChart from "@/components/Charts/BarChart.vue";
import MixedChart from "@/components/Charts/MixedChart.vue";
import { onMounted, reactive, ref } from "vue";
import { ElMessage } from "element-plus";
import { getDataes,getDayPayType,getDayDataes,getSalesRanking,getDayRanking,getPrivilegeCollect} from "@/request/report";

let amountData=reactive({
  currentPerson:'0',
  noPayTotal:'0',
  noPayTotalCount:'0',
  payTotal:'0',
  payTotalCount:'0',
  totalPerson:'0'
})

const active=ref(1)//时段趋势状态 1：金额 2：数量
const active1=ref(1)//菜品占比状态 1：金额 2：数量

let privilegeData=reactive({
  dataList:[
    {name:'test',value:0,percent:'0%'}
  ],
  total:0
})
const dataTime = ref("");

let BasicData = reactive({
  series:[0,0,0],
  xaxis:["0","1","2"]
});

let CurrentDishRankData = reactive({
  series:[0,0,0],
  xaxis:["0","1","2"]
});

let CategoryData=reactive({
  dataList:[{name:"test",value:"0"}]
})

let PayTypeData=reactive({
  dataList:[{name:"test",value:"0"}]
})

  init();



function init() {
  getHourCollectByType()
  getAmountCollect()
  getCategoryCollect()
  getCurrentDishRank()
  getPayTypeCollect()
  privilegeCollect()
}

//获取当日24小时的销售数据
function getHourCollectByType(){
  getDayDataes({'type':active.value})
    .then((res) => {
      console.log(res);
      BasicData.series=res.data.series
      BasicData.xaxis=res.data.xaxis
    })
    .catch((err) => {
      ElMessage.error("请求出错了：" + err);
    });
}

//获取当日销售数据
function getAmountCollect(){
  getDataes().then(res=>{
    console.log(res,"=======当日销售数据");
  amountData.currentPerson=res.data.currentPerson
  amountData.noPayTotal=res.data.noPayTotal
  amountData.noPayTotalCount=res.data.noPayTotalCount
  amountData.payTotal=res.data.payTotal
  amountData.payTotalCount=res.data.payTotalCount
  amountData.totalPerson=res.data.totalPerson
  })
}

//获取菜品分类占比
function getCategoryCollect() {
  getSalesRanking({'type':active1.value}).then(res=>{
    console.log(res,"=======菜品分类占比");
    CategoryData.dataList=res.data
  })
}

//获取当日菜单销售排行
function getCurrentDishRank(){
  getDayRanking().then(res=>{
    console.log(res,"=======菜单销售排行");
    CurrentDishRankData.series=res.data.series
    CurrentDishRankData.xaxis=res.data.xaxis
  })
}

//获取店内收款构成
function getPayTypeCollect(){
  getDayPayType().then(res=>{
    console.log(res,"=======店内收款构成");
    PayTypeData.dataList=res.data
  })
}

//获取优惠指标
function privilegeCollect(){
  getPrivilegeCollect().then(res=>{
    console.log(res,"=======获取优惠指标");
    privilegeData.dataList=res.data.dataList
    privilegeData.total=res.data.total
  })
}

function activeChange(num:number){
  active.value=num
  getHourCollectByType()
}

function activeChange1(num:number){
  active1.value=num
  getCategoryCollect()
}
</script>
<style lang="scss" scoped>
.butAct{
  background: #3a9bff;
    color: #fff;
}
.dashboard {
  &-container {
    margin: 30px;
    .topLable {
      font-size: 16px;
      background: #fff;
      position: relative;
      z-index: 1;
      padding: 15px 28px;
      margin-bottom: 30px;
      border-radius: 4px;
      .tit {
        line-height: 40px;
        color: #ff984b;
      }
      .dataSelect {
        display: flex;
        justify-content: space-between;
        line-height: 40px;
      }
      .but {
        background: #ff984b;
        display: inline-block;
        color: #fff;
        padding: 0px 20px;
        line-height: 30px;
        height: 30px;
        border-radius: 4px;
        font-size: 14px;
      }
    }
    .container {
      background: #fff;
      position: relative;
      z-index: 1;
      padding: 30px 28px;
      border-radius: 4px;
      margin-bottom: 30px;
      .topDataBox {
        display: flex;
        margin-bottom: 15px;
        .icon {
          width: 80px;
          height: 80px;
          /*padding-top: 15px;*/
          border-radius: 100%;
          background: #fff;
          margin-right: 10px;
          text-align: center;
          display: flex;
          justify-content: center;
          align-items: center;
        }
        .box {
          margin-right: 15px;
          display: flex;
          padding: 15px;
          flex: 1;
          border-radius: 3px;
          color: #fff;
          .item {
            div:nth-child(2) {
              font-size: 18px;
              line-height: 36px;
            }
          }
        }
        .nowData {
          background: #3f9eff;
        }
        .noData {
          background: #ff984b;
        }
        .member {
          margin-right: 0;
          background: #fa7b7b;
        }
      }
      .memberChart{
        width:100%;
        position: relative;
        .topButBox{
          position: absolute;
          top:0;
          right:20px;
          z-index: 999;
          font-size: 14px;
          span{
            margin-left:10px;
            border-radius: 5px;
            cursor: pointer;
          }
      }
      }
      
      .chartBox {
        display: flex;
        div {
          flex: 1;
        }
        .itemList {
          .title {
            font-size: 18px;
            font-weight: bold;
            margin-bottom: 20px;
          }
          .item {
            display: flex;
            line-height: 45px;
            padding: 0 20px;
            border-bottom: solid 1px #f0f1f4;
            span {
              flex: 1;
              text-align: center;
            }
            span:first-child {
              text-align: left;
            }
          }
          .topLab {
            background: #f0f1f4;
            border-radius: 4px;
          }
        }
      }
    }
  }
}
</style>
