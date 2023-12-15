const database = require('../model/hoadon.model')

async function getHoaDon(req,res){
    let id = req.params.id

    let result = await database.returnHoaDon(id)
    .catch(
        err=>{
            console.log(err)
            return res.json({
                isSuccess: false,
                message: 'request Failure',
                status: res.statusCode,
                data: ''
            })
        }
    )
    // console.log(result)
    return res.json({
        isSuccess: true,
        message: 'request Successfully',
        status: res.statusCode,
        data: {
            listhoadon: result.recordset
        }
    })
}

async function getHoaDonNgay(req,res){
    let date = req.params.date
    let result = await database.returnHoaDonNgay(date)
    .catch(
        err=>{
            console.log(err)
            return res.json({
                isSuccess: false,
                message: 'request Failure',
                status: res.statusCode,
                data: ''
            })
        }
    )
    console.log(result)
    return res.json({
        isSuccess: true,
        message: 'request Successfully',
        status: res.statusCode,
        data: {
            listDonThuoc: result.recordset
        }
    })
}

async function getChiTietHoaDon(req,res){
    let id = req.params.id
    let result = await database.returnChiTietHoaDon(id)
    .catch(
        err=>{
            console.log(err)
            return res.json({
                isSuccess: false,
                message: 'request Failure',
                status: res.statusCode,
                data: ''
            })
        }
    )
    // console.log(result)
    return res.json({
        isSuccess: true,
        message: 'request Successfully',
        status: res.statusCode,
        data: {
            hoadon: result.recordsets[0],
            buoidieutri : result.recordsets[1],
            thuoc : result.recordsets[2]
        }
    })
}

async function addHoaDon(req,res){
    // let date = req.params.date
    let result = await database.returnAddHoaDon()
    .catch(
        err=>{
            console.log(err)
            return res.json({
                isSuccess: false,
                message: 'request Failure',
                status: res.statusCode,
                data: ''
            })
        }
    )
    console.log(result)
    return res.json({
        isSuccess: true,
        message: 'request Successfully',
        status: res.statusCode,
        data: {
            listDonThuoc: result.recordset
        }
    })
}

module.exports={
    getHoaDon,
    getHoaDonNgay,
    getChiTietHoaDon,
    addHoaDon
}
