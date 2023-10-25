<template>
  <div class="login-container">
    <div class="header">
      <div class="container">
        <!-- <img
          src="./../../assets/logo.png"
          width="153.6"
          alt=""
        >  -->
        小欢掌柜
        <span>|</span> 管家系统
      </div>
    </div>

    <div class="content">
      <el-form
        v-show="type != 3"
        ref="loginFormRef"
        :model="loginForm"
        :rules="rules"
        autocomplete="on"
        label-position="left"
        class="login-form"
        @keyup.enter.native="handleLogin(loginFormRef)"
      >
        <div class="formBox">
          <div class="title-container">
            <span :class="{ act: type === 1 }" @click="loginType(1)"
              >集团管理</span
            >
            <span :class="{ act: type === 2 }" @click="loginType(2)"
              >门店管理</span
            >
          </div>
          <el-form-item prop="shopId">
            <el-input
              ref="shopId"
              v-model="loginForm.shopId"
              name="shopId"
              type="text"
              autocomplete="on"
              placeholder="请输入商铺号"
            />
          </el-form-item>
          <el-form-item prop="phone">
            <el-input
              ref="phone"
              v-model="loginForm.phone"
              name="phone"
              type="text"
              autocomplete="on"
              placeholder="请输入用户名"
            />
          </el-form-item>
          <el-form-item prop="password">
            <el-input
              ref="password"
              v-model="loginForm.password"
              placeholder="请输入密码"
              name="password"
              autocomplete="on"
              type="password"
            />
            <span class="show-pwd" @click="showPwd">
              <el-icon
                :name="passwordType === 'password' ? 'eye-off' : 'eye-on'"
              />
            </span>
          </el-form-item>

          <el-button
            :loading="loading"
            type="warning"
            style="width: 100%; margin-bottom: 30px; background-color: orange"
            v-on:focus.native="handleLogin(loginFormRef)"
            @click="handleLogin(loginFormRef)"
          >
            登录
          </el-button>
          <div class="passwordChange">
            <span @click="changePass(3)">忘记密码？</span>
          </div>
        </div>
      </el-form>

      <!-- 忘记密码 -->
      <el-form
        v-show="type == 3"
        ref="forgotPwdRef"
        :model="forgotPwd"
        :rules="rulesForgotPwd"
        autocomplete="on"
        label-position="left"
        class="login-form"
      >
        <div class="formBox">
          <div class="title-container">
            <span>重置密码</span>
          </div>
          <el-form-item prop="phone">
            <el-input
              ref="phone"
              v-model="forgotPwd.phone"
              name="phone"
              type="text"
              autocomplete="on"
              placeholder="请输入注册手机号"
            />
          </el-form-item>
          <el-form-item prop="oPwd">
            <el-input
              ref="oPwd"
              v-model="forgotPwd.oPwd"
              name="oPwd"
              type="password"
              autocomplete="on"
              placeholder="请输入密码"
            />
          </el-form-item>
          <el-form-item prop="nPwd">
            <el-input
              ref="nPwd"
              v-model="forgotPwd.nPwd"
              placeholder="请重置密码"
              name="nPwd"
              autocomplete="on"
              type="password"
            />
            <span class="show-pwd" @click="showPwd">
              <el-icon
                :name="passwordType === 'password' ? 'eye-off' : 'eye-on'"
              />
            </span>
          </el-form-item>

          <el-button
            :loading="loading"
            type="warning"
            style="width: 100%; margin-bottom: 30px; background-color: orange"
            @keyup.enter.native="forgotPwd1(loginFormRef)"
            @click="forgotPwd1(loginFormRef)"
          >
            密码更改
          </el-button>
          <div class="passwordChange">
            <span @click="changePass(1)">已有账号返回登录？</span>
          </div>
        </div>
      </el-form>
    </div>

    <div class="footer">Copyright @ 2023 xiaohuan All Rights Reserved</div>
  </div>
</template>

<script lang="ts">
import { defineComponent, reactive, toRefs, ref } from "vue";
import { FormInstance, ElMessage } from "element-plus";
import { login } from "../../request/api";
import { useRouter } from "vue-router";

export default defineComponent({
  setup() {
    const data = reactive({
      loginForm: {
        shopId: "16513893",
        phone: "13203050639",
        password: "123456",
        type: 1,
      },
      forgotPwd: {
        phone: "",
        oPwd: "",
        nPwd: "",
      },
      type: 1,
      loading: false,
      passwordType: "test",
    });
    const rules = {
      shopId: [{ required: true, message: "请输入商铺号", trigger: "blur" }],
      phone: [{ required: true, message: "请输入用户名", trigger: "blur" }],
      password: [
        { required: true, message: "请输入密码", trigger: "blur" },
        { min: 6, message: "密码最少6位", trigger: "blur" },
      ],
    };

    const rulesForgotPwd = {
      phone: [{ required: true, message: "请输入用户名", trigger: "blur" }],
      oPwd: [
        { required: true, message: "请输入密码", trigger: "blur" },
        { min: 6, message: "密码最少6位", trigger: "blur" },
      ],
      nPwd: [
        { required: true, message: "请重复密码", trigger: "blur" },
        { min: 6, message: "密码最少6位", trigger: "blur" },
      ],
    };

    //登录类型
    function loginType(type1: number) {
      type1 !== 3 ? (data.loginForm.type = type1) : "";
      type1 !== 3 ? (data.type = type1) : "";
      if(type1==1){
        data.loginForm.shopId="16513893" 
        data.loginForm.phone= "13203050639"
        data.loginForm.password="123456"
        data.loginForm.type= 1
      }
      if(type1==2){
        data.loginForm.shopId="16513893" 
        data.loginForm.phone= "13203050639"
        data.loginForm.password="123456"
        data.loginForm.type= 2
      }
      
    }

    const loginFormRef = ref<FormInstance>();
    const router = useRouter();
    //登录
    const handleLogin = async (formEl: FormInstance | undefined) => {
      if (!formEl) return;
      await formEl.validate((valid, fields) => {
        if (valid) {
          // console.log('submit!')
          data.loading = true;
          setTimeout(() => {
            login(data.loginForm)
              .then((res) => {
                 data.loading = false;
                if (res.status == 200) {
                  ElMessage.success("登录成功!");
                  localStorage.setItem("token", res.token);
                  localStorage.setItem("user", JSON.stringify(res.data));
                  if(data.type==1){
                    router.replace("/group");
                  }else{
                    router.replace("/shopAdmin");
                  }
                  
                }else{
                  ElMessage.error("登录失败!");
                }
                console.log(res);
              })
              .catch((error) => {
                ElMessage.error("登录失败");
              });
          }, 1000);
        } else {
          console.log("error submit!", fields);
        }
      });
    };

    //忘记密码
    function changePass(number: number) {
      if (number == 3) {
        data.type = 3;
      } else {
        data.type = 1;
      }
    }

    const forgotPwdRef = ref<FormInstance>();
    //忘记密码
    const forgotPwd1 = async (formEl: FormInstance | undefined) => {
      if (!formEl) return;
      console.log(data.forgotPwd.oPwd, data.forgotPwd.nPwd);

      if (data.forgotPwd.oPwd != data.forgotPwd.nPwd) {
        ElMessage("两次密码不一样!");
        return;
      }
      await formEl.validate((valid, fields) => {
        if (valid) {
          // console.log('submit!')
          data.loading = true;
          setTimeout(() => {
            //     login(data.loginForm).then((res)=>{
            //     console.log(res);
            data.loading = false;

            // })
          }, 1000);
        } else {
          console.log("error submit!", fields);
        }
      });
    };

    return {
      ...toRefs(data),
      loginType,
      rules,
      handleLogin,
      loginFormRef,
      changePass,
      forgotPwd1,
      forgotPwdRef,
      rulesForgotPwd,
    };
  },
});
</script>

<style lang='scss' scoped>
.login-container {
  height: 100%;
  width: 100%;
  overflow: hidden;
  display: flex;
  flex-direction: column;
  //   background-color: $loginBg;
  .header {
    background: #fff;
    padding: 20px 0;
    .container {
      width: 1200px;
      margin: 0 auto;
      line-height: 52px;
      font-size: 28px;
      img {
        float: left;
      }
      span {
        display: inline-block;
        padding: 0 20px;
        color: #ccc;
      }
    }
  }
  .footer {
    background: #fff;
    color: #818693;
    text-align: center;
    font-size: 14px;
    line-height: 100px;
  }
  .content {
    flex: 1;
    background: url("./../../assets/img_denglu_bj.jpg") top center no-repeat;
    background-size: cover;
  }
  .login-form {
    position: relative;
    max-width: 100%;
    top: 50%;
    transform: translateY(-50%);
    overflow: hidden;
    .formBox {
      position: relative;
      background: #fff;
      border-radius: 16px;
      padding: 40px;
      left: 75%;
      transform: translateX(-50%);
      width: 350px;
      height: 413px;
    }
  }

  .tips {
    font-size: 14px;
    color: #fff;
    margin-bottom: 10px;

    span {
      &:first-of-type {
        margin-right: 16px;
      }
    }
  }

  .title-container {
    position: relative;
    display: flex;
    text-align: center;
    span {
      flex: 1;
      cursor: pointer;
      margin: 30px 0 40px 0;
      border-right: solid 1px #ccc;
    }
    span:last-child {
      border-right: none;
    }
    .act {
      color: orange;
    }
  }
  .passwordChange {
    text-align: right;
    cursor: pointer;
  }
  .show-pwd {
    position: absolute;
    right: 10px;
    top: 7px;
    font-size: 16px;
    color: orange;
    cursor: pointer;
    user-select: none;
  }
}
</style>