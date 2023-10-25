<template>
  <div class="common-layout">
    <el-container>
      <el-aside width="200px" class="aside">
        <div class="img-div">
          <img style="height: 60px; width: 200px" src="../../assets/logo.png" />
        </div>
        <el-menu
          active-text-color="#ffd04b"
          background-color="#343744"
          class="el-menu-vertical-demo"
          :default-active="path"
          router
          text-color="#fff"
          @select="select"
        >
          <el-sub-menu index="1">
            <template #title
              ><el-icon><OfficeBuilding /></el-icon> 门店管理</template
            >
            <el-menu-item index="/about">门店概况</el-menu-item>
            <el-menu-item index="/member">员工管理</el-menu-item>
            <el-menu-item index="/class">分类管理</el-menu-item>
            <el-menu-item index="/fond">菜品管理</el-menu-item>
            <el-menu-item index="/setmeal">套餐管理</el-menu-item>
            <el-menu-item index="/shopTable">桌台管理</el-menu-item>
            <el-menu-item index="/area">区域管理</el-menu-item>
            <el-menu-item index="/accounts">挂账管理</el-menu-item>
            <el-menu-item index="/shopSet">门店设置</el-menu-item>
            <!-- <el-menu-item index="shop/set">门店设置</el-menu-item> -->
          </el-sub-menu>
          <el-sub-menu index="2">
            <template #title
              ><el-icon><Coin /></el-icon> 收银报表</template
            >
            <el-menu-item index="chartAabout">营收概况</el-menu-item>
            <!-- <el-menu-item index="shop/set">门店设置</el-menu-item> -->
          </el-sub-menu>
        </el-menu>
      </el-aside>
      <el-container>
        <el-header class="header">
            <span class="span1 title" v-if="show"  :key="keyDiv">
            <span class="span2" v-if="data.goback" @click="goBack">
              <img src="@/assets/icons/btn_back@2x.png" alt="" /> 返回 |
            </span>
            {{ title }}
          </span>

          <span class="span3">
            当前店铺:
            <el-select
              v-model="value"
              class="m-2"
              placeholder="Select"
              @change="change"
            >
              <el-option
                v-for="item in user.stores"
                :key="item.storeId"
                :label="item.storeName"
                :value="item.storeId"
              />
            </el-select>
            <span class="span4">
              店长: {{ user.storeManagerName }}
              <el-tooltip
                class="box-item"
                effect="dark"
                content="退出登录"
                placement="bottom"
              >
                <img
                  style="cursor: pointer"
                  src="../../assets/goOut.png"
                  @click="goOut"
                />
              </el-tooltip>
            </span>
          </span>
        </el-header>
        <el-main class="main"><router-view /></el-main>
      </el-container>
    </el-container>
  </div>
</template>

<script setup lang="ts">
import { switchStore } from "@/request/api";
import { ElMessage } from "element-plus";
import { onMounted, onBeforeMount, onUpdated, reactive, ref } from "vue";
import { onBeforeRouteLeave, useRouter, onBeforeRouteUpdate } from "vue-router";

const router = useRouter();
const keyDiv=ref(0)
let show=ref(true)
let path = ref(
  localStorage.getItem("path") == undefined
    ? "/about"
    : localStorage.getItem("path")
);
let data = reactive({
  goback: false,
});
const title = ref("");
function select(val: String) {
  localStorage.setItem("path", val);
  path.value = val;
}
onBeforeMount(() => {
  title.value =
    localStorage.getItem("title") == undefined
      ? "门店概况"
      : localStorage.getItem("title");
  data.goback =
    localStorage.getItem("goback") == undefined
      ? false
      : localStorage.getItem("goback");
});
const user = JSON.parse(localStorage.getItem("user"));

const value = ref(localStorage.getItem("storeId")==undefined? user.stores[0].storeId:localStorage.getItem("storeId"));

onBeforeRouteUpdate((to, from) => {
  //当前组件路由改变后，进行触发

  localStorage.setItem("title", to.meta.title);

  title.value = to.meta.title;
  keyDiv.value+=1;
  if (
    to.path == "/member/add" ||
    to.path == "/fond/add" ||
    to.path == "/setmeal/add" ||
    to.path == "/shopTable/add" ||
    to.path == "/accounts/add" ||
    to.path == "/accounts/order" ||
    to.path == "/accounts/repayment"
  ) {
    data.goback = true;
    localStorage.setItem("goback", "true");
  } else if(to.path=="/chartAabout"){
    // show.value=false
  } else{
    data.goback = false;
    localStorage.removeItem("goback");
  }
});

//店铺选择变换时
function change(val: any) {
  switchStore(val).then((res) => {
    // console.log(res);
    if(res.status==200){
      localStorage.setItem("storeId",val)
    localStorage.setItem("token", res.token);
    if (localStorage.getItem("path") == "/about") {
      router.go(0);
    } else {
      localStorage.setItem("path", "/about");
      path.value = "/about";
      router.replace("/about");
    }
    }else{
      ElMessage.error("切换失败")
    }
  }).catch(error=>{
    ElMessage.error(error)
  });
}

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
.common-layout {
  position: relative;
  .aside {
    .img-div {
      background-color: #ffcfac;
    }
    position: fixed;
    .el-menu {
      height: calc(100vh - 64px);
    }
    .el-menu-item {
      background-color: #272a36;
    }
  }
  .header {
    height: 64px;
    width: 86%;
    // background-color: red;
    position: absolute;
    left: 200px;
    .title {
    opacity: 0;
    animation: opacity 500ms ease-out 800ms forwards;
  }
    .span1 {
      font-size: 20px;
      font-weight: bold;
      line-height: 64px;
      .span2 {
        cursor: pointer;
        img {
          position: relative;
          top: 4px;
          width: 20px;
        }
        font-size: 15px;
        margin-left: 10px;
      }
    }
    .span3 {
      float: right;
      line-height: 64px;
      color: orange;
      .span4 {
        img {
          position: relative;
          top: 9px;
          width: 30px;
        }
      }
    }
  }
  .main {
    position: absolute;
    top: 64px;
    left: 200px;
    width: 86.5%;
    height: 100vh;
    background-color: #f3f4f7;
  }
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