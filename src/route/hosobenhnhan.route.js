const controller = require('../controller/hosobenhnhan.controller')
const express = require('express')
const route = express.Router()

route.get('/hosobenhnhan/:id', controller.getChiTietHoSoBenhNhan);
route.post('/hosobenhnhan/capnhat', controller.postCapNhatHoSoBenhNhan);
route.get('/dangnhap', controller.getDangNhap);
route.post('/dangky', controller.postDangKy);

module.exports = route;