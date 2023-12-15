---------Xem danh sach thuoc
CREATE OR ALTER PROC SP_XEMDANHSACHTHUOC
AS
BEGIN TRAN
	BEGIN TRY
		SELECT * FROM THUOC 
	END TRY
	BEGIN CATCH
		SELECT ERROR_MESSAGE() AS ErrorMessage;
		ROLLBACK TRAN
		RETURN 2
	END CATCH
COMMIT TRAN
GO
--EXEC SP_XEMDANHSACHTHUOC
-------them 1 loai thuoc
CREATE OR ALTER PROC SP_THEM1LOAITHUOC 
	@IDTHUOC CHAR(8),
	@TENTHUOC NCHAR(30),
	@THANHPHAN NCHAR(30),
	@DONVITINH NCHAR(10),
	@GIATHUOC FLOAT
AS
BEGIN TRAN
	BEGIN TRY
		IF EXISTS (SELECT * FROM THUOC WHERE IDTHUOC = @IDTHUOC)
		BEGIN
			ROLLBACK TRAN
			RETURN 1
		END
		
		IF (@GIATHUOC <0)
		BEGIN
			ROLLBACK TRAN
			RETURN 1
		END
		INSERT THUOC(IDTHUOC, TENTHUOC, THANHPHAN, DONVITINH, GIATHUOC)
		VALUES (@IDTHUOC, @TENTHUOC, @THANHPHAN, @DONVITINH, @GIATHUOC)
	END TRY
	BEGIN CATCH
		SELECT ERROR_MESSAGE() AS ErrorMessage;
		ROLLBACK TRAN
		RETURN 2
	END CATCH
COMMIT TRAN
GO

EXEC SP_THEM1LOAITHUOC 'DC000060' , 'VITAMINC' , 'C,A,D', N'ống' , 10
go

select * from thuoc where idthuoc = 'DC000059'

go

-----Cap nhat 1 loai thuoc----- (idthuoc, tenthuoc, thanh phan, donvitinh, giathuoc)
CREATE OR ALTER PROC SP_CAPNHAT1LOAITHUOC
	@IDTHUOC CHAR(8),
	@TENTHUOC NCHAR(30) = NULL,
	@THANHPHAN NCHAR(30) = NULL,
	@DONVITINH NCHAR(10) = NULL,
	@GIATHUOC FLOAT = NULL
AS 
BEGIN TRAN
	BEGIN TRY
		IF NOT EXISTS (SELECT IDTHUOC FROM THUOC WHERE IDTHUOC = @IDTHUOC)
		BEGIN
			ROLLBACK TRAN
			RETURN 1
		END
		IF (@GIATHUOC < 0 )
		BEGIN
			ROLLBACK TRAN
			RETURN 1
		END
		UPDATE THUOC
		SET
			TENTHUOC = ISNULL(@TENTHUOC, TENTHUOC),
			THANHPHAN = ISNULL (@THANHPHAN, THANHPHAN),
			DONVITINH = ISNULL (@DONVITINH, DONVITINH),
			GIATHUOC = ISNULL (@GIATHUOC, GIATHUOC)
		WHERE IDTHUOC = @IDTHUOC
		END TRY
	BEGIN CATCH
		SELECT ERROR_MESSAGE() AS ErrorMessage;
		ROLLBACK TRAN
		RETURN 2
	END CATCH
COMMIT TRAN
GO

--EXEC SP_CAPNHAT1LOAITHUOC 'DC000059' , NULL, NULL , NULL , 40
GO

/*
----- Xóa 1 loại thuốc ------
CREATE OR ALTER PROC SP_XOA1LOAITHUOC
	@IDTHUOC CHAR(8)
AS
BEGIN TRAN
	BEGIN TRY
		IF NOT EXISTS (SELECT IDTHUOC FROM THUOC WHERE IDTHUOC = @IDTHUOC)
		BEGIN
			ROLLBACK TRAN
			RETURN 1
		END
		DELETE CHITIETDONTHUOC
		WHERE IDTHUOC = @IDTHUOC
		DELETE THUOC
		WHERE IDTHUOC = @IDTHUOC
		END TRY
	BEGIN CATCH
		SELECT ERROR_MESSAGE() AS ErrorMessage;
		ROLLBACK TRAN
		RETURN 2
	END CATCH
COMMIT TRAN
GO

EXEC SP_XOA1LOAITHUOC 'DC000058'
*/

-----Xem danh sách các đơn thuốc (theo bệnh nhân)

CREATE OR ALTER PROC SP_XEMDANHSACHDONTHUOCBN 
	@IDBENHNHAN CHAR(8)
AS
BEGIN TRAN
	BEGIN TRY
	SELECT DT.IDDONTHUOC, DT.NGAYCAP, DT.IDBUOIDIEUTRI, BN.TENBN, SUM(CT.SOLUONG * T.GIATHUOC) AS 'GIA'
	FROM DONTHUOC DT, CHITIETDONTHUOC CT, THUOC T, BUOIDIEUTRI BDT, HOSOBENHNHAN BN
	WHERE CT.IDTHUOC = T.IDTHUOC AND BDT.BNKHAMLE = @IDBENHNHAN AND BDT.IDBUOIDIEUTRI = DT.IDBUOIDIEUTRI AND DT.IDDONTHUOC = CT.IDDONTHUOC AND BN.IDBENHNHAN=@IDBENHNHAN
	GROUP BY DT.IDDONTHUOC, DT.NGAYCAP, DT.IDBUOIDIEUTRI, BN.TENBN
	END TRY
	BEGIN CATCH
		--SELECT ERROR_MESSAGE() AS ErrorMessage;
		ROLLBACK TRAN
		RETURN 2
	END CATCH
COMMIT TRAN

GO

EXEC SP_XEMDANHSACHDONTHUOCBN 'BN091850'
go

----Xem danh sách đơn thuốc (theo ngày)

-----Xem chi tiết đơn thuốc -----
CREATE OR ALTER PROC SP_XEMCHITIETDONTHUOC 
	@IDDONTHUOC CHAR(12)
AS
BEGIN TRAN
	BEGIN TRY
	DECLARE @TONGGIA FLOAT
	SET @TONGGIA = (SELECT SUM(T.GIATHUOC * CT.SOLUONG) FROM CHITIETDONTHUOC CT JOIN THUOC T ON CT.IDTHUOC = T.IDTHUOC WHERE CT.IDDONTHUOC = @IDDONTHUOC GROUP BY CT.IDDONTHUOC)
	SELECT CT.IDTHUOC , T.TENTHUOC, CT.SOLUONG, T.GIATHUOC * CT.SOLUONG as 'GIA', @TONGGIA 'TONGGIA'
	FROM CHITIETDONTHUOC CT, THUOC T, DONTHUOC D
	WHERE D.IDDONTHUOC = @IDDONTHUOC AND CT.IDDONTHUOC = D.IDDONTHUOC AND T.IDTHUOC = CT.IDTHUOC
	
	END TRY
	BEGIN CATCH
		SELECT ERROR_MESSAGE() AS ErrorMessage;
		ROLLBACK TRAN
		RETURN 2
	END CATCH
COMMIT TRAN
GO

--EXEC SP_XEMCHITIETDONTHUOC 'ÐTBDT0000001'

----THÊM ĐƠN THUỐC
CREATE OR ALTER PROC SP_THEMDONTHUOC 
	@IDDONTHUOC CHAR(12),
	@NGAYCAP DATE,
	@IDBUOIDIEUTRI CHAR(10)
AS
BEGIN TRAN
	BEGIN TRY
	IF NOT EXISTS (SELECT * FROM BUOIDIEUTRI WHERE IDBUOIDIEUTRI=@IDBUOIDIEUTRI)
	BEGIN
		ROLLBACK TRAN
		RETURN 1
	END
	INSERT DONTHUOC (IDDONTHUOC,NGAYCAP,IDBUOIDIEUTRI)
	VALUES (@IDDONTHUOC, @NGAYCAP, @IDBUOIDIEUTRI)
	END TRY
	BEGIN CATCH
		SELECT ERROR_MESSAGE() AS ErrorMessage;
		ROLLBACK TRAN
		RETURN 2
	END CATCH
COMMIT TRAN
GO

/*
EXEC SP_THEMDONTHUOC 'ÐTBDT0100001', '2023-12-14' , 'BDT0100000'
GO

SELECT * FROM DONTHUOC WHERE IDDONTHUOC = 'ÐTBDT0100001'
*/

CREATE OR ALTER PROC SP_THEMCHITIETDONTHUOC 
	@IDTHUOC CHAR(8),
	@IDDONTHUOC CHAR(12),
	@SOLUONG INT
AS
BEGIN TRAN
	BEGIN TRY
	IF NOT EXISTS (SELECT * FROM THUOC WHERE IDTHUOC = @IDTHUOC)
	BEGIN
		ROLLBACK TRAN
		RETURN 1
	END
	IF NOT EXISTS (SELECT * FROM DONTHUOC WHERE IDDONTHUOC = @IDDONTHUOC)
	BEGIN
		ROLLBACK TRAN
		RETURN 1
	END
	INSERT CHITIETDONTHUOC(IDTHUOC, IDDONTHUOC, SOLUONG)
	VALUES (@IDTHUOC, @IDDONTHUOC, @SOLUONG)
	
	--DECLARE @GIA FLOAT
	--DECLARE @GIATHUOC FLOAT
	--SET @GIATHUOC = SELECT GIATHUOC FROM THUOC WHERE IDTHUOC=@IDTHUOC
	--SET @GIA = @SOLUONG * @GIA
	--DECLARE @TONGGIA FLOAT
	--SET @TONGGIA = SELECT TONGGIA FROM BUOIDIEUTRI WHERE IDBUOIDIEUTRI=@IDBUOIDIEUTRI
	--SET @TONGGIA = @TONGGIA + @GIA
	--UPDATE BUOIDIEUTRI
	--SET TONGGIA = @TONGGIA
	--WHERE IDBUOIDIEUTRI = @IDBUOIDIEUTRI
	--END TRY
	
	END TRY
	BEGIN CATCH
		SELECT ERROR_MESSAGE() AS ErrorMessage;
		ROLLBACK TRAN
		RETURN 2
	END CATCH
COMMIT TRAN
GO

/*
EXEC SP_THEMCHITIETDONTHUOC 'DC000001' , 'ÐTBDT0100001', 5
GO

SELECT * FROM CHITIETDONTHUOC WHERE IDDONTHUOC='ÐTBDT0100001'
*/

CREATE OR ALTER PROC SP_XOADONTHUOC
	@IDDONTHUOC CHAR(12)
AS
BEGIN TRAN
	BEGIN TRY
	IF NOT EXISTS (SELECT * FROM DONTHUOC WHERE IDDONTHUOC = @IDDONTHUOC)
	BEGIN
		ROLLBACK TRAN
		RETURN 1
	END
	DECLARE @IDBUOIDIEUTRI char(10)
	SET @IDBUOIDIEUTRI = (SELECT IDBUOIDIEUTRI FROM DONTHUOC WHERE IDDONTHUOC = @IDDONTHUOC)

	IF EXISTS (SELECT * FROM HOADON WHERE IDBUOIDIEUTRI = @IDBUOIDIEUTRI)
	BEGIN 
		PRINT 'DON THUOC DA THANH TOAN KHONG THE XOA'
		ROLLBACK TRAN
		RETURN 1
	END
/*
	DECLARE @TONGDONTHUOC FLOAT
	SET @TONGDONTHUOC = (SELECT SUM(CT.GIATHUOC * T.SOLUONG) FROM THUOC T JOIN CHITIETDONTHUOC CT ON CT.IDTHUOC = T.IDTHUOC WHERE CT.IDDONTHUOC = @IDDONTHUOC GROUP BY CT.IDDONTHUOC)

	UPDATE BUOIDIEUTRI
	SET TONGGIA = TONGGIA - @TONGDONTHUOC
	WHERE IDBUOIDIEUTRI = @IDBUOIDIEUTRI
*/
	DELETE CHITIETDONTHUOC
	WHERE IDDONTHUOC = @IDDONTHUOC
	
	DELETE DONTHUOC
	WHERE IDDONTHUOC = @IDDONTHUOC

	END TRY
	BEGIN CATCH
		SELECT ERROR_MESSAGE() AS ErrorMessage;
		ROLLBACK TRAN
		RETURN 2
	END CATCH
COMMIT TRAN
GO

--EXEC SP_XOADONTHUOC 'ÐTBDT0100001'

CREATE OR ALTER PROC SP_THEMHOADON 
	@IDHOADON CHAR(15),
	@TIENDATRA FLOAT,
	@LOAITHANHTOAN NVARCHAR(12),
	@GHICHUHOADON NVARCHAR(100),
	@NGAYGIAODICH DATE,
	@IDBENHNHAN CHAR(8),
	@IDBUOIDIEUTRI CHAR(10)
AS
BEGIN TRAN
	BEGIN TRY
		IF EXISTS (SELECT * FROM HOADON WHERE IDHOADON=@IDHOADON)
		BEGIN
			ROLLBACK TRAN
			RETURN 1
		END
		/*
		DECLARE @TONGTIEN FLOAT
		SET @TONGTIEN = (SELECT TONGGIA FROM BUOIDIEUTRI WHERE IDBUOIDIEUTRI = @IDBUOIDIEUTRI )
		INSERT HOADON (IDHOADON, TONGTIEN, TIENDATRA, LOAITHANHTOAN, GHICHUHOADON, NGAYGIAODICH)
		VALUES (@IDHOADON, @TONGTIEN, @TIENDATRA, @LOAITHANHTOAN, @GHICHUHOADON, @NGAYGIAODICH)
		*/

		DECLARE @TONGTIEN FLOAT
		SET @TONGTIEN = (SELECT SUM(LDT.GIA) FROM LOAIDIEUTRI LDT JOIN CHITIETDIEUTRI CT ON LDT.MADIEUTRI = CT.MADIEUTRI
		WHERE CT.IDBUOIDIEUTRI = @IDBUOIDIEUTRI
		GROUP BY CT.IDBUOIDIEUTRI)
		SET @TONGTIEN = @TONGTIEN + (SELECT SUM(T.GIATHUOC * CTDT.SOLUONG) FROM 
		 DONTHUOC DT 
		JOIN CHITIETDONTHUOC CTDT ON CTDT.IDDONTHUOC = DT.IDDONTHUOC
		JOIN THUOC T ON T.IDTHUOC = CTDT.IDTHUOC
		WHERE DT.IDBUOIDIEUTRI=@IDBUOIDIEUTRI
		GROUP BY DT.IDBUOIDIEUTRI)

		INSERT HOADON (IDHOADON, TONGTIEN, TIENDATRA, LOAITHANHTOAN, GHICHUHOADON, NGAYGIAODICH, IDBENHNHAN, IDBUOIDIEUTRI)
		VALUES (@IDHOADON, @TONGTIEN, @TIENDATRA, @LOAITHANHTOAN, @GHICHUHOADON, @NGAYGIAODICH, @IDBENHNHAN, @IDBUOIDIEUTRI)

		SELECT @TONGTIEN
	END TRY
	 
	BEGIN CATCH
		SELECT ERROR_MESSAGE() AS ErrorMessage;
		ROLLBACK TRAN
		RETURN 2
	END CATCH
COMMIT TRAN
GO
/*
EXEC SP_THEMHOADON 'HÐ2023010238243',	658.65,	'ONLINE', 'field commercial law.'	,'2020-01-02',	'BN077799',	'BDT0033941'

SELECT * FROM HOADON WHERE IDHOADON='HÐ2023010238243'
SELECT * FROM HOADON WHERE IDHOADON = 'HÐ2020010238243'

SELECT * FROM HOADON WHERE IDBUOIDIEUTRI = 'BDT0033941'

*/

CREATE OR ALTER PROC SP_XEMDANHSACHHOADONBN
	@IDBENHNHAN CHAR(8)
	
AS
BEGIN TRAN
	BEGIN TRY
		IF NOT EXISTS (SELECT * FROM HOSOBENHNHAN WHERE IDBENHNHAN=@IDBENHNHAN)
		BEGIN
			ROLLBACK TRAN
			RETURN 1
		END
		
		SELECT HD.IDHOADON, HD.TONGTIEN, HD.NGAYGIAODICH, HD.GHICHUHOADON, BN.TENBN, HD.IDBUOIDIEUTRI
		FROM HOADON HD JOIN HOSOBENHNHAN BN ON HD.IDBENHNHAN = BN.IDBENHNHAN
		WHERE BN.IDBENHNHAN = @IDBENHNHAN
	END TRY
	 
	BEGIN CATCH
		ROLLBACK TRAN
		RETURN 2
	END CATCH
COMMIT TRAN
GO

--exec sp_xemdanhsachhoadonbn 'BN010554'

CREATE OR ALTER PROC SP_XEMDANHSACHHOADONTHEONGAY
	@NGAY DATE
AS
BEGIN TRAN
	BEGIN TRY
		SELECT IDHOADON, TONGTIEN, NGAYGIAODICH, GHICHU, TENBENHNHAN, IDBUOIDIEUTRI
		FROM HOADON
		WHERE NGAYGIAODICH = @NGAY
	END TRY
	 
	BEGIN CATCH
		ROLLBACK TRAN
		RETURN 2
	END CATCH
COMMIT TRAN
GO
--sao laij xem chi tiet hoa don theo benh nhan ta?

CREATE OR ALTER PROC SP_XEMCHITIETHOADON
	@IDHOADON CHAR(15)
AS
BEGIN TRAN
	BEGIN TRY 
		IF NOT EXISTS (SELECT * FROM HOADON WHERE IDHOADON=@IDHOADON)
		BEGIN
			ROLLBACK TRAN
			RETURN 1
		END
		DECLARE @IDBUOIDIEUTRI CHAR(10)
		SET @IDBUOIDIEUTRI = (SELECT BDT.IDBUOIDIEUTRI FROM HOADON HD JOIN BUOIDIEUTRI BDT ON HD.IDBUOIDIEUTRI = BDT.IDBUOIDIEUTRI 
									WHERE HD.IDHOADON = @IDHOADON)

		--SELECT HD.IDHOADON, HD.TONGTIEN, HD.TIENDATRA, HD.LOAITHANHTOAN, HD.GHICHUHOADON, HD.NGAYGIAODICH, BDT.IDBUOIDIEUTRI, LDT.MADIEUTRI, LDT.TENDIEUTRI, LDT.GIA, T.IDTHUOC, T.TENTHUOC, CT.SOLUONG, T.GIATHUOC * CT.SOLUONG 'GIATHUOC'
		--FROM HOADON HD JOIN BUOIDIEUTRI BDT ON HD.IDBUOIDIEUTRI = BDT.IDBUOIDIEUTRI
		--JOIN CHITIETDIEUTRI CTDT ON CTDT.IDBUOIDIEUTRI = HD.IDBUOIDIEUTRI
		--JOIN LOAIDIEUTRI LDT ON LDT.MADIEUTRI = CTDT.MADIEUTRI
		--JOIN DONTHUOC DT ON DT.IDBUOIDIEUTRI = BDT.IDBUOIDIEUTRI
		--JOIN CHITIETDONTHUOC CT ON CT.IDDONTHUOC = DT.IDDONTHUOC
		--JOIN THUOC T ON T.IDTHUOC=CT.IDTHUOC
		--WHERE HD.IDHOADON = @IDHOADON 
		
		SELECT HD.IDHOADON, HD.TONGTIEN, HD.TIENDATRA, HD.LOAITHANHTOAN, HD.GHICHUHOADON, HD.NGAYGIAODICH
		FROM HOADON HD WHERE HD.IDHOADON = @IDHOADON

		SELECT CTDT.IDBUOIDIEUTRI, LDT.MADIEUTRI, LDT.TENDIEUTRI, LDT.GIA
		FROM CHITIETDIEUTRI CTDT JOIN LOAIDIEUTRI LDT ON CTDT.MADIEUTRI = LDT.MADIEUTRI
		WHERE CTDT.IDBUOIDIEUTRI = @IDBUOIDIEUTRI

		SELECT T.IDTHUOC, T.TENTHUOC, CT.SOLUONG, T.GIATHUOC * CT.SOLUONG 'GIATHUOC'
		FROM DONTHUOC DT JOIN CHITIETDONTHUOC CT ON CT.IDDONTHUOC = DT.IDDONTHUOC
		JOIN THUOC T ON T.IDTHUOC=CT.IDTHUOC
		WHERE DT.IDBUOIDIEUTRI = @IDBUOIDIEUTRI
	END TRY
	BEGIN CATCH
		ROLLBACK TRAN
		RETURN 2
	END CATCH
COMMIT TRAN
GO
--SELECT * FROM CHITIETDIEUTRI WHERE IDBUOIDIEUTRI = 'BDT0030976'

--exec sp_xemchitiethoadon 'HÐ2020010222768'

--Tìm 1 loại thuốc THEO TEN
CREATE OR ALTER PROC SP_TIM1LOAITHUOC
	@TENTHUOC NCHAR(30)
AS
BEGIN TRAN
	BEGIN TRY
	SELECT * FROM THUOC WHERE TENTHUOC = @TENTHUOC
	END TRY
	BEGIN CATCH
		ROLLBACK TRAN
		RETURN 2
	END CATCH
COMMIT TRAN
GO

CREATE OR ALTER PROC LAYBUOIDT_NGAY
	@DATEA DATE,
	@DATEB DATE
AS
BEGIN TRAN
	BEGIN TRY
		--KIỂM TRA ÐIỀU KIỆN
		--THỰC THI
		SELECT *
		FROM BUOIDIEUTRI BDT 
		WHERE BDT.NGAYDT >= @DATEA AND BDT.NGAYDT <= @DATEB
		ORDER BY BDT.NGAYDT DESC
	END TRY
	BEGIN CATCH
		PRINT N'LỖI HỆ THỐNG'
		ROLLBACK TRAN
		RETURN 1
	END CATCH
COMMIT TRAN
RETURN 0
GO

EXEC LAYBUOIDT_NGAY '2023-11-30','2023-12-1'

GO

CREATE OR ALTER PROC SP_MAU 
	@IDBENHNHAN CHAR(10)
AS
BEGIN 
DECLARE @TONGTIENDIEUTRI FLOAT
SELECT @TONGTIENDIEUTRI = SUM(LDT.GIA) + SUM(T.GIATHUOC * CTDON.SOLUONG)
FROM BUOIDIEUTRI BDT
JOIN CHITIETDIEUTRI CTDT ON BDT.IDBUOIDIEUTRI = CTDT.IDBUOIDIEUTRI
JOIN LOAIDIEUTRI LDT ON CTDT.MADIEUTRI = LDT.MADIEUTRI
JOIN DONTHUOC DT ON DT.IDBUOIDIEUTRI = BDT.IDBUOIDIEUTRI
JOIN CHITIETDONTHUOC CTDON ON CTDON.IDDONTHUOC = DT.IDDONTHUOC
JOIN THUOC T ON T.IDTHUOC = CTDON.IDTHUOC
WHERE BDT.BNKHAMLE = @IDBENHNHAN
GROUP BY BDT.BNKHAMLE
SELECT @TONGTIENDIEUTRI

END

GO
CREATE OR ALTER PROC SP_MAU2
	@IDBENHNHAN CHAR(10)
AS
BEGIN
DECLARE @TONGTIENDIEUTRI FLOAT
SET @TONGTIENDIEUTRI = (SELECT SUM(LDT.GIA) FROM LOAIDIEUTRI LDT JOIN CHITIETDIEUTRI CTDT ON LDT.MADIEUTRI = CTDT.MADIEUTRI JOIN BUOIDIEUTRI BDT ON BDT.IDBUOIDIEUTRI = CTDT.IDBUOIDIEUTRI
WHERE BDT.BNKHAMLE = @IDBENHNHAN GROUP BY BDT.BNKHAMLE)

SET @TONGTIENDIEUTRI = @TONGTIENDIEUTRI + (SELECT SUM(CTDT.SOLUONG * T.GIATHUOC) FROM CHITIETDONTHUOC CTDT JOIN THUOC T ON CTDT.IDTHUOC = T.IDTHUOC JOIN DONTHUOC DT ON DT.IDDONTHUOC = CTDT.IDDONTHUOC
JOIN BUOIDIEUTRI BDT ON BDT.IDBUOIDIEUTRI = DT.IDBUOIDIEUTRI WHERE BDT.BNKHAMLE = @IDBENHNHAN GROUP BY BDT.BNKHAMLE)

SELECT @TONGTIENDIEUTRI 
END 

-- EXEC SP_MAU2 

-- SELECT * FROM LOAIDIEUTRI LDT JOIN CHITIETDIEUTRI CTDT ON LDT.MADIEUTRI = CTDT.MADIEUTRI JOIN BUOIDIEUTRI BDT ON BDT.IDBUOIDIEUTRI = CTDT.IDBUOIDIEUTRI WHERE BDT.BNKHAMLE = 'BN000001'

-- SELECT * FROM DONTHUOC DT JOIN CHITIETDONTHUOC CTDT ON DT.IDDONTHUOC = CTDT.IDDONTHUOC JOIN THUOC T ON T.IDTHUOC = CTDT.IDTHUOC JOIN BUOIDIEUTRI BDT ON BDT.IDBUOIDIEUTRI = DT.IDBUOIDIEUTRI
-- WHERE BDT.BNKHAMLE = 'BN000001'

-- EXEC SP_MAU2 'BN000001'
-- EXEC SP_MAU 'BN000001'