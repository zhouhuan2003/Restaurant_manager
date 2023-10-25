<template>
	<view class="login-view">
		<view class="login-from">
			<view style="margin-top: 20px;margin-left: 15%;"><text style="font-size: 35px;padding-right: 10px;">小欢掌柜 &nbsp;|</text><text style="font-size: 35px;">收银系统</text></view>

			<view>
				<!-- <uni-section  > -->
				<view class="example">
					<!-- 基础表单校验 -->
					<uni-forms ref="valiForm" :rules="rules" :modelValue="valiFormData">
						<uni-forms-item label="商户号" required name="name">
							<uni-easyinput v-model="valiFormData.shopId" placeholder="请输入商户号" />
						</uni-forms-item>
						<uni-forms-item label="用户名" required name="age">
							<uni-easyinput v-model="valiFormData.loginName" placeholder="请输入用户名" />
						</uni-forms-item>
						<uni-forms-item label="密码" required name="age">
							<uni-easyinput type="password" v-model="valiFormData.loginPass" placeholder="请输入密码" />
						</uni-forms-item>
					</uni-forms>
					<button style="color: white;background-color: orange;" @click="submit('valiForm')">提交</button>
				</view>
				<!-- </uni-section> -->
			</view>
			
			<view style="text-align: center;margin-top: 10px;font-size: 20px;">忘记密码了？请联系店长进行密码重置</view>
		</view>

	</view>
</template>

<script>
	
	export default {
		data() {
			return {
				// 校验表单数据
				valiFormData: {
					shopId: '01854018',
					loginName: '周雅轩',
					loginPass: '123456',
				},
				// 校验规则
				rules: {
					shopId: {
						rules: [{
							required: true,
							errorMessage: '商户号不能为空'
						}]
					},
					loginName: {
						rules: [{
							required: true,
							errorMessage: '用户名不能为空'
						} ]
					},
					loginPass:{
						rules:[
							{
								required: true,
								errorMessage: '密码不能为空'
							}
						]
					}
				},
			};
		},
		onLoad() {

		},
		methods: {
			submit(ref) {
				this.$refs[ref].validate().then(res => {
					const data=this.valiFormData
					console.log('success', this.valiFormData);
					this.$request({
						url:'/login',
						method:'post',
						data:data
					}).then(res =>{
						console.log(res)
						if(res.status=='500'){
							uni.showToast({
								icon:'none',
								title:res.desc
							})
						}else{
							uni.showToast({
								icon:'success',
								title:"登录成功"
							})
							uni.setStorageSync('token',res.token)
							uni.setStorageSync('user',res.data)
							//跳转到主页
							uni.navigateTo({
								url:'/pages/index/index'
							})
						}
						
					})
					
				}).catch(err => {
					console.log('err', err);
				})
			},
		}
	}
</script>

<style lang="scss">
	.login-view {
		height: 100vh;
		background-image: url("../../static/images/logBg.jpg");
		// background-size: contain ;
		// background-repeat: no-repeat
		background-size: cover;
		/* 让背景图基于容器大小伸缩 */
		background-attachment: fixed;
		/* 当内容高度大于图片高度时，背景图像的位置相对于viewport固定 */
		//此条属性必须设置否则可能无效/
		display: flex;
		align-items: center; // 垂直居中，针对的是mycontainer类下面的子元素，不包含“孙子”元素
		justify-content: center; // 水平居中，针对的是mycontainer类下面的子元素，不包含“孙子”元素

		.login-from {
			z-index: 999;
			width: 50%;
			height: 50%;
			background-color: white;
			border-radius: 15px;
			// display: flex;
			// flex-direction:row-reverse;
			// // align-items: center;   // 垂直居中，针对的是mycontainer类下面的子元素，不包含“孙子”元素
			// justify-content: center; // 水平居中，针对的是mycontainer类下面的子元素，不包含“孙子”元素

			.example {
				padding: 15px;
				background-color: #fff;
				margin-top: 20px;
				font-size: 35px;
			}
		}

	}
</style>