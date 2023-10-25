<template>
	<view class="cart">
		<slot></slot>
	</view>
</template>

<script>
	export default {
		name:"cart",
		data() {
			return {
				
			};
		}
	}
</script>

<style lang="scss">
	.cart{
		 position: fixed;
		 bottom: 30px;
		 margin-left:15px;
		 width: 100%;
		 z-index: 999;
	}
</style>