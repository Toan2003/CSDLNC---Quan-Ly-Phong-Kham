const controller = require('../controller/lichhen.controller')
const express = require('express')
const route = express.Router()

route.post('/lichhen/searchLHBN', controller.postLichHenIDBN);
route.post('/lichhen/searchLHNS', controller.postLichHenIDNS);
route.post('/lichhen/searchLHPK', controller.postLichHenIDPK);
route.post('/lichhen/searchD2D', controller.postLichHenDayToDay);
route.post('/lichhen/createLH', controller.postThemLichHen);
route.post('/lichhen/deleteLH', controller.postXoaLichHen);
route.post('/lichhen/updateLH', controller.postCapNhatLichHen);

module.exports = route;