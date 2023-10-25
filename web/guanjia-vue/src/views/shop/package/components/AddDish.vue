<template>
  <div class="addDish">
    <div class="leftCont">
      <div v-show="seachKey.trim() == ''" class="tabBut">
        <span
          v-for="(item, index) in dishType"
          :key="index"
          :class="{ act: index == keyInd }"
          @click="checkTypeHandle(index, item.category_id)"
          >{{ item.name }}</span
        >
      </div>
      <div class="tabList">
        <div class="table">
          <div v-if="dishList.length == 0">暂无菜品!</div>
          <el-checkbox-group
            v-if="dishList.length > 0"
            v-model="checkedList"
            @change="checkedListHandle"
          >
            <div v-for="(item, index) in dishList" :key="index" class="items">
              <el-checkbox :key="index" :label="item">
                <div class="item">
                  <span style="flex: 3; text-align: left">{{
                    item.dishName
                  }}</span>
                  <span>{{ item.status == 0 ? "停售" : "在售" }}</span>
                  <span>￥{{ Number(item.price) / 100 }}</span>
                </div>
              </el-checkbox>
            </div>
          </el-checkbox-group>
        </div>
      </div>
    </div>
    <div class="ritCont">
      <div class="tit">已选菜品()</div>
      <div class="items">
        <div v-for="(item, ind) in checkedList" :key="ind" class="item">
          <span>{{ item.dishName }}</span>
          <span class="price">￥{{ Number(item.price) / 100 }} </span>
          <span class="del" @click="delCheck(ind)">
            <img src="@/assets/icons/btn_clean@2x.png" alt="" />
          </span>
        </div>
      </div>
    </div>
  </div>
</template>

<script lang="ts" setup>
import { ref, toRefs, watch } from "vue";
import { getCategroyByType, getDishListType } from "@/request/api";
const emit = defineEmits(["getCheckList"]);
const props = defineProps({
  checkList: Array,
  seachKey: String,
  value: Number,
});

const { checkList, seachKey, value } = toRefs(props);
const dishType = ref([]);
const dishList = ref([]);
const dishListCache = ref([]);
const keyInd = ref(0);
const searchValue = ref("");
const checkedList = ref([]);

getDishType();

watch(()=>checkList,(value1:any)=>{
  checkedList.value = value1;
})

// @Watch('seachKey')
watch(()=>seachKey ,(value:any)=>{
    console.log(value.trim());
  if (value.trim()) {
    getDishForName(value);
  }
} )

// 获取套餐分类
function getDishType() {
  getCategroyByType(1).then((res) => {
    dishType.value = res.data;
    getDishList(res.data[0].category_id);
  });
}

// 通过套餐ID获取菜品列表分类
function getDishList(id: number) {
  getDishListType({ id:id,name:'' }).then((res) => {
    if (res.data.length == 0) {
      dishList.value = [];
      return;
    }
    let newArr = res.data;
    newArr.forEach((n: any) => {
      n.dishId = n.id;
      n.copies = 1;
      n.dishName = n.name;
    });
    dishList.value = newArr;
  });
}

// 关键词收搜菜品列表分类
function getDishForName(name1: number) {
  getDishListType({ id:1,name:name1 }).then((res) => {
    // const { data } = res.data;
    let newArr = res.data.items;
    newArr.forEach((n: any) => {
      n.dishId = n.id;
      n.dishName = n.name;
    });
    dishList.value = newArr;
  });
}

function checkTypeHandle(ind: number, id: any) {
  keyInd.value = ind;
  getDishList(id);
}

function checkedListHandle(value: any) {
   emit('getCheckList', checkedList);
}

function open(done: any) {
  dishListCache.value = JSON.parse(JSON.stringify(checkList));
}

function close(done: any) {
   checkList.value=  dishListCache;
}

// 删除
function delCheck(ind: any) {
  console.log(ind);
  
  checkedList.value.splice(ind, 1);

  console.log(checkedList.value);
  
}
</script>
<style lang="scss">
.addDish {
  .el-checkbox__label {
    width: 100%;
  }
}
</style>
<style lang="scss" scoped>
.addDish {
  padding: 0 20px;
  display: flex;
  line-height: 40px;
  .leftCont {
    display: flex;
    border-right: solid 2px #e4e7ed;
    width: 60%;
    padding: 15px;
    .tabBut {
      width: 110px;
      span {
        display: block;
        text-align: center;
        border-right: solid 2px #f4f4f4;
        cursor: pointer;
      }
    }
    .act {
      color:orange;
      border-color: orange !important;
    }
    .tabList {
      flex: 1;
      padding: 15px;
      .table {
        border: solid 1px #f4f4f4;
        border-bottom: solid 1px #f4f4f4;
        .items {
          border-bottom: solid 1px #f4f4f4;
          padding: 0 10px;
          display: flex;
          .el-checkbox,
          .el-checkbox__label {
            width: 100%;
          }
          .item {
            display: flex;
            padding-right: 20px;
            span {
              display: inline-block;
              text-align: center;
              flex: 1;
            }
          }
        }
      }
    }
  }
  .ritCont {
    width: 40%;
    padding: 0 15px;
    .item {
      box-shadow: 0px 1px 4px 3px rgba(0, 0, 0, 0.03);
      display: flex;
      text-align: center;
      padding: 0 10px;
      margin-bottom: 20px;
      border-radius: 6px;
      color: #818693;
      span:first-child {
        text-align: left;
        color: #20232a;
      }
      .price {
        display: inline-block;
        flex: 1;
      }
      .del {
        cursor: pointer;
        img {
          position: relative;
          top: 5px;
          width: 20px;
        }
      }
    }
  }
}
</style>
