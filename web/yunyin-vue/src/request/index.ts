import axios from 'axios'

const service=axios.create({
    baseURL:"http://192.168.0.105:8085",
    timeout:5000,
    headers:{
        "Content-Type":"application/json;charset=utf=8"
    }
})

//请求拦截
service.interceptors.request.use((config)=>{
    config.headers=config.headers || {}
    if(localStorage.getItem('token')){
        config.headers.Authorization =localStorage.getItem('token') || ""
    }
    return config
})

//响应拦截
service.interceptors.response.use((res)=>{
    // const status:number=res.data.status
    // if(status!=200){
    //     return Promise.reject(res.data)
    // }
    // return Promise.reject(res.data)
    return res.data
},(err)=>{
    console.log(err); 
})

export default service