import service from ".";
let base_url='/cash-web';
//登录
export function login(data){
    return service({
        url:base_url+"/login",
        method:"post",
        data
    })
}

//查询所有的区域
export function listTableArea(){
    return service({
        url:base_url+'/table/listTableArea'
    })
}

//查询桌台面板
export function tableList(data){
    return service({
        url:base_url+'/table/search/'+data.areaId+"/"+data.page+"/"+data.pageSize
    })
}

//根据桌台id获取桌台信息
export function getTableByid(id){
    return service({
        url:base_url+'/table/get/'+id
    })
}

//开桌
export function openTable(data){
    return service({
        url:base_url+"/table/openTable/"+data.tableId+"/"+data.numbers,
        method:'put'
    })
}

//获取分类列表
export function getCategoryList(data){
    return service({
        url:"/enterpise-web/dishCategory/pageList/"+data.page+"/"+data.pageSize
    })
}

//获取菜品列表
export function getDishList(data){
    return service({
        url:base_url+"/dish/list/"+data.page+"/"+data.pageSize,
        params:data
    })
}

//下单
export function addOrder(data){
    return service({
        url:base_url+"/order/add",
        method:'post',
        data
    })
}

