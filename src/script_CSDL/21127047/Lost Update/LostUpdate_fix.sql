﻿-----LOST UPDATE

CREATE OR ALTER PROC THEMCHITIETDT
	@MADIEUTRI CHAR(5),
	@IDBUOIDIEUTRI CHAR(10)
AS
SET TRAN ISOLATION LEVEL REPEATABLE READ
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
		(SELECT @NGAY1 = NGAYDT FROM BUOIDIEUTRI BDT WITH (UPDLOCK) WHERE BDT.IDBUOIDIEUTRI = @IDBUOIDIEUTRI)
		IF (@NGAY1 IS NULL)
			BEGIN
				PRINT N'BUỔI ĐIỀU TRỊ KHÔNG TỒN TẠI';
				ROLLBACK TRAN
				RETURN 1	
			END
		--IF (@NGAY1 < GETDATE()) 
		--	BEGIN 
		--		PRINT N'BUỔI ĐIỀU TRỊ ĐÃ XẢY RA KHÔNG THỂ CHỈNH SỬA';
		--		ROLLBACK TRAN
		--		RETURN 1
		--	END
		DECLARE @TONGTIEN FLOAT
		SELECT @TONGTIEN = TONGTIEN FROM BUOIDIEUTRI WHERE IDBUOIDIEUTRI = @IDBUOIDIEUTRI
		----READ (A)
		DECLARE @TIEN FLOAT
		SELECT @TIEN = GIA
		FROM LOAIDIEUTRI LDT
		WHERE LDT.MADIEUTRI = @MADIEUTRI

		--THỰC THI
		
		 -- DEADLOCK   --lost update
		SET @TONGTIEN = @TONGTIEN + @TIEN
		WAITFOR DELAY '0:0:05'
		UPDATE BUOIDIEUTRI
		SET TONGTIEN = @TONGTIEN 
		WHERE IDBUOIDIEUTRI = @IDBUOIDIEUTRI

		--WAITFOR DELAY '0:0:03' --DIRTY READ

		INSERT CHITIETDIEUTRI(MADIEUTRI,IDBUOIDIEUTRI)
		VALUES
			(@MADIEUTRI, @IDBUOIDIEUTRI)
		SELECT @TONGTIEN
	END TRY
	BEGIN CATCH
		PRINT N'LỖI HỆ THỐNG'
		SELECT ERROR_MESSAGE() AS ErrorMessage;
		ROLLBACK TRAN
		RETURN 1
	END CATCH
COMMIT TRAN
RETURN 0
GO

CREATE OR ALTER PROC SP_XOA1CHITIETDONTHUOC
	@IDDONTHUOC CHAR(12),
	@IDTHUOC CHAR(8)
AS

BEGIN TRAN
BEGIN TRY
		IF NOT EXISTS (SELECT * FROM DONTHUOC WHERE IDDONTHUOC = @IDDONTHUOC)
		BEGIN
			PRINT @IDDONTHUOC + 'KHONG TON TAI'
			ROLLBACK TRAN
			RETURN 1		 
		END
		IF NOT EXISTS (SELECT * FROM THUOC WHERE IDTHUOC = @IDTHUOC)
		BEGIN
			PRINT @IDTHUOC + 'KHONG TON TAI'
			ROLLBACK TRAN
			RETURN 1
		END

		IF NOT EXISTS (SELECT * FROM CHITIETDONTHUOC WHERE IDDONTHUOC = @IDDONTHUOC AND IDTHUOC = @IDTHUOC)
		BEGIN
			PRINT 'IDTHUOC KHONG TON TAI TRONG DON THUOC'
			ROLLBACK TRAN
			RETURN 1
		END
		---- TEST---------------


 		
		DECLARE @IDBUOIDIEUTRI CHAR(10)
		SELECT @IDBUOIDIEUTRI = IDBUOIDIEUTRI FROM DONTHUOC WHERE IDDONTHUOC = @IDDONTHUOC

		IF NOT EXISTS (SELECT * FROM HOADON WHERE IDBUOIDIEUTRI = @IDBUOIDIEUTRI AND NGAYGIAODICH  IS NULL)
		BEGIN
			PRINT 'DON THUOC DA THANH TOAN KHONG THE THEM'
			ROLLBACK TRAN
			RETURN 1
		END
		--SELECT * FROM HOADON WHERE IDBUOIDIEUTRI = @IDBUOIDIEUTRI AND NGAYGIAODICH IS  NULL
		DECLARE @SOLUONG INT
		SELECT @SOLUONG= SOLUONG FROM CHITIETDONTHUOC WHERE IDDONTHUOC = @IDDONTHUOC AND IDTHUOC = @IDTHUOC
		--WAITFOR DELAY '0:0:10'
		DECLARE @TONGTIEN FLOAT
		SELECT @TONGTIEN = TONGTIEN FROM BUOIDIEUTRI WITH (UPDLOCK) WHERE IDBUOIDIEUTRI = @IDBUOIDIEUTRI
		SELECT @TONGTIEN 'TONGTIEN TRC'
		DECLARE @TIEN FLOAT
		SET @TIEN = (SELECT GIATHUOC * @SOLUONG FROM THUOC WHERE IDTHUOC = @IDTHUOC)
		--WAITFOR DELAY '0:0:10'
		SET @TONGTIEN = @TONGTIEN - @TIEN

		UPDATE BUOIDIEUTRI
		SET TONGTIEN = @TONGTIEN
		WHERE IDBUOIDIEUTRI = @IDBUOIDIEUTRI
		
		UPDATE HOADON
		SET TONGTIEN = @TONGTIEN
		WHERE IDBUOIDIEUTRI = @IDBUOIDIEUTRI

	-----ĐỂ TEST
		--WAITFOR DELAY '0:0:20'		 

		DELETE FROM CHITIETDONTHUOC 
		WHERE IDDONTHUOC = @IDDONTHUOC AND IDTHUOC =@IDTHUOC
		SELECT @TONGTIEN 

		--UPDATE CHITIETDONTHUOC
		--SET SOLUONG = 5
		--WHERE IDDONTHUOC = @IDDONTHUOC AND IDTHUOC = @IDTHUOC
	-------

	END TRY
	BEGIN CATCH		PRINT N'LỖI HỆ THỐNG'		SELECT ERROR_MESSAGE() AS ErrorMessage;		ROLLBACK TRAN		RETURN 1	END CATCHCOMMIT TRANRETURN 0
GO