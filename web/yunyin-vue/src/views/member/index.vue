<template>
  <div class="dashboard-container">
    <div class="container">
      <div class="tableBar">
        <el-input placeholder="请输入企业关键词" style="width: 250px" size="small" v-model="input" clearable
        @keyup.enter.native="init"
        @clear="clear()"
        >
          <template #prefix>
            <el-icon class="el-input__icon" @click="init"
              ><search
            /></el-icon>
          </template>
        </el-input>
        <el-button style="color:white;background-color:orange" @click="addMemberHandle('add')" > +新增账号 </el-button>
      </div>
      <el-table :data="tableData" stripe class="tableBox">
        <el-table-column prop="enterpriseId" label="ID"  > </el-table-column>
        <el-table-column prop="enterpriseName" label="企业名称" > </el-table-column>
        <el-table-column prop="shopId" label="商户号" > </el-table-column>
        <!-- <el-table-column prop="phone" label="账号" width="113"> </el-table-column> -->
        <el-table-column prop="applicant" label="申请人" > </el-table-column>
        <el-table-column prop="email" label="邮箱" width="115"> </el-table-column>
        <el-table-column prop="phone" label="手机号/账号" width="115"> </el-table-column>
        <el-table-column prop="applicationTime" label="申请日期" >
          <template #default="scope">
            {{momentData(scope.row.applicationTime)}}
          </template>
        </el-table-column>
        <el-table-column prop="expireTime" label="到期日期" >
          <template #default="scope">
            {{momentData(scope.row.applicationTime)}}
          </template>
        </el-table-column>
        <el-table-column label="账号状态">
          <template #default="scope">
            <span v-if="scope.row.status == 0">试用中</span>
            <span v-if="scope.row.status == -1">已停用</span>
            <span v-if="scope.row.status == 1">正式</span>
          </template>
        </el-table-column>
        <el-table-column label="操作" width="240" align="center">
          <template #default="scope">
            <el-button link style="color:orange" @click="addMemberHandle(scope.row.enterpriseId)">编辑</el-button>
            <el-button link style="color:orange" @click="statusHandle(scope.row)">{{scope.row.status == '-1' ? '启用' : '禁用'}}</el-button>
            <el-button link style="color:orange" @click="rePassword1(scope.row.enterpriseId)">重置密码</el-button>
            <el-button link style="color:red" @click="del1(scope.row.enterpriseId)">删除</el-button>
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
import { ElMessage } from "element-plus"
import { ref } from "vue"
import { useRouter } from "vue-router"
import moment from "moment";
import { getMemberList, rePassword, memberOpen, memberClose,del } from "@/request/api";
import { th } from "element-plus/es/locale";
const router=useRouter()


    const input = ref('')
    const counts = ref(0)
    const page = ref(1)
    const pageSize = ref(10)
    const pages=ref(0)
    const tableData = ref([])
    const changeRow = ref([])
    const rmId = ref('')


         init()


    function init() {
         getMemberList({page:  page.value, pageSize:  pageSize.value, name: input.value || ''}).then(res => {
             tableData.value = res.data.items
             counts.value = Number(res.data.counts)
             pages.value=res.data.pages
        }).catch(err => {
             ElMessage.error('请求出错了：' + err)
        })
    }

    function momentData(dat: any){
        return moment(dat).format('YYYY-MM-DD HH:mm:ss')
    }
    // 添加
    function addMemberHandle(st:string) {
        if (st == 'add'){
             router.push({ path: '/addMember' })
        }else{
             router.push({ path: '/addMember', query: {id: st}})
        }
    }
    // 重置密码
    function rePassword1(id:string) {
        rePassword({'id':id,pwd:'123456'}).then(res => {
             ElMessage.success('密码重置短信已发送，请注意查收')
        }).catch(err => {
             ElMessage.error('请求出错了：' + err)
        })
    }

    //删除
    function del1(id:String){
      del(id).then(res=>{
        if(res.code=200){
          ElMessage.success("删除成功!")
          init()
        }else{
          ElMessage.error("删除失败!")
        }
      })
    }

    //状态修改
    function statusHandle(row:object) {
            if ( row.status == -1){
                memberOpen(row.enterpriseId).then(res => {
                     ElMessage.success('账号已起用成功！')
                     init()
                }).catch(err => {
                     ElMessage.error('请求出错了：' + err)
                })
            } else {
                memberClose(row.enterpriseId).then(res => {
                     ElMessage.success('账号已禁用成功！')
                     init()
                }).catch(err => {
                     ElMessage.error('请求出错了：' + err)
                })
            }
    }

    function handleSizeChange(val: any) {
         pageSize.value = val
         init()
    }

    function handleCurrentChange(val: any) {
         page.value = val
         init()
    }

    function clear(){
      input.value=''
      init()
    }


</script>

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
          .el-input__icon {
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
