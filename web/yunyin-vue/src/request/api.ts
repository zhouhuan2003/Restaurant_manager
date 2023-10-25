import service from ".";

//登录
export function login(data: any){
    return service({
        url:"/operator-web/login",
        method:"post",
        data
    })
}

//获取账号管理列表
export function getMemberList(data:any){
    return service({
        url:'/operator-web//enterprise/pageList/'+data.page+"/"+data.pageSize+"?enterpriseName="+data.name
    })
}

//账号启用
export function memberOpen(id:String){
    return service({
        url:"/operator-web/enterprise/enable/"+id,
        method:'put'
    })
}

//账号禁用
export function memberClose(id:String){
    return service({
        url:"/operator-web//enterprise/forbidden/"+id,
        method:'put'
    })
}

//获取账号详情
export function getMemberDetile(id:String){
    return service({
        url:"/operator-web//enterprise/getById/"+id
    })
}

// 添加账号
export function addMember (data:any){
    return service({
    url: `/operator-web/enterprise/add`,
    method: 'post',
    data
  })
}
// 编辑账号
export function editMember (data:any){
    return service({
    url: `/operator-web/enterprise/update`,
    method: 'put',
    data
  })
}

//重置密码
export function rePassword(data:any){
    return service({
        url:"/operator-web/enterprise/restPwd",
        method:"put",
        data
    })
}


//删除
export function del(id:String){
    return service({
        url:"/operator-web/enterprise/deleteById/"+id,
        method:"delete"
    })
}