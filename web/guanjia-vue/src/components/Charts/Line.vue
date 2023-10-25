<template>
  <e-charts class="chart" :option="option" />
</template>

<script lang="ts" setup>

import { ref } from "vue";
const option = ref({
  xAxis: {
    type: "category",
    data: ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"],
  },
  yAxis: {
    type: "value",
  },
  series: [
    {
      data: [120, 200, 150, 80, 70, 110, 130],
      type: "bar",
    },
  ],
});
</script>

<style scoped>
    .chart{
        height: 250px;
     width: 100%;
    }
</style>
