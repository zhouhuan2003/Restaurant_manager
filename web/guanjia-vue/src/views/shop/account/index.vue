<template>
  <div class="dashboard-container">
    <div class="container">
      <div class="tableBar">
        <el-input
          v-model="input"
          placeholder="请输入挂账人"
          style="width: 250px"
          clearable
          @keydown.enter="init"
          @clear="clear"
        >
           <template #prefix>
            <el-icon class="el-input__icon" @click="init"
              ><search
            /></el-icon>
          </template>
        </el-input>
        <el-button
          style="color:white;background-color:orange"
          @click="addAccount('add')"
        >
          +添加挂账
        </el-button>
      </div>
      <el-table
        :data="tableData"
        stripe
        class="tableBox"
      >
        <el-table-column
          prop="creditType"
          label="挂账类型"
          width="110"
        >
          <template #default="scope">
            {{ scope.row.creditType == '2' ? '公司' : '个人' }}
          </template>
        </el-table-column>
        <el-table-column
          prop="companyName"
          label="挂账公司"
          align="center"
        >
          <template #default="scope">
            {{ scope.row.companyName || '--' }}
          </template>
        </el-table-column>
        <el-table-column label="挂账人">
          <template #default="scope">
            <div v-if="scope.row.creditType == '2'">
              <div v-for="(it, index) in scope.row.users" :key="index">
                {{ it.userName || '--' }}
              </div>
            </div>
            <div v-if="scope.row.creditType == '1'">
              {{ scope.row.userName || '--' }}
            </div>
          </template>
        </el-table-column>
        <el-table-column label="挂账电话">
          <template #default="scope">
            <div v-if="scope.row.creditType == '2'">
              <div v-for="(it, index) in scope.row.users" :key="index">
                {{ it.phone || '--' }}
              </div>
            </div>
            <div v-if="scope.row.creditType == '1'">
              {{ scope.row.phone || '--' }}
            </div>
          </template>
        </el-table-column>
        <el-table-column
          prop="creditAmount"
          label="欠款金额"
        >
          <template #default="scope">
            {{ scope.row.creditAmount/100 }}
          </template>
        </el-table-column>
        <el-table-column
          prop="status"
          label="状态"
        >
          <template #default="scope">
            {{ scope.row.status == '0' ? '停用' : '有效' }}
          </template>
        </el-table-column>
        <el-table-column
          prop="address"
          label="操作"
          width="300"
          align="center"
        >
          <template #default="scope">
            <el-button
              link
              style="color:orange"
              @click="addAccount(scope.row.creditId)"
            >
              修改
            </el-button>
            <el-button
              link
              style="color:red"
              @click="stopHandle(scope.row)"
            >
              {{ scope.row.status == '1' ? '停用' : '启用' }}
            </el-button>
            <el-button
              link
              style="color:orange"
              @click="() => $router.push({path: '/accounts/repayment', query: {id: scope.row.creditId}})"
            >
              还款
            </el-button>
            <el-button
              link
              style="color:red"
              @click="deleteHandle(scope.row.creditId)"
            >
              删除
            </el-button>
            <el-button
              link
              style="color:orange"
              @click="() => $router.push({path: '/accounts/order', query: {id: scope.row.creditId}})"
            >
              订单明细
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
import { creditPageList,editStatusCredit, delCredit} from "@/request/api"
import { ElMessage } from "element-plus"
import { ref } from "vue"
import { useRouter } from "vue-router"
const router =useRouter()


    const input = ref('')
    const counts = ref(0)
    const page = ref(1)
    const pageSize = ref(10)
    const pages = ref(10)
    const tableData = ref([])
    const creditId = ref('')
    const status = ref(0)

    
         init();
    

    function  init() {
         creditPageList({'page':  page.value, 'pageSize':  pageSize.value,'name': input.value}).then(res => {
             tableData.value = res.data.items;
             counts.value = Number(res.data.counts);
        }).catch(err => {
             ElMessage.error('请求出错了：' + err);
        });
    }
    // 添加
    function addAccount(st:string) {
        if (st == 'add'){
             router.push({ 'path': '/accounts/add' });
        } else {
             creditId.value = st;
             router.push({ 'path': '/accounts/add', 'query': {'id': st}});
        }
    }

    //删除
    function deleteHandle(id:String) {
            
            delCredit(id).then(res => {
                 if(res.code==200){
                  ElMessage.success('删除成功！');
                 init();
                 }else{
                  ElMessage.error("删除失败!")
                 }
            }).catch(err => {
                 ElMessage.error('请求出错了：' + err);
            });

    }
    //停业
    function stopHandle(row:object) {
        console.log(row);
        
         creditId.value = row.creditId;
         status.value = row.status;
        console.log(creditId.value,status.value);
        
            editStatusCredit({'id':  creditId.value, 'status':  status.value == 0 ? 1 : 0}).then(res => {
                 if(status.value==0){
                    ElMessage.success('该门店已启业！');
                 init();
                 }else{
                    ElMessage.success('该门店已停业！');
                 init();
                 }
            }).catch(err => {
                 ElMessage.error('请求出错了：' + err);
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

    function clear(){
        input.value=""
        init()
    }


</script>
<style lang="scss">
  .el-table-column--selection .cell{
    padding-left: 10px;
  }
</style>
<style lang="scss" scoped>
  .dashboard {
    &-container {
      margin: 30px;
      .container{
        background: #fff;
        position: relative;
        z-index: 1;
        padding: 30px 28px;
        border-radius: 4px;
        min-height: 500px;
        .tableBar{
          display: flex;
          margin-bottom: 20px;
          justify-content: space-between;
          .el-input__icon{
            cursor: pointer;
          }
        }
        .tableBox{
          width: 100%;
          border: solid 2px rgb(216, 215, 213);
          border-radius: 2px;
        }
        .pageList{
          text-align: center;
          margin-top: 30px;
        }
      }
    }
  }
</style>
