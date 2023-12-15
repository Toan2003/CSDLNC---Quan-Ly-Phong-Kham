const controller = require('../controller/hoadon.controller')
const express = require('express')
const route = express.Router()

route.get('/hoadon/getHoaDon/:id', controller.getHoaDon) //xem danh sachs hoa don cua 1bn

route.get('/hoadon/getHoaDon/date/:date', controller.getHoaDonNgay) //xem hoa don theo ngay
route.get('/hoadon/getHoaDon/chitiethoadon/:id', controller.getChiTietHoaDon) // xem chi tiet hoa don theo ma benh nhan

route.post('/hoadon/addHoaDon', controller.addHoaDon)    //Add theem hoa don

module.exports = route