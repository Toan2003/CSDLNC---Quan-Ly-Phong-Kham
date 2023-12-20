﻿USE QLPK_CSDL
GO
--XEM TẤT CẢ LOẠI ÐIỀU TRỊ
--RETURN TABLE: MÃ DANH MỤC, TÊN DANH MỤC, MÃ ÐIỀU TRỊ, TÊN ÐIỀU TRỊ
CREATE FUNCTION LAYTATCADIEUTRI()
RETURNS TABLE
AS
	RETURN (SELECT LDT.MADANHMUC , DM.TENDM , LDT.MADIEUTRI , LDT.TENDIEUTRI  
			FROM LOAIDIEUTRI LDT JOIN DANHMUCDIEUTRI DM ON LDT.MADANHMUC = DM.MADANHMUC)
GO

--LẤY DANH SÁCH BUỔI ĐIỀU TRỊ THEO BỆNH NHÂN VÀ SẮP XẾP THEO NGÀY
CREATE OR ALTER PROC LAYBUOIDT_BN
	@MABENHNHAN CHAR(8)
AS
BEGIN TRAN
	BEGIN TRY
		--KIỂM TRA ÐIỀU KIỆN
		--IF NOT EXISTS (SELECT HSBN.IDBENHNHAN
		--				FROM HOSOBENHNHAN HSBN
		--				WHERE HSBN.IDBENHNHAN = @MABENHNHAN)
		--	BEGIN
		--		PRINT N'KHÔNG TÌM THẤY BỆNH NHÂN'
		--		ROLLBACK TRAN
		--		RETURN 1
		--	END
		--THỰC THI
		SELECT *
		FROM BUOIDIEUTRI BDT 
		WHERE BDT.BNKHAMLE = @MABENHNHAN
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

--EXEC LAYBUOIDT_BN 'BN030190'

--LẤY DANH SÁCH BUỔI ĐIỀU TRỊ TỪ NGÀY A->B
CREATE OR ALTER PROC LAYBUOIDT_NGAY
	@DATEA DATE,
	@DATEB DATE
AS
BEGIN TRAN
	BEGIN TRY
		--KIỂM TRA ÐIỀU KIỆN
		IF @DATEA > @DATEB
		BEGIN
			DECLARE @TEMP DATE
			SET @TEMP = @DATEA
			SET @DATEA = @DATEB
			SET @DATEB = @TEMP
		END
		PRINT @DATEA
		PRINT @DATEB
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

EXEC LAYBUOIDT_NGAY '2023-11-1','2023-12-1'

--HÀM TRỢ GIÚP LẤY BÁC SĨ CHÍNH
--CREATE FUNCTION LAYKHAMCHINH 
--	(@IDBUOIDIEUTRI CHAR(10))
--RETURNS TABLE
--AS
--	RETURN (SELECT BDT.IDBUOIDIEUTRI, NV.TENNV KHAMCHINH
--			FROM BUOIDIEUTRI BDT 
--				JOIN NHANVIEN NV ON BDT.KHAMCHINH = NV.IDNHANVIEN
--			WHERE BDT.IDBUOIDIEUTRI = @IDBUOIDIEUTRI)
--GO

--HÀM TRỢ GIÚP LẤY TRỢ KHÁM
--CREATE FUNCTION LAYTROKHAM
--	(@IDBUOIDIEUTRI CHAR(10))
--RETURNS TABLE
--AS
--	RETURN (SELECT BDT.IDBUOIDIEUTRI, NV.TENNV TROKHAM
--			FROM BUOIDIEUTRI BDT 
--			JOIN NHANVIEN NV ON BDT.TROKHAM = NV.IDNHANVIEN
--			WHERE BDT.IDBUOIDIEUTRI = @IDBUOIDIEUTRI)
--GO

GO
--XEM THÔNG TIN CHI TIẾT CỦA 1 BUỔI ÐIỀU TRỊ
CREATE OR ALTER PROC XEMCHITIETBDT
	@IDBUOIDIEUTRI CHAR(10)
AS
BEGIN TRAN
	BEGIN TRY
		--KIỂM TRA ÐIỀU KIỆN
		IF (@IDBUOIDIEUTRI IS NULL)
			BEGIN 
				PRINT N'THIẾU TRƯỜNG CẦN THIẾT'
				ROLLBACK TRAN
				RETURN 1
			END
		--THỰC THI
		--LẤY THÔNG TIN TỔNG QUAN
		--SELECT BDT.IDBUOIDIEUTRI, BDT.KEHOACHDT, BDT.NGAYDT, BDT.MOTABDT, BDT.GHICHUBDT, 
		--	KHAMCHINH.IDNHANVIEN N'KHAMCHINH_ID', KHAMCHINH.TENNV N'KHAMCHINH_HT',TROKHAM.IDNHANVIEN N'TROKHAM_ID', TROKHAM.TENNV N'TROKHAM_HT'
		--FROM BUOIDIEUTRI BDT 
		--	JOIN NHANVIEN KHAMCHINH ON BDT.KHAMCHINH = KHAMCHINH.IDNHANVIEN
		--	JOIN NHANVIEN TROKHAM ON BDT.TROKHAM = TROKHAM.IDNHANVIEN
		--	--GIÁ
		--	--JOIN (SELECT BDT.IDBUOIDIEUTRI, SUM(LDT.GIA) GIA
		--	--		FROM BUOIDIEUTRI BDT 
		--	--			JOIN CHITIETDIEUTRI CTDT ON BDT.IDBUOIDIEUTRI = CTDT.IDBUOIDIEUTRI
		--	--			JOIN LOAIDIEUTRI LDT ON LDT.MADIEUTRI = CTDT.MADIEUTRI
		--	--		WHERE BDT.IDBUOIDIEUTRI = @IDBUOIDIEUTRI
		--	--		GROUP BY BDT.IDBUOIDIEUTRI) R1 ON BDT.IDBUOIDIEUTRI = R1.IDBUOIDIEUTRI
		--WHERE BDT.IDBUOIDIEUTRI = @IDBUOIDIEUTRI
		SELECT BDT.IDBUOIDIEUTRI, BDT.KEHOACHDT, BDT.NGAYDT, BDT.MOTABDT, BDT.GHICHUBDT, 
			BSCHINH.IDNHANVIEN N'KHAMCHINH_ID', BSCHINH.TENNV N'KHAMCHINH_HT',TROKHAM.IDNHANVIEN N'TROKHAM_ID', TROKHAM.TENNV N'TROKHAM_HT',
			DT.IDDONTHUOC,
			BN.IDBENHNHAN, BN.TENBN
		FROM BUOIDIEUTRI BDT
			left JOIN NHANVIEN BSCHINH ON BDT.KHAMCHINH = BSCHINH.IDNHANVIEN
			left JOIN NHANVIEN TROKHAM ON BDT.TROKHAM = TROKHAM.IDNHANVIEN
			left JOIN DONTHUOC DT ON DT.IDBUOIDIEUTRI = BDT.IDBUOIDIEUTRI
			left JOIN HOSOBENHNHAN BN ON BDT.BNKHAMLE = BN.IDBENHNHAN
		WHERE BDT.IDBUOIDIEUTRI = @IDBUOIDIEUTRI

		
		--LẤY THÔNG TIN CHI TIẾT
		SELECT CTDT.MADIEUTRI, LDT.TENDIEUTRI, CTRDT.TENRANG, CTRDT.MATDIEUTRI
		FROM  BUOIDIEUTRI BDT
			left JOIN CHITIETDIEUTRI CTDT ON BDT.IDBUOIDIEUTRI = CTDT.IDBUOIDIEUTRI
			left JOIN LOAIDIEUTRI LDT ON CTDT.MADIEUTRI = LDT.MADIEUTRI
			left JOIN CHITIETRANGDIEUTRI CTRDT ON CTDT.MADIEUTRI = CTRDT.MADIEUTRI AND CTDT.IDBUOIDIEUTRI = CTRDT.IDBUOIDIEUTRI
		WHERE BDT.IDBUOIDIEUTRI = @IDBUOIDIEUTRI

	END TRY
	BEGIN CATCH
		PRINT N'LỖI HỆ THỐNG'
		ROLLBACK TRAN
		RETURN 1
	END CATCH
COMMIT TRAN
RETURN 0
GO

EXEC XEMCHITIETBDT 'BDT0000001'

GO
--XEM CHI TIẾT KẾ HOẠCH ĐIỀU TRỊ
CREATE OR ALTER PROC XEMCHITIETKH
	@IDDIEUTRI CHAR(10)
AS
BEGIN TRAN
	BEGIN TRY
		--KIỂM TRA ÐIỀU KIỆN
		IF (@IDDIEUTRI IS NULL)
			BEGIN 
				PRINT N'THIẾU TRƯỜNG CẦN THIẾT'
				ROLLBACK TRAN
				RETURN 1
			END
		--THỰC THI
		--LẤY THÔNG TIN TỔNG QUAN
		SELECT KH.*,BN.TENBN, NV.TENNV
		FROM KEHOACHDIEUTRI KH 
		JOIN HOSOBENHNHAN BN ON KH.BENHNHAN = BN.IDBENHNHAN
		JOIN NHANVIEN NV ON NV.IDNHANVIEN = KH.BSPHUTRACH
		WHERE KH.IDDIEUTRI = @IDDIEUTRI
		
		--LẤY DANH SÁCH CÁC BUỔI ĐIỀU TRỊ THUỘC KẾ HOẠCH
		SELECT *
		FROM BUOIDIEUTRI BDT 
		WHERE BDT.KEHOACHDT = @IDDIEUTRI
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

--EXEC XEMCHITIETKH KH00000001

--THÊM KẾ HOẠCH ĐIỀU TRỊ
CREATE OR ALTER PROC THEMKEHOACH
	@IDDIEUTRI CHAR(10),
	@MOTAKHDT NVARCHAR(100),
	@TRANGTHAI NCHAR(10),
	@GHICHUKHDT NVARCHAR(100),
	@BENHNHAN CHAR(8),
	@BSPHUTRACH CHAR(8)
AS
BEGIN TRAN
	BEGIN TRY
		--KIỂM TRA ÐIỀU KIỆN
		IF (@IDDIEUTRI IS NULL OR @BENHNHAN IS NULL OR @BSPHUTRACH IS NULL OR @TRANGTHAI IS NULL)
			BEGIN 
				PRINT N'THIẾU TRƯỜNG CẦN THIẾT'
				ROLLBACK TRAN
				RETURN 1
			END
		--THỰC THI
		INSERT KEHOACHDIEUTRI(IDDIEUTRI,MOTAKHDT,TRANGTHAI,GHICHUKHDT,BENHNHAN,BSPHUTRACH)
		VALUES
			( @IDDIEUTRI,@MOTAKHDT,@TRANGTHAI, @GHICHUKHDT, @BENHNHAN, @BSPHUTRACH)
	END TRY
	BEGIN CATCH
		PRINT N'LỖI HỆ THỐNG'
		ROLLBACK TRAN
		RETURN 1
	END CATCH
COMMIT TRAN
RETURN 0
GO

--THÊM BUỔI ĐIỀU TRỊ
--THÊM 1 BUỔI ÐIỀU TRỊ - THÔNG TIN TỔNG QUAN
CREATE OR ALTER PROC THEMBUOIDT
	@MABENHNHAN CHAR(8), 
	@IDBUOIDIEUTRI CHAR(10), 
	@MOTA NVARCHAR(100),
	@GHICHU NVARCHAR(100),
	@NGAY DATE,
	@KHAMCHINH CHAR(8),
	@TROKHAM CHAR(8),
	@KEHOACH CHAR(10)
AS
BEGIN TRAN
	BEGIN TRY
		--KIỂM TRA ÐIỀU KIỆN
		IF (@MABENHNHAN IS NULL) OR
			(@IDBUOIDIEUTRI IS NULL) OR
			(@NGAY IS NULL) OR
			(@KHAMCHINH IS NULL) OR
			(@TROKHAM IS NULL)
			BEGIN 
				PRINT N'THIẾU TRƯỜNG CẦN THIẾT'
				ROLLBACK TRAN
				RETURN 1
			END
		IF (@KHAMCHINH = @TROKHAM)
			BEGIN
				PRINT N'KHÁM CHÍNH KO ÐUỢC GIỐNG TRỢ KHÁM'
				ROLLBACK TRAN
				RETURN 1
			END
		--THỰC THI
		INSERT BUOIDIEUTRI (IDBUOIDIEUTRI, BNKHAMLE, MOTABDT, GHICHUBDT, NGAYDT, KHAMCHINH, TROKHAM, KEHOACHDT)
		VALUES 
			(@IDBUOIDIEUTRI, @MABENHNHAN, @MOTA, @GHICHU, @NGAY, @KHAMCHINH, @TROKHAM, @KEHOACH)
	END TRY
	BEGIN CATCH
		PRINT N'LỖI HỆ THỐNG'
		ROLLBACK TRAN
		RETURN 1
	END CATCH
COMMIT TRAN
RETURN 0
GO

--THÊM CHI TIẾT BUỔI ÐIỀU TRỊ
CREATE OR ALTER PROC THEMCHITIETDT
	@MADIEUTRI CHAR(5),
	@IDBUOIDIEUTRI CHAR(10)
AS
BEGIN TRAN
	BEGIN TRY
		--KIỂM TRA ÐIỀU KIỆN
		IF (@MADIEUTRI IS NULL) OR (@IDBUOIDIEUTRI IS NULL)
			BEGIN 
				PRINT N'THIẾU TRƯỜNG CẦN THIẾT'
				ROLLBACK TRAN
				RETURN 1
			END

		DECLARE @NGAY1 DATE;
		(SELECT @NGAY1 = NGAYDT FROM BUOIDIEUTRI BDT WHERE BDT.IDBUOIDIEUTRI = @IDBUOIDIEUTRI)
		IF (@NGAY1 < GETDATE()) 
			BEGIN 
				PRINT N'BUỔI ĐIỀU TRỊ ĐÃ XẢY RA KHÔNG THỂ CHỈNH SỬA';
				ROLLBACK TRAN
				RETURN 1
			END

		--THỰC THI
		INSERT CHITIETDIEUTRI(MADIEUTRI,IDBUOIDIEUTRI)
		VALUES
			(@MADIEUTRI, @IDBUOIDIEUTRI)
	END TRY
	BEGIN CATCH
		PRINT N'LỖI HỆ THỐNG'
		ROLLBACK TRAN
		RETURN 1
	END CATCH
COMMIT TRAN
RETURN 0
GO

--THÊM THÔNG TIN RĂNG ĐIỀU TRỊ
CREATE OR ALTER PROC THEMRANGDT
	@MADIEUTRI CHAR(5),
	@IDBUOIDIEUTRI CHAR(10),
	@TENRANG NCHAR(20),
	@MATDIEUTRI CHAR(1)
AS
BEGIN TRAN
	BEGIN TRY
		--KIỂM TRA ÐIỀU KIỆN
		IF (@MADIEUTRI IS NULL) OR 
			(@IDBUOIDIEUTRI IS NULL) OR 
			(@TENRANG IS NULL) OR
			(@MATDIEUTRI IS NULL)
			BEGIN 
				PRINT N'THIẾU TRƯỜNG CẦN THIẾT'
				ROLLBACK TRAN
				RETURN 1
			END

		DECLARE @NGAY1 DATE;
		(SELECT @NGAY1 = NGAYDT FROM BUOIDIEUTRI BDT WHERE BDT.IDBUOIDIEUTRI = @IDBUOIDIEUTRI)
		IF (@NGAY1 < GETDATE()) 
			BEGIN 
				PRINT N'BUỔI ĐIỀU TRỊ ĐÃ XẢY RA KHÔNG THỂ CHỈNH SỬA';
				ROLLBACK TRAN
				RETURN 1
			END

		--THỰC THI
		INSERT CHITIETRANGDIEUTRI(MADIEUTRI,IDBUOIDIEUTRI, TENRANG, MATDIEUTRI)
		VALUES
			(@MADIEUTRI, @IDBUOIDIEUTRI, @TENRANG, @MATDIEUTRI)
	END TRY
	BEGIN CATCH
		PRINT N'LỖI HỆ THỐNG'
		ROLLBACK TRAN
		RETURN 1
	END CATCH
COMMIT TRAN
RETURN 0
GO

--XÓA BUỔI ĐIỀU TRỊ
--XÓA BUỔI ĐIỀU TRỊ - NẾU MÀ NGÀY ĐIỀU TRỊ CHƯA XẢY RA
CREATE OR ALTER PROC XOABUOIDT
	@IDBUOIDIEUTRI CHAR(10)
AS
BEGIN TRAN
	BEGIN TRY
		--KIỂM TRA ÐIỀU KIỆN
		IF (@IDBUOIDIEUTRI IS NULL)
			BEGIN 
				PRINT N'THIẾU TRƯỜNG CẦN THIẾT'
				ROLLBACK TRAN
				RETURN 1
			END
		
		DECLARE @NGAY1 DATE = NULL;
		(SELECT @NGAY1 = NGAYDT FROM BUOIDIEUTRI BDT WHERE BDT.IDBUOIDIEUTRI = @IDBUOIDIEUTRI)
		IF (@NGAY1 IS NULL)
			BEGIN
				PRINT N'BUỔI ĐIỀU TRỊ KHÔNG TỒN TẠI';
				ROLLBACK TRAN
				RETURN 1	
			END

		IF (@NGAY1 < GETDATE()) 
			BEGIN 
				PRINT N'BUỔI ĐIỀU TRỊ ĐÃ XẢY RA KHÔNG THỂ XÓA';
				ROLLBACK TRAN
				RETURN 1
			END

		--THỰC THI
		DELETE 
			FROM CHITIETRANGDIEUTRI 
			WHERE IDBUOIDIEUTRI = @IDBUOIDIEUTRI
		DELETE
			FROM CHITIETDIEUTRI
			WHERE IDBUOIDIEUTRI = @IDBUOIDIEUTRI
		DELETE
			FROM BUOIDIEUTRI
			WHERE IDBUOIDIEUTRI = @IDBUOIDIEUTRI
	END TRY
	BEGIN CATCH
		PRINT N'LỖI HỆ THỐNG'
		ROLLBACK TRAN
		RETURN 1
	END CATCH
COMMIT TRAN
RETURN 0
GO

--CHỈNH SỬA BUỔI ĐIỀU TRỊ
--CẬP NHẬT THÔNG TIN TỔNG QUAN BUỔI ÐIỀU TRỊ
CREATE OR ALTER PROC UPDATEBUOIDT
	@MABENHNHAN CHAR(8), 
	@IDBUOIDIEUTRI CHAR(10), 
	@MOTA NVARCHAR(100),
	@GHICHU NVARCHAR(100),
	@NGAY DATE,
	@KHAMCHINH CHAR(8),
	@TROKHAM CHAR(8),
	@KEHOACH CHAR(10)
AS
BEGIN TRAN
	BEGIN TRY
		--KIỂM TRA ÐIỀU KIỆN
		IF (@IDBUOIDIEUTRI IS NULL)
		BEGIN 
			PRINT N'THIẾU TRƯỜNG CẦN THIẾT - IDBUOIDIEUTRI'
			ROLLBACK TRAN
			RETURN 1
		END
		
		DECLARE @NGAY1 DATE;
		(SELECT @NGAY1 = NGAYDT FROM BUOIDIEUTRI BDT WHERE BDT.IDBUOIDIEUTRI = @IDBUOIDIEUTRI)
		IF (@NGAY1 < GETDATE()) 
			BEGIN 
				PRINT N'BUỔI ĐIỀU TRỊ ĐÃ XẢY RA KHÔNG THỂ CHỈNH SỬA';
				ROLLBACK TRAN
				RETURN 1
			END
		--THỰC THI
		UPDATE BUOIDIEUTRI
		SET BNKHAMLE = @MABENHNHAN, MOTABDT = @MOTA, GHICHUBDT = @GHICHU, NGAYDT = @NGAY, KHAMCHINH = @KHAMCHINH, TROKHAM = @TROKHAM, KEHOACHDT = @KEHOACH
		WHERE IDBUOIDIEUTRI = @IDBUOIDIEUTRI

	END TRY
	BEGIN CATCH
		PRINT N'LỖI HỆ THỐNG'
		ROLLBACK TRAN
		RETURN 1
	END CATCH
COMMIT TRAN 
RETURN 0
GO

--XÓA CTDT ĐIỀU TRỊ CŨ THÊM CTDT MỚI
CREATE OR ALTER PROC THEMCHITIETDT
	@MADIEUTRI CHAR(5),
	@IDBUOIDIEUTRI CHAR(10)
AS
BEGIN TRAN
	BEGIN TRY
		--KIỂM TRA ÐIỀU KIỆN
		IF (@MADIEUTRI IS NULL) OR 
			(@IDBUOIDIEUTRI IS NULL)
			BEGIN 
				PRINT N'THIẾU TRƯỜNG CẦN THIẾT'
				ROLLBACK TRAN
				RETURN 1
			END

		DECLARE @NGAY1 DATE;
		(SELECT @NGAY1 = NGAYDT FROM BUOIDIEUTRI BDT WHERE BDT.IDBUOIDIEUTRI = @IDBUOIDIEUTRI)
		IF (@NGAY1 < GETDATE()) 
			BEGIN 
				PRINT N'BUỔI ĐIỀU TRỊ ĐÃ XẢY RA KHÔNG THỂ CHỈNH SỬA';
				ROLLBACK TRAN
				RETURN 1
			END

		--THỰC THI
		DELETE 
			FROM CHITIETRANGDIEUTRI
			WHERE IDBUOIDIEUTRI = @IDBUOIDIEUTRI AND MADIEUTRI = @MADIEUTRI
		DELETE 
			FROM CHITIETDIEUTRI
			WHERE MADIEUTRI = @MADIEUTRI AND IDBUOIDIEUTRI = @IDBUOIDIEUTRI

	END TRY
	BEGIN CATCH
		PRINT N'LỖI HỆ THỐNG'
		ROLLBACK TRAN
		RETURN 1
	END CATCH
COMMIT TRAN
RETURN 0
GO


