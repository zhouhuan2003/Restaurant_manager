import service from ".";

//登录
export function login(data: any){
    return service({
        url:"/enterpise-web/login",
        method:"post",
        data
    })
}
//获取品牌列表
export function getBarndList(){
    return service({
        url:'/enterpise-web/brand/pageList/1/100'
    })
}
//获取品牌下拉
export function getBarnd(){
    return service({
        url:'/enterpise-web/brand/brandList'
    })
}
//品牌添加
export function addBarnd(data: any){
    return service({
        url:'/enterpise-web/brand/add',
        method:"post",
        data
    })
}

//获取所有的门店
export function getStoreList(data:any){
    return service({
        url:'/enterpise-web/store/pageList/'+data.page+'/'+data.pageSize+"?name="+data.name,
    })
}

//添加门店
export function addStore(data:any){
    return service({
        url:'/enterpise-web/store/add',
        method:'post',
        data
    })
}

//获取门店详情
export function getShopDetails(id:String){
    return service({
        url:'/enterpise-web/store/get/'+id
    })
}

//门店停业
export function disableStore(id:String){
    return service({
        url:'/enterpise-web/store/disabled/'+id,
        method:'put'
    })
}

//修改门店信息
export function updateShop(data:any){
    return service({
        url:'/enterpise-web/store/update',
        method:'put',
        data
    })
}

//删除门店
export function delShop(id:String){
    return service({
        url:'/enterpise-web/store/del/'+id,
        method:'delete'
    })
}

//获取门店省份信息
export function getStoreListProvince(){
    return service({
        url:'/enterpise-web/store/listProvince'
    })
}

//根据省份获取门店列表
export function getStoreListByProvince(province:String){
    return service({
        url:'/enterpise-web/store/getStoreByProvince/'+province
    })
}


//获取店长列表
export function getShopownerList(params:any){
    return service({
        url:'/enterpise-web/storeManger/pageList/'+params.page+'/'+params.pageSize+"?name="+params.criteria,
        method:'post'
    })
}

//添加店长
export function addStoreManager(data:any){
    return service({
        url:'/enterpise-web/storeManger/add',
        method:'post',
        data
    })
}

//删除店长
export function delStoreManager(id:String){
    return service({
        url:'/enterpise-web/storeManger/del/'+id,
        method:'delete'
    })
}

//店长停用
export function pauseStoreManager(id:String,status:number){
    return service({
        url:'/enterpise-web/storeManger/pause/'+id+'/'+status,
        method:'put'
    })
}

//根据id获取店长信息
export function getStoreManagerByid(id:String){
    return service({
        url:'/enterpise-web/storeManger/get/'+id,
    })
}

//店长信息修改
export function updateStroreManager(data:any){
    return service({
        url:'/enterpise-web/storeManger/update',
        method:'put',
        data
    })
}

//======================店员管理

//切换门店
export function switchStore(id:String){
    return service({
        url:'/enterpise-web/store/switchStore/'+id
    })
}

//查询店员分页信息
export function getMemberList(data:any){
    return service({
        url:'/enterpise-web/staff/pageList/'+data.page+'/'+data.pageSize+"?name="+data.name,
    })
}

//禁用、启用店员
export function editStatusMember(id:String){
    return service({
        url:'/enterpise-web/staff/editStatus/'+id,
        method:'put'
    })
}

//根据id查询店员
export function getMemberById(id:String){
    return service({
        url:'enterpise-web/staff/get/'+id
    })
}


//添加店员
export function addMember(data:any){
    return service({
        url:'/enterpise-web/staff/add',
        method:"post",
        data
    })
}

//删除员工
export function delMenber(id:String){
    return service({
        url:'/enterpise-web/staff/del/'+id,
        method:'delete'
    })
}

//获取分类信息
export function dishCategoryPageList(page:number,pageSize:number){
    return service({
        url:'/enterpise-web/dishCategory/pageList/'+page+"/"+pageSize
    })
}


//添加分类
export function dishCategoryAdd(data:any){
    return service({
        url:'/enterpise-web/dishCategory/add',
        method:'post',
        data
    })
}

//修改分类
export function dishCategoryUpdate(data:any){
    return service({
        url:'/enterpise-web/dishCategory/update/'+data.id+"?categoryName="+data.categoryName,
        method:'put'
    })
}

//删除分类
export function delCategory(id:String){
    return service({
        url:'/enterpise-web/dishCategory/delete/'+id,
        method:"delete"
    })
}

//根据类型查询分类 1:菜品 2:套餐
export function getCategroyByType(type:number){
    return service({
        url:'/enterpise-web/dishCategory/type/'+type
    })
}

// 分类id获取菜品列表
export function getDishListType(params: any){
    return service({
        'url': `/enterpise-web/dish/findEnableDishList/${params.id}`+"?name="+params.name,
    });
}

//菜品列表
export function getDishList(data:any){
    return service({
        url:'/enterpise-web/dish/pageList/'+data.page+"/"+data.pageSize+"?name="+data.name,
    })
}

//根据id获取菜品信息
export function getDishById(id:String){
    return service({
        url:"/enterpise-web/dish/"+id
    })
}

//添加菜品信息
export function addDish(data:any){
    return service({
        url:"/enterpise-web/dish/add",
        method:"post",
        data
    })
}

//修改菜品信息
export function editDish(data:any){
    return service({
        url:"/enterpise-web/dish/update",
        method:'put',
        data
    })
}

//删除菜品信息
export function delDish(data:any){
    return service({
        url:"/enterpise-web/dish/delete",
        method:"delete",
        data
    })
}

//设置菜品状态
export function editDishStatus(data:any){
    return service({
        url:'/enterpise-web/dish/updateStatus',
        method:"put",
        data
    })
}

//查询菜品口味
export function getDishFlavorList(){
    return service({
        url:'/enterpise-web/dish/flavorList'
    })
}

//查询套餐分页
export function setMealPageList(data:any){
    return service({
        url:"/enterpise-web/setMeal/queryPage/"+data.page+"/"+data.pageSize+"?name="+data.name,
    })
}

//删除套餐
export function setMealDelete(data:any){
    return service({
        url:'/enterpise-web/setMeal/delete',
        method:"delete",
        data
    })
}

//套餐停/启售
export function setMealUpdateStatus(data:any){
    return service({
        url:'/enterpise-web/setMeal/updateStatus',
        method:'put',
        data
    })
}

//添加套餐
export function setMealAdd(data:any){
    return service({
        url:'/enterpise-web/setMeal/add',
        method:"post",
        data
    })
}

//添加套餐
export function setMealUpdate(data:any){
    return service({
        url:'/enterpise-web/setMeal/update',
        method:"put",
        data
    })
}

//根据id查询套餐信息
export function setMealByid(id:String){
    return service({
        url:'/enterpise-web/setMeal/'+id
    })
}

//桌台列表
export function getTableList(data:any){
    return service({
        url:'/enterpise-web/table/search/'+data.areaId+'/'+data.page+'/'+data.pageSize
    })
}

//区域列表
export function getAreaList(data:any){
    return service({
        url:'/enterpise-web/table/area/pageList/'+data.page+'/'+data.pageSize
    })
}

//删除桌台
export function delTable(id:String){
    return service({
        url:'/enterpise-web/table/'+id,
        method:"delete"
    })
}

//添加桌台
export function addTable1(data:any){
    return service({
        url:'/enterpise-web/table/addTable',
        method:"post",
        data
    })
}

//添加桌台
export function editTable(data:any){
    return service({
        url:'/enterpise-web/table/update',
        method:"put",
        data
    })
}

//删除区域
export function delArea(id:string){
    return service({
        url:'/enterpise-web/table/area/delete/'+id,
        method:'delete'
    })
}

//添加区域
export function addArea(data:any){
    return service({
        url:'/enterpise-web/table/addArea?name='+data.name,
        method:'post'
    })
}

//修改区域
export function editArea(data:any){
    return service({
        url:'/enterpise-web/table/area/update',
        method:'put',
        data
    })
}


//新增挂账
export function addCredit(data:any){
    return service({
        url:"/enterpise-web/credit/add",
        method:"post",
        data
    })
}

//挂账管理列表
export function creditPageList(data:any){
    return service({
        url:'/enterpise-web/credit/pageList/'+data.page+"/"+data.pageSize+"?name="+data.name
    })
}

//挂账详情列表
export function creditLongPageList(data:any){
    return service({
        url:'/enterpise-web/credit/creditLog/'+data.page+"/"+data.pageSize+"/"+data.creditId+"?start="+data.start+"&end="+data.end
    })
}

//导出详情
export function exportCredit(data:any){
    return service({
        url:'/enterpise-web/credit/export/'+data.creditId+"/"+data.start+"/"+data.end,
        responseType:'blob'
    })
}

//还款
export function creditRepayment(data:any){
    return service({
        url:"/enterpise-web/credit/repayment",
        method:'post',
        data
    })
}

//修改挂账
export function editCredit(data:any){
    return service({
        url:"/enterpise-web/credit/update/"+data.id,
        method:'put',
        data
    })
}

//根据id获取挂账详情
export function getCreditById(id:String){
    return service({
        url:"/enterpise-web/credit/"+id
    })
}

//删除挂账
export function delCredit(id:String){
    return service({
        url:'/enterpise-web/credit/'+id,
        method:"delete"
    })
}

//修改挂账状态
export function editStatusCredit(data:any){
    return service({
        url:"/enterpise-web/credit/update/status/"+data.id+"/"+data.status,
        method:"put"
    })
}

//获取门店信息
export function settingPageList(){
    return service({
        url:'/enterpise-web/setting/getSysSettings'
    })
}

//修改门店信息
export function editSetting(data:any){
    return service({
        url:'/enterpise-web/setting/update',
        method:'put',
        data
    })
}
