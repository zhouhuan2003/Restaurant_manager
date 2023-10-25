import axios from 'axios'

const service=axios.create({
    baseURL:"http://192.168.1.3:8085",
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
    return res.data
},(err)=>{
    console.log(err); 
})

export default service