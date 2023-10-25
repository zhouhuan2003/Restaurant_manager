<template>
  <div class="addBrand-container">
    <div class="container">
      <el-form
        ref="ruleFormRef"
        :model="ruleForm"
        :inline="true"
        label-width="180px"
        class="demo-ruleForm"
      >
        <!--        <div>-->
        <!--          <el-form-item label="结算模式:" prop="name">-->
        <!--            <el-radio-group v-model="ruleForm.resource">-->
        <!--              <el-radio label="先就餐后结账"></el-radio>-->
        <!--              <el-radio label="先结账后就餐"></el-radio>-->
        <!--            </el-radio-group>-->
        <!--          </el-form-item>-->
        <!--          <el-form-item label="结账后自动清台:" prop="name">-->
        <!--            <el-radio-group v-model="ruleForm.resource">-->
        <!--              <el-radio label="是"></el-radio>-->
        <!--              <el-radio label="否"></el-radio>-->
        <!--            </el-radio-group>-->
        <!--          </el-form-item>-->
        <!--        </div>-->
        <!--        <div>-->
        <!--          <el-form-item label="结算时间:" prop="time">-->
        <!--            <el-time-select v-model="ruleForm.time" size="mini" style="width: 120px" :picker-options="{start: '08:30', step: '00:15', end: '18:30'}" placeholder="选择时间" />-->
        <!--          </el-form-item>-->
        <!--          <el-form-item label="零头处理:" prop="name">-->
        <!--          <el-radio-group v-model="ruleForm.resource">-->
        <!--            <el-radio label="不处理"></el-radio>-->
        <!--            <el-radio label="抹零"></el-radio>-->
        <!--          </el-radio-group>-->
        <!--        </el-form-item>-->
        <!--        </div>-->
        <div class="describeBox">
          <el-form-item label="备注:">
            <div class="describe">
              <div class="lab">
                <span
                  v-for="(item, index) in remarks"
                  :key="index"
                  :class="{act:index == mak}"
                  @click="actionHandle(index)"
                >{{ item.remarkName }}</span>
              </div>
              <div class="desBox">
                <div class="labCont">
                  <span
                    v-for="(item, index) in remarks[mak].remarkValue"
                    :key="index"
                  > {{ item }} <i @click="desLable(index)">X</i></span>
                </div>
                <div class="inputBox">
                  <el-input
                    v-model="desValue"
                    class="inputBut"
                    width="100%"
                    placeholder="请输入备注内容，不超过20字"
                  />
                  <div>
                    <span
                      style="cursor: pointer;background-color:#419EFF"
                      class="continue"
                      @click="addDesLable"
                    >添加备注</span>
                  </div>
                </div>
              </div>
            </div>
          </el-form-item>
        </div>
        <div class="subBox address">
          <el-form-item>
            <el-button
              style="color:white;background-color:orange"
              @click="submitForm(ruleFormRef)"
            >
              保存
            </el-button>
          </el-form-item>
        </div>
      </el-form>
    </div>
  </div>
</template>

<script lang="ts" setup>
import { reactive, ref } from "vue";
import { settingPageList,editSetting} from "@/request/api"
import { ElMessage,FormInstance } from "element-plus"
import { useRouter } from "vue-router"
const ruleFormRef = ref<FormInstance>();
const router =useRouter()


    const mak = ref(0)
    const desValue = ref('')
    let ruleForm = reactive({
        // time: '8:00',
        'remarks': [{
            'remarkName': '退菜原因',
            'remarkValue': ['太难吃']
        }]
    })
    let remarks=ref([
        {
             'remarkName': '退菜原因',
            'remarkValue': ['太难吃']
        }
    ])

    // get rules() {
    //     return {
    //         time: [
    //             { required: true, message: '请选择结算时间！', trigger: 'blur' }
    //         ]
    //     }
    // }


         init();


    function init(){
        settingPageList().then( (res:any) => {
    
             remarks.value = res.data.remarks;
             console.log(remarks);
             
        }).catch( (err:any) => {
             ElMessage.error('获取初始化门店信息失败：' + err);
        });
    }
    // 点击标签
    function actionHandle(ind:number){
         mak.value = ind;
    }

    // 添加备注标签
    function addDesLable(){
        if ( desValue.value) {
             remarks.value[mak.value].remarkValue.push( desValue.value);
             desValue.value = '';
        }
    }

    //删除标签
    function desLable(ind:number){
         remarks.value[mak.value].remarkValue.splice(ind, 1);
         console.log(ruleForm);
         
    }
const submitForm = async (formEl: FormInstance | undefined) => {
  if (!formEl) return;
  await formEl.validate((valid, fields) => {
            if (valid) {
                editSetting( {'remarks':remarks.value}).then(res => {
                     ElMessage.success('门店设置成功！');
                }).catch(err => {
                     ElMessage.error('请求出错了：' + err);
                });
            } else {
                console.log('error submit!!');
                return false;
            }
        });
    }

</script>
<style lang="scss">
  .addBrand-container{
    .avatar-uploader .el-upload {
      border: 1px dashed #d9d9d9;
      border-radius: 6px;
      cursor: pointer;
      position: relative;
      overflow: hidden;
    }
    .avatar-uploader .el-upload:hover {
      border-color: #409EFF;
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
    .el-form--inline .el-form-item__content{
      width: 293px;
    }
    .el-input{
      width: 293px;
    }
    .address {
      .el-form-item__content{
        width: 777px !important;
      }
    }
    .describeBox{
      .el-form-item__content{
        width: 777px !important;
      }
    }
    .inputBut{
      .el-input__inner{
        border:none !important;
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
        .subBox{
          padding-top: 30px;
          text-align: center;
          border-top: solid 1px rgb(216, 215, 213);
        }
        .describe{
          display: flex;
          position: relative;
          width: 100%;
          padding-top: 50px;
          .lab{
            width: 120px;
            min-height: 250px;
            span{
              display: inline-block;
              cursor: pointer;
              width: 92px;
              border-right: solid 2px rgb(216, 215, 213);
              padding-right: 10px;
            }
            .act{
              color: orange;
            border-right: solid 2px orange;
              }
            }
            .desBox{
              flex: 1;
              position: relative;
              background: #FAFAFB;
              border: solid 2px rgb(216, 215, 213);
              border-radius: 4px;
              .labCont{
                span{
                display: inline-block;
                color:orange;
                margin: 5px;
                line-height: 30px;
                height: 30px;
                padding: 0 10px;
                background: #fdf4eb;
                border-radius: 3px;
                border: solid 1px #fae2cd;
                i{
                  cursor: pointer;
                  font-style: normal;
                }
              }
            }
            .inputBox{
              position: absolute;
              display: flex;
              background: #fff;
              width: 97%;
              bottom: 0;
              padding-right: 20px;
              border-top: solid 2px rgb(216, 215, 213);
              span{
                padding: 5px 15px;
                color: #fff;
                border-radius: 3px;
                font-size: 12px;
              }
            }
            .inputBut{
              flex: 1;
              color: #fff;
              padding-right:20px;
            }
          }
        }
      }
    }
  }
</style>
