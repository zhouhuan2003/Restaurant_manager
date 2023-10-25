<template>
  <div class="selectInput">
    <el-input
      v-model="keyValue"
      type="text"
      style="width: 100%;height:40px"
      placeholder="请输入口味"
      @focus="selectFlavor(true)"
      @blur="outSelect(false)"
      @input="inputHandle"
    />
    <div
      v-if="mak"
      class="flavorSelect"
    >
      <span
        v-for="(it, ind) in dishFlavorsData"
        :key="ind"
        class="items"
        @click="select(it,ind)"
      >{{ it.flavor }}</span>
      <span
        v-if="dishFlavorsData == []"
        class="none"
      >无数据</span>
    </div>
  </div>
</template>

<script lang="ts" setup>
import { ref,toRefs,defineEmits } from "vue";
      const props= defineProps({
        dishFlavorsData:Array,
        index:Number,
        value1:String
      })


const emit = defineEmits(['select'])


      const keyValue=ref('')
    

      const {dishFlavorsData,index,value1} = toRefs(props)

      // console.log(keyValue+"=========");

        const mak = ref(false)
        // const value: string = ''

        
             keyValue.value =  value1.value;
            // console.log(7878, dishFlavorsData?.value,  index?.value);
        

        function selectFlavor(st:boolean){
             mak.value = st;
        }

        function outSelect(st:boolean){
            
            setTimeout(function () {
                mak.value = st;
            }, 200);
        }

        function inputHandle(val:any){
             selectFlavor(false);
        }

        function select(val: any, ind: any){
             emit('select', val.flavor,  index, ind);
             keyValue.value = val.flavor;
        }

</script>

<style lang="scss" scoped>
  .selectInput{
    position: relative;
    width: 100%;
    min-width: 100px;
    .flavorSelect{
      position: absolute;
      width: 100%;
      padding: 0 10px;
      border-radius: 3px;
      border: solid 1px orange;
      line-height: 30px;
      text-align: center;
      background: #fff;
      top:50px;
      z-index: 99;
      .items{
        cursor: pointer;
        display: inline-block;
        width: 100%;
        line-height: 35px;
        border-bottom:solid 1px #f4f4f4;
        color:#666;
      }
      .none{
         font-size: 14px;

      }
    }
  }
</style>
