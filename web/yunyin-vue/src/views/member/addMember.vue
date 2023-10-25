<template>
  <div class="addBrand-container">
    <div class="container">
      <el-form
        :model="ruleForm"
        :rules="rules"
        ref="ruleFormRef"
        :inline="false"
        label-width="180px"
        class="demo-ruleForm"
      >
        <el-form-item label="企业名称:" prop="enterpriseName">
          <el-input
            v-model="ruleForm.enterpriseName"
            placeholder="请输入企业名称"
          ></el-input>
        </el-form-item>
        <el-form-item label="申请人:" prop="applicant">
          <el-input
            v-model="ruleForm.applicant"
            placeholder="请输入申请人"
          ></el-input>
        </el-form-item>
        <el-form-item label="邮箱:" prop="email">
          <el-input
            v-model="ruleForm.email"
            placeholder="请输入邮箱(请输入正确的邮箱)"
          ></el-input>
        </el-form-item>
        <el-form-item label="手机号:" prop="phone">
          <el-input
            v-model="ruleForm.phone"
            placeholder="请输入手机号"
          ></el-input>
        </el-form-item>
        <el-form-item label="地区:" prop="province">
          <el-cascader
            placeholder="请选择地区"
            v-model="value"
            :options="regionData"
            :props="props"
            @change="handleChange"
          />
        </el-form-item>
        <el-form-item label="详细地址:" prop="address">
          <el-input
            type="textarea"
            style="width: 294px"
            v-model="ruleForm.address"
            placeholder="请输入详细地址"
          ></el-input>
        </el-form-item>
        <el-form-item label="账号状态" prop="status">
          <el-select v-model="ruleForm.status" placeholder="请选择账号状态">
            <el-option label="试用" value="0"> </el-option>
            <el-option label="正常" value="1"> </el-option>
            <el-option v-if="ruleForm.status == -1" label="已禁用" value="-1">
            </el-option>
          </el-select>
        </el-form-item>
        <el-form-item
          v-if="ruleForm.status == 1"
          label="使用期限"
          prop="validityDay"
        >
          <el-select
            v-model="ruleForm.validityDay"
            placeholder="请选择使用期限"
          >
            <el-option label="7天" value="7"> </el-option>
            <el-option label="一个月" value="30"> </el-option>
            <el-option label="三个月" value="90"> </el-option>
            <el-option label="一年" value="365"> </el-option>
            <el-option label="两年" value="730"> </el-option>
            <el-option label="三年" value="1095"> </el-option>
            <el-option label="四年" value="1460"> </el-option>
            <el-option label="五年" value="1825"> </el-option>
            <el-option label="不限" value="9999999"> </el-option>
          </el-select>
        </el-form-item>
        <div class="subBox address">
          <el-form-item>
            <el-button @click="router.back()">取消</el-button>
            <el-button type="primary" @click="submitForm(ruleFormRef)"
              >保存</el-button
            >
            <el-button
              type="primary"
              v-if="actionType == 'add'"
              @click="submitForm(ruleFormRef, 'go')"
              class="continue"
              >保存并继续添加</el-button
            >
          </el-form-item>
        </div>
      </el-form>
    </div>
  </div>
</template>

<script lang="ts" setup>
import { reactive, ref } from "vue";
import { ElMessage, FormInstance } from "element-plus";
import { getMemberDetile, addMember, editMember } from "@/request/api";
import { useRouter } from "vue-router";
import { regionData, CodeToText, TextToCode } from "element-china-area-data";
const router = useRouter();
const value = ref([]);
const props = {
  expandTrigger: "hover" as const,
};
const ruleFormRef = ref<FormInstance>();
const id =
  router.currentRoute.value.query.id == undefined
    ? ""
    : router.currentRoute.value.query.id;

const actionType = ref("");
// const pca = pca
let ruleForm = reactive({
  enterpriseName: "",
  applicant: "",
  selected: [],
  email: "",
  phone: "",
  province: "",
  city: "",
  area: "",
  address: "",
  status: "",
  validityDay: "",
});

const rules = {
  enterpriseName: [
    { required: true, message: "请输入企业名称", trigger: "blur" },
  ],
  applicant: [{ required: true, message: "请输入申请人", trigger: "blur" }],
  email: [{ required: true, message: "请输入邮箱", trigger: "blur" }],
  phone: [{ required: true, message: "请输入手机号", trigger: "blur" }],
  province: [{ required: true, message: "请选择地区", trigger: "blur" }],
  address: [{ required: true, message: "请输入详细地址", trigger: "blur" }],
  status: [{ required: true, message: "请选择账号状态", trigger: "change" }],
  validityDay: [
    { required: true, message: "请选择使用期限", trigger: "change" },
  ],
};

actionType.value = id ? "edit" : "add";
if (id) {
  init();
}

function init() {
  console.log(id, "==========");

  getMemberDetile(id).then((res) => {
    ruleForm.enterpriseName = res.data.enterpriseName;
    ruleForm.applicant = res.data.applicant;
    ruleForm.province = res.data.province;
    ruleForm.email = res.data.email;
    ruleForm.phone = res.data.phone;
    ruleForm.city = res.data.city;
    ruleForm.area = res.data.area;
    ruleForm.address = res.data.address;
    ruleForm.status = String(res.data.status);
    ruleForm.validityDay = String(res.data.validityDay);
    value.value.push(TextToCode[res.data.province]);
    value.value.push(TextToCode[res.data.province][res.data.city].code);
    value.value.push(
      TextToCode[res.data.province][res.data.city][res.data.area].code
    );
  });
}

const submitForm = async (formEl: FormInstance | undefined, and: boolean) => {
  if (!formEl) return;
  await formEl.validate((valid, fields) => {
    if (valid) {
      let params = {... ruleForm}
      if ( actionType.value == 'add') {
          addMember(params).then(res => {
               ElMessage.success('员工添加成功！')
              if (!and) {
                   router.back()
              }
              formEl.resetFields()
              value.value=''
          }).catch(err => {
               ElMessage.error('请求出错了：' + err)
          })
      } else {
          params.enterpriseId=id
          editMember(params).then(res => {
               ElMessage.success('员工信息修改成功！')
               router.back()
          }).catch(err => {
               ElMessage.error('请求出错了：' + err)
          })
      }
    } else {
      console.log("error submit!!");
      return false;
    }
  });
};

const handleChange = (value: any) => {
  ruleForm.province = CodeToText[value[0]];
  ruleForm.city = CodeToText[value[1]];
  ruleForm.area = CodeToText[value[2]];
  ruleForm.selected.push(CodeToText[value[0]]);
  ruleForm.selected.push(CodeToText[value[1]]);
  ruleForm.selected.push(CodeToText[value[2]]);
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
  .area-select {
    height: 40px;
  }
  .large {
    width: 294px !important;
  }
  .area-select .area-selected-trigger {
    padding-top: 0px;
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
</style>
