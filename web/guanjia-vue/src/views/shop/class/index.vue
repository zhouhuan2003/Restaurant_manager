<template>
  <div class="dashboard-container">
    <div class="container">
      <div class="tableBar" style="display: inline-block">
        <el-button
          type="primary"

          class="continue"
          @click="addClass('class')"
        >
          + 新增菜品分类
        </el-button>
        <el-button color="#FF903D" style="color:white" @click="addClass('meal')">
          + 新增套餐分类
        </el-button>
      </div>
      <el-table :data="tableData" stripe class="tableBox">
        <el-table-column prop="name" label="分类名称" />
        <el-table-column prop="type" label="分类类型">
          <template #default="scope">
            <span>{{ scope.row.type == "1" ? "菜品分类" : "套餐分类" }}</span>
          </template>
        </el-table-column>
        <el-table-column prop="lastUpdateTime" label="操作时间" />
        <el-table-column label="操作" width="160" align="center">
          <template #default="scope">
            <el-button link 
            style="color:orange"
             @click="editHandle(scope.row)">
              修改
            </el-button>
            <el-button
              link
              style="color:red"
              @click="deleteHandle(scope.row.categoryId)"
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
      :title="classData.title"
      v-model="classData.dialogVisible"
      width="30%"
      :before-close="handleClose"
      class="dialog"
    >
      <el-form :inline="true" class="demo-form-inline">
        <el-form-item label="分类名称：">
          <el-input
            v-model="classData.categoryName"

            placeholder="请输入分类名称"
          />
        </el-form-item>
      </el-form>
      <template #footer >
        <el-button  @click="classData.dialogVisible = false"
          >取 消</el-button
        >
        <el-button style="color:white;background-color:orange"  @click="submitForm()"
          >确 定</el-button
        >
        <el-button
          v-if="action != 'edit'"
          type="primary"
          class="continue"
          @click="submitForm('go')"
        >
          保存并继续添加
        </el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script lang="ts" setup>
import { dishCategoryPageList,dishCategoryType,dishCategoryAdd,dishCategoryUpdate ,delCategory} from "@/request/api";
import { ElMessage } from "element-plus";
import { focusNode } from "element-plus/es/utils";
import { reactive, ref } from "vue";


const action = ref("");
const counts = ref(0);
const page = ref(1);
const pageSize = ref(10);
const pages=ref(0)
const tableData = ref([]);
const type = ref(0);
const classData = reactive({
  title: "添加菜品分类",
  dialogVisible: false,
  categoryId: "",
  categoryName: "",
});

// 初始化信息
getList()

function getList(){
  dishCategoryPageList(page.value,pageSize.value).then(res=>{
    console.log(res);
    if(res.code==200){
      tableData.value=res.data.items
      counts.value=res.data.counts
      pages.value=res.data.pages
    }
  }).catch(error=>{
    ElMessage.error(error)
  })
}

// 添加
function addClass(st: any) {
  if (st == "class") {
    classData.title = "新增菜品分类";
    type.value = 1;
  } else {
    classData.title = "新增套餐分类";
    type.value = 2;
  }
  action.value = "add";
  classData.categoryName = "";
  classData.dialogVisible = true;
}

// 修改
function editHandle(dat: object) {
  classData.title = "修改分类";
  action.value = "edit";
  classData.categoryName = dat.name;
  classData.categoryId = dat.categoryId;
  classData.dialogVisible = true;
}

// 关闭弹窗
function handleClose(st: string) {
  classData.dialogVisible = false;
}

//删除
function deleteHandle(id: any) {
  delCategory(id).then(res=>{
    if(res.code==200){
      getList()
      ElMessage.success("删除成功!")
    }else{
      ElMessage.error("删除失败")
    }
  }).catch(error=>{
    ElMessage.error(error)
  })
  
}

//数据提交
function submitForm(st: any) {
  if (action.value == 'add') {
      if ( classData.categoryName) {
          dishCategoryAdd({'categoryName':  classData.categoryName,'type': type.value}).then(res => {
               ElMessage.success('分类添加成功！');
              if (!st) {
                   classData.dialogVisible = false;
              }
              classData.categoryName=''
               getList();
          }).catch(err => {
              ElMessage.error('请求出错了：' + err);
          });
      } else {
           ElMessage.error('请输入分类名称');
      }
  } else if ( classData.categoryName) {
      console.log( classData);
      dishCategoryUpdate({'id': classData.categoryId,'categoryName': classData.categoryName}).then(res => {
           ElMessage.success('分类修改成功！');
           classData.dialogVisible = false;
           getList();
      }).catch(err => {
           ElMessage.error('请求出错了：' + err);
      });
  } else {
       ElMessage.error('请输入分类名称');
  }
}

//分页
function handleSizeChange(val: any) {
  pageSize.value = val;
  getList()
}

function handleCurrentChange(val: any) {
  page.value = val;
  getList();
}
</script>
<style lang="scss">
.el-dialog__body {
  padding-bottom: 0px;
}
.dialog{
  border-radius: 2%;
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
        border: solid 2px #F3F4F7;
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
