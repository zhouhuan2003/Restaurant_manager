<template>
  <div class="dashboard-container">
    <div class="container">
      <div class="tableBar">
        <div />
        <el-button
          style="color: white; background-color: orange"
          @click="addHandle"
        >
          +添加区域
        </el-button>
      </div>
      <el-table :data="tableData" stripe class="tableBox">
        <el-table-column prop="areaName" label="区域名称" align="center" />
        <el-table-column label="操作" align="center">
          <template #default="scope">
            <el-button style="color: orange" @click="editHandle(scope.row)">
              修改
            </el-button>
            <el-button
              style="color: red"
              @click="deleteHandle(scope.row.areaId)"
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
      :title="areaData.title"
      v-model="areaData.dialogVisible"
      width="30%"
      :before-close="handleClose"
      @close="close"
    >
      <el-form :inline="true" class="demo-form-inline">
        <el-form-item label="区域名称：">
          <el-input v-model="areaData.areaName" placeholder="请输入区域名称" />
        </el-form-item>
      </el-form>
      <template #footer>
        <span class="dialog-footer">
          <el-button @click="areaData.dialogVisible = false">取 消</el-button>
          <el-button
            style="color: white; background-color: orange"
            @click="submitForm()"
            >确 定</el-button
          >
        </span>
      </template>
    </el-dialog>
  </div>
</template>

<script lang="ts" setup>
import { getAreaList, delArea, addArea, editArea } from "@/request/api";
import { ElMessage, FormInstance } from "element-plus";
import { reactive, ref } from "vue";
const ruleFormRef = ref<FormInstance>();

const input = ref("");
const counts = ref(0);
const page = ref(1);
const pageSize = ref(10);
const pages = ref(0);
const tableData = ref([]);
const action = ref("");
const delAreaId = ref("");
const areaData = reactive({
  title: "添加区域",
  dialogVisible: false,
  areaName: "",
});

init();

function init() {
  getAreaList({ page: page.value, pageSize: pageSize.value })
    .then((res) => {
      tableData.value = res.data.items;
      counts.value = Number(res.data.counts);
      pages.value = res.data.pages;
    })
    .catch((err) => {
      ElMessage.error("请求出错了：" + err);
    });
}

// 关闭弹窗
function handleClose(st: string) {
  areaData.dialogVisible = false;
}

// 添加
function addHandle() {
  action.value = "add";
  areaData.dialogVisible = true;
}

// 修改
function editHandle(dat: object) {
  areaData.title = "修改区域";
  action.value = "edit";
  areaData.areaName = dat.areaName;
  areaData.areaId = dat.areaId;
  areaData.dialogVisible = true;
}

//删除
function deleteHandle(areaId: any) {
  delAreaId.value = areaId;
  delArea(delAreaId.value)
    .then((res) => {
      ElMessage.success("删除成功！");
      init();
    })
    .catch((err) => {
      ElMessage.error("请求出错了：" + err);
    });
}

function close(){
  areaData.areaName='',
  areaData.title='添加区域',
  areaData.areaId=''
}

//数据提交
function submitForm() {
  if (action.value == "add") {
    if (areaData.areaName) {
      addArea({ name: areaData.areaName })
        .then((res) => {
          if (res.code == 200) {
            ElMessage.success("区域添加成功！");
            init();
            areaData.dialogVisible = false;
          } else {
            ElMessage.error("区域添加失败!");
          }
        })
        .catch((err) => {
          ElMessage.error("请求出错了：" + err);
        });
    } else {
      ElMessage.error("请输入区域名称");
    }
  } else if (areaData.areaName) {
    editArea({ areaId: areaData.areaId, areaName: areaData.areaName })
      .then((res) => {
        if (res.code == 200) {
          ElMessage.success("区域修改成功！");
          areaData.dialogVisible = false;
          init();
        } else {
          ElMessage.error("区域修改失败!");
        }
      })
      .catch((err) => {
        ElMessage.error("请求出错了：" + err);
      });
  } else {
    ElMessage.error("请输入分类名称");
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
