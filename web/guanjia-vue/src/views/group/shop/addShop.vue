<template>
  <div class="addBrand-container">
    <!-- <HeadLable :title="'添加门店'" :goback="true" /> -->
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
          <el-form-item label="门店名称:" prop="storeName">
            <el-input
              v-model="ruleForm.storeName"
              placeholder="请输入门店名称"
            />
          </el-form-item>
          <el-form-item label="所属品牌:" prop="brandId">
            <el-select v-model="ruleForm.brandId" placeholder="请选择品牌名称">
              <el-option
                v-for="item in brandList"
                :label="item.brand_name"
                :value="item.brand_id"
                :key="item.brand_id"
              />
            </el-select>
          </el-form-item>
        </div>
        <div>
          <el-form-item label="地区:" prop="selected">
            <el-cascader
              placeholder="请选择地区"
              v-model="value"
              :options="regionData"
              :props="props"
              @change="handleChange"
            />
          </el-form-item>
        </div>
        <div class="address">
          <el-form-item label="详细地址:" prop="address">
            <el-input
              v-model="ruleForm.address"
              type="textarea"
              :rows="3"
              placeholder="建议您如实填写详细地址，例如街道名称，门牌号，楼层和房间号码等"
            />
          </el-form-item>
        </div>
        <div>
          <el-form-item label="门店联系人:" prop="contact">
            <el-input
              v-model="ruleForm.contact"
              placeholder="请输入门店联系人姓名"
            />
          </el-form-item>
        </div>
        <div>
          <el-form-item label="门店电话:" prop="contactPhone">
            <el-input
              v-model="ruleForm.contactPhone"
              placeholder="请输入门店电话"
            />
          </el-form-item>
        </div>
        <div class="subBox address">
          <el-form-item>
            <el-button @click="() => $router.push('/shop')"> 取消 </el-button>
            <el-button
              style="color:white; background-color: orange"
              @click="submitForm(ruleFormRef)"
            >
              保存
            </el-button>
            <el-button
              v-show="id == ''"
              type="primary"
              class="continue"
              @click="submitForm(ruleFormRef, 'and')"
            >
              保存并继续添加
            </el-button>
          </el-form-item>
        </div>
      </el-form>
    </div>
  </div>
</template>

<script setup lang="ts">
import { addStore, getBarnd, getShopDetails } from "@/request/api";
import { reactive, ref } from "vue";
import { ElMessage, FormInstance } from "element-plus";
import { useRouter } from "vue-router";
import { regionData, CodeToText, TextToCode } from "element-china-area-data";
const router = useRouter();
const id =
  router.currentRoute.value.query.id == undefined
    ? ""
    : router.currentRoute.value.query.id;
const props = {
  expandTrigger: "hover" as const,
};
const value = ref([]);

let ruleForm = reactive({
  storeName: "",
  address: "",
  selected: {
    province: "",
    city: "",
    area: "",
  },
  brandId: "",
  contact: "",
  contactPhone: "",
});

const brandList = ref([]);

//编辑过来的根据id查询
if (id != "") {
  getShopDetails(id).then((res) => {
    ruleForm.storeName = res.data.storeName;
    ruleForm.address = res.data.address;
    ruleForm.contact = res.data.contact;
    ruleForm.contactPhone = res.data.contactPhone;
    ruleForm.brandId = res.data.brand.brandId;
    ruleForm.selected.province = res.data.province;
    ruleForm.selected.city = res.data.city;
    ruleForm.selected.area = res.data.area;
    value.value.push(TextToCode[res.data.province].code);
    value.value.push(TextToCode[res.data.province][res.data.city].code);
    value.value.push(
      TextToCode[res.data.province][res.data.city][res.data.area].code
    );
  });
}

getBarnd().then((res) => {
  // console.log(res);
  if (res.code == 200) {
    brandList.value = res.data;
  }
});

const handleChange = (value: any) => {
  ruleForm.selected.province = CodeToText[value[0]];
  ruleForm.selected.city = CodeToText[value[1]];
  ruleForm.selected.area = CodeToText[value[2]];
};

//添加
const ruleFormRef = ref<FormInstance>();
const submitForm = async (formEl: FormInstance | undefined, and: String) => {
  if (!formEl) return;
  await formEl.validate((valid, fields) => {
    if (valid) {
      const data = { ...ruleForm };
      data.province = ruleForm.selected.province;
      data.city = ruleForm.selected.city;
      data.area = ruleForm.selected.area;
      data.storeId = id;
      //   console.log(data);
      addStore(data)
        .then((res) => {
          if (res.code == 200) {
            if (and != "and") {
              if (id != "") {
                ElMessage.success("修改成功!");
              } else {
                ElMessage.success("添加成功!");
              }
              formEl.resetFields();
              value.value = [];
              router.back();
            } else {
              ElMessage.success("添加成功,继续添加");
              value.value = [];
              formEl.resetFields();
            }
          }
        })
        .catch((error) => {
          console.log(error);
          ElMessage.error("添加失败");
        });
    } else {
      console.log("error submit!", fields);
    }
  });
};

const rules = {
  storeName: [{ required: true, message: "请输入门店名称", trigger: "blur" }],
  brandId: [{ required: true, message: "请选择品牌", trigger: "blur" }],
  selected: [{ required: true, message: "请输入地区", trigger: "blur" }],
  address: [{ required: true, message: "请输入详细地址", trigger: "blur" }],
  contact: [{ required: true, message: "请输入门店联系人", trigger: "blur" }],
  contactPhone: [
    { required: true, message: "请输入门店电话", trigger: "blur" },
    // { type: "number", message: "电话号必须为数字" },
  ],
};
</script>

<style lang="scss">
.addBrand-container {
  .area-select.large {
    width: 292px;
    height: 40px;
  }

  .area-select .area-selected-trigger {
    padding-top: 0px;
  }

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

      .subBox {
        padding-top: 30px;
        text-align: center;
        border-top: solid 1px rgb(243, 244, 247);
      }
    }
  }
}
</style>