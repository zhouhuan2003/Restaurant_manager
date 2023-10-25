<template>
  <div class="common-layout">
    <el-container>
      <!-- <el-affix :offset="120">
        <div> -->
      <el-aside width="200px">
        <img style="height: 60px; width: 200px" src="@/assets/logo.png" />

        <el-menu
          active-text-color="#ffd04b"
          background-color="#343744"
          class="el-menu-vertical-demo"
          :default-active="path"
          router
          text-color="#fff"
        >
          <el-sub-menu index="1-4">
            <template #title
              ><el-icon><OfficeBuilding /></el-icon> 账号管理</template
            >
            <el-menu-item index="/member">账号管理</el-menu-item>
            <el-menu-item index="/addMember">账号添加</el-menu-item>
          </el-sub-menu>
        </el-menu>
      </el-aside>
      <!-- </div>
      </el-affix> -->

      <el-container style="position: relative; left: 200px">
        <el-header style="width: 1255px">
          <el-row :gutter="20">
            <el-col :span="16" >
              <div class="title" :key="keyDiv">
                <span class="header-1"
                ><span v-if="data.goback" class="goBack" @click="goBack()"
                  ><img src="@/assets/icons/btn_back@2x.png" alt="" />
                  返回 |
                </span>
              </span>
              <span
                style="
                  color: #010101;
                  line-height: 60px;
                  font-size: 18px;
                  float: left;
                "
                >{{ title }}</span
              >
              </div>
            </el-col>
            <el-col :span="8"
              ><span
                >{{ user.loginname }}
                <el-tooltip
                  class="box-item"
                  effect="dark"
                  content="退出登录"
                  placement="bottom"
                >
                  <img
                    style="cursor: pointer"
                    src="@/assets/goOut.png"
                    @click="goOut"
                  />
                </el-tooltip> </span
            ></el-col>
          </el-row>
        </el-header>
        <el-main style="width: 1355px"><router-view></router-view></el-main>
      </el-container>
    </el-container>
  </div>
</template>

<script setup lang="ts">
import { onMounted, onBeforeMount, onUpdated, reactive, ref } from "vue";
import { onBeforeRouteLeave, useRouter, onBeforeRouteUpdate } from "vue-router";
const router = useRouter();
const keyDiv=ref(0)
const path =
  localStorage.getItem("path") == undefined
    ? "/member"
    : localStorage.getItem("path");
let data = reactive({
  goback: false,
});
const title = ref("");
onBeforeMount(() => {
  title.value = localStorage.getItem("title")==undefined? '账号管理':localStorage.getItem("title");
  data.goback =localStorage.getItem("goback") == undefined? false: localStorage.getItem("goback");
});
const user = JSON.parse(localStorage.getItem("user"));

onBeforeRouteUpdate((to, from) => {
  //当前组件路由改变后，进行触发
  localStorage.setItem("path", to.path);
  localStorage.setItem("title", to.meta.title);

  title.value = to.meta.title;
  keyDiv.value+=1;
  if (to.path == "/addMember") {
    data.goback = true;
    localStorage.setItem("goback", "true");
  } else {
    data.goback = false;
    localStorage.removeItem("goback");
  }
});

//退出
function goOut() {
  router.replace("/");
  localStorage.clear();
}

//返回
function goBack() {
  router.back();
}


</script>

<style lang="scss" scoped>
.el-header {
  height: "60px";
  .title {
    opacity: 0;
    animation: opacity 500ms ease-out 800ms forwards;
  }
  .header-1 {
    float: left;

    span {
      line-height: 60px;
      font-size: 18px;
    }
    .goBack {
      padding-right: 14px;
      margin-right: 10px;
      color: #666;
      cursor: pointer;
      img {
        position: relative;
        top: 20px;
        margin-right: 5px;
        width: 18px;
        height: 18px;
        float: left;
      }
    }
  }

  span {
    color: orange;
    font-size: 17px;
    float: right;

    line-height: 60px;
    img {
      height: 30px;
      position: relative;
      top: 8px;
    }
  }
}
.el-aside {
  position: fixed;
  background-color: #ffcfac;
  .el-menu {
    height: calc(100vh - 64px);
  }
}
.el-main {
  background-color: #f3f4f7;
}
.el-menu-item {
  background-color: #272a36;
}
@keyframes opacity {
  0% {
    opacity: 0;
    margin-left: 80px;
  }
  100% {
    opacity: 1;
    left: 0;
  }
}
</style>