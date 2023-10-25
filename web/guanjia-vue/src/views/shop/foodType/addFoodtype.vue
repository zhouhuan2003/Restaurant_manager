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
          <el-form-item label="菜品名称:" prop="name">
            <el-input v-model="ruleForm.name" placeholder="请填写菜品名称" />
          </el-form-item>
          <el-form-item label="菜品分类" prop="cateoryId">
            <el-select
              v-model="ruleForm.categoryId"
              placeholder="请选择菜品分类"
            >
              <el-option
                v-for="item in dishList"
                :label="item.name"
                :value="item.category_id"
                :key="item.category_id"
              />
            </el-select>
          </el-form-item>
        </div>
        <div>
          <el-form-item label="菜品价格:" prop="price">
            <el-input
              v-model.number="ruleForm.price"
              placeholder="请设置菜品价格"
            />
          </el-form-item>
          <el-form-item label="商品码:" prop="code">
            <el-input
              v-model="ruleForm.code"
              placeholder="请输入商品码 如:辣椒炒肉(LJCR)"
            />
          </el-form-item>
        </div>
        <el-form-item label="口味做法配置:">
          <el-form-item>
            <div class="flavorBox">
              <span
                v-if="dishFlavors.length == 0"
                class="addBut"
                @click="addFlavore"
              >
                + 添加口味</span
              >
              <div v-if="dishFlavors.length != 0" class="flavor">
                <div class="title">
                  <span>口味名（3个字内）</span
                  ><span>口味标签（输入标签回车添加）</span>
                </div>
                <div class="cont">
                  <div
                    v-for="(item, index) in dishFlavors"
                    :key="index"
                    class="items"
                  >
                    <div class="itTit">
                      <SelectInput
                        :dishFlavorsData="dishFlavorsData"
                        :index="index"
                        :value1="item.flavor"
                        @select="selectHandle"
                      />
                    </div>
                    <div class="labItems" style="display: flex">
                      <span v-for="(it, ind) in item.flavorData" :key="ind"
                        >{{ it }}
                        <i @click="delFlavorLabel(index, ind)">X</i></span
                      >
                      <div
                        class="inputBox"
                        :style="inputStyle"
                        contenteditable="true"
                        @focus="flavorPosition(index)"
                        @keydown.enter="keyDownHandle"
                      />
                    </div>
                    <span class="delFlavor" @click="delFlavor(index)"
                      >删除</span
                    >
                  </div>
                </div>
                <div class="addBut" @click="addFlavore">添加口味</div>
              </div>
            </div>
          </el-form-item>
        </el-form-item>
        <div>
          <el-form-item label="店内售卖状态:" prop="name">
            <el-switch v-model="ruleForm.status" inactive-color="#ccc" />
          </el-form-item>
        </div>
        <div>
          <el-form-item label="菜品图片" prop="region">
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
        <div class="address">
          <el-form-item label="菜品描述" prop="region">
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
            <el-button @click="toBack"> 取消 </el-button>
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
              @click="submitForm(ruleFormRef,true)"
            >
              保存并继续添加菜品
            </el-button>
          </el-form-item>
        </div>
      </el-form>
    </div>
  </div>
</template>

<script lang="ts" setup>
import {
  getCategroyByType,
  getDishById,
  getDishFlavorList,
  editDish,
  addDish,
} from "@/request/api";
import { ElMessage, FormInstance } from "element-plus";
import { reactive, ref } from "vue";
import { useRouter } from "vue-router";
import SelectInput from "./components/SelectInput.vue";
const router = useRouter();

const ruleFormRef = ref<FormInstance>();

const textarea = ref("");
const value = ref("");
let imageUrl = ref("");
const actionType = ref("");
const dishList = ref([]);
const dishFlavorsData = ref([]);
let dishFlavors = ref([]);
const index = ref(0);
const inputStyle = reactive({ flex: 1 });
let ruleForm = reactive({
  name: "",
  categoryId: "",
  price: 0,
  code: "",
  image: "",
  description: "",
  dishFlavors: [],
  status: true,
});
const dishId=router.currentRoute.value.query.id

const rules = {
  name: [{ required: true, message: "请填写菜品名称", trigger: "blur" }],
  price: [{ required: true, message: "请填写菜品价格", trigger: "blur" }],
  code: [{ required: true, message: "请填写菜品编码", trigger: "blur" }],
};

getDishList();
getFlavorListHand();

actionType.value = router.currentRoute.value.query.id ? "edit" : "add";
if (dishId) {
  init();
}

function selectHandle(val: any, key: any, ind: any) {
//   console.log(val, " ==", key, " ===", ind);

  const arrDate = [...dishFlavors.value];
  arrDate[key.value] = JSON.parse(JSON.stringify(dishFlavorsData.value[ind]));
  dishFlavors.value = arrDate;
}

function init(){
  getDishById(dishId).then((res) => {
    ruleForm.name= res.data.name;
    ruleForm.categoryId= res.data.categoryId;
    ruleForm.code= res.data.code;
    ruleForm.description=res.data.description
    ruleForm.price = res.data.price / 100;
    ruleForm.status = res.data.status == "1";
    dishFlavors.value = res.data.dishFlavors;
    ruleForm.dishFlavors = res.data.dishFlavors;
    imageUrl.value = res.data.image;
    ruleForm.image = res.data.image;
    console.log(ruleForm.name + "==============");
  });
}

// 按钮 - 添加口味
function addFlavore() {
  dishFlavors.value.push({ flavor: "", flavorData: [] }); // JSON.parse(JSON.stringify( dishFlavorsData))
}

// 按钮 - 删除口味
function delFlavor(ind: number) {
  dishFlavors.value.splice(ind, 1);
}

// 按钮 - 删除口味标签
function delFlavorLabel(index: number, ind: number) {
  dishFlavors.value[index].flavorData.splice(ind, 1);
}

//口味位置记录
function flavorPosition(ind: number) {
  index.value = ind;
}

// 添加口味标签
function keyDownHandle(val: any) {
  console.log(val.target.innerText);

  if (event) {
    event.cancelBubble = true;
    event.preventDefault();
    event.stopPropagation();
  }

  if (val.target.innerText.trim() != "") {
    dishFlavors.value[index.value].flavorData.push(val.target.innerText);
    // console.log(dishFlavors.value[index.value].flavorData);
    val.target.innerText = "";
  }
}

// 获取菜品分类
function getDishList() {
  getCategroyByType(1).then((res) => {
    dishList.value = res.data;
  });
}

// 获取口味列表
function getFlavorListHand() {
  getDishFlavorList().then((res) => {
    dishFlavorsData.value = res.data;
  });
}

const submitForm = async (formEl: FormInstance | undefined, and: boolean) => {
  if (!formEl) return;
  await formEl.validate((valid, fields) => {
    if (valid) {
      let params: any = { ...ruleForm };
      params.dishFlavors = dishFlavors.value;
      params.status = ruleForm ? 1 : 0;
      params.price *= 100;
      console.log(params);
      if (actionType.value == "add") {
        addDish(params)
          .then((res) => {
            ElMessage.success("菜品添加成功！");
            if (!and) {
              router.back();
            }
            formEl.resetFields()
            ruleForm.description=""
            ruleForm.categoryId=""
          })
          .catch((err) => {
            ElMessage.error("请求出错了：" + err);
          });
      } else {
        params.id=dishId
        editDish(params)
          .then((res) => {
            if (!and) {
              router.back();
            }
            ElMessage.success("菜品修改成功！");
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
  console.log(ruleForm.image+"image=======");
  
}

function beforeAvatarUpload(file: any) {
  console.log(file);
}

function toBack() {
  router.back();
}
</script>
<style>
.avatar-uploader .el-icon-plus:after {
  position: absolute;
  display: inline-block;
  content: " " !important;
  left: calc(50% - 20px);
  top: calc(50% - 40px);
  width: 40px;
  height: 40px;
  background: url("../../../assets/icons/icon_upload@2x.png") center center
    no-repeat;
  background-size: 20px;
}
</style>
<style lang="scss">
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
        border-top: solid 1px rgb(216, 215, 213);
      }
    }
  }
}

.flavorBox {
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

  .flavor {
    width: 750px;
    border: solid 1px #dfe2e8;
    border-radius: 3px;
    padding: 15px;
    background: #fafafb;

    .title {
      color: #606168;
    }

    .cont {
      .items {
        display: flex;
        margin: 10px 0;

        .itTit {
          width: 150px;
          margin-right: 15px;

          input {
            width: 100%;
            line-height: 40px;
            border-radius: 3px;
            padding: 0 10px;
          }
        }

        .labItems {
          flex: 1;

          display: flex;
          flex-wrap: wrap;
          border-radius: 3px;
          min-height: 39px;
          border: solid 1px #d8dde3;
          background: #fff;
          padding: 0 5px;
          span {
            display: inline-block;
            color: #f19c59;
            margin: 5px;
            line-height: 26px;
            height: 26px;
            padding: 0 10px;
            background: #fdf4eb;
            border-radius: 3px;
            border: solid 1px #fae2cd;

            i {
              cursor: pointer;
              font-style: normal;
            }
          }
          .inputBox {
            display: inline-block;
            width: 100%;
            height: 36px;
            line-height: 36px;
            overflow: hidden;
          }
        }

        .delFlavor {
          display: inline-block;
          padding: 0 10px;
          color: #f19c59;
          cursor: pointer;
        }
      }
    }
  }
}
</style>
