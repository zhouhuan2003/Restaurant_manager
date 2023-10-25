<template>
  <div class="container">
    <div class="header">
      <el-input
        v-model="data.query.name"
        style="width: 250px; color: orange"
        placeholder="请输入门店名称"
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

      <el-button type="warning" style="background-color: orange; float: right" @click="addShop"
        >+ 添加</el-button
      >
    </div>

    <div style="">
    <el-table :data="tableData" stripe class="tableBox">
      <el-table-column prop="storeName" label="门店名" width="120" />
      <el-table-column prop="brand.brandName" label="所属品牌" width="110" />
      <el-table-column prop="brand.category" label="所属业态" width="110" />
      <el-table-column prop="address" label="详细地址" width="220"/>
      <el-table-column prop="contact" label="门店负责人" />
      <el-table-column prop="contactPhone" label="门店电话" />
      <el-table-column prop="status" label="门店状态">
        <template #default="scope">
          {{ scope.row.status == 1 ? "正常" : "停业" }}
        </template>
      </el-table-column>
      <el-table-column label="操作" width="160" align="center">
        <template #default="scope">
          <el-button link
                type="primary"  @click="stopHandle(scope.row)">
           <span style="color:orange"> {{ scope.row.status == "1" ? "停业" : "开业" }}</span>
          </el-button>
          <el-button link
                type="primary"  @click="addShop(scope.row)">
            <span style="color:orange">编辑</span>
          </el-button>
          <el-button link
                type="primary"  @click="deleteHandle(scope.row)">
           <span style="color:red"> 删除</span>
          </el-button>
        </template>
      </el-table-column>
    </el-table>

    <el-pagination
      v-if="counts > 10"
      class="pageList"
      v-model:currentPage="data.query.page"
      :page-sizes="[10, 20, 30, 40]"
      :page-size="data.query.pageSize"
      :page-count="pages"
      layout="total, sizes, prev, pager, next, jumper"
      :total="counts"
      @size-change="handleSizeChange"
      @current-change="handleCurrentChange"
    />
    </div>
    
  </div>
</template>

<script setup lang="ts">
import { reactive, ref } from "vue";
import { Calendar, Search } from "@element-plus/icons-vue";
import { getStoreList,disableStore,delShop } from "@/request/api";
// let storeName = ref("");
import { useRouter } from "vue-router";
import { ElMessage } from "element-plus";

const router=useRouter()

let data = reactive({
  query: {
    page: 1, //当前页码
    pageSize: 10,
    name: "",
  },
});
let tableData = ref([]);
let counts=ref(0)
let pages=ref(0);

//获取门店列表
function getList() {
  getStoreList(data.query)
    .then((res) => {
      if(res.code==200){
        tableData.value=res.data.items
        counts.value=res.data.counts
        pages.value=res.data.pages
      }
    })
    .catch((error) => {
      console.log(error);
    });
}

getList();

function stopHandle(data:any){
  disableStore(data.storeId).then(res=>{
    if(res.code==200){
      ElMessage.success("设置成功!")
      getList()
    }else{
      ElMessage.error("设置失败!")
    }
  })
}

function addShop(data:any){
    router.push({
        path:"/shop/add",
        query:{
            id:data.storeId
        }
    })
}

function deleteHandle(data:any){
    delShop(data.storeId).then(res =>{
       if(res.code==200){
      ElMessage.success("删除成功!")
      getList()
    }else{
      ElMessage.error("删除失败!")
    }
    })
}

const handleSizeChange = (val: number) => {
  data.query.pageSize=val
  getList()
}
const handleCurrentChange = (val: number) => {
  data.query.page=val
  getList()
}



const searchShop = () => {
  //   console.log("搜索");
  getList();
};
function clear() {
  //   console.log("清空");
  data.query.name = "";
  getList();
}
</script>

<style lang="scss" scoped>
.container {
  background-color: white;
  width: 1230px;
  margin-left: 10px;
  margin-top: 10px;
  .header {
    // background-color: orange;
    width: 97%;
    height: 50px;
    margin: auto auto;
    position: relative;
    top: 20px;
    .el-input__icon {
      cursor: pointer;
    }
  }
  .tableBox {
          width: 97%;
          border: solid 2px #F3F4F7;
          border-radius: 2px;
           margin: auto auto;
           margin-top: 20px;
        }
    .pageList {
        
        //   text-align: center;
          margin-top: 20px;
          margin-left:20%;
        }
}
</style>