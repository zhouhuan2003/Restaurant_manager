<template>
  <e-charts class="chart" :option="option" />
</template>

<script lang="ts" setup>
import * as echarts from "echarts";
import { computed, ref, defineProps, toRefs } from "vue";

const props = defineProps({
  chartData: String,
  title: String,
});

const { chartData, title } = toRefs(props);

const option = computed(() => {
  return {
    title: {
      text: title?.value,
      left: "left",
    },
    tooltip: {
      trigger: "item",
      formatter: "{a} <br/>{b} : {c} ({d}%)",
    },
    legend: {
      type: "scroll",
      orient: "vertical",
      left: 0,
      top: 50,
      bottom: 20,
      // data: chartData?.value,
      // selected: data.selected,
    },
    series: [
      {
        name: "占比",
        type: "pie",
        radius: "65%",
        left: 80,
        center: ["40%", "50%"],
        data: chartData?.value,
        emphasis: {
          itemStyle: {
            shadowBlur: 10,
            shadowOffsetX: 0,
            shadowColor: "rgba(0, 0, 0, 0.5)",
          },
        },
        itemStyle: {
          normal: {
            color: function (params) {
              var colorList = [
                "#389BFF",
                "#FF903D",
                "#FFFF00",
                "#FF8C00",
                "#FF0000",
                "#FE8463",
              ];
              return colorList[params.dataIndex];
            },
          },
        },
      },
    ],
  };
});
</script>

<style scoped>
.chart {
  height: 250px;
  width: 100%;
}
</style>
