const sql = require ('mssql');
const model = require('../model/dieutri.model')

function checkId(id){
    if (id == null) return false
    return true
}

async function getListBDTbyID(req,res){
    let id = req.params.id
    let request = new sql.Request()
    request.input('MABENHNHAN', sql.Char, id);
    
    let result = await request.execute('LAYBUOIDT_BN')
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
            listBDT: result.recordsets[0]
        }
    })
}


async function getListBDTbyDate(req,res){
    let dateA = req.params.dateA
    let dateB = req.params.dateB
    console.log(dateA)
    console.log(dateB)
    if (dateA == null || dateB == null){
        return res.json({
            isSuccess: false,
            message: 'request Failure',
            status: res.statusCode,
            data: ''
        })
    }

    let request = new sql.Request()
    // request.stream = true;

    request.input('DATEA', sql.Char, dateA)
            .input('DATEB',sql.Char, dateB)
    let result = await request.execute('LAYBUOIDT_NGAY',[], {resultSet:true})
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

    // let result = await model.te(dateA,dateB)

    console.log(result)
    return res.json({
        isSuccess: true,
        message: 'request Successfully',
        status: res.statusCode,
        data: {
            listBDT: result.recordset
        }
    })
}

async function getKeHoach(req,res){
    let id = req.params.id
    let request = new sql.Request()
    // request.stream = true;
    // console.log(id)
    request.input('IDDIEUTRI', sql.Char,id )
    let result = await request.execute('XEMCHITIETKH')
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
            kehoach: result.recordsets[0],
            listBDT: result.recordsets[1],
        }
    })
}

async function getBDT(req,res){
    let id = req.params.id
    let request = new sql.Request()
    request.input('IDBUOIDIEUTRI', sql.Char,id )
    let result = await request.execute('XEMCHITIETBDT')
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
    let tongquan = result.recordsets[0]
    let chitiet = result.recordsets[1]
    let chitietrang = result.recordsets[2]
    let rangdieutri;
    for (let ldt  in chitiet) {
        rangdieutri = []
        for (let x in chitietrang){
            if (chitietrang[x].MADIEUTRI == chitiet[ldt].MADIEUTRI){
                let temp = {
                    TENRANG: chitietrang[x].TENRANG,
                    MATDIEUTRI: chitietrang[x].MATDIEUTRI,
                }
                rangdieutri.push(temp)
            }
        }
        chitiet[ldt].RANGDIEUTRI = rangdieutri
    }
    //console.log(result.recordsets[0])
    //console.log(result.recordsets[1])
    return res.json({
        isSuccess: true,
        message: 'request Successfully',
        status: res.statusCode,
        data: {
            tongquan,
            chitiet
        }
    })
}

async function addBDT(req,res){
    let { IDDIEUTRI, 
        MOTAKHDT,
        TRANGTHAI,
        GHICHUKHDT,
        TONGGIA,
        BENHNHAN,
        BSPHUTRACH} = req.body.tongquan

    let request = new sql.Request()
    request.input('IDBUOIDIEUTRI', sql.Char,id )
    .input('IDDIEUTRI',sql.Char, IDDIEUTRI)
    .input('MOTAKHDT', sql.NVarChar, MOTAKHDT)
    .input('TRANGTHAI', sql.NChar, TRANGTHAI)
    .input('GHICHUKHDT', sql.NVarChar, GHICHUKHDT)
    .input('TONGGIA', sql.Float, TONGGIA)
    .input('BENHNHAN', sql.Char, BENHNHAN)
    .input('BSPHUTRACH', sql.Char, BSPHUTRACH)
    let result = await request.execute('XEMCHITIETBDT')
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
            listBDT: result.recordset
        }
    })
}

async function addKeHoach(req,res){
    let { IDDIEUTRI, 
        MOTAKHDT,
        TRANGTHAI,
        GHICHUKHDT,
        TONGGIA,
        BENHNHAN,
        BSPHUTRACH} = req.body
    
    let request = new sql.Request()
    request.input('IDBUOIDIEUTRI', sql.Char,id )
    .input('IDDIEUTRI',sql.Char, IDDIEUTRI)
    .input('MOTAKHDT', sql.NVarChar, MOTAKHDT)
    .input('TRANGTHAI', sql.NChar, TRANGTHAI)
    .input('GHICHUKHDT', sql.NVarChar, GHICHUKHDT)
    .input('TONGGIA', sql.Float, TONGGIA)
    .input('BENHNHAN', sql.Char, BENHNHAN)
    .input('BSPHUTRACH', sql.Char, BSPHUTRACH)
    let result = await request.execute('THEMKEHOACH')
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
        data: ''
    })

}

module.exports = {
    getListBDTbyID,
    getListBDTbyDate,
    getBDT,
    getKeHoach,
    getBDT,
    addBDT,
    addKeHoach,
}