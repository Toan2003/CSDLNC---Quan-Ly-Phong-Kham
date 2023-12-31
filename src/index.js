const express =require('express')
const app = express()
// const user = require('./model/user')
const port = 8080
const db = require('./database/database')
const cors = require('cors')

app.use(cors())
app.use(express.json({ limit: "50mb" }));
app.use(express.urlencoded({ 
    extended: true, 
    limit: "50mb",
}));

const donthuoc = require('./route/donthuoc.route')
const dieutri = require('./route/dieutri.route')
const hosobenhnhan = require('./route/hosobenhnhan.route')
const hoadon = require ('./route/hoadon.route')
const lichhen = require('./route/lichhen.route')
const lichlamviec = require('./route/lichlamviec.route')
const nhanvien = require('./route/nhanvien.route');

app.use(donthuoc)
app.use(dieutri)
app.use(hosobenhnhan)
app.use(lichhen)
app.use(lichlamviec)
app.use(nhanvien)
app.use(hoadon)

app.listen(port, ()=>console.log(`Example app listening at htttp://localhost:${port}`))