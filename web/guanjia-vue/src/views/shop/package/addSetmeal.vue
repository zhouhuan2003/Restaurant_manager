<template>
  <div class="addBrand-container">
    <div class="container">
      <el-form
        ref="ruleFormRef"
        :model="ruleForm"
        :rules="rules"
        :inline="true"
        label-width="180px"
        class="demo-ruleForm"
      >
        <div>
          <el-form-item label="套餐名称:" prop="name">
            <el-input v-model="ruleForm.name" placeholder="请填写套餐名称" />
          </el-form-item>
          <el-form-item label="套餐分类" prop="categoryId">
            <el-select
              v-model="ruleForm.categoryId"
              placeholder="请选择套餐分类"
            >
              <el-option
                v-for="item in setMealList"
                :label="item.name"
                :value="item.category_id"
                :key="item.category_id"
              />
            </el-select>
          </el-form-item>
        </div>
        <div>
          <el-form-item label="套餐价格:" prop="price">
            <el-input v-model="ruleForm.price" placeholder="请设置套餐价格" />
          </el-form-item>
        </div>
        <div>
          <el-form-item label="套餐菜品:">
            <el-form-item>
              <div class="addDish">
                <span
                  v-if="dishTable.length == 0"
                  class="addBut"
                  @click="openAddDish"
                >
                  + 添加菜品</span
                >
                <div v-if="dishTable.length != 0" class="content">
                  <div
                    class="addBut"
                    style="margin-bottom: 20px"
                    @click="openAddDish"
                  >
                    + 添加菜品
                  </div>
                  <div class="table">
                    <el-table :data="dishTable" style="width: 100%">
                      <el-table-column
                        prop="dishName"
                        label="名称"
                        width="180"
                        align="center"
                      />
                      <el-table-column prop="price" label="原价" width="180">
                        <template #default="scope">
                          ￥{{ Number(scope.row.price) / 100 }}
                        </template>
                      </el-table-column>
                      <el-table-column
                        prop="address"
                        label="份数"
                        align="center"
                      >
                        <template #default="scope">
                          <el-input-number
                            v-model="scope.row.copies"
                            
                            :min="1"
                            :max="99"
                            label="描述文字"
                          />
                        </template>
                      </el-table-column>
                      <el-table-column
                        prop="address"
                        label="操作"
                        width="180px;"
                        align="center"
                      >
                        <template #default="scope">
                          <el-button
                            link
                            style="color:orange"
                            @click="delDishHandle(scope.$index)"
                          >
                            删除
                          </el-button>
                        </template>
                      </el-table-column>
                    </el-table>
                  </div>
                </div>
              </div>
            </el-form-item>
          </el-form-item>
        </div>
        <div>
          <el-form-item label="套餐图片">
            <el-upload
              class="avatar-uploader"
              action="http://192.168.0.105:8081/fileUpload"
              :show-file-list="false"
              :on-success="handleAvatarSuccess"
              :before-upload="beforeAvatarUpload"
            >
              <img v-if="imageUrl" :src="imageUrl" class="avatar" />
              <i v-else class="el-icon-plus avatar-uploader-icon" />
            </el-upload>
          </el-form-item>
        </div>
        <el-form-item label="商品码:" prop="code">
          <el-input v-model="ruleForm.code" placeholder="请输入商品码" />
        </el-form-item>
        <div class="address">
          <el-form-item label="菜品描述">
            <el-input
              v-model="ruleForm.description"
              type="textarea"
              :rows="3"
              placeholder="菜品描述，最长200字"
            />
          </el-form-item>
        </div>
        <div class="subBox address">
          <el-form-item>
            <el-button @click="router.back()"> 取消 </el-button>
            <el-button
              style="color: white; background-color: orange"
              @click="submitForm(ruleFormRef)"
            >
              保存
            </el-button>
            <el-button
              v-if="actionType == 'add'"
              type="primary"
              class="continue"
              @click="submitForm(ruleFormRef, true)"
            >
              保存并继续添加门店
            </el-button>
          </el-form-item>
        </div>
      </el-form>
    </div>
    <el-dialog
      title="添加菜品"
      class="addDishList"
      v-model="dialogVisible"
      width="60%"
      :before-close="handleClose"
    >
      <el-input
        v-model="value1"
        class="seachDish"
        placeholder="请输入菜品名称进行搜索"
        style="width: 250px"
        clearable
        @keydown.enter="seachHandle"
        @clear="clear1()"
      >
        <template #prefix>
          <el-icon
            class="el-input__icon el-icon-search"
            style="cursor: pointer"
            @click="seachHandle"
            ><search
          /></el-icon>
        </template>
      </el-input>
      <AddDish
        ref="adddish"
        :checkList="checkList"
        :seachKey="seachKey"
        @getCheckList="getCheckList"
      />
      <template #footer>
        <span class="dialog-footer">
          <el-button @click="handleClose">取 消</el-button>
          <el-button
            style="color: white; background-color: orange"
            @click="addTableList"
            >确 定</el-button
          >
        </span>
      </template>
    </el-dialog>
  </div>
</template>

<script lang="ts" setup>
import {
  setMealByid,
  setMealAdd,
  getCategroyByType,
  setMealUpdate,
  getDishListType,
} from "@/request/api";
import { ElMessage, FormInstance } from "element-plus";
import { reactive, ref } from "vue";
import { useRouter } from "vue-router";
import AddDish from "./components/AddDish.vue";

const ruleFormRef = ref<FormInstance>();
const router = useRouter();
const id1 = router.currentRoute.value.query.id;

const value1 = ref("");
const setMealList = ref([]);
const seachKey = ref("");
const dishList = ref([]);
const imageUrl = ref("");
const actionType = ref("");
const dishTable = ref([]);
const dialogVisible = ref(false);
const checkList = ref([]);
const ruleForm = reactive({
  name: "",
  categoryId: "",
  price: 0,
  code: "",
  image: "",
  description: "",
  dishList: [],
  status: true,
});

const rules = {
  name: { required: true, message: "请输入套餐名称", trigger: "blur" },
  region: { required: true, message: "请选择套餐分类", trigger: "blur" },
  price: { required: true, message: "请输入套餐价格", trigger: "blur" },
  code: { required: true, message: "请输入商品码", trigger: "blur" },
};

getDishTypeList();
actionType.value = router.currentRoute.value.query.id ? "edit" : "add";
if (actionType.value == "edit") {
  init();
}

function init() {
  setMealByid(id1).then((res) => {
    ruleForm.name = res.data.name;
    ruleForm.categoryId = res.data.categoryId;
    ruleForm.code = res.data.code;
    ruleForm.description = res.data.description;
    ruleForm.status = res.data.status == "1";
    ruleForm.price = res.data.price / 100;
    imageUrl.value = res.data.image;
    ruleForm.image = res.data.image;
    checkList.value = res.data.dishList;
    dishTable.value = res.data.dishList;
  });
}
function seachHandle() {
  seachKey.value = value1.value;
}

function clear1() {
  seachKey.value = "";
}
// 获取套餐分类
function getDishTypeList() {
  getCategroyByType(2).then((res) => {
    setMealList.value = res.data;
  });
}

// 通过套餐ID获取菜品列表分类
function getDishList(id: number) {
  getDishListType({ id }).then((res) => {
    dishList.value = res.data;
  });
}

// 删除套餐菜品
function delDishHandle(index: any) {
  dishTable.value.splice(index, 1);
  checkList.value.splice(index, 1);
}

// 获取添加菜品数据
function getCheckList(value1: any) {
  checkList.value = [...value1.value];
  // console.log(value);
}

function openAddDish() {
  seachKey.value = "";
  dialogVisible.value = true;
  //      $refs.adddish.open()
}
// 取消添加菜品
function handleClose(done: any) {
  //  $refs.adddish.close()
  dialogVisible.value = false;
  //  checkList = JSON.parse(JSON.stringify( dishTable))
  //  dialogVisible = false
}

// 保存添加菜品列表
function addTableList() {
  dishTable.value = JSON.parse(JSON.stringify(checkList.value));
  console.log(dishTable.value);

  dishTable.value.forEach((n: any) => {
    n.copies = 1;
  });
  dialogVisible.value = false;
}

const submitForm = async (formEl: FormInstance | undefined, and: boolean) => {
  if (!formEl) return;
  await formEl.validate((valid, fields) => {
    if (valid) {
      let prams = { ...ruleForm };
      prams.price *= 100;
      prams.dishList = dishTable.value;
      prams.status = ruleForm.status ? 1 : 0;
      if (actionType.value == "add") {
        setMealAdd(prams)
          .then((res) => {
            ElMessage.success("套餐添加成功！");
            if (!and) {
              router.back();
            }
            formEl.resetFields();
            ruleForm.image = "";
            ruleForm.description = "";
            ruleForm.categoryId = "";
            dishTable.value = [];
          })
          .catch((err) => {
            ElMessage.error("请求出错了：" + err);
          });
      } else {
        prams.id = id1;
        setMealUpdate(prams)
          .then((res) => {
            ElMessage.success("套餐修改成功！");
            if (!and) {
              router.back();
            }
          })
          .catch((err) => {
            ElMessage.error("请求出错了：" + err);
          });
      }
    } else {
      console.log("error submit!!");
      return false;
    }
  });
};

function handleAvatarSuccess(response: any, file: any, fileList: any) {
  imageUrl.value = response.data;
  ruleForm.image = response.data;
}

function beforeAvatarUpload(file: any) {
  console.log(file);
}
</script>
<style >
.avatar-uploader .el-icon-plus:after {
  position: absolute;
  display: inline-block;
  content: " " !important;
  left: calc(50% - 20px);
  top: calc(50% - 40px);
  width: 40px;
  height: 40px;
  background: url("@/assets/icons/icon_upload@2x.png") center center no-repeat;
  background-size: 20px;
}
</style>
<style lang="scss" scoped>
.addBrand-container {
  .avatar-uploader .el-upload {
    border: 1px dashed #d9d9d9;
    border-radius: 6px;
    cursor: pointer;
    position: relative;
    overflow: hidden;
  }
  .avatar-uploader .el-upload:hover {
    border-color: #409eff;
  }
  .avatar-uploader-icon {
    font-size: 28px;
    color: #8c939d;
    width: 200px;
    height: 160px;
    line-height: 160px;
    text-align: center;
  }
  .avatar {
    width: 160px;
    height: 160px;
    display: block;
  }
  .el-form--inline .el-form-item__content {
    width: 293px;
  }
  .el-input {
    width: 293px;
  }
  .address {
    .el-form-item__content {
      width: 777px !important;
    }
  }
  .addDish {
    .el-input {
      width: 130px;
    }
    .el-input-number__increase {
      border-left: solid 1px #ffe1ca;
      background: rgba(255, 243, 234, 1);
    }
    .el-input-number__decrease {
      border-right: solid 1px #ffe1ca;
      background: rgba(255, 243, 234, 1);
    }
    input {
      border: 1px solid rgba(255, 225, 202, 1);
    }
    .table {
      width: 750px;
      border: solid 1px #ebeef5;
      border-radius: 3px;
      th {
        padding: 5px 0;
      }
      td {
        padding: 7px 0;
      }
    }
  }
  .addDishList {
    .seachDish {
      position: absolute;
      top: 10px;
      right: 20px;
    }
    .el-dialog__body {
      padding: 0;
      border-bottom: solid 1px #ccc;
    }
  }
}
</style>
<style lang="scss" scoped>
.addBrand {
  &-container {
    margin: 30px;
    .container {
      position: relative;
      z-index: 1;
      background: #fff;
      padding: 30px;
      border-radius: 4px;
      min-height: 500px;
      .subBox {
        padding-top: 30px;
        text-align: center;
        border-top: solid 1pxrgb (216, 215, 213);
      }
      .addDish {
        width: 777px;
        .addBut {
          background: #409eff;
          display: inline-block;
          padding: 0px 15px;
          border-radius: 3px;
          line-height: 30px;
          color: #fff;
          cursor: pointer;
        }
        .content {
          background: #fafafb;
          padding: 20px;
          border: solid 1px #ccc;
          border-radius: 3px;
        }
      }
    }
  }
}
</style>
