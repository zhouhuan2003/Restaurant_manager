<template>
	<view>
		<card ></card>
		<view style="margin-top: 40px;"></view>
		<view class="dish-item" v-for="item in shopCart" :key="item.id" v-if="item.number>0">
			<image style="width: 60px;height: 60px;border-radius: 5px;margin: 10px;" :src="item.image"></image>
			<view style="margin-top:10px">
				<view><text style="font-weight: bold;">{{item.name}}</text></view>
				<view><text style="font-size: 15px;color:gray;">x {{item.number}}</text></view>
			</view>
			<view style="position: absolute;right: 0;margin-top:50px"><text style="color: red;">￥{{item.price*item.number/100 | tofixed}}</text></view>
		</view>
		
		<!-- <button type="primary" @click="login">一键登录</button> -->
		
		
		<!-- 悬浮的购物车 -->
		<cart >
			<view style="background-color: black;color: white;width: 90%;height: 40px;border-radius: 45px;">
				<text style="line-height: 40px;"><text style="font-size: 12px;">￥</text>{{totalPrice/100 | tofixed}}</text>
				<view style="float:right">
					<button style="float: left;height: 35px;margin-top: 2px;border-top-left-radius: 45px; border-bottom-left-radius: 45px; background-color: #443F3D;" @click="toBack"><text style="position: relative;bottom: 5px;font-size: 15px;color: orange;" >继续加菜</text></button>
					<button style="float: right;height: 35px;margin-top: 2px;margin-right: 3px;border-top-right-radius: 45px; border-bottom-right-radius: 45px; background-color: orange;" @click="pay"><text style="position: relative;bottom: 5px;font-size: 15px;" >支付下单</text></button>
				</view>
			</view>
		</cart>
	</view>
</template>

<script>
	import cart from '@/components/cart.vue' // 自定义购物车组件
	import card from '@/components/card.vue'
	export default {
		components: {
			cart,
			card
		},
		data() {
			return {
				shopCart: [],
				tableId: '1643615244894773249',
			};
		},
		filters:{
			tofixed(num){
				return Number(num).toFixed(2)
			}
		},
		onLoad() {
			this.getShopCart(this.tableId)
		},
		computed:{
				totalPrice(){
					let price=0;
					 this.shopCart.map(d=>{
						if(d.number>0){
							price+=d.price*d.number
						}
					})
					return price;
				},
				cartNumber(){
					let num=0;
					this.shopCart.map(d=>{
						num+=d.number
					})
					return num;
				}
		},
		methods:{
			//获取购物车信息
			async getShopCart(tableId) {
				const res = await uni.$http.get("/order/shopCart/" + tableId)
				this.shopCart = res.data.data.dishList
			},
			toBack(){
				uni.navigateBack()
			},
			pay(){
				
			},
			// login(){
			// 	var that=this
			// 	uni.showModal({
			// 		mask:true,
			// 		title:"温馨提示",
			// 		content:"授权登录后才能正常的使用小程序功能",
			// 		success(res){
			// 			if(res.confirm){
			// 				uni.getUserProfile({
			// 					desc:"获取你的昵称、头像",
			// 					success:userRes=>{
			// 						if(userRes.errMsg=='getUserProfile:ok' && userRes.userInfo!=undefined){
			// 							var userInfo={
			// 								avatarUrl:userRes.userInfo.avatarUrl,
			// 								nickName:userRes.userInfo.nickName
			// 							}
			// 							//渲染页面
										
			// 							//调用接口请求openid
			// 							that.getUserOpenId(userInfo)
			// 						}else{
			// 							uni.showToast({
			// 								icon:"none",
			// 								title:"获取失败"
			// 							})
			// 						}
			// 					},
			// 					fail:error=>{}
			// 				});
			// 			}else if(res.cancel){}
			// 		}
			// 	});
			// },
			// getUserOpenId(userInfo){
			// 	var that=uni
			// 	uni.login({
			// 		provider:"weixin",
			// 		success(loginAuth){
			// 			var data={'code':loginAuth.code}
			// 			var path='/user/getOpenId'
			// 			console.log(that)
			// 			that.$http.get(path,data).then(res=>{
			// 				userInfo['openid']=res
			// 				console.log(userInfo)
			// 			})
			// 		}
			// 	})
			// },
		}
	}
</script>

<style lang="scss">
	.dish-item{
		display: flex;
		height: 80px;
		border-bottom: 1px solid #d4d3d3;
	}
</style>
