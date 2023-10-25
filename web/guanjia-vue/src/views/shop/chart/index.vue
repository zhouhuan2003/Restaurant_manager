<template>
  <div class="dashboard-container">
    <div class="headBut">
      <span :class="{ act: act === 'day' }" @click="dateAct('day')">日报</span>
      <span :class="{ act: act === 'week' }" @click="dateAct('week')"
        >周报</span
      >
      <span :class="{ act: act === 'mouth' }" @click="dateAct('mouth')"
        >月报</span
      >
    </div>

    <div class="topLable">
      <div class="tit">统计时间：00：00 - 24：00</div>
      <div v-if="act === 'day'" class="dataSelect">
        <div>
          <span>前一天</span>
          <el-date-picker
            v-model="dataTime"
            size="mini"
            type="date"
            placeholder="选择日期"
            @change="change"
          />
          <span>后一天</span>
        </div>
        <div><span class="but">查看今日数据</span></div>
      </div>
      <div v-if="act === 'week'" class="dataSelect">
        <div>
          <span>前一周</span>
          <el-date-picker
            v-model="dataTime"
            size="mini"
            type="week"
            format="YYYY 第 ww 周"
            placeholder="选择周"
            @change="change"
          />
          <span>后一周</span>
        </div>
        <div><span class="but">查看本周数据</span></div>
      </div>
      <div v-if="act === 'mouth'" class="dataSelect">
        <div>
          <span>前一月</span>
          <el-date-picker
            v-model="dataTime"
            size="mini"
            type="month"
            placeholder="选择月"
            @change="change"
          />
          <span>后一月</span>
        </div>
        <div><span class="but">查看本月数据</span></div>
      </div>
    </div>
    <div class="container">
      <div class="topDataBox" v-if="act=='day'">
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
            <div>{{ topData.payTotal || 0 }}元</div>
            <div>较前一日 0%</div>
          </div>
        </div>
        <div class="box noData">
          <div class="icon">
            <img src="@/assets/icons/jine_m-2@2x.png" width="50" alt="" />
          </div>
          <div class="item">
            <div>未收金额</div>
            <div>{{ topData.noPayTotal || 0 }}元</div>
            <div>较前一日 0%</div>
          </div>
        </div>
        <div class="box member">
          <div class="icon">
            <img src="@/assets/icons/renshu@2x.png" width="46" alt="" />
          </div>
          <div class="item">
            <div>就餐人数</div>
            <div>{{ topData.totalPerson + topData.currentPerson || 0 }}人</div>
            <div>较前一日 0%</div>
          </div>
        </div>
      </div>
      <div class="memberChart">
        <div class="topButBox">
          <span :class="{ butAct: active == 1 }" @click="activeChange(1)"
            >按金额</span
          >
          <span :class="{ butAct: active == 2 }" @click="activeChange(2)"
            >按单数</span
          >
        </div>
        <Basic id="line" :chartData="BasicData" title="时段销售趋势" />
      </div>
    </div>
    <div class="container">
      <div class="chartBox">
        <div class="memberChart">
          <div class="topButBox">
            <span :class="{ butAct: active1 == 1 }" @click="activeChange1(1)"
              >按金额</span
            >
            <span :class="{ butAct: active1 == 2 }" @click="activeChange1(2)"
              >按单数</span
            >
          </div>
          <BarChart :chartData="CategoryData.dataList" title="菜品分类占比" />
        </div>
        <div>
          <MixedChart
            :chartData="CurrentDishRankData"
            title="菜单销售排行"
          />
        </div>
      </div>
    </div>
    <div class="container">
      <div class="chartBox">
        <div>
          <BarChart
            id="bar"
            :chartData="PayTypeData.dataList"
            title="店内收款构成"
          />
        </div>
        <div class="itemList">
          <div class="title">优惠指标</div>
          <div class="item topLab">
             <span>优惠合计</span><span>{{privilegeData.total}}元</span>
          </div>
          <div class="item" v-for="(item,index) in privilegeData.dataList" :key="index">
            <span>{{item.name}}</span><span>{{item.value}}元</span><span>{{item.percent=='NaN'? '0%': item.percent}}%</span>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script lang="ts" setup>
import Basic from "@/components/Charts/Basic.vue";
import BarChart from "@/components/Charts/BarChart.vue";
import MixedChart from "@/components/Charts/MixedChart.vue";
import moment from "moment";
import {
  getDataes,
  getTimeQuantumDataes,
  getTimeQuantumReceivables,
  getTimeQuantumType,
  getTimeQuantumDishes,
  getTimeQuantumDiscount,
} from "@/request/report";
import { ElMessage } from "element-plus";
import { reactive, ref } from "vue";
import { en } from "element-plus/es/locale";
let dataTime = ref("");
let dataTime1 = ref("");
let start = ref("");
let end = ref("");
// const moment = moment
const Today = moment().format("YYYY-MM-DD");
const month = [
  moment().startOf("month").format("YYYY-MM-DD"),
  moment().endOf("month").format("YYYY-MM-DD"),
];
const week = [
  moment().startOf("week").add(1, "day").format("YYYY-MM-DD"),
  moment().endOf("week").add(1, "day").format("YYYY-MM-DD"),
];
let topData = reactive({
  currentPerson: "0",
  noPayTotal: "0",
  noPayTotalCount: "0",
  payTotal: "0",
  payTotalCount: "0",
  totalPerson: "0",
});
const act = ref("week");
const active = ref(1); //时段趋势状态 1：金额 2：数量
const active1 = ref(1); //菜品占比状态 1：金额 2：数量

let privilegeData = reactive({
  dataList: [{ name: "test", value: 0, percent: "0%" }],
  total: 0,
});

let BasicData = reactive({
  series: [0, 0, 0],
  xaxis: ["0", "1", "2"],
});

let CurrentDishRankData = reactive({
  series: [0, 0, 0],
  xaxis: ["0", "1", "2"],
});

let CategoryData = reactive({
  dataList: [{ name: "test", value: "0" }],
});

let PayTypeData = reactive({
  dataList: [{ name: "test", value: "0" }],
});

init();

function change(data: any) {
  dataTime1.value = data;
  dataTime1.value = Today;
  start.value = dataTime1.value;
  end.value = dataTime1.value;
  getDateTime1();
  init();
}
dataTime.value = Today;
function init() {
  getDateTime1();
  getAmountCollect();
  getDateDataes();
  getCategoryCollect();
  getCurrentDishRank()
  getPayTypeCollect()
  privilegeCollect()
}

//获取当日销售数据
function getAmountCollect() {
  getDataes().then((res) => {
    console.log(res, "=======当日销售数据");
    topData.currentPerson = res.data.currentPerson;
    topData.noPayTotal = res.data.noPayTotal;
    topData.noPayTotalCount = res.data.noPayTotalCount;
    topData.payTotal = res.data.payTotal;
    topData.payTotalCount = res.data.payTotalCount;
    topData.totalPerson = res.data.totalPerson;
  });
}

//获取一定日期的销售趋势
function getDateDataes() {
  getDateTime1();
  console.log(start.value, end.value);
  getTimeQuantumDataes({
    type: active.value,
    start: start.value,
    end: end.value,
  })
    .then((res) => {
      console.log("一定日期的销售趋势", res);
      BasicData.series = res.data.series;
      BasicData.xaxis = res.data.xaxis;
    })
    .catch((error) => {
      ElMessage.error("数据错误", error);
    });
}

//获取一定日期的菜品分类销售
function getCategoryCollect() {
  getTimeQuantumType({
    type: active1.value,
    start: start.value,
    end: end.value,
  }).then((res) => {
    CategoryData.dataList = res.data;
  });
}

//获取一定日期的菜品销售排行
function getCurrentDishRank(){
    getTimeQuantumDishes({start:start.value,end:end.value}).then(res=>{
        console.log(res,"=======菜单销售排行");
    CurrentDishRankData.series=res.data.series
    CurrentDishRankData.xaxis=res.data.xaxis
    })
}

//获取一定日期店内收款
function getPayTypeCollect(){
    getTimeQuantumReceivables({start:start.value,end:end.value}).then(res=>{
        console.log(res,"=======店内收款构成");
    PayTypeData.dataList=res.data
    })
}

//获一定日期取优惠指标
function privilegeCollect(){
  getTimeQuantumDiscount({start:start.value,end:end.value}).then(res=>{
    console.log(res,"=======获取优惠指标");
    privilegeData.dataList=res.data.dataList
    privilegeData.total=res.data.total
  })
}

function getDateTime1() {
  dataTime1.value = dataTime.value;
  if (act.value == "day") {
    dataTime1.value = Today;
    start.value = dataTime1.value;
    end.value = dataTime1.value;
  } else if (act.value == "week") {
    dataTime1.value = week;
    start.value = dataTime1.value[0];
    end.value = dataTime1.value[1];
  } else if (act.value == "mouth") {
    dataTime1.value = month;
    start.value = dataTime1.value[0];
    end.value = dataTime1.value[1];
  }
}

function dateAct(val: string) {
  act.value = val;
  init();
}

function activeChange(num: number) {
  active.value = num;
  getDateDataes();
}

function activeChange1(num: number) {
  active1.value = num;
    getCategoryCollect()
}
</script>
<style lang="scss" scoped>
.butAct {
  background: #3a9bff;
  color: #fff;
}
.headBut {
  position: absolute;
  z-index: 9999;
  top: 0px;
  span {
    cursor: pointer;
    margin: 0 10px;
    font-size: 18px;
    padding: 16px 0px;
  }
  .act {
    border-bottom: solid 4px orange;
    font-weight: bold;
  }
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
        color: orange;
      }
      .dataSelect {
        display: flex;
        justify-content: space-between;
        line-height: 40px;
        div:first-child {
          span:first-child {
            margin-right: 10px;
            cursor: pointer;
          }
          span:last-child {
            margin-left: 10px;
            cursor: pointer;
          }
        }
      }
      .but {
        background: orange;
        cursor: pointer;
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
          border-radius: 4px;
          color: #fff;
          .item {
            div:nth-child(2) {
              font-size: 18px;
              line-height: 36px;
            }
          }
        }
        .nowData {
          background: linear-gradient(to right, #55a9ff, #379aff);
        }
        .noData {
          background: linear-gradient(to right, #ffa868, #ff903d);
        }
        .member {
          margin-right: 0;
          background: linear-gradient(to right, #ff8888, #f56c6c);
        }
      }
      .memberChart {
        width: 100%;
        position: relative;
        .topButBox {
          position: absolute;
          top: 0;
          right: 20px;
          z-index: 999;
          font-size: 14px;
          span {
            margin-left: 10px;
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
