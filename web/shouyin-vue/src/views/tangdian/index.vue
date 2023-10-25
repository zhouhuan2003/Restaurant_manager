<template>
  <div style="position: relative; height: 100vh">
    <div class="top">
      <el-row style="margin-left: 40px">
        <el-col :span="3"
          ><div style="line-height: 70px; cursor: pointer">
            <span :class="{ acitve: act == 0 }" @click="change(0)">全部</span>
          </div></el-col
        >
        <el-col :span="4" v-for="item in areaList" :key="item.area_id">
          <div class="area-item">
            <span
              :class="{ acitve: act == item.area_id }"
              @click="change(item.area_id)"
              >{{ item.area_name }}</span
            >
          </div>
        </el-col>
      </el-row>
    </div>

    <div class="body_">
      <div
        class="table-item"
        :class="{ tableAct: tableAct == item.tableId }"
        @click="tableChange(item)"
        v-for="item in tableData.tablePage.items"
        :key="item.tableId"
        v-show="cutIndex == -1 ? 1 == 1 : cutIndex == item.status"
      >
        <div
          style="
            width: 100%;
            font-size: 18px;
            color: #caced8;
            padding-left: 10px;
            padding-top: 10px;
          "
        >
          {{ item.tableName }}
        </div>
        <div style="width: 100%; font-size: 15px; text-align: center">
          <img
            v-if="item.status == 0 && tableAct != item.tableId"
            style="width: 35px; height: 35px"
            src="@/assets/images/icon/icon_card_free_nor@2x.png"
          />
          <img
            v-if="item.status == 0 && tableAct == item.tableId"
            style="width: 35px; height: 35px"
            src="@/assets/images/icon/icon_card_free_sel@2x.png"
          />
          <img
            v-if="item.status == 1 && tableAct != item.tableId"
            style="width: 35px; height: 35px"
            src="@/assets/images/icon/icon_card_lock_nor@2x.png"
          />
          <img
            v-if="item.status == 1 && tableAct == item.tableId"
            style="width: 35px; height: 35px"
            src="@/assets/images/icon/icon_card_lock_sel@2x.png"
          />
          <img
            v-if="item.status == 2 && tableAct != item.tableId"
            style="width: 35px; height: 35px"
            src="@/assets/images/icon/icon_card_eating_nor@2x.png"
          />
          <img
            v-if="item.status == 2 && tableAct == item.tableId"
            style="width: 35px; height: 35px"
            src="@/assets/images/icon/icon_card_eating_sel@2x.png"
          />
          <div
            style="padding-top: 0; color: #8f949f; font-weight: bold"
            :class="{ 'span-act': tableAct == item.tableId }"
          >
            <span v-if="item.status == 0">空闲中</span>
            <span v-if="item.status == 1">锁定中</span>
            <span v-if="item.status == 2">用餐中</span>
          </div>
        </div>
        <div
          v-if="item.status == 2"
          style="
            width: 100%;
            margin-top: 8px;
            font-size: 15px;
            color: #caced8;
            position: relative;
          "
        >
          <div style="position: absolute; left: 10px; bottom: -19px">
            <img
              style="width: 20px; height: 20px"
              src="@/assets/images/icon/icon_renshu.png"
            />
            <span style="position: absolute">{{ item.userNumbers }}</span>
          </div>
          <div style="position: absolute; right: 62px; bottom: -19px">
            <img
              style="width: 20px; height: 20px"
              src="@/assets/images/icon/icon_time.png"
            />
            <span style="position: absolute">{{ item.createTime }}</span>
          </div>
        </div>
      </div>
    </div>

    <div style="width: 100%">
      <!-- <ul>
            <li></li>
        </ul> -->
    </div>

    <div class="dibu">
      <el-button style="height: 50px; margin-left: 30px" @click="cut(0)" round
        >空闲中({{ tableData.freeNumbers }})</el-button
      >
      <el-button style="height: 50px" @click="cut(2)" round
        >用餐中({{ tableData.openedNumbers }})</el-button
      >
      <el-button style="height: 50px" @click="cut(1)" round
        >已锁定({{ tableData.lockedNumbers }})</el-button
      >

      <!-- <div style="position: absolute;"> -->
        <el-button
        style="position: absolute;right:230px;top:15px; height: 50px; width: 100px"
        type="primary"
        v-show="actTableStatus == 2 && (cutIndex==2 || cutIndex==-1)"
        @click="$router.push('/orderInfo?tableId='+tableAct)"
        >详情</el-button
      >
      <el-button
        style="position: absolute;right:120px;top:15px; height: 50px; width: 100px"
        type="danger"
        @click="openTable"
        >开桌</el-button
      >
      <el-button style="position: absolute;right:10px;top:15px; height: 50px; width: 100px" type="primary"
        >预定</el-button
      >
      <!-- </div> -->
    </div>

    <!-- 开桌 -->
    <el-dialog title="开桌" :visible.sync="dialogFormVisible" @close="close">
      <el-form :model="form">
        <el-form-item label="请输入人数" :label-width="formLabelWidth">
          <el-input
            v-model="form.numbers"
            :placeholder="`请输入1~${form.seatNumber}`"
            autocomplete="off"
          ></el-input>
        </el-form-item>
      </el-form>
      <div slot="footer" class="dialog-footer">
        <el-button @click="dialogFormVisible = false">取 消</el-button>
        <el-button
          style="color: white; background-color: orange"
          @click="submit"
          >确 定</el-button
        >
      </div>
    </el-dialog>
  </div>
</template>

<script>
import { listTableArea, tableList, openTable } from "@/request/api";
export default {
  data() {
    return {
      areaList: [],
      tableData: { tablePage: { items: [] } },
      act: 0, //选中的区域id
      cutIndex: -1, //桌台状态
      tableAct: 0, //选中的桌台id
      page: 1,
      pageSize: 20,
      pages: 0,
      form: {
        seatNumber: 0,
        numbers: "",
      },
      dialogFormVisible: false,
      formLabelWidth: "120px",
      actTableStatus: -1,
    };
  },
  created() {
    listTableArea().then((res) => {
      console.log(res);
      this.areaList = res.data;
    });

    this.getTableList({
      areaId: "all",
      page: this.page,
      pageSize: this.pageSize,
    });
  },
  methods: {
    openTable() {
      if (this.tableAct == 0) {
        return this.$message.error("请选择空闲桌台再操作!");
      }
      this.dialogFormVisible = true;
    },

    close() {
      console.log(this.form);
      this.form.numbers = "";
    },
    submit() {
      if (this.form.numbers == "") {
        return this.$message("至少要一个人");
      }
      if (this.form.numbers > this.form.seatNumber) {
        return this.$message("人数大于桌台限定人数");
      }
      // console.log(this.form.numbers);
      openTable({ tableId: this.tableAct, numbers: this.form.numbers }).then(
        (res) => {
          console.log(res);
          if (res.code == 200) {
            // this.$message.success("开桌成功!");
            // this.getTableList({
            //   areaId: this.act == "0" ? "all" : this.act,
            //   page: this.page,
            //   pageSize: this.pageSize,
            // });
            this.dialogFormVisible = false;
            this.$router.push("/orderInfo?tableId"+this.tableAct)
          } else {
            this.$message.error("开桌失败!");
          }
        }
      );
    },

    tableChange(item) {
      this.actTableStatus = item.status;
      this.form.seatNumber = item.seatNumber;
      if (this.tableAct == item.tableId) {
        this.actTableStatus = 0;
        this.tableAct = 0;
      } else {
        this.tableAct = item.tableId;
      }
    },
    change(id) {
      this.act = id;
      this.cutIndex = -1;
      if (id == 0) {
        this.getTableList({
          areaId: "all",
          page: this.page,
          pageSize: this.pageSize,
        });
      } else {
        this.getTableList({
          areaId: id,
          page: this.page,
          pageSize: this.pageSize,
        });
      }
    },

    getTableList(data) {
      tableList(data).then((res) => {
        // console.log(res);
        this.tableData = res.data;
      });
    },

    cut(status) {
      if (this.cutIndex == status) {
        this.cutIndex = -1;
      } else {
        this.cutIndex = status;
      }
    },
  },
};
</script>

<style scoped>
.top {
  height: 70px;
  background-color: white;
}
.area-item {
  line-height: 70px;
  cursor: pointer;
}
.acitve {
  padding-bottom: 10px;
  border-bottom: 7px solid #f06d58;
  border-radius: 5px;
}
.body_ {
  margin-top: 10px;
  margin-left: 20px;
  display: flex;
  flex-wrap: wrap;
}
.table-item {
  width: 17%;
  height: 120px;
  background-color: white;
  border-radius: 10px;
  margin: 10px;
}
.tableAct {
  background-color: #556388;
}
.span-act {
  color: #f1cfa9;
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
</style>