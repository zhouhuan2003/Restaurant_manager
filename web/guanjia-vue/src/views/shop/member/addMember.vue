<template>
  <div class="addBrand-container">
    <div class="container">
      <el-form
        ref="ruleFormRef"
        :model="ruleForm"
        :rules="rules"
        :inline="false"
        label-width="180px"
        class="demo-ruleForm"
      >
        <!--          <el-form-item label="员工职级" prop="region">-->
        <!--            <el-select v-model="ruleForm.region" placeholder="请选择品牌名称">-->
        <!--              <el-option label="区域一" value="shanghai"></el-option>-->
        <!--              <el-option label="区域二" value="beijing"></el-option>-->
        <!--            </el-select>-->
        <!--            <el-button @click="submitForm('ruleForm')" type="primary" class="continue" style="margin-left: 10px;" >+新增职级</el-button>-->
        <!--          </el-form-item>-->
        <el-form-item
          label="员工姓名:"
          prop="staffName"
        >
          <el-input
            v-model="ruleForm.staffName"
            placeholder="请输入员工姓名"
          />
        </el-form-item>
        <el-form-item
          label="密码:"
          prop="password"
        >
          <el-input
            v-model="ruleForm.password"
            type="password"
            autocomplete="off"
            placeholder="请输入密码"
          />
        </el-form-item>
        <el-form-item
          label="确认密码:"
          prop="rePassword"
        >
          <el-input
            v-model="ruleForm.rePassword"
            type="password"
            autocomplete="off"
            placeholder="请输入确认密码"
          />
        </el-form-item>
        <el-form-item
          label="邮箱:"
          prop="email"
        >
          <el-input
            v-model="ruleForm.email"
            placeholder="请输入邮箱"
          />
        </el-form-item>
        <el-form-item
          label="手机号:"
          prop="phone"
        >
          <el-input
            v-model="ruleForm.phone"
            placeholder="请输入手机号"
          />
        </el-form-item>
        <el-form-item
          label="性别"
          prop="sex"
        >
          <el-radio-group v-model="ruleForm.sex">
            <el-radio label="男" />
            <el-radio label="女" />
          </el-radio-group>
        </el-form-item>
        <el-form-item
          label="身份证号"
          prop="idNumber"
        >
          <el-input
            v-model="ruleForm.idNumber"
            placeholder="请输入身份证号"
          />
        </el-form-item>
        <div class="subBox address">
          <el-form-item>
            <el-button @click="goBack(ruleFormRef)">
              取消
            </el-button>
            <el-button
              v-if="id!=''"
              style="background-color:orange;color:white"
              @click="submitForm(ruleFormRef)"
            >
              修改
            </el-button>
            <el-button
              v-else
              style="background-color:orange;color:white"
              @click="submitForm(ruleFormRef)"
            >
              保存
            </el-button>
            <el-button
              v-if="id == ''"
              type="primary"
              class="continue"
              @click="submitForm(ruleFormRef, 'go')"
            >
              保存并继续添加
            </el-button>
          </el-form-item>
        </div>
      </el-form>
    </div>
  </div>
</template>

<script lang="ts" setup>
import { reactive, ref } from "vue";
import { ElMessage, FormInstance } from "element-plus";
import { addMember, getMemberById } from "@/request/api";
import { da } from "element-plus/es/locale";
import { useRouter } from "vue-router";
const router =useRouter()

const id =
  router.currentRoute.value.query.id == undefined
    ? ""
    : router.currentRoute.value.query.id;

const ruleFormRef = ref<FormInstance>();


  const actionType =ref('')
  const ruleForm = reactive({
      'staffName': '',
      'email': '',
      'phone': '',
      'password': '',
      'rePassword': '',
      'sex': '男',
      'idNumber': '',
      // 'status':0
  })

    //如果id有值，为修改
    if(id!=''){
        getMemberById(id).then(res=>{
            console.log(res);
            ruleForm.staffName=res.data.staffName
            ruleForm.email=res.data.email
            ruleForm.phone=res.data.phone
            ruleForm.sex=res.data.sex
            ruleForm.idNumber=res.data.idNumber
        })
    }

  function validateRepassword(rule, value, callback) {
      if (value === '') {
          callback(new Error('请再次输入密码'));
      } else if (value !== ruleForm.password) {
          callback(new Error('两次输入密码不一致!'));
      } else {
          callback();
      }
  }

  const rules= {
          'staffName': [{ 'required': true, 'message': '请输入员工姓名', 'trigger': 'blur' }],
          'email': [{ 'required': true, 'message': '请输入员邮箱', 'trigger': 'blur' }],
          'password': [
              { 'required': true, 'message': '请输入密码', 'trigger': 'blur' }
          ],
          'rePassword': [
              { 'required': true, 'message': '请确认密码', 'trigger': 'blur' },
              { 'validator': validateRepassword, 'trigger': 'blur' }
          ],
          'phone': [{ 'required': true, 'message': '请输入手机号', 'trigger': 'blur' }],
          'idNumber': [{ 'required': true, 'message': '请输输入身份证号', 'trigger': 'blur' }]
  }

//添加

const submitForm = async (formEl: FormInstance | undefined, and: String) => {
  if (!formEl) return;
  await formEl.validate((valid, fields) => {
    if (valid) {
     console.log(ruleForm);
    let data={...ruleForm};
    if(id!=""){
        data.staffId=id
    }
    addMember(data).then(res=>{
        if(res.code==200){
         
            if(id==''){
                ElMessage.success("添加成功!")
            }else{
                ElMessage.success("修改成功!")
            }
            if(!and){
                router.back()
            }
            formEl.resetFields();
        }
    })
    } else {
      console.log("error submit!", fields);
    }
  });
};

//取消
function goBack(formEl:any){
    formEl.resetFields();
    router.back()
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
          border-top: solid 1px rgb(243, 244, 247) ;
        }
      }
    }
  }
</style>
