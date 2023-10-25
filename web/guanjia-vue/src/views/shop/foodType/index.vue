<template>
  <div class="dashboard-container">
    <div class="container">
      <div class="tableBar">
        <el-input
          v-model="input"
          placeholder="请输入菜品名称"
          style="width: 250px"
          size="small"
          clearable
          @keyup.enter.native="searchFood"
          @clear="clear()"
        >
          <template #prefix>
            <el-icon class="el-input__icon" @click="searchFood"
              ><search
            /></el-icon>
          </template>
        </el-input>
        <div class="tableLab">
          <span @click="deleteHandle('1')">批量删除</span>
          <span @click="statusHandle('1')" style="color: orange">批量启售</span>
          <span style="border: none" @click="statusHandle('0')">批量停售</span>
          <el-button
            style="color: white; background-color: orange"
            @click="addFoodtype('add')"
          >
            +新建菜品
          </el-button>
        </div>
      </div>
      <el-table
        :data="tableData"
        stripe
        class="tableBox"
        @selection-change="handleSelectionChange"
      >
        <el-table-column type="selection" width="25" />
        <el-table-column prop="name" label="菜品名称" />
        <el-table-column prop="dishCategory.name" label="菜品分类" />
        <el-table-column prop="price" label="售价" width="100">
          <template #default="scope">
            <span >￥{{ scope.row.price / 100 }}</span>
          </template>
        </el-table-column>
        <el-table-column prop="code" label="商品码" />
        <el-table-column label="售卖状态" width="90">
          <template #default="scope">
            <span>{{
              scope.row.status == "0" ? "停售" : "启售"
            }}</span>
          </template>
        </el-table-column>
        <el-table-column prop="lastUpdateTime" label="最后操作时间" />
        <el-table-column label="操作" width="160" align="center">
          <template #default="scope">
            <el-button
              link
              style="color: orange"
              @click="addFoodtype(scope.row.id)"
            >
              修改
            </el-button>
            <el-button
              link
              style="color: orange"
              @click="statusHandle(scope.row)"
            >
              {{ scope.row.status == "0" ? "启售" : "停售" }}
            </el-button>
            <el-button
              link
              style="color: red"
              @click="deleteHandle(scope.row)"
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
  </div>
</template>

<script lang="ts" setup>
import { getDishList, delDish, editDishStatus } from "@/request/api";
import { ElMessage } from "element-plus";
import { ref } from "vue";
import { useRouter } from "vue-router";

const router = useRouter();
const input = ref("");
const counts = ref(0);
const page = ref(1);
const pageSize = ref(10);
const pages = ref(0);
const checkList = ref([]);
const tableData = ref([]);
const dishState = ref("");

init();

function init() {
  getDishList({ page: page.value, pageSize: pageSize.value, name: input.value })
    .then((res) => {
      tableData.value = res.data.items;
      counts.value = Number(res.data.counts);
      pages.value = res.data.pages;
    })
    .catch((err) => {
      ElMessage.error("请求出错了：" + err);
    });
}

// 添加
function addFoodtype(st: string) {
  if (st == "add") {
    router.push({ path: "/fond/add" });
  } else {
    router.push({ path: "/fond/add", query: { id: st } });
  }
}

// 删除
function deleteHandle(row: any) {
  let params: any = {};
  if (typeof row === "string") {
    if (checkList.value.length == 0) {
      ElMessage.error("批量操作，请先勾选操作菜品！");
      return false;
    }
    params.ids = checkList.value;
  } else {
    params.ids = [row.id];
  }

  console.log(params);

  delDish(params)
    .then((res) => {
      if(res.code==200){
        ElMessage.success("删除成功！");
      init();
      }else{
        ElMessage.error("删除失败!")
      }
    })
    .catch((err) => {
      ElMessage.error("请求出错了：" + err);
    });
}

//状态更改
function statusHandle(row: any) {
  let params: any = {};
  if (typeof row === "string") {
    if (checkList.value.length == 0) {
      ElMessage.error("批量操作，请先勾选操作菜品！");
      return false;
    }
    params.ids = checkList;
    params.status = row;
  } else {
    params.ids = [row.id];
    params.status = row.status ? "0" : "1";
  }
  dishState.value = params;

  console.log(dishState.value);
  

  editDishStatus(dishState.value)
    .then((res) => {
      if(res.code==200){
        ElMessage.success("菜品状态已经更改成功！");
      init();
      }else{
        ElMessage.error("更改失败!")
      }
    })
    .catch((err) => {
      ElMessage.error("请求出错了：" + err);
    });
}

// 全部操作
function handleSelectionChange(val: any) {
  let checkArr: [] = [];
  val.forEach((n: any) => {
    checkArr.push(n.id);
  });
  checkList.value = checkArr;
  console.log(checkList);
}

function handleSizeChange(val: any) {
  pageSize.value = val;
  init();
}

function handleCurrentChange(val: any) {
  page.value = val;
  init();
}

//清空
function clear() {
  input.value = "";
  init();
}

function searchFood() {
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
        .el-input__icon {
          cursor: pointer;
        }
        .tableLab {
          span {
            cursor: pointer;
            display: inline-block;
            font-size: 14px;
            padding: 0 10px;
            color: red;
            border-right: solid 1px rgb(216, 215, 213);
          }
        }
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
