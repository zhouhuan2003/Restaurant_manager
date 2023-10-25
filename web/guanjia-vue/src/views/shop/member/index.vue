<template>
  <div class="dashboard-container">
    <div class="container">
      <div class="tableBar">
        <el-input
          v-model="input"
          placeholder="请输入员工姓名"
          style="width: 250px"
          size="small"
          clearable
          @keyup.enter.native="searchShop"
          @clear="clear()"
        >
          <template #prefix>
            <el-icon class="el-input__icon" @click="searchShop"
              ><search
            /></el-icon>
          </template>
        </el-input>
        <el-button
          style="color:white; background-color: orange"
          @click="addMemberHandle('add')"
        >
          +添加员工
        </el-button>
      </div>
      <el-table :data="tableData" stripe class="tableBox">
        <el-table-column prop="staffName" label="员工姓名" />
        <el-table-column prop="phone" label="账号" />
        <el-table-column prop="phone" label="手机号" />
        <el-table-column prop="idNumber" label="身份证" />
        <el-table-column label="账号状态">
          <template #default="scope">
            {{ scope.row.status == "1" ? "已禁用" : "正常" }}
          </template>
        </el-table-column>
        <el-table-column label="操作" width="160" align="center">
          <template #default="scope">
            <el-button
              link
              style="color:orange"
              @click="addMemberHandle(scope.row.staffId)"
            >
              编辑
            </el-button>
            <el-button
              link
              style="color:orange"
              @click="statusHandle(scope.row)"
            >
              {{ scope.row.status == "1" ? "禁用" : "启用" }}
            </el-button>
            <el-button
              link
              style="color:red"
              @click="del(scope.row.staffId)"
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
import { ref } from "vue";
import { useRouter } from "vue-router";
import { ElMessage, ElMessageBox } from "element-plus";
import { getMemberList,editStatusMember ,delMenber} from "@/request/api";
const router = useRouter();

const input = ref("");
const counts = ref(0);
const page = ref(1);
const pageSize = ref(10);
const pages=ref(0)
const tableData = ref([]);
const id = ref("");
const status = ref("");

// 添加
function addMemberHandle(st: string) {
  if (st == "add") {
    router.push({ path: "/member/add" });
  } else {
    router.push({ path: "/member/add", query: { id: st } });
  }
}

//删除
function del(id:String){
    delMenber(id).then(res=>{
        if(res.code==200){
            ElMessage.success("删除成功!")
            getList()
        }else{
            ElMessage.error("删除失败!")
        }
    })
}

//状态修改
function statusHandle(row: object) {
  console.log(row);
    editStatusMember(row.staffId).then(res=>{
        if(res.code==200){
            ElMessage.success("设置成功")
            getList()
        }else{
            ElMessage.error("设置失败")
        }
    })

//   ElMessageBox.confirm(
//     "你确定要改变改店员的状态吗?",
//     "改变状态",
//     {
//       confirmButtonText: "确定",
//       cancelButtonText: "取消",
//       type: "warning",
//     }
//   )
//     .then(() => {
//       ElMessage({
//         type: "success",
//         message: "Delete completed",
//       });
//     })
//     .catch(() => {
//       ElMessage({
//         type: "info",
//         message: "Delete canceled",
//       });
//     });
}

function searchShop() {
    getList()
}

function handleSizeChange(val: any) {
  pageSize.value = val;
  getList()
}

function handleCurrentChange(val: any) {
  page.value = val;
  getList()
}

getList()

//获取店员列表
function getList(){
    getMemberList({page:page.value,pageSize:pageSize.value,name:input.value}).then(res=>{
    // console.log(res);
    tableData.value=res.data.items
    counts.value=res.data.counts
    pages.value=res.data.pages
}).then(error=>{
    console.log(error);
})
}


//清空
function clear() {
    input.value=""
    getList()
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
        .el-input__icon {
          cursor: pointer;
        }
      }
      .tableBox {
        width: 100%;
        border: solid 2px rgb(216, 215, 213);
        border-radius: 2px;
      }
      .pageList {
        // text-align: center;
        margin-left:25%;
        margin-top: 30px;
      }
    }
  }
}
</style>
