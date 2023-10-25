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
          <el-form-item label="店长姓名:" prop="name">
            <el-input v-model="ruleForm.name" placeholder="请输入店长姓名" />
          </el-form-item>
        </div>
        <div>
          <el-form-item label="店长邮箱:" prop="email">
            <el-input v-model="ruleForm.email" placeholder="请输入邮箱" />
          </el-form-item>
        </div>
        <div>
          <el-form-item label="店长联系方式:" prop="phone">
            <el-input v-model="ruleForm.phone" placeholder="请输入联系方式" />
          </el-form-item>
        </div>
        <div class="checkboxCont">
          <div class="title">负责门店:</div>
          <div class="labCont">
            <span
              :class="{ act: active === '全国' }"
              @click="handleActive('全国')"
              >全国</span
            >
            <span
              v-for="(item, index) in regionData"
              :key="index"
              :class="{ act: active === item }"
              @click="handleActive(item)"
              >{{ item }}</span
            >
          </div>
          <div class="checkCont">
            <el-checkbox-group v-model="checkList">
              <el-checkbox
                v-for="(item, index) in stopList"
                :key="index"
                :disabled="isDisabled(item)"
                :label="item.storeId"
              >
                {{ item.storeName }}
              </el-checkbox>
            </el-checkbox-group>
          </div>
        </div>
        <div class="subBox address">
          <el-form-item>
            <el-button @click="() => $router.push('/shopowner')">
              取消
            </el-button>
            <el-button
              v-if="id == ''"
              style="color:white; background-color: orange"
              @click="submitForm(ruleFormRef)"
            >
              保存
            </el-button>
            <el-button
              v-else
              style="color:white; background-color: orange"
              @click="editStroreManager(ruleFormRef)"
            >
              修改
            </el-button>
            <el-button
              v-show="id == ''"
              type="primary"
              class="continue"
              @click="submitForm(ruleFormRef, true)"
            >
              保存并继续添加
            </el-button>
          </el-form-item>
        </div>
      </el-form>
    </div>
  </div>
</template>

<script lang="ts" setup>
import {
  getStoreListProvince,
  getStoreListByProvince,
  addStoreManager,
  getStoreManagerByid,
  updateStroreManager,
} from "@/request/api";
// import router from "@/router";
import { ElMessage, FormInstance } from "element-plus";
import { el } from "element-plus/es/locale";
import { onBeforeMount, onMounted, reactive, ref } from "vue";
import { useRouter } from "vue-router";
const router = useRouter();

const regionData = ref([]);
const stopList = ref([]);
const ruleForm = reactive({
  name: "",
  email: "",
  phone: "",
  storeIds: [],
});
const checkList = ref([]);
const active = ref("全国");
const id =
  router.currentRoute.value.query.id == undefined
    ? ""
    : router.currentRoute.value.query.id;

if (id != undefined) {
  console.log(id);
  getStoreManagerByid(id).then((res) => {
    console.log(res);
    ruleForm.name = res.data.storeManagerName;
    ruleForm.email = res.data.storeManagerEmail;
    ruleForm.phone = res.data.storeManagerPhone;
    res.data.stores.forEach((item) => {
      ruleForm.storeIds.push(item.storeId);
    });
    checkList.value = ruleForm.storeIds;
  });
}

//获取门店省份信息
getStoreListProvince()
  .then((res) => {
    if (res.code == 200) {
      regionData.value = res.data;
    }
  })
  .catch((error) => {
    console.log(error);
  });

getStoreListByProvince("all").then((res) => {
  stopList.value = res.data;
});

// 根据区域获取门店列表
function getRegionStop(region: any) {
  // let params = region == '全国' ? 'all': region;
  getStoreListByProvince(region.value == "全国" ? "all" : region.value).then(
    (res) => {
      stopList.value = res.data;
    }
  );
}

// 是否已被勾选
function isDisabled(item: { storeManagerId: any; storeId: any }) {
  let disable = false;
  if (item.storeManagerId && ruleForm.storeIds.indexOf(item.storeId) == -1) {
    disable = true;
  }
  // console.log(88,item , ruleForm.storeIds);

  return disable;
}

//修改
const editStroreManager = async (formEl: FormInstance | undefined) => {
  if (!formEl) return;
  await formEl.validate((valid, fields) => {
    if (valid) {
      let data = {
        ...ruleForm,
        storeIds: checkList.value,
        storeManagerId: id,
      };
      updateStroreManager(data).then((res) => {
        if (res.code == 200) {
          ElMessage.success("修改成功!");
          router.back();
          formEl.resetFields();
        } else {
          ElMessage.error("修改失败!");
        }
      });
    } else {
      console.log("error submit!", fields);
    }
  });
};

//添加
const ruleFormRef = ref<FormInstance>();
const submitForm = async (formEl: FormInstance | undefined, and: boolean) => {
  if (!formEl) return;
  await formEl.validate((valid, fields) => {
    if (valid) {
      let data = {
        ...ruleForm,
        storeIds: checkList.value,
      };
      addStoreManager(data).then((res) => {
        if (res.code == 200) {
          if (!and) {
            ElMessage.success("添加成功!");
            router.back();
            formEl.resetFields();
          } else {
            ElMessage.success("添加成功,继续添加!");
            formEl.resetFields();
            getRegionStop(active);
          }
        } else {
          ElMessage.error("添加失败!");
        }
      });
    } else {
      console.log("error submit!", fields);
    }
  });
};

function handleActive(state: any) {
  active.value = state;
  getRegionStop(active);
}

const rules = {
  name: [{ required: true, message: "请输入店长姓名", trigger: "blur" }],
  email: [{ required: true, message: "请输入店长邮箱", trigger: "blur" }],
  phone: [{ required: true, message: "请输入店长联系方式", trigger: "blur" }],
};
</script>
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
  .el-select > .el-input {
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
      .checkboxCont {
        margin-bottom: 30px;
        .title {
          width: 180px;
          text-align: right;
          font-size: 14px;
          padding-right: 12px;
          // color: red;
        }
        .labCont {
          color: rgb(139, 137, 134);
          margin: 20px 0;
          margin-left: 99px;
          span {
            font-size: 12px;
            cursor: pointer;
            display: inline-block;
            padding: 4px 10px;
            margin: 10px;
            border: solid 1px rgb(139, 137, 134);
            border-radius: 3px;
          }
          .act {
            color: orange;
            border-color: orange;
          }
        }
        .checkCont {
          margin-left: 108px;
        }
      }
      .subBox {
        padding-top: 30px;
        text-align: center;
        border-top: solid 1px rgb(243, 244, 247);
      }
    }
  }
}
</style>
