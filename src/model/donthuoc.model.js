const sql = require ('mssql');
// const request = new sql.Request()

async function returnAllDonThuoc()
{
    // request.input('IDDIEUTRI', '1')
    // .input('TONGGIA',1000)
    // const listDonThuoc = await request.execute(`xemkehoachdieutri`);
    // // const listDonThuoc = await request.query `select * from dbo.xembang()`
    // // console.log(listDonThuoc.recordsets)
    // // console.log("-------------------")
    // return listDonThuoc
    const listDonThuoc = await request.execute(`SP_XEMDANHSACHTHUOC`)
    return listDonThuoc
}

async function returnDonThuoc(id)
{
    request.input('IDBENHNHAN', id)
    const listDonThuoc = await request.execute('SP_XEMDANHSACHDONTHUOCBN')
    return listDonThuoc
}

async function returnChiTietDonThuoc(id)
{
    const request = new sql.Request()
    request.input('IDDONTHUOC', id)
    const chitietdonthuoc = await request.execute(`SP_XEMCHITIETDONTHUOC`)
    return chitietdonthuoc
}

async function returnDonThuocNgay(date)
{
    request.input('NGAY', date)
    const listDonThuoc = await request.execute(`SP_XEMDANHSACHTHUOCNGAY`)
    return listDonThuoc
}

async function returnAddLoaiThuoc(idthuoc, tenthuoc, thanhphan, donvitinh, giathuoc)
{
    request.input('IDTHUOC', idthuoc)
    .input('TENTHUOC', tenthuoc)
    .input('THANHPHAN', thanhphan)
    .input('DONVITINH', donvitinh)
    .input('GIATHUOC', giathuoc)

    const isSuccess = await request.execute(`SP_THEM1LOAITHUOC`)
    if (isSuccess != 1 && isSuccess != 2)
    {
        
        return true
    }
    
    return false
}

async function returnUpdateLoaiThuoc(idthuoc, tenthuoc, thanhphan, donvitinh, giathuoc)
{
    request.input('IDTHUOC', idthuoc)
    .input('TENTHUOC', tenthuoc)
    .input('THANHPHAN', thanhphan)
    .input('DONVITINH', donvitinh)
    .input('GIATHUOC', giathuoc)

    const isSuccess = await request.execute(`SP_CAPNHAT1LOAITHUOC`)
    if (isSuccess != 1 && isSuccess != 2)
    {
        
        return true
    }

    return false
}

async function returnAddDonThuoc(iddonthuoc, ngaycap, idbuoidieutri)
{
    request.input('IDDONTHUOC', iddonthuoc)
    .input('NGAYCAP', ngaycap)
    .input('IDBUOIDIEUTRI', idbuoidieutri)

    const isSuccess = await request.execute(`SP_THEMDONTHUOC`)
    if (isSuccess != 1 && isSuccess != 2)
    {
        
        return true
    }

    return false
}

async function returnDeleteDonThuoc(id)
{
    request.addListener('IDDONTHUOC', id)

    const isSuccess = await request.execute(`SP_XOADONTHUOC`)
    if (isSuccess != 1 && isSuccess != 2)
    {
        
        return true
    }

    return false
}


module.exports={returnAllDonThuoc,
    returnChiTietDonThuoc
}