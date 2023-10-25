<template>
  <div class="container">
    <div class="header">
      <el-input
        v-model="data.query.criteria"
        style="width: 250px; color: orange"
        placeholder="请输入店长的姓名"
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
        type="warning"
        style="background-color: orange; float: right"
        @click="addShop"
        >+ 添加</el-button
      >
    </div>

    <div style="">
      <el-table :data="tableData" stripe class="tableBox">
        <el-table-column prop="storeManagerName" label="店长姓名" width="160" />
        <el-table-column
          prop="storeManagerPhone"
          label="联系方式"
          width="160"
        />
        <el-table-column label="所属店面">
          <template #default="scope">
            <span v-for="(item, index) in scope.row.stores" :key="index"
              >{{ item.storeName }}、</span
            >
          </template>
        </el-table-column>
        <el-table-column prop="status" label="账号状态" width="160">
          <template #default="scope">
            <span>{{ scope.row.status == 0 ? "暂停" : "正常" }}</span>
          </template>
        </el-table-column>
        <el-table-column label="操作" width="160" align="center">
          <template #default="scope">
          <el-button link
                type="primary"  @click="stopHandle(scope.row)">
           <span style="color:orange"> {{ scope.row.status == "1" ? "暂停" : "启用" }}</span>
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
import { pushScopeId, reactive, ref } from "vue";
import { Calendar, Search } from "@element-plus/icons-vue";
import { getShopownerList ,delStoreManager,pauseStoreManager } from "@/request/api";
// let storeName = ref("");
import { useRouter } from "vue-router";
import { ElMessage } from "element-plus";

const router = useRouter();

let data = reactive({
  query: {
    page: 1, //当前页码
    pageSize: 10,
    criteria: "",
  },
});
let tableData = ref([]);
let counts = ref(0);
let pages = ref(0);

//获取门店列表
function getList() {
  getShopownerList(data.query)
    .then((res) => {
      if (res.code == 200) {
        tableData.value = res.data.items;
        counts.value = res.data.counts;
        pages.value = res.data.pages;
      }
    })
    .catch((error) => {
      console.log(error);
    });
}

getList();

//暂停/启用
function stopHandle(data: any) {
  pauseStoreManager(data.storeManagerId,data.status).then(res=>{
      if(res.code==200){
        ElMessage.success("编辑成功")
        getList()
      }
  })
}

function addShop(data: any) {
  router.push({
    path: "/shopowner/add",
    query: {
      id: data.storeManagerId,
    },
  });
}

//删除
function deleteHandle(data: any) {
  delStoreManager(data.storeManagerId).then(res =>{
    if(res.code==200){
      ElMessage.success("删除成功")
      getList()
    }
  })
}

const handleSizeChange = (val: number) => {
  data.query.pageSize = val;
  getList();
};
const handleCurrentChange = (val: number) => {
  data.query.page = val;
  getList();
};

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
    border: solid 2px #f3f4f7;
    border-radius: 2px;
    margin: auto auto;
    margin-top: 20px;
  }
  .pageList {
    //   text-align: center;
    margin-top: 20px;
    margin-left: 20%;
  }
}
</style>