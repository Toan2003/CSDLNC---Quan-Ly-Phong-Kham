const database = require('../model/donthuoc.model')

async function getAllDonThuoc(req,res){
    let result = await database.returnAllDonThuoc()
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

async function getDonThuoc(req,res){
    let id = req.params.id

    let result = await database.returnDonThuoc(id)
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
            listDonThuoc: result.recordset
        }
    })
}

async function getChiTietDonThuoc(req,res){
    let id = req.params.id

    let result = await database.returnChiTietDonThuoc(id)
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
            chitietdonthuoc: result.recordset
        }
    })
}

async function getDonThuocNgay(req,res){
    let dateA = req.params.date

    let result = await database.returnDonThuocNgay(dateA)
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
            listDonThuoc: result.recordset
        }
    })
}

async function addLoaiThuoc(req,res){
    // let id = req.params.id
    let {idthuoc, tenthuoc, thanhphan, donvitinh, giathuoc}=req.body
    let result = await database.returnAddLoaiThuoc(idthuoc, tenthuoc, thanhphan, donvitinh, giathuoc)
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
            
        }
    })
}

async function updateLoaiThuoc(req,res){
    // let id = req.params.id
    let {idthuoc, tenthuoc, thanhphan, donvitinh, giathuoc} = req.body
    let result = await database.returnUpdateLoaiThuoc(idthuoc, tenthuoc, thanhphan, donvitinh, giathuoc)
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
            
        }
    })
}
async function addDonThuoc(req,res){
    // let id = req.params.id
    let {iddonthuoc, ngaycap, idbuoidieutri} = req.body
    let result = await database.returnAddDonThuoc(iddonthuoc, ngaycap, idbuoidieutri)
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
            
        }
    })
}

async function deleteDonThuoc(req,res){
    let id = req.params.id

    let result = await database.returnDeleteDonThuoc(id)
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
            
        }
    })
}

async function addChiTietDonThuoc(req,res){
    // let id = req.params.id

    let result = await database.returnAddChiTietDonThuoc()
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
            listDonThuoc: result.recordset
        }
    })
}

async function getLoaiThuoc(req,res)
{
    let tenthuoc = req.params.tenthuoc

    let result = await database.returnLoaiThuoc(tenthuoc)
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
            listDonThuoc: result.recordset
        }
    })
}
module.exports={getAllDonThuoc, 
    getDonThuoc, 
    addLoaiThuoc, 
    updateLoaiThuoc,
    getChiTietDonThuoc,
    
    addDonThuoc,
    deleteDonThuoc,
    addChiTietDonThuoc,
    getLoaiThuoc,
    getDonThuocNgay}