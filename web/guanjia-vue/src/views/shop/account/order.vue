<template>
  <div class="dashboard-container">
    <div class="container">
      <div class="tableBar">
        <div>
          <el-date-picker
            v-model="time"
            type="daterange"
            range-separator="至"
            start-placeholder="开始日期"
            end-placeholder="结束日期"
            @change="init"
          />
        </div>
        <el-button
          style="color: white; background-color: orange"
          @click="download"
        >
          下载报表
        </el-button>
      </div>
      <el-table :data="tableData" stripe class="tableBox">
        <el-table-column
          prop="orderId"
          label="订单号"
          align="center"
          width="185"
        />
        <el-table-column prop="userName" label="挂账人" align="center" />
        <el-table-column prop="creditType" label="挂账类型">
          <template #default="scope">
            {{ scope.row.creditType == "2" ? "公司" : "个人" }}
          </template>
        </el-table-column>
        <el-table-column label="挂账公司">
          <template #default="scope">
            {{ scope.row.companyName || "--" }}
          </template>
        </el-table-column>
        <el-table-column prop="creditAmount" label="订单金额" width="110">
          <template #default="scope">
            {{ scope.row.orderAmount / 100 }}
          </template>
        </el-table-column>
        <el-table-column prop="receivableAmount" label="应收金额" width="110">
          <template #default="scope">
            {{ scope.row.creditAmount / 100 }}
          </template>
        </el-table-column>
        <el-table-column prop="creditAmount" label="挂账金额" width="110">
          <template #default="scope">
            {{ scope.row.creditAmount / 100 }}
          </template>
        </el-table-column>
        <el-table-column prop="lastUpdateTime" label="挂账时间" width="175" />
      </el-table>
      <el-pagination
        v-if="counts > 10"
        class="pageList"
        v-model:currentPage="page"
        :page-sizes="[10, 20, 30, 40]"
        :page-size="pageSize"
        :page-count="pages"
        layout="total, sizes, prev, pager, next, jumper"
        :total="counts"
        @size-change="handleSizeChange"
        @current-change="handleCurrentChange"
      />
    </div>
  </div>
</template>

<script lang="ts" setup>
import { creditLongPageList, exportCredit } from "@/request/api";
import { ElMessage } from "element-plus";
import { ref } from "vue";
import { useRouter } from "vue-router";
import dayjs from "dayjs";

const router = useRouter();
const id = router.currentRoute.value.query.id;

const input = ref("");
const counts = ref(0);
const page = ref(1);
const pageSize = ref(10);
const pages = ref(0);
const tableData = ref([]);
const time = ref([]);

init();

function init() {
  console.log(time);
  let start = "";
  let end = "";
  if (time.value != null) {
    start =
      time.value[0] == undefined
        ? ""
        : dayjs(time.value[0]).format("YYYY-MM-DD");
    end =
      time.value[1] == undefined
        ? ""
        : dayjs(time.value[1]).format("YYYY-MM-DD");
  }
  creditLongPageList({
    page: page.value,
    pageSize: pageSize.value,
    creditId: id,
    start: start,
    end: end,
  })
    .then((res) => {
      tableData.value = res.data.items;
      counts.value = Number(res.data.counts);
      pages.value = res.data.pages;
    })
    .catch((err) => {
      ElMessage.error("请求出错了：" + err);
    });
}

function download() {
  let start = "";
  let end = "";
  if (time.value != null) {
    start =
      time.value[0] == undefined
        ? ""
        : dayjs(time.value[0]).format("YYYY-MM-DD");
    end =
      time.value[1] == undefined
        ? ""
        : dayjs(time.value[1]).format("YYYY-MM-DD");
  }
  if (start == "") {
    ElMessage.error("请选择时间再操作！");
    return;
  }
  exportCredit({ creditId: id, start: start, end: end })
    .then((res) => {
      const link = document.createElement('a')
    const blob = new Blob([res], { type: 'application/vnd.ms-excel' })
    link.style.display = 'none'
    link.href = URL.createObjectURL(blob)
    link.setAttribute('download', `订单详情.xlsx`)
    document.body.appendChild(link)
    link.click()
    document.body.removeChild(link)
    })
    .catch((err) => {
      ElMessage.error("请求出错了：" + err);
    });
}

function handleSizeChange(val: any) {
  pageSize.value = val;
  init();
}

function handleCurrentChange(val: any) {
  page.value = val;
  init();
}
</script>
<style lang="scss">
.el-table-column--selection .cell {
  padding-left: 10px;
}
</style>
<style lang="scss" scoped>
.dashboard {
  &-container {
    margin: 30px;
    .container {
      background: #fff;
      position: relative;
      z-index: 1;
      padding: 30px 28px;
      border-radius: 4px;
      min-height: 500px;
      .tableBar {
        display: flex;
        margin-bottom: 20px;
        justify-content: space-between;
      }
      .tableBox {
        width: 100%;
        border: solid 2px rgb(216, 215, 213);
        border-radius: 2px;
      }
      .pageList {
        text-align: center;
        margin-top: 30px;
      }
    }
  }
}
</style>
