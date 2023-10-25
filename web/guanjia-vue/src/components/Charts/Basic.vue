<template>
  <e-charts class="chart" :option="option" />
</template>

<script lang="ts" setup>
import { computed, ref, defineProps, toRefs } from "vue";
import * as echarts from 'echarts';

const props = defineProps({
  chartData: String,
  title:String
});

const { chartData,title } = toRefs(props);

console.log("chartData==============", chartData);

const option = computed(() => {
  return {
    backgroundColor: "#fff",
    title: {
      text: title?.value,
      top: "0",
      textStyle: {
        color: "#000",
        fontSize: 18,
      },
      subtextStyle: {
        color: "#90979c",
        fontSize: 16,
      },
    },
    tooltip: {
      trigger: "axis",
    },
    grid: {
      left: "50",
      right: "5%",
      borderWidth: 0,
      top: 60,
      bottom: 25,
      textStyle: {
        color: "#fff",
      },
    },
    xAxis: [
      {
        type: "category",
        axisLine: {
          lineStyle: {
            color: "ornage",
          },
        },
        splitLine: {
          show: false,
        },
        axisTick: {
          show: true,
        },
        splitArea: {
          show: false,
        },
        axisLabel: {
          interval: 0,
        },
        data: chartData?.value.xaxis,
      },
    ],
    yAxis: [
      {
        type: "value",
        splitLine: {
          show: false,
        },
        axisLine: {
          lineStyle: {
            color: "#90979c",
          },
        },
        axisTick: {
          show: false,
        },
        axisLabel: {
          interval: 0,
        },
        splitArea: {
          show: false,
        },
      },
    ],
    series: [
      {
        name: "店内",
        type: "bar",
        stack: "total",
        barMaxWidth: 15,
        barGap: "10%",
        itemStyle: {
          normal: {
            barBorderRadius: [10, 10, 0, 0],
            color: new echarts.graphic.LinearGradient(0, 0, 0, 1, [
              { offset: 0, color: "#FFA868" },
              { offset: 1, color: "#FF9240" },
            ]),
          },
          label: {
            show: true,
            textStyle: {
              color: "#fff",
            },
            position: "insideTop",
            formatter(p: any) {
              return p.value > 0 ? p.value : "";
            },
          },
        },
        data: chartData?.value.series,
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
