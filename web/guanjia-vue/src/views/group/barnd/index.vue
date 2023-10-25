<template>
  <div class="container">
    <div v-for="(item, index) in list" class="item" :key="index">
      <img />
      <img
        v-if="!item.logo"
        style="width: 120px; height: 120px"
        src="@/assets/img_brand01@2x.png"
        
      />
      <el-image
        v-if="item.logo"
        style="width: 120px; height: 120px"
        :src="item.logo"
        
      />
      <div class="tit">
        {{ item.brandName }}
      </div>
      <div class="des">
        {{ item.info }}
      </div>
    </div>
    <div class="item-add" @click="add">
      <div class="add">+</div>
      <div class="tit">添加品牌</div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { useRouter } from "vue-router";
import { getBarndList } from "@/request/api";
import { ElMessage } from "element-plus";
import { onMounted, onUpdated, reactive, ref } from "vue";
const router = useRouter();

let list = ref([]);

//添加品牌
function add() {
  router.push({
    path: "/barnd/add",
    query: {
      goback: true,
    },
  });
}

getBarndList()
  .then((res) => {
    if (res.code == 200) {
      list.value = res.data.items;
    }
  })
  .catch((error) => {
    console.log(error);
  });

//获取品牌列表
// function getList() {
//   getBarndList()
//     .then((res) => {
//       if (res.code == 200) {
//         list = res.data.items;
//       }
//     })
//     .catch((error) => {
//       console.log(error);
//     });
// }
// onMounted(() => {
//   getList();
// });
</script>

<style lang="scss" scoped>
.container {
  width: 1187px;
  display: -webkit-box;
  display: -ms-flexbox;
  display: flex;
  -ms-flex-wrap: wrap;
  flex-wrap: wrap;
  position: relative;
  top: 10px;
  left: 10px;
  z-index: 1;
  .item {
    text-align: center;
    padding: 15px;
    width: 15%;
    height: 230px;
    margin: 1%;
    border-radius: 3px;
    -webkit-box-shadow: 2px 2px 12px rgba(0, 0, 0, 0.1);
    box-shadow: 2px 2px 12px rgba(0, 0, 0, 0.1);
    background: #fff;
    line-height: 2;
    .des {
      font-size: 12px;
      line-height: 20px;
      color: #b69593;
    }
  }
  .item-add {
    cursor: pointer; //悬浮时变手指
    text-align: center;
    padding: 15px;
    width: 15%;
    height: 230px;
    margin: 1%;
    border-radius: 3px;
    -webkit-box-shadow: 2px 2px 12px rgba(0, 0, 0, 0.1);
    box-shadow: 2px 2px 12px rgba(0, 0, 0, 0.1);
    background: #fff;
    line-height: 2;
    .tit {
      font-size: 16px;
      line-height: 50px;
      color: #20232a;
    }
    .add {
      background: #818693;
      display: inline-block;
      width: 66px;
      height: 66px;
      border-radius: 100%;
      font-size: 52px;
      color: #fff;
      line-height: 55px;
      margin-top: 60px;
    }
  }
  .item-add:hover {
    .tit {
      color: orange;
    }
    .add {
      background: orange;
    }
  }
}
</style>