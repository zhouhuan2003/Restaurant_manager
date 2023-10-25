import service from ".";

// 获取当日销售数据
export function getDataes () {
return service({
        'url': '/enterpise-web/report/amountCollect'
    });
}
// 获取当日销售数据
export function getDayDataes (params: any){
return service({
        'url': '/enterpise-web/report/hourCollect/'+params.type,
        'method': 'get'
    });
}
// 支付类型数据汇总 - 店内收款构成 - 当日
export function getDayPayType(){
    return service({
    url: '/enterpise-web/report/payTypeCollect'
  })
}

// 获取菜品分类销售排行 - 菜品分类占比 -当日
export function getSalesRanking(params: any){
    return service({
        url:'/enterpise-web/report/categoryCollect/'+params.type
    })
}

// 获取当日菜品销售排行
export function getDayRanking(){
    return service({
        url:'/enterpise-web/report/currentDishRank/'
    })
}


// 获取一定日期之内的销售趋势
export function getTimeQuantumDataes(data:any){
    return service({
        url:'/enterpise-web/report/dayAmountCollect/'+data.type+"/"+data.start+"/"+data.end
    })
}

// 获取时间范围之内的各种支付类型数据汇总 - 店内收款构成 - 时间段
export function getTimeQuantumReceivables(data:any){
    return service({
        url:'/enterpise-web/report/datePayTypeCollect/'+data.start+"/"+data.end
    })
}

// 获取时间范围之内的菜品类别销售汇总 -  菜品分类占比 - 时间段
export function getTimeQuantumType(data:any){
    return service({
        url:'/enterpise-web/report/dateCategoryCollect/'+data.type+"/"+data.start+"/"+data.end
    })
}

// 获取时间范围之内的菜品销售排行
export function getTimeQuantumDishes(data:any){
    return service({
        url:'/enterpise-web/report/dishRankForDate/'+data.start+"/"+data.end
    })
}

// 获取时间范围之内的优惠指标汇总数据
export function getTimeQuantumDiscount(data:any){
    return service({
        url:'/enterpise-web/report/privilegeByDate/'+data.start+"/"+data.end
    })
}

//获取各种优惠类型数据汇总
export function getPrivilegeCollect(){
    return service({
        url:"/enterpise-web/report/privilegeCollect"
    })
}