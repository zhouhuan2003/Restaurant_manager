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
          <el-form-item label="品牌名称:" prop="brandName">
            <el-input
              v-model="ruleForm.brandName"
              placeholder="请输入品牌名称"
            />
          </el-form-item>
          <el-form-item label="负责人:" prop="contact">
            <el-input v-model="ruleForm.contact" placeholder="请输入负责人" />
          </el-form-item>
        </div>
        <div>
          <el-form-item label="所属业态" prop="category">
            <el-select v-model="ruleForm.category" placeholder="请选择活动区域">
              <el-option label="甜点饮品" value="甜点饮品" />
              <el-option label="小吃/快餐" value="小吃/快餐" />
              <el-option label="中餐" value="中餐" />
              <el-option label="粥/粉/面" value="粥/粉/面" />
              <el-option label="火锅" value="火锅" />
              <el-option label="西餐" value="西餐" />
              <el-option label="烧烤/烤肉" value="烧烤/烤肉" />
              <el-option label="咖啡/酒吧" value="咖啡/酒吧" />
              <el-option label="美食广场（档口）" value="美食广场（档口）" />
              <el-option label="日韩料理" value="日韩料理" />
              <el-option label="便利店/零售店" value="便利店/零售店" />
              <el-option label="麻辣烫" value="麻辣烫" />
              <el-option label="香锅/烤鱼" value="香锅/烤鱼" />
              <el-option label="生鲜蔬菜" value="生鲜蔬菜" />
              <el-option label="海鲜" value="海鲜" />
              <el-option label="串串香" value="串串香" />
              <el-option label="饺子馆" value="饺子馆" />
              <el-option label="自助餐" value="自助餐" />
              <el-option label="其他" value="其他" />
            </el-select>
          </el-form-item>
          <el-form-item label="联系方式:" prop="contactPhone">
            <el-input
              v-model="ruleForm.contactPhone"
              placeholder="请输入联系方式"
            />
          </el-form-item>
        </div>
        <div>
          <el-form-item label="品牌log:" prop="name">
            <el-upload
              class="avatar-uploader"
              action="http://192.168.0.105:8081/fileUpload"
              :data="imgData"
              :show-file-list="false"
              :on-success="handleAvatarSuccess"
              :before-upload="beforeAvatarUpload"
            >
              <img v-if="imageUrl" :src="imageUrl" class="avatar" />
              <i v-else class="el-icon-plus avatar-uploader-icon" />
            </el-upload>
          </el-form-item>
        </div>
        <div class="subBox">
          <el-form-item>
            <el-button @click="cancel()"> 取消 </el-button>
            <el-button type="primary" @click="submitForm(ruleFormRef)">
              保存
            </el-button>
          </el-form-item>
        </div>
      </el-form>
    </div>
  </div>
</template>

<script lang="ts">
import { defineComponent, reactive, toRefs, ref } from "vue";
import { ElMessage } from "element-plus";
import type { FormInstance, FormRules } from "element-plus";
import { Plus } from "@element-plus/icons-vue";
import type { UploadProps } from "element-plus";
import { addBarnd } from "@/request/api";
import { useRouter } from "vue-router";

export default defineComponent({
  setup() {
    const data = reactive({
      ruleForm: {
        brandName: "",
        category: "",
        contact: "",
        contactPhone: "",
        logo: "",
      },
      imgData: { fileName: "img.png" },
    });
    const imageUrl = ref("");
    const rules = {
      brandName: [
        { required: true, message: "请输入品牌名称", trigger: "blur" },
      ],
      contact: [{ required: true, message: "请输入负责人", trigger: "blur" }],
      category: [
        { required: true, message: "请选择所属业态", trigger: "change" },
      ],
      contactPhone: [
        { required: true, message: "请输入联系方式", trigger: "blur" },
      ],
    };

    const router=useRouter()
    
    //添加
    const ruleFormRef = ref<FormInstance>();
    const submitForm = async (formEl: FormInstance | undefined) => {
      if (!formEl) return;
      await formEl.validate((valid, fields) => {
        if (valid) {
          console.log(data.ruleForm);
          addBarnd(data.ruleForm).then(res =>{
            console.log(res);
            if(res.code==200){
                ElMessage.success("添加成功!")
                router.back()
            }
          })
        } else {
          console.log("error submit!", fields);
        }
      });
    };

    //取消
    function cancel(){
        router.back()
    }

    const handleAvatarSuccess: UploadProps["onSuccess"] = (
      response,
      uploadFile
    ) => {
        console.log(response);
        data.ruleForm.logo=response.data
      imageUrl.value = URL.createObjectURL(uploadFile.raw!);
    };

    const beforeAvatarUpload: UploadProps["beforeUpload"] = (rawFile) => {
      if (rawFile.type !== "image/jpeg") {
        ElMessage.error("Avatar picture must be JPG format!");
        return false;
      } else if (rawFile.size / 1024 / 1024 > 2) {
        ElMessage.error("Avatar picture size can not exceed 2MB!");
        return false;
      }
      return true;
    };

    return {
      ...toRefs(data),
      rules,
      imageUrl,
      handleAvatarSuccess,
      beforeAvatarUpload,
      ruleFormRef,
      submitForm,
      router,
      cancel
    };
  },
});
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
  .el-select > .el-input {
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
        border-top: solid 1px rgb(243, 244, 247);
      }
    }
  }
}
</style>
