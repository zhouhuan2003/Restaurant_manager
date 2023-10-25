<template>
	<view class="card">
		<!-- <slot/> -->
		<view class="card-item">
			<view style="margin-top: 10px;margin-left: 10px;"><text>{{shopName}}</text></view>
			<view style="margin-top: 10px;margin-left: 10px;"><text style="color:#999">{{tableName}}</text></view>
			<view style="position: absolute;top: 10px;right: 20px;">
				<image style="height: 50px;width: 50px;" :src="avatarUrl"></image>
				<view style="text-align: center;">{{nickName}}</view>
			</view>
		</view>
	</view>
</template>

<script>
	export default {
		name:"card",
		data() {
			return {
				
			};
		},
		props:{
			shopName:{
				type:String,
				default:'测试店'
			},
			tableName:{
				type:String,
				default:'A1'
			},
			avatarUrl:{
				type:String,
				default:"https://thirdwx.qlogo.cn/mmopen/vi_32/O4wvxJDGOBoT8geY4hiacibldXsHxyiaFAUyibDZu7Xicr88ZaH37GwNhqu98jsgmutDhSQZrF4fkicoeMkTIpvibicRqg/132",
			},
			nickName:{
				type:String,
				default:'空'
			}
		}
	}
</script>

<style lang="scss">
	.card{
		// position: fixed;
		// top:0;
		width: 100%;
		height: 50px;
		background-color: #ff5500;
		.card-item{
			position: fixed;
			top:0px;
			width: 90%;
			height: 90px;
			margin-left:15px;
			border-radius: 5px;
			background-color: white;
			box-shadow: 0 0 5px 1px #999;
			// opacity: 0.95;
			z-index: 777;
		}
	}
	
</style>