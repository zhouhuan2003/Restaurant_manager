<template>
	<view style="background-color: white;">
		<card :avatarUrl="userInfo.avatarUrl" :nickName="userInfo.nickName"></card>

		<view class="scroll-view-container">
			<!--左侧的滑动区域 {height:wh + 'px'}-->
			<scroll-view class="left-scroll-view" scroll-y="true" :key="item.categoryId" style="height: 100vh;">
				<view class="left-scroll-view-item" :class="{'act' : active==item.categoryId}"
					v-for="(item,index) in categoryList" @click="activeChanged(item)">{{item.name}}</view>
			</scroll-view>

			<!--右侧的滑动区域-->
			<scroll-view class="right-scroll-view" scroll-y="true" :key="item.categoryId" :scroll-top="screenTop"
				style="height: 100vh;">
				<view class="right-view-item" v-for="(item,index) in dishList" :key="index" @click="toDetail(item)">
					<image style="width: 100px;height: 100px;" :src="item.imageUrl"></image>
					<test style="position: absolute;left:110px;top:10px;">{{item.dishName}}</test>
					<test style="position: absolute;left:110px;top:30px;font-size: 12px;">{{item.dishName}}</test>
					<test style="position: absolute;left:110px;top:60px;color: red;"><text
							style="font-size: 10px;">￥</text>{{item.price/100 | tofixed}}</test>
					<view v-for="item1 in shopCart" :key="item.id" v-if="item.dishId==item1.id && item1.number>0">
						<view class="subtract-dish" @click.stop="subtractDish(item)">-</view>
						<test style="position: absolute;bottom: 1px;right: 37px;text-align: center;">{{item1.number}}
						</test>
					</view>
					<view class="add-dish" @click.stop="addDish(item)">+</view>
				</view>
				<view style="width: 100%;text-align: center;margin-top:10px" v-if="dishList.length==0">暂无该类菜品，看看别的吧!
				</view>
			</scroll-view>
		</view>

		<!-- 菜品详情 -->
		<uni-popup :show="show" type="center" :custom="true" :mask-click="false">

			<view class="uni-tip">
				<!-- 标题 -->
				<view class="uni-tip-title" v-if="dishData.type==2">{{dishData.dishName}}</view>
				<view class="uni-tip-content">
					<!-- 中间内容进行自定义 -->
					<scroll-view style="height: 280px;" scroll-y="true">
						<view class="dishItem" v-if="dishData.type==1">
							<image style="width: 200px;height: 200px;" :src="dishData.imageUrl"></image>
							<view style="margin-top: 10px;font-size: 15px;font-weight: bold;">{{dishData.dishName}}
							</view>
							<view style="margin-top: 15px;">
								<test style="font-size: 15px;color:red"><text
										style="font-size: 10px;">￥</text>{{dishData.price/100 | tofixed}}</test>

								<view class="edit-number-dish">
									<view v-for="item1 in shopCart" :key="item1.id"
										v-if="dishData.dishId==item1.id && item1.number>0">
										<view class="subtract-dish" @click.stop="subtractDish(dishData)">-</view>
										<view class="dish-number">{{item1.number}}</view>
									</view>
									<view class="add-dish" @click.stop="addDish(dishData)">+</view>
								</view>

							</view>
						</view>

						<block v-else>
							<view class="dishItem" v-for="item in dishData.setMealDishList">

								<image style="width: 200px;height: 200px;" :src="item.image"></image>
								<view>
									<view style="margin-top: 10px;font-size: 15px;font-weight: bold;float: left;">
										{{item.dishName}}
									</view>
									<view style="float: right;"><text
											style="color: red;">￥{{item.dishPrice/100 | tofixed}}</text>
										<text style="font-size: 12px;">x 1</text>
									</view>
								</view>
							</view>

						</block>
					</scroll-view>
				</view>
				<view style="margin-top: 15px;" v-if="dishData.type==2">
					<test style="font-size: 15px;color:red"><text
							style="font-size: 10px;">￥</text>{{dishData.price/100 | tofixed}}</test>
					<view class="edit-number-dish">
						<view v-for="item1 in shopCart" :key="item1.id"
							v-if="dishData.dishId==item1.id && item1.number>0">
							<view class="subtract-dish" @click.stop="subtractDish(dishData)">-</view>
							<view class="dish-number">{{item1.number}}</view>
						</view>
						<view class="add-dish" @click.stop="addDish(dishData)">+</view>
					</view>
				</view>
				<!-- 按钮部分 -->
				<view class="uni-tip-group-button">
					<button type="warn" @click="onClose">取消</button>
				</view>
			</view>
		</uni-popup>

		<!-- 悬浮的购物车 -->
		<cart>
			<view style="background-color: black;color: white;width: 90%;height: 40px;border-radius: 45px;">
				<van-icon @click="toCartDetail" style="margin-left:10px;margin-right: 10px;" color="orange" name="cart"
					:info="cartNumber>0 ? cartNumber : ''" />
				<text style="line-height: 40px;"><text
						style="font-size: 12px;">￥</text>{{totalPrice/100 | tofixed}}</text>
				<button
					style="float: right;height: 35px;margin-top: 2px;margin-right: 3px;border-radius: 45px;background-color: orange;"
					@click="toOrder"><text style="position: relative;bottom: 5px;font-size: 15px;">去结算</text></button>
			</view>
		</cart>

		<!-- 购物车详情 -->
		<!-- <cartDetail :show="showCartDetail" type="bottom" :custom="true" :mask-click="false">
			<view>ces</view>
		</cartDetail> -->
		<uni-popup ref="popup" type="bottom" :maskClick="true">
			<view style="background-color: #fff;" :style="{height:ph}">
				<view
					style="position: fixed;top: 0; width: 92%;border-bottom: 1px solid grey;height:40px;background-color: #fff;padding-left: 10px;z-index: 999;">
					<text style="font-weight: bold;line-height: 40px;">购物车</text>
					<view style="position: absolute;right:10px;top:10px;font-size: 14px;"><van-icon name="delete-o" />清空
					</view>
				</view>

				<view style="margin-top: 40px;">
					<scroll-view >
						<view style="position: relative; height: 80px;" v-for="item in shopCart" :key="item.id" v-if="item.number>0">
							<image style="width: 70px;height: 70px;" :src="item.image"></image>
							
						<view style="position: absolute;left: 80px;top:10px">{{item.name}}</view>
						<view style="position: absolute;left: 80px;top:40px;color: red;">￥{{item.price*item.number/100 | tofixed}}</view>
						<view style="position: absolute;right: 5px;bottom: 10px;">
							<view class="edit-number-dish" >
								<view v-for="item1 in shopCart" :key="item1.id"
									v-if="item.id==item1.id && item1.number>0">
									<view class="subtract-dish" @click.stop="subtractDish(
									{
									'tableId':item1.tableId,
									'type':item1.type, 
									'dishId':item1.id})">
									-</view>
									<view class="dish-number">{{item1.number}}</view>
								</view>
								<view class="add-dish" @click.stop="addDish({
									'tableId':item.tableId,
									'type':item.type, 
									'dishId':item.id})">+</view>
							</view>
						</view>
						</view>
					</scroll-view>
				</view>
			</view>
		</uni-popup>


		<!-- <view style="background-color: red;"> ces</view> -->
	</view>
</template>

<script>
	import uniPopup from '@/components/uni-dialog.vue' // 自定义弹窗组件
	import cartDetail from '@/components/cart-detail.vue' // 自定义弹窗组件
	import cart from '@/components/cart.vue' // 自定义购物车组件
	import card from '@/components/card.vue'
	export default {
		components: {
			uniPopup,
			cart,
			card
		},
		data() {
			return {
				//可用屏幕的高度
				wh: 0,
				//菜品分类列表
				categoryList: [],
				//菜品列表
				dishList: [],
				shopCart: [],
				active: 0,
				dishData: {},
				screenTop: 0,
				tableId: '1643615244894773249',
				show: false,
				showCartDetail: false,
				showCart: true,
				userInfo: {},
				ph: 0,
				shopH: 0
			};
		},
		filters: {
			tofixed(num) {
				return Number(num).toFixed(2)
			}
		},
		onLoad() {
			this.login()
			uni.getSystemInfo({
				success: res => {
					console.log(res)
					this.wh = res.windowHeight
					this.ph = res.screenHeight * 0.7 + "px"
					this.shopH = res.screenHeight * 0.7 * 0.7 + "px"
				}
			})


			//调用方法,获取菜品分类列表
			this.getCategoryList()
			this.getShopCart(this.tableId)
		},
		computed: {
			totalPrice() {
				let price = 0;
				this.shopCart.map(d => {
					if (d.number > 0) {
						price += d.price * d.number
					}
				})
				return price;
			},
			cartNumber() {
				let num = 0;
				this.shopCart.map(d => {
					num += d.number
				})
				return num;
			}
		},
		methods: {
			async getCategoryList() {
				const res = await uni.$http.get("/dish/category")
				if (res.data.code != 200) return uni.$showMsg()
				this.active = res.data.data[0].categoryId
				this.categoryList = res.data.data
				this.getDishList({
					'categoryId': res.data.data[0].categoryId,
					'type': res.data.data[0].type,
					'page': 1,
					'pageSize': 100
				})
			},
			async getDishList(data) {
				const res = await uni.$http.get("/dish/dishPageList/" + data.categoryId + "/" + data.type + "/" + data
					.page + "/" + data.pageSize)
				this.dishList = res.data.data.items
			},

			activeChanged(item) {
				this.screenTop = this.screenTop == 0 ? 1 : 0
				this.active = item.categoryId
				this.getDishList({
					'categoryId': item.categoryId,
					'type': item.type,
					'page': 1,
					'pageSize': 100
				})
			},

			//添加菜品
			addDish(item) {
				const data = {
					...item
				}
				data.dishNumber = 1
				data.tableId = this.tableId
				uni.$http.post("/order/addDish", data).then(res => {
					this.getShopCart(this.tableId)
				})

			},

			//减少菜品
			subtractDish(item) {
				const data = {
					...item
				}
				data.dishNumber = -1
				data.tableId = this.tableId
				uni.$http.post("/order/addDish", data).then(res => {
					this.getShopCart(this.tableId)
				})
			},

			//获取购物车信息
			async getShopCart(tableId) {
				const res = await uni.$http.get("/order/shopCart/" + tableId)
				this.shopCart = res.data.data.dishList
			},

			toDetail(item) {
				this.dishData = {
					...item
				}
				this.show = true
			},

			toCartDetail() {
				console.log("to")
				this.showCartDetail = !this.showCartDetail
				this.$refs['popup'].open();
			},

			onClose() {
				// this.setData({ close: false });
				this.show = false
			},

			toOrder() {
				console.log('跳转')
				uni.navigateTo({
					url: "/pages/order/order",
					animationType: 'pop-in',
					animationDuration: 300
				})
			},



			login() {
				var that = this
				uni.showModal({
					mask: true,
					title: "温馨提示",
					content: "亲，授权微信登录后才能正式点餐",
					showCancel: false,
					success(res) {
						if (res.confirm) {
							uni.getUserProfile({
								desc: "获取你的昵称、头像",
								success: userRes => {
									if (userRes.errMsg == 'getUserProfile:ok' && userRes.userInfo !=
										undefined) {
										var userInfo = {
											avatarUrl: userRes.userInfo.avatarUrl,
											nickName: userRes.userInfo.nickName
										}
										//渲染页面

										//调用接口请求openid
										that.getUserOpenId(userInfo)
									} else {
										uni.showToast({
											icon: "none",
											title: "获取失败"
										})
									}
								},
								fail: error => {}
							});
						} else if (res.cancel) {}
					}
				});
			},
			getUserOpenId(userInfo) {
				var that = uni
				var this_ = this
				uni.login({
					provider: "weixin",
					success(loginAuth) {
						var data = {
							'code': loginAuth.code
						}
						var path = '/user/getOpenId'
						that.$http.get(path, data).then(res => {
							userInfo['openid'] = res
							console.log(userInfo)
							this_.userInfo = userInfo
						})
					}
				})
			},
		}
	}
</script>

<style lang="scss">
	.scroll-view-container {
		display: flex;
		margin-top: 40px;

		.left-scroll-view {
			width: 120px;

			.left-scroll-view-item {
				background-color: #f7f7f7;
				line-height: 60px;
				text-align: center;
				font-size: 15px;

				&.act {
					background-color: #ffffff;
					color: orange;
					position: relative;

					&::before {
						content: '';
						display: block;
						width: 3px;
						height: 30px;
						background-color: orange;
						position: absolute;
						top: 50%;
						transform: translateY(-50%);
					}
				}
			}
		}

		;

		.right-scroll-view {
			background-color: #ffffff;

			.right-view-item {
				position: relative;
				height: 100px;
				// background-color: red;
				margin: 10px 10px;

				.add-dish {
					position: absolute;
					right: 10px;
					bottom: 0px;
					font-size: 20px;
					line-height: 23px;
					text-align: center;
					color: black;
					width: 23px;
					height: 23px;
					border-radius: 50%;
					background-color: orange;
				}

				;

				.subtract-dish {
					position: absolute;
					right: 53px;
					bottom: 0px;
					font-size: 20px;
					line-height: 21px;
					text-align: center;
					color: black;
					width: 21px;
					height: 21px;
					border-radius: 50%;
					border: 1px solid orange;
				}
			}
		}

	}

	/* 提示窗口 */
	.uni-tip {
		padding: 15px;
		width: 300px;
		background: #fff;
		box-sizing: border-box;
		border-radius: 10px;
	}

	.uni-tip-title {
		text-align: center;
		font-weight: bold;
		font-size: 16px;
		color: #333;
		text-align: center;
	}

	.uni-tip-content {
		padding: 15px;
		font-size: 14px;
		color: #666;
		/* background: #C8C7CC; */
		// border:2upx solid #ccc;
		border-radius: 10upx;

		.dishItem {
			margin-left: 20px;

			.edit-number-dish {
				float: right;
				display: flex;

				.dish-number {
					float: right;
					margin-left: 10px;
					margin-right: 10px;
				}

				.subtract-dish {
					float: left;
					font-size: 20px;
					line-height: 21px;
					text-align: center;
					color: black;
					width: 21px;
					height: 21px;
					border-radius: 50%;
					border: 1px solid orange;
				}

				.add-dish {
					font-size: 20px;
					line-height: 23px;
					text-align: center;
					color: black;
					width: 23px;
					height: 23px;
					border-radius: 50%;
					background-color: orange;
				}
			}
		}
	}

	.edit-number-dish {
		float: right;
		display: flex;

		.dish-number {
			float: right;
			margin-left: 10px;
			margin-right: 10px;
		}

		.subtract-dish {
			float: left;
			font-size: 20px;
			line-height: 21px;
			text-align: center;
			color: black;
			width: 21px;
			height: 21px;
			border-radius: 50%;
			border: 1px solid orange;
		}

		.add-dish {
			font-size: 20px;
			line-height: 23px;
			text-align: center;
			color: black;
			width: 23px;
			height: 23px;
			border-radius: 50%;
			background-color: orange;
		}
	}
	

	.uni-tip-content-textarea {
		height: 300upx;
		width: 100%;
		text-align: center;
	}

	.uni-tip-group-button {
		margin-top: 10px;
		display: flex;
	}

	.uni-tip-group-button>button {
		font-size: 24upx;
		height: 60upx;
		line-height: 60upx;

	}
</style>