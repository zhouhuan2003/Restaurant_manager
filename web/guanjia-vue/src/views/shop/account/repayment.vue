<template>
  <div class="addBrand-container">
    <div class="container">
      <el-form
        ref="ruleFormRef"
        :model="ruleForm"
        :inline="true"
        label-width="180px"
        class="demo-ruleForm"
      >
        <div
          class="formDataTop"
          style="display: flex"
        >
          <div><span>挂账人类型：</span>{{ ruleForm.creditType == '2' ? '公司' : '个人' }}</div>
          <div v-if="ruleForm.creditType == '1'">
            <span>挂账人： </span>{{ ruleForm.userName }}
          </div>
          <div v-if="ruleForm.creditType == '2'">
            <span>挂账公司：</span>{{ ruleForm.companyName }}
          </div>
          <div><span>欠款金额：</span>{{ ruleForm.creditAmount/100 }}</div>
        </div>
        <div style="margin-bottom: 20px;">
          <el-form-item
            label="还款方式"
            prop="region"
          >
            <el-select
              v-model="ruleForm.payType"
              placeholder="请选择还款方式"
            >
              <el-option
                label="现金"
                value="1"
              />
              <el-option
                label="微信"
                value="2"
              />
              <el-option
                label="支付宝"
                value="3"
              />
              <el-option
                label="银行卡"
                value="4"
              />
            </el-select>
          </el-form-item>
          <el-form-item
            label="还款金额:"
            prop="name"
          >
            <el-input
              v-model="ruleForm.repaymentAmount"
              placeholder="请填写还款金额"
            />
          </el-form-item>
        </div>
        <div class="subBox address">
          <el-form-item>
            <el-button @click="router.back()">
              取消
            </el-button>
            <el-button
              type="primary"
              @click="submitForm(ruleFormRef)"
            >
              保存
            </el-button>
          </el-form-item>
        </div>
      </el-form>
    </div>
  </div>
</template>

<script lang="ts" setup>
import { getCreditById,creditRepayment } from "@/request/api";
import { ElMessage,FormInstance } from "element-plus";
import { reactive, ref } from "vue";
import { useRouter } from "vue-router";
const router=useRouter()
const id=router.currentRoute.value.query.id;
const ruleFormRef = ref<FormInstance>();
        const textarea = ref('')
        const value= ref('')
        let ruleForm = reactive({
            'creditId':'',
            'creditType': '2',
            'userName': '',
            'companyName':'',
            'creditAmount': '',
            'payType': '1',
            'repaymentAmount': 10000,
            'users': [
                {
                    'name':'',
                    'phone': ''
                }
            ]
        })
             init();
        function init(){
            getCreditById(id).then(res => {
                ruleForm.creditId=res.data.creditId
                ruleForm.creditType=res.data.creditType
                ruleForm.userName=res.data.userName
                ruleForm.companyName=res.data.companyName
                ruleForm.creditAmount=res.data.creditAmount
                ruleForm.users=res.data.users
                ruleForm.repaymentAmount=res.data.creditAmount/100
                console.log(ruleForm);
                
            });
        }

const submitForm = async (formEl: FormInstance | undefined) => {
  if (!formEl) return;
  await formEl.validate((valid, fields) => {
                if (valid) {
                    const params =  ruleForm;
                    params.repaymentAmount =  ruleForm.repaymentAmount * 100;
                    console.log(params);
                    creditRepayment(params).then(res => {
                         if(res.code==200){
                            ElMessage.success('还款成功！');
                         router.back();
                         }else{
                            ElMessage.error("还款失败!",res.message)
                         }
                    }).catch(err => {
                        ruleForm.repaymentAmount/100
                         ElMessage.error('请求出错了：' + err);
                    });
                } else {
                    console.log('error submit!!');
                    return false;
                }
            });
        }

</script>
<style lang="scss">
  .addBrand-container{
    .avatar-uploader .el-upload {
      border: 1px dashed #d9d9d9;
      border-radius: 6px;
      cursor: pointer;
      position: relative;
      overflow: hidden;
    }
    .avatar-uploader .el-upload:hover {
      border-color: #409EFF;
    }
    .avatar-uploader-icon {
      font-size: 28px;
      color: #8c939d;
      width: 200px;
      height: 160px;
      line-height: 160px;
      text-align: center;
    }
    .avatar {
      width: 160px;
      height: 160px;
      display: block;
    }
    .el-form--inline .el-form-item__content{
      width: 293px;
    }
    .el-input{
      width: 293px;
    }
    .address {
      .el-form-item__content{
        width: 777px !important;
      }
    }
  }
</style>
<style lang="scss" scoped>
  .addBrand {
    &-container {
      margin: 30px;
      .container {
        position: relative;
        z-index: 1;
        background: #fff;
        padding: 30px;
        border-radius: 4px;
        min-height: 500px;
        .subBox{
          padding-top: 30px;
          text-align: center;
          border-top: solid 1px rgb(216, 215, 213);
        }
      }
      .formDataTop{
        display: flex;
        div{
          flex: 1;
          text-align: center;
          line-height: 50px;
          margin-bottom: 50px;
          font-size: 14px;
          color: orange;
          span{
            color: #333;
          }
        }
      }
    }
  }
</style>
