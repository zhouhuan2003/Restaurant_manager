<template>
  <div style="position: relative; height: 100vh">
    <div class="order_body">
      <div class="left_body">
        <div>
          <el-button
            type="primary"
            style="width: 27%; height: 70px; font-weight: bold; font-size: 20px"
            @click="toBack()"
            >返回<br />桌台</el-button
          >
          <div
            style="
              font-size: 20px;
              position: absolute;
              top: 3px;
              left: 30%;
              width: 38%;
              background-color: white;
              border-radius: 5px;
            "
          >
            桌号: {{ table.tableName }}
          </div>
          <div
            style="
              font-size: 20px;
              position: absolute;
              top: 37px;
              left: 30%;
              width: 38%;
              background-color: white;
              border-radius: 5px;
            "
          >
            人数: {{ table.userNumbers }}
          </div>
          <div
            style="
              font-size: 18px;
              position: absolute;
              top: 3px;
              left: 70%;
              width: 27%;
              background-color: white;
              border-radius: 5px;
              color: red;
            "
          >
            <img
              src="@/assets/images/icon/icon_huanzhuo@2x.png"
              style="width: 18px; height: 18px"
            />换桌
          </div>
          <div
            style="
              font-size: 18px;
              position: absolute;
              top: 37px;
              left: 70%;
              width: 27%;
              background-color: white;
              border-radius: 5px;
              color: red;
            "
          >
            <img
              src="@/assets/images/icon/icon_gairenshu@2x.png"
              style="width: 18px; height: 18px"
            />改人数
          </div>
        </div>

        <div
          style="
            border-top-left-radius: 5px;
            border-top-right-radius: 5px;
            position: absolute;
            bottom: 0;
            height: 85%;
            width: 100%;
            background-color: white;
          "
        >
          <div
            style="
              height: 75%;
              width: 100%;
              display: flex;
              flex-direction: column;
              overflow: auto;
            "
          >
            <div
              style="
                font-size: 20px;
                border-bottom: 3px dashed #f0e2d9;
                width: 90%;
                height: 60px;
                margin-top: 5px;
                margin-left: 5%;
              "
              v-for="item in orderList"
              :key="item.dishId"
            >
              <div>
                <span>{{ item.dishName }}</span>
              </div>
              <div style="width: 100%; position: relative">
                <span style="color: red">￥{{ item.price / 100 }}</span>
                <div style="position: absolute; top: -10px; right: 10px">
                  <img
                    @click="reduceDish(item)"
                    src="@/assets/images/icon/btn_caishuliang_-_dis@2x.png"
                    style="width: 40px; height: 40px"
                  />
                  <span style="position: relative; bottom: 11px">{{
                    item.dishNumber
                  }}</span>
                  <img
                    @click="addDish(item)"
                    src="@/assets/images/icon/btn_caishuliang_+_nor@2x.png"
                    style="width: 40px; height: 40px"
                  />
                </div>
              </div>
            </div>
          </div>

          <div
            style="
              line-height: 50px;
              position: absolute;
              bottom: 50px;
              z-index: 999;
              height: 50px;
              width: 100%;
              background-color: rgb(255, 226, 255);
            "
          >
            <img
              src="@/assets/images/icon/icon_beizhu@2x.png"
              style="
                margin-left: 10px;
                width: 25px;
                height: 25px;
                position: relative;
                top: 5px;
              "
            /><span style="font-size: 20px; color: #ffb302">备注:</span>
          </div>
          <div
            style="
              line-height: 50px;
              position: absolute;
              bottom: 0;
              z-index: 999;
              height: 50px;
              width: 100%;
              background-color: #f56c6c;
            "
          >
            <div style="float: right; margin-right: 10px">
              <span style="color: white">总价:￥ {{totalPrice/100}}</span>
            </div>
          </div>
        </div>
      </div>

      <div class="right_body">
        <div class="left">
          <div
            :class="{ act: categoryActive == 0 }"
            @click="editCategory('')"
            class="category"
          >
            <span>全部</span>
          </div>
          <!-- <div style="height:90px"></div> -->
          <div
            :class="{ act: categoryActive == item.categoryId }"
            class="category"
            @click="editCategory(item.categoryId)"
            v-for="item in categoryList"
            :key="item.categoryId"
          >
            <span>{{ item.name }}</span>
          </div>
        </div>
        <div class="right">
          <el-input
            placeholder="请输入菜名"
            v-model="dishName"
            class="input-with-select"
            style="margin: 10px; width: 95%"
          >
            <i
              slot="prefix"
              @click="getDishPage()"
              class="el-icon-search"
              style="padding-top: 14px"
            ></i>
            <el-button slot="append" @click="colse()">重置</el-button>
          </el-input>

          <div
            style="
              margin: 10px;
              width: 95%;
              height: 89%;
              overflow: auto;
              display: flex;
              flex-wrap: wrap;
            "
          >
            <div
              style="
                position: relative;
                font-size: 20px;
                border-radius: 10px;
                width: 30%;
                margin: 5px;
                height: 100px;
                border: 1px solid black;
              "
              v-for="item in dishList"
              :key="item.dishId"
              @click="addOrderList(item)"
            >
              <span style="padding: 10px">{{ item.dishName }}</span>
              <span style="position: absolute; left: 10px; bottom: 0"
                >￥{{ item.price / 100 }}</span
              >
            </div>
          </div>
        </div>
      </div>
    </div>

    <div class="dibu">
      <el-button style="height: 50px; margin-left: 30px" icon="el-icon-delete"
        >一键扫台</el-button
      >
      <el-button style="height: 50px" @click="cut(2)" icon="el-icon-edit"
        >添加备注</el-button
      >
      <el-button
        style="height: 50px"
        @click="cut(1)"
        icon="el-icon-circle-plus-outline"
        >加菜</el-button
      >
      <el-button style="height: 50px" @click="addOrder()" icon="el-icon-s-claim"
        >下单</el-button
      >

      <el-button
        style="
          position: absolute;
          right: 120px;
          top: 15px;
          height: 50px;
          width: 100px;
        "
        type="danger"
        >补单</el-button
      >
      <el-button
        style="
          position: absolute;
          right: 10px;
          top: 15px;
          height: 50px;
          width: 100px;
        "
        type="primary"
        >结账</el-button
      >
    </div>
  </div>
</template>

<script>
import { getCategoryList, getDishList, getTableByid,addOrder } from "@/request/api";
export default {
  data() {
    return {
      tableId:
        this.$route.query.tableId == undefined ? "" : this.$route.query.tableId,
      table: {},
      categoryActive: "",
      categoryList: [],
      dishList: [],
      orderList: [],
      dishName: "",
      orderRemark:'',
      page: 1,
      pageSize: 10,
    };
  },
  computed:{
    totalPrice:function(){
      let price=0;
      this.orderList.forEach(res=>{
        price+=res.price*res.dishNumber
      })
      return price;
    }
  },
  created() {
    //获取分类信息
    getCategoryList({ page: 1, pageSize: 100 }).then((res) => {
      // console.log(res);
      this.categoryList = res.data.items;
    });
    //获取桌台信息
    getTableByid(this.tableId).then((res) => {
      this.table = res.data;
    });
    this.getDishPage();
  },
  methods: {
    addOrder(){
      let data={}
      data.dishes=this.orderList
      data.tableId=this.tableId
      data.personNumbers=this.table.userNumbers
      data.totalAmount=this.totalPrice
      data.orderRemark=this.orderRemark
      addOrder(data).then(res=>{
        if(res.code==200){
          this.$message.success("下单成功!")
          this.$router.back()
        }
      })
    },
    reduceDish(item) {
      let temp=[]
      this.orderList.map((res) => {
        if (res.dishId == item.dishId) {
          res.dishNumber -= 1;
        }
        if(res.dishNumber>0){
           temp.push(res)
        }
      });
      this.orderList=temp
    },
    addDish(item) {
      let temp=[]
      this.orderList.map((res) => {
        if (res.dishId == item.dishId) {
          res.dishNumber += 1;
        }
         temp.push(res)
      });
      this.orderList=temp
    },
    addOrderList(item) {
      item.dishNumber = 1;
      let float = false;
      this.orderList.forEach((res) => {
        if (res.dishId == item.dishId) {
          float = true;
        }
      });
      if (!float) {
        this.orderList.push(item);
      }
    },
    editCategory(id) {
      this.categoryActive = id;
      if (id == 0) {
        this.categoryActive = "";
      }
      this.getDishPage();
    },
    getDishPage() {
      getDishList({
        page: this.page,
        pageSize: this.pageSize,
        name: this.dishName,
        categoryId: this.categoryActive,
      }).then((res) => {
        // console.log(res);
        this.dishList = res.data.items;
      });
    },
    colse() {
      this.dishName = "";
      this.getDishPage();
    },
    toBack() {
      this.$router.back();
    },
  },
};
</script>

<style scoped>
.order_body {
  position: relative;
  top: 30px;
  height: 83%;
  /* background-color:aqua; */
}
.left_body {
  position: absolute;
  bottom: 0;
  left: 10px;
  height: 97%;
  width: 38%;
  /* background-color: red; */
  /* border-radius: 10px; */
}
.right_body {
  position: absolute;
  right: 10px;
  bottom: 0;
  height: 100%;
  width: 58%;
  /* background-color: red; */
  /* border-radius: 10px; */
}
.left {
  height: 100%;
  width: 20%;
  overflow: auto;
  background-color: #495462;
  /* padding-top: 20px; */
  /* overflow: hidden; */
}
.right {
  position: absolute;
  top: 0;
  right: 0;
  height: 100%;
  width: 80%;
  background-color: white;
}
.dibu {
  width: 100%;
  height: 80px;
  position: absolute;
  background-color: white;
  bottom: 0;
  line-height: 80px;
  /* display: flex;
    align-items: center; */
  /* padding-left: 40px; */
}
.category {
  line-height: 70px;
  text-align: center;
  color: white;
  position: relative;
  top: 20px;
  height: 70px;
  border-top: 1px solid white;
  border-bottom: 1px solid white;
}
.act {
  background-color: white;
  color: black;
  border-left: 5px solid #409eff;
}
</style>