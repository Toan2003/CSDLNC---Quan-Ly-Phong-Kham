﻿﻿---------------------------------------------------TOOLS
--XEM CLUSTERED INDEX CỦA TỪNG BẢNG
EXEC sp_helpindex 'CHITIETDONTHUOC'

--XEM ĐỀ XUẤT INDEX CỦA DBMS
SELECT * FROM sys.dm_db_missing_index_details

--XÓA PLANCACHE PROCEDURE
EXEC sp_recompile 'SP_XEM_LICH_HEN_BN'

--LICH HEN
--DROP INDEX LICHHEN_NGAYHEN
--ON LICHHEN;

	DROP INDEX LICHHEN_PHONGKHAM_NGAYHEN
	ON LICHHEN;

	DROP INDEX LICHHEN_BENHNHAN_NGAYHEN
	ON LICHHEN;

	DROP INDEX LICHHEN_BACSI_NGAYHEN
	ON LICHHEN;

--ĐIỀU TRỊ
DROP INDEX BDT_NGAY
ON BUOIDIEUTRI;

DROP INDEX BDT_BN_NGAY
ON BUOIDIEUTRI;

DROP INDEX BDT_KH
ON BUOIDIEUTRI;

DROP INDEX KH_BENHNHAN
ON KEHOACHDIEUTRI;

--ĐƠN THUỐC

DROP INDEX DT_BDT
ON DONTHUOC;

--DROP INDEX CTDT_DT
--ON CHITIETDONTHUOC;

--HÓA ĐƠN
DROP INDEX HD_BDT
ON HOADON

DROP INDEX HD_BN
ON HOADON

--HỒ SƠ
DROP INDEX HS_TEN
ON HOSOBENHNHAN

--CHUNG
DROP INDEX HS_ID
ON HOSOBENHNHAN

DROP INDEX NV_ID
ON NHANVIEN

---------------------------------------------------TẠO INDEX
--LỊCH HẸN

CREATE NONCLUSTERED INDEX LICHHEN_BENHNHAN_NGAYHEN
ON LICHHEN (BENHNHAN DESC, NGAYHEN DESC)

CREATE NONCLUSTERED INDEX LICHHEN_PHONGKHAM_NGAYHEN
ON LICHHEN (PHONG DESC, NGAYHEN DESC)

--CREATE NONCLUSTERED INDEX LICHHEN_NGAYHEN
--ON LICHHEN (NGAYHEN DESC)

CREATE NONCLUSTERED INDEX LICHHEN_BACSI_NGAYHEN
ON LICHHEN (NGAYHEN DESC, BACSI DESC, TROKHAM DESC)

--ĐIỀU TRỊ
CREATE NONCLUSTERED INDEX BDT_BN_NGAY
ON BUOIDIEUTRI (BNKHAMLE DESC,NGAYDT DESC)

CREATE NONCLUSTERED INDEX BDT_NGAY
ON BUOIDIEUTRI (NGAYDT DESC)

CREATE NONCLUSTERED INDEX BDT_KH
ON BUOIDIEUTRI ( KEHOACHDT DESC)

CREATE NONCLUSTERED INDEX KH_BENHNHAN
ON KEHOACHDIEUTRI (BENHNHAN DESC)

--ĐƠN THUỐC
CREATE NONCLUSTERED INDEX DT_BDT
ON DONTHUOC (IDBUOIDIEUTRI DESC)

--CREATE NONCLUSTERED INDEX CTDT_DT
--ON CHITIETDONTHUOC (IDDONTHUOC DESC, IDTHUOC DESC)
--DROP INDEX CTDT_DT
--ON CHITIETDONTHUOC
--HÓA ĐƠN
CREATE NONCLUSTERED INDEX HD_BDT
ON HOADON (IDBUOIDIEUTRI DESC)

CREATE NONCLUSTERED INDEX HD_BN
ON HOADON (IDBENHNHAN DESC)

--HỒ SƠ BỆNH NHÂN
CREATE NONCLUSTERED INDEX HS_TEN
ON HOSOBENHNHAN (TENBN DESC)

--chung 
CREATE NONCLUSTERED INDEX HS_ID
ON HOSOBENHNHAN (IDBENHNHAN DESC)
INCLUDE (TENBN)


CREATE NONCLUSTERED INDEX NV_ID
ON NHANVIEN (IDNHANVIEN DESC)
INCLUDE (TENNV)
