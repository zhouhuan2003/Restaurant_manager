<template>
  <div>
    <el-container>
      <el-aside width="150px">
        <div>
          <img
            src="@/assets/images/icon/img_logo.png"
            style="
              width: 100px;
              height: 100px;
              margin-top: 10px;
              margin-left: 20%;
            "
          />
        </div>

        <div>
          <div class="menu" :class="{'act_menu' : active==item.id}"  v-for="item in menuList" :key="item.name" @click="chenge(item)">
            <el-image
              style="width: 80px; height: 80px; margin-top: 5px"
              :src="active==item.id? item.url_active:item.url"
              fit="fit"
            ></el-image>
            <div>
              <span>{{ item.name }}</span>
            </div>
          </div>
        </div>
      </el-aside>
      <el-main>
        <router-view/>
      </el-main>
    </el-container>
  </div>
</template>

<script>
export default {
  data() {
    return {
        active:1,
      menuList: [
        {
          id: 1,
          url: require("../../assets/images/icon/icon_tangdian_nor@2x.png"),
          url_active: require("../../assets/images/icon/icon_tangdian_sel@2x.png"),
          name: "堂点",
          path:'/tangdian',
        },
        {
          id: 2,
          url: require("../../assets/images/icon/icon_guqing_nor@2x.png"),
          url_active: require("../../assets/images/icon/icon_guqing_sel@2x.png"),
          name: "沽清",
          path:'/guqing',
        },
        {
          id: 3,
          url: require("../../assets/images/icon/icon_dingdan_nor@2x.png"),
          url_active: require("../../assets/images/icon/icon_dingdan_sel@2x.png"),
          name: "订单",
          path:'/dingdan',
        },
        {
          id: 4,
          url: require("../../assets/images/icon/icon_shouju_nor@2x.png"),
          url_active: require("../../assets/images/icon/icon_shouju_sel@2x.png"),
          name: "收据",
          path:'/shouju',
        },
      ],
    };
  },
  methods:{
    chenge(item){
        this.active=item.id
        this.$router.replace(item.path)
    }
  }
};
</script>

<style scoped>
.el-aside {
  width: 200px;
  height: 100vh;
  background-color: #2e3b60;
}
.el-main {
  width: 100%;
  height: 100vh;
  background-color: #f0e2d9;
  padding:0
}
.menu {
  width: 100%;
  height: 120px;
  /* background-color: aqua; */
  border: 1px solid #1f2d54;
  text-align: center;
  font-size: 20px;
  color: #7f8fba;
  cursor: pointer;
}
.act_menu{
    background-color: #1f2d54;
    /* width: 180px; */
    color:#f06d58;
    z-index: 999;
    
}
</style>