<template>
  <div class="login-container">
    <div class="header">
      <div class="container">
        <img
          src="@/assets/logo.png"
          width="153.6"
          alt=""
        > 
        小欢掌柜
        <span>|</span> 运营中心
      </div>
    </div>

    <div class="content">
      <el-form
        ref="loginFormRef"
        :model="loginForm"
        :rules="rules"
        autocomplete="on"
        label-position="left"
        class="login-form"
        @keyup.enter.native="handleLogin(loginFormRef)"
      >
        <div class="formBox">
          <!-- <div class="title-container">

          </div> -->
          <el-form-item prop="loginName">
            <el-input
              ref="loginName"
              v-model="loginForm.loginName"
              name="loginName"
              type="text"
              autocomplete="on"
              placeholder="请输入用户名"
            />
          </el-form-item>
          <el-form-item prop="loginPass">
            <el-input
              ref="loginPass"
              v-model="loginForm.loginPass"
              placeholder="请输入密码"
              name="loginPass"
              autocomplete="on"
              type="password"
            />
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
        loginName: "zh",
        loginPass: "123456",
      },
      loading: false,
      passwordType: "test",
    });
    const rules = {
      loginName: [{ required: true, message: "请输入用户名", trigger: "blur" }],
      loginPass: [
        { required: true, message: "请输入密码", trigger: "blur" },
        { min: 6, message: "密码最少6位", trigger: "blur" },
      ],
    };
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

                    router.replace("/member");
    
                  
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

    return {
      ...toRefs(data),
      rules,
      handleLogin,
      loginFormRef,
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
    background: url("@/assets/img_denglu_bj.jpg") top center no-repeat;
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
      height: 313px;
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