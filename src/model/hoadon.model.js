const sql = require ('mssql');
const { generateIDHD} = require('../generateID');

async function returnChiTietHoaDon(idhoadon)     //DA LAM
{
    const request = new sql.Request()
   
    request.input('IDHOADON', idhoadon)
    const listhoadon = await request.execute(`SP_XEMCHITIETHOADON`)
    return listhoadon
}

async function returnHoaDon(id)                     //DA LAM
{
    const request = new sql.Request()
    request.input('IDBENHNHAN', id)
    const listhoadon = await request.execute(`SP_XEMDANHSACHHOADONBN`)
    return listhoadon
}

async function returnAddHoaDon (loaithanhtoan, ghichuhoadon, ngaygiaodich, idbenhnhan, idbuoidieutri)
{
    const request = new sql.Request()
    var idhoadon = await generateIDHD(ngaygiaodich)
    request.input('IDHOADON', idhoadon)
    .input('LOAITHANHTOAN', loaithanhtoan)
    .input('GHICHUHOADON', ghichuhoadon)
    .input('NGAYGIAODICH', ngaygiaodich)
    .input('IDBENHNHAN', idbenhnhan)
    .input('IDBUOIDIEUTRI', idbuoidieutri)
    const isSuccess = await request.execute(`SP_THEMHOADON`)
    console.log(isSuccess)
    return isSuccess.returnValue
}

async function returnHoaDonNgay(date)
{
    const request = new sql.Request()
    request.input('NGAY', sql.Char, date)
    const listHoaDon = await request.execute(`SP_XEMDANHSACHHOADONTHEONGAY`)

    console.log(listHoaDon)
    return listHoaDon
}
module.exports={returnChiTietHoaDon, 
    returnHoaDon,
returnAddHoaDon,
returnHoaDonNgay}
