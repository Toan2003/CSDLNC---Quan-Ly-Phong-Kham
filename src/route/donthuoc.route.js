const controller = require('../controller/donthuoc.controller')
const express = require('express')
const route = express.Router()

route.get('/donthuoc/getALLDonThuoc', controller.getAllDonThuoc)
route.get('/donthuoc/getDonThuoc/:id', controller.getDonThuoc) //xem ds don thuoc theo benh nhan

route.post('/donthuoc/addLoaiThuoc', controller.addLoaiThuoc)
route.post('/donthuoc/updateLoaiThuoc', controller.updateLoaiThuoc)

route.get('/donthuoc/chitietdonthuoc/:id', controller.getChiTietDonThuoc)   //ddax check
// route.get('/donthuoc/getDonThuoc/date/:date'.controller.getDonThuocNgay)

route.post('/donthuoc/addDonThuoc', controller.addDonThuoc)
route.post('/donthuoc/deleteDonThuoc/:id', controller.deleteDonThuoc)
route.post('/donthuoc/addChiTietDonThuoc', controller.addChiTietDonThuoc)

route.get('/donthuoc/getLoaiThuoc/:tenthuoc', controller.getLoaiThuoc)

module.exports = route