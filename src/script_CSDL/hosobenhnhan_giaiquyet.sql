﻿--GIẢI QUYẾT UNREPEATABLE READ: XEM TRƯỚC - CẬP NHẬT SAU
-- XEM CHI TIẾT HỒ SƠ BỆNH NHÂN
CREATE OR ALTER PROC xemchitiethosobenhnhan @IDBENHNHAN CHAR(8)
AS 
SET TRAN ISOLATION LEVEL REPEATABLE READ
BEGIN TRAN
	BEGIN TRY
		IF (@IDBENHNHAN IS NULL)
			BEGIN
				PRINT N'KHÔNG TÌM THẤY NGƯỜI DÙNG'
				ROLLBACK TRAN
				RETURN;
			END

			DECLARE @TONGTIENDATRA FLOAT
			SELECT @TONGTIENDATRA = SUM(TONGTIEN)
			FROM HOADON HD
			WHERE HD.IDBENHNHAN = @IDBENHNHAN
			GROUP BY HD.IDBENHNHAN

			DECLARE @TONGTIENDIEUTRI FLOAT
			SELECT @TONGTIENDIEUTRI = SUM(BDT.TONGTIEN)
			FROM BUOIDIEUTRI BDT
			WHERE BDT.BNKHAMLE = @IDBENHNHAN
			GROUP BY BDT.BNKHAMLE
			
			IF NOT EXISTS (SELECT BN.IDBENHNHAN
						FROM HOSOBENHNHAN BN
							left JOIN NHANVIEN NV
						ON NV.IDNHANVIEN = BN.BACSIMD 
						WHERE BN.IDBENHNHAN = @IDBENHNHAN)
			BEGIN 
				PRINT N'KHÔNG TỒN TẠI BỆNH NHÂN'
				ROLLBACK TRAN
				RETURN 1
			END

			WAITFOR DELAY '0:0:10'

			SELECT BN.*, NV.TENNV, @TONGTIENDIEUTRI AS TONGTIENDIEUTRI, @TONGTIENDATRA AS TONGTIENDATRA
			FROM HOSOBENHNHAN BN
				left JOIN NHANVIEN NV
			ON NV.IDNHANVIEN = BN.BACSIMD 
			WHERE BN.IDBENHNHAN = @IDBENHNHAN
	END TRY
	BEGIN CATCH
		PRINT N'LỖI HỆ THỐNG'
		ROLLBACK TRAN
		RETURN 1
	END CATCH
COMMIT TRAN
RETURN 0

-- CẬP NHẬT HỒ SƠ BỆNH NHÂN
GO
CREATE OR ALTER PROC capnhathosobenhnhan 
		@IDBENHNHAN CHAR(8), 
		@TENBN NVARCHAR(50),
		@IDPHONGKHAM CHAR(3),
		@NAMSINH DATE,
		@GIOITINH NVARCHAR(3),
		@SDT CHAR(10),
		@EMAIL VARCHAR(50), 
		@DIACHI NVARCHAR(200),
		@MATKHAU VARCHAR(10),
		@BACSIMD CHAR(8),
		@TTTQ NVARCHAR(100),
		@TTDU NVARCHAR(100),
		@THUOCCHONGCD NVARCHAR(30)
AS
BEGIN TRAN
	BEGIN TRY
		IF (@IDBENHNHAN IS NULL)
		BEGIN
			PRINT N'THIẾU TRƯỜNG THÔNG TIN'
			ROLLBACK TRAN
			RETURN 1;
		END
		IF (@TENBN IS NULL)
		BEGIN
			PRINT N'HỌ TÊN BỆNH NHÂN KHÔNG ĐƯỢC ĐỂ TRỐNG'
			ROLLBACK TRAN
			RETURN 1;
		END
		IF (@IDPHONGKHAM IS NULL)
		BEGIN
			PRINT N'ID PHÒNG KHÁM KHÔNG ĐƯỢC ĐỂ TRỐNG'
			ROLLBACK TRAN
			RETURN 1;
		END
		IF (@NAMSINH IS NULL)
		BEGIN
			PRINT N'NĂM SINH KHÔNG ĐƯỢC ĐỂ TRỐNG'
			ROLLBACK TRAN
			RETURN 1;
		END
		IF (@GIOITINH IS NULL)
		BEGIN
			PRINT N'GIỚI TÍNH KHÔNG ĐƯỢC ĐỂ TRỐNG'
			ROLLBACK TRAN
			RETURN 1;
		END
		IF (@SDT IS NULL)
		BEGIN
			PRINT N'SỐ ĐIỆN THOẠI KHÔNG ĐƯỢC ĐỂ TRỐNG'
			ROLLBACK TRAN
			RETURN 6;
		END
		IF (@DIACHI IS NULL)
		BEGIN
			PRINT N'ĐỊA CHỈ KHÔNG ĐƯỢC ĐỂ TRỐNG'
			ROLLBACK TRAN
			RETURN 1;
		END
		UPDATE HOSOBENHNHAN
		SET TENBN = @TENBN, IDPHONGKHAM = @IDPHONGKHAM, NAMSINHBN = @NAMSINH, GIOITINHBN = @GIOITINH, TUOI = YEAR(GETDATE()) - YEAR(@NAMSINH), SODIENTHOAIBN = @SDT,
			EMAIL = @EMAIL, DIACHI = @DIACHI, MATKHAU = @MATKHAU, BACSIMD = @BACSIMD, TTTONGQUAN = @TTTQ, TINHTRANGDIUNG = @TTDU, 
			THUOCCHONGCHIDINH = @THUOCCHONGCD
		WHERE @IDBENHNHAN = IDBENHNHAN
	END TRY
	BEGIN CATCH
		PRINT N'LỖI HỆ THỐNG'
		ROLLBACK TRAN
		RETURN 1
	END CATCH
COMMIT TRAN
RETURN 0


--PHANTOM: giải quyết: xem trước - thêm sau
-- TÌM KIẾM HỒ SƠ BỆNH NHÂN QUA TÊN
GO
CREATE OR ALTER PROC timhosobenhnhanquaten @TEN NVARCHAR(50)
AS
SET TRAN ISOLATION LEVEL SERIALIZABLE
BEGIN TRAN
 	BEGIN TRY
		-- KIỂM TRA
		IF (@TEN IS NULL)
			BEGIN
				PRINT N'KHÔNG CÓ THÔNG TIN TÌM KIẾM'
				ROLLBACK TRAN
				RETURN;
			END
		DECLARE @CNT_BN INT
		SELECT @CNT_BN =COUNT (*)
						FROM HOSOBENHNHAN BN
						WHERE BN.TENBN LIKE '%' + @TEN + '%'
		IF (@CNT_BN = 0)
		BEGIN
			PRINT N'KHÔNG TỒN TẠI BỆNH NHÂN'
			ROLLBACK TRAN
			RETURN 1;
		END

		-- ĐỂ TEST 
		WAITFOR DELAY '0:0:05'

		--THỰC THI
		SELECT * FROM HOSOBENHNHAN BN WHERE BN.TENBN LIKE '%' + @TEN + '%'

	END TRY
	BEGIN CATCH
		PRINT (N'LỖI HỆ THỐNG')
		ROLLBACK TRAN
		RETURN 1
	END CATCH
COMMIT TRAN
RETURN 0

-- THÊM HỒ SƠ BỆNH NHÂN
GO
CREATE OR ALTER PROC themhosobenhnhan 
		@IDBENHNHAN CHAR(8), 
		@TENBN NVARCHAR(50),
		@IDPHONGKHAM CHAR(3),
		@NAMSINH DATE,
		@GIOITINH NVARCHAR(3),
		@SDT CHAR(10),
		@EMAIL VARCHAR(50), 
		@DIACHI NVARCHAR(200),
		@MATKHAU VARCHAR(10),
		@BACSIMD CHAR(8),
		@TTTQ NVARCHAR(100),
		@TTDU NVARCHAR(100),
		@THUOCCHONGCD NVARCHAR(30)
AS 
BEGIN TRAN
	BEGIN TRY
		IF EXISTS (SELECT 1 FROM HOSOBENHNHAN WHERE @SDT = SODIENTHOAIBN)
			BEGIN
				PRINT N'SỐ ĐIỆN THOẠI ĐÃ TỒN TẠI';
				ROLLBACK TRAN;
				RETURN;
			END
			IF (@IDBENHNHAN IS NULL)
			BEGIN
				PRINT N'THIẾU TRƯỜNG ID BỆNH NHÂN'
				ROLLBACK TRAN
				RETURN;
			END
			IF (@TENBN IS NULL)
			BEGIN
				PRINT N'HỌ TÊN BỆNH NHÂN KHÔNG ĐƯỢC ĐỂ TRỐNG'
				ROLLBACK TRAN
				RETURN;
			END
			IF (@IDPHONGKHAM IS NULL)
			BEGIN
				PRINT N'ID PHÒNG KHÁM KHÔNG ĐƯỢC ĐỂ TRỐNG'
				ROLLBACK TRAN
				RETURN;
			END
			IF (@NAMSINH IS NULL)
			BEGIN
				PRINT N'NĂM SINH KHÔNG ĐƯỢC ĐỂ TRỐNG'
				ROLLBACK TRAN
				RETURN;
			END
			IF (@GIOITINH IS NULL)
			BEGIN
				PRINT N'GIỚI TÍNH KHÔNG ĐƯỢC ĐỂ TRỐNG'
				ROLLBACK TRAN
				RETURN;
			END
			IF (@SDT IS NULL)
			BEGIN
				PRINT N'SỐ ĐIỆN THOẠI KHÔNG ĐƯỢC ĐỂ TRỐNG'
				ROLLBACK TRAN
				RETURN;
			END
			IF (@DIACHI IS NULL)
			BEGIN
				PRINT N'ĐỊA CHỈ KHÔNG ĐƯỢC ĐỂ TRỐNG'
				ROLLBACK TRAN
				RETURN;
			END
			IF EXISTS (SELECT 1 FROM HOSOBENHNHAN WHERE IDBENHNHAN = @IDBENHNHAN)
			BEGIN
				PRINT N'BỆNH NHÂN TỒN TẠI';
				ROLLBACK;
				RETURN;
			END
			ELSE
			BEGIN
				DECLARE @TUOI INT
				SET @TUOI = YEAR(GETDATE()) - YEAR(@NAMSINH)
				INSERT QLPK_CSDL.dbo.HOSOBENHNHAN(IDBENHNHAN, TENBN, IDPHONGKHAM, NAMSINHBN, GIOITINHBN, TUOI, SODIENTHOAIBN, EMAIL, DIACHI, MATKHAU, BACSIMD, TTTONGQUAN, TINHTRANGDIUNG, THUOCCHONGCHIDINH) 
				VALUES (@IDBENHNHAN, @TENBN, @IDPHONGKHAM, @NAMSINH, @GIOITINH, @TUOI, @SDT, @EMAIL, @DIACHI, @MATKHAU, @BACSIMD, @TTDU, @TTDU, @THUOCCHONGCD)
			END
	END TRY
	BEGIN CATCH
		PRINT N'LỖI HỆ THỐNG'
		ROLLBACK TRAN
		RETURN 1
	END CATCH
COMMIT TRAN
RETURN 0