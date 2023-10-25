<template>
  <div class="login-div">
    <div class="login-from">
      <div style="margin-top: 20px; margin-left: 15%">
        <span style="font-size: 35px; padding-right: 10px"
          >小欢掌柜 &nbsp;|</span
        ><span style="font-size: 35px">收银系统</span>
      </div>

      <div style="margin-top:20px">
        <el-form
          :model="ruleForm"
          :rules="rules"
          ref="ruleForm"
          label-width="100px"
          class="demo-ruleForm"
        >
          <el-form-item label="商户号" prop="shopId">
            <el-input v-model="ruleForm.shopId"></el-input>
          </el-form-item>
          <el-form-item label="用户名" prop="loginName">
            <el-input v-model="ruleForm.loginName"></el-input>
          </el-form-item>
          <el-form-item label="密码" prop="loginPass">
            <el-input v-model="ruleForm.loginPass" type="password"></el-input>
          </el-form-item>
          <el-form-item >
            <el-button style="color:white;background-color:orange;margin-left:20%" @click="submitForm('ruleForm')"
              >登录</el-button
            >
            <el-button @click="resetForm('ruleForm')">重置</el-button>
          </el-form-item>
        </el-form>
      </div>

      <div style="text-align: center; margin-top: 10px; font-size: 20px">
        忘记密码了？请联系店长进行密码重置
      </div>
    </div>
  </div>
</template>

<script>
import {login} from '@/request/api'
export default {
  data() {
    return {
      ruleForm: {
        shopId: "16513893",
        loginName: "贺琪",
        loginPass: "123456",
      },

      rules: {
        shopId: [{ required: true, message: "请输入商户号", trigger: "blur" }],
        loginName: [
          { required: true, message: "用户名不能为空", trigger: "blur" },
        ],
        loginPass: [
          { required: true, message: "密码不能为空", trigger: "blur" },
        ],
      },
    };
  },
  methods: {
      submitForm(formName) {
        this.$refs[formName].validate((valid) => {
          if (valid) {
            // alert('submit!');
            
            login(this.ruleForm).then(res=>{
                if(res.status=='500'){
                    this.$message.error(res.desc)
                }else if(res.status=='200'){
                    this.$message.success("登录成功")
                    localStorage.setItem('user',JSON.stringify(res.data))
                    localStorage.setItem("token",res.token)
                    this.$router.replace("/index")
                }
            })
          } else {
            console.log('error submit!!');
            return false;
          }
        });
      },
      resetForm(formName) {
        console.log("重置");
        this.$refs[formName].resetFields();
      }
    }
};
</script>

<style  >
.login-div {
  height: 100vh;
  background-image: url("../../assets/images/logBg.jpg");
  background-size: cover;
  /* 让背景图基于容器大小伸缩 */
  background-attachment: fixed;
  /* 当内容高度大于图片高度时，背景图像的位置相对于viewport固定 */
  display: flex;
  align-items: center;
  justify-content: center;
}
.login-from {
  z-index: 999;
  width: 50%;
  height: 50%;
  background-color: white;
  border-radius: 15px;
}
</style>