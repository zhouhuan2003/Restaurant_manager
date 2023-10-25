<template>
  <div class="dashboard-container">
    <div class="container">
      <div class="tableBar">
        <div>
          地区：
          <el-select v-model="seachId" placeholder="请选择" clearable  @change="init">
            <el-option
              v-for="item in areaData"
              :key="item.value"
              :label="item.areaName"
              :value="item.areaId"
            />
          </el-select>
        </div>
        <el-button
          style="color: white; background-color: orange"
          @click="addTable"
        >
          +新建台桌
        </el-button>
      </div>
      <el-table :data="tableData" stripe class="tableBox">
        <el-table-column prop="tableName" label="台桌名称" />
        <el-table-column prop="tableSeatNumber" label="座位数" />
        <el-table-column prop="area.areaName" label="所属区域" />
        <el-table-column prop="address" label="操作" align="center">
          <template #default="scope">
            <el-button
              link
              style="color: orange"
              @click="editHandle(scope.row)"
            >
              修改
            </el-button>
            <el-button
              link
              style="color: red"
              @click="deleteHandle(scope.row.tableId)"
            >
              删除
            </el-button>
          </template>
        </el-table-column>
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
    <el-dialog
      :title="tableDataes.title"
      v-model="tableDataes.dialogVisible"
      width="30%"
      :before-close="handleClose"
    >
      <el-form
        ref="tableDataesRef"
        :inline="true"
        :model="tableDataes"
        :rules="rules"
        class="demo-form-inline"
        label-width="110px"
      >
        <el-form-item label="所属区域：" prop="areaId">
          <el-select
            v-model="tableDataes.areaId"
            placeholder="请选择"
            @change="init"
          >
            <el-option
              v-for="item in areaData"
              :key="item.value"
              :label="item.areaName"
              :value="item.areaId"
            />
          </el-select>
        </el-form-item>
        <el-form-item label="桌台名称：" prop="name">
          <el-input v-model="tableDataes.name" placeholder="不超过20个汉字" />
        </el-form-item>
        <el-form-item label="座位数：" prop="seatNumber">
          <el-input v-model="tableDataes.seatNumber" placeholder="请输入1-99" />
        </el-form-item>
      </el-form>
      <template #footer>
        <span class="dialog-footer">
          <el-button @click="tableDataes.dialogVisible = false"
            >取 消</el-button
          >
          <el-button
            style="color: white; background-color: orange"
            @click="submitForm(tableDataesRef)"
            >确 定</el-button
          >
        </span>
      </template>
    </el-dialog>
  </div>
</template>

<script lang="ts" setup>
import {
  getTableList,
  getAreaList,
  delTable,
  addTable1,
  editTable,
} from "@/request/api";
import { ElMessage, FormInstance } from "element-plus";
import { reactive, ref } from "vue";
const ruleFormRef = ref<FormInstance>();

const seachId = ref("");
const areaData = ref([]);
const counts = ref(0);
const page = ref(1);
const pageSize = ref(10);
const pages = ref(0);
const tableData = ref([]);
const action = ref("");
const tableDataes = reactive({
  title: "添加桌台",
  dialogVisible: false,
  name: "",
  areaId: "",
  seatNumber: "",
});

const rules = {
  name: [{ required: true, message: "请输入桌台名称", trigger: "blur" }],
  seatNumber: [{ required: true, message: "请输入座位数", trigger: "blur" }],
  areaId: [{ required: true, message: "请选择品牌区域", trigger: "blur" }],
};

init();
getAreaData();

function init() {
  getTableList({
    areaId: seachId.value == "" ? "all" : seachId.value,
    page: page.value,
    pageSize: pageSize.value,
  })
    .then((res) => {
      tableData.value = res.data.items;
      counts.value = Number(res.data.counts);
      pages.value = res.data.pages;
    })
    .catch((err) => {
      ElMessage.error("请求桌台列表出错了：" + err);
    });
}

// 获取区域列表
function getAreaData() {
  getAreaList({ page: 1, pageSize: 1000 })
    .then((res) => {
      areaData.value = res.data.items;
    })
    .catch((err) => {
      ElMessage.error("获取区域信息出错了：" + err);
    });
}

// 关闭弹窗
function handleClose(st: string) {
  tableDataes.dialogVisible = false;
}

// 添加
function addTable() {
  tableDataes.title = "添加桌台";
  action.value = "add";
  tableDataes.areaId = "";
  tableDataes.name = "";
  tableDataes.seatNumber = "";
  tableDataes.dialogVisible = true;
}

// 修改
function editHandle(dat: any) {
  tableDataes.title = "修改桌台";
  action.value = "edit";
  tableDataes.id = dat.tableId;
  tableDataes.areaId = dat.areaId;
  tableDataes.name = dat.tableName;
  tableDataes.seatNumber = dat.tableSeatNumber;
  tableDataes.dialogVisible = true;
}

//删除
function deleteHandle(tableId: any) {
  delTable(tableId)
    .then((res) => {
      ElMessage.success("删除成功！");
      init();
    })
    .catch((err) => {
      ElMessage.error("请求出错了：" + err);
    });
}

//数据提交
function submitForm() {
  console.log("sub");

  if (action.value == "add") {
    const { areaId, name, seatNumber } = tableDataes;
    addTable1({ areaId, tableName: name, tableSeatNumber: Number(seatNumber) })
      .then((res) => {
        if (res.code == 200) {
          ElMessage.success("桌台添加成功！");
          tableDataes.dialogVisible = false;
          init();
        } else {
          ElMessage.error("桌台添加失败!");
        }
      })
      .catch((err) => {
        ElMessage.error("请求出错了：" + err);
      });
  } else {
    const { areaId, id, name, seatNumber } = tableDataes;
    editTable({
      tableId: id,
      areaId,
      tableName: name,
      tableSeatNumber: Number(seatNumber),
    })
      .then((res) => {
        if (res.code == 200) {
          ElMessage.success("桌台修改成功！");
          tableDataes.dialogVisible = false;
          init();
        } else {
          ElMessage.error("桌台修改失败!");
        }
      })
      .catch((err) => {
        ElMessage.error("请求出错了：" + err);
      });
  }
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
