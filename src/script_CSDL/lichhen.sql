﻿--FORMAT INPUT: YYYY - MM - DD
-- 1. Xem danh sách lịch hẹn của 1 bệnh nhân theo ngày
CREATE OR ALTER PROC SP_XEM_LICH_HEN_BN
	@ID_BENHNHAN CHAR(8),
	@NGAY DATE
AS
BEGIN TRAN
	BEGIN TRY
		SELECT BN.TENBN, BN.IDBENHNHAN, LH.NGAYHEN, LH.THOIGIANHEN, LH.TINHTRANG, LH.PHONG, LH.GHICHULICHHEN, LH.BACSI, LH.TROKHAM
		FROM LICHHEN LH
		JOIN HOSOBENHNHAN BN ON LH.BENHNHAN = BN.IDBENHNHAN
		WHERE BN.IDBENHNHAN = @ID_BENHNHAN AND LH.NGAYHEN = @NGAY
	END TRY
	BEGIN CATCH
		SELECT ERROR_MESSAGE() AS errormessage
		ROLLBACK TRAN
		RETURN 1
	END CATCH
COMMIT TRAN
RETURN 0
GO

EXEC SP_XEM_LICH_HEN_BN 'BN000006','2022-10-11'
GO

-- 2. Xem danh sách lịch hẹn của phòng khám theo ngày
CREATE OR ALTER PROC SP_XEM_LICH_HEN_PK
	@ID_PHONGKHAM CHAR(3),
	@NGAY DATE
AS
BEGIN TRAN
	BEGIN TRY
		SELECT PK.TENPK, LH.*
		FROM LICHHEN LH
		JOIN PHONGKHAM PK ON LH.PHONG = PK.IDPHONGKHAM
		WHERE PK.IDPHONGKHAM = @ID_PHONGKHAM AND LH.NGAYHEN = @NGAY
	END TRY
	BEGIN CATCH
		SELECT ERROR_MESSAGE() AS errormessage
		ROLLBACK TRAN
		RETURN 1
	END CATCH
COMMIT TRAN
RETURN 0
GO

EXEC SP_XEM_LICH_HEN_PK 'P01','2023-12-09'
GO

-- 3. Xem danh sách lịch hẹn của 1 nha sĩ theo ngày
CREATE OR ALTER PROC SP_XEM_LICH_HEN_NS
	@ID_NHASI CHAR(8),
	@NGAY DATE
AS
BEGIN TRAN
	BEGIN TRY
		SELECT NS.TENNV, NS.IDNHANVIEN, LH.NGAYHEN, LH.THOIGIANHEN, LH.TINHTRANG, LH.PHONG, LH.GHICHULICHHEN, LH.BENHNHAN, LH.TROKHAM
		FROM LICHHEN LH
		JOIN NHANVIEN NS ON LH.BACSI = NS.IDNHANVIEN
		WHERE NS.IDNHANVIEN = @ID_NHASI	AND LH.NGAYHEN = @NGAY
	END TRY
	BEGIN CATCH
		SELECT ERROR_MESSAGE() AS errormessage
		ROLLBACK TRAN
		RETURN 1
	END CATCH
COMMIT TRAN
RETURN 0
GO

EXEC SP_XEM_LICH_HEN_NS 'NS000003','2022-10-11'
GO
-- 4. Thêm lịch hẹn
CREATE OR ALTER PROC SP_THEM_LICH_HEN
	@NGAYHEN DATE,
	@THOIGIANHEN TIME,
	@TINHTRANG NVARCHAR(10),
	@PHONG CHAR(3),
	@GHICHU NVARCHAR(100),
	@BACSI CHAR(8),
	@BENHNHAN CHAR(8),
	@TROKHAM CHAR(8)
AS
BEGIN TRAN
	BEGIN TRY
		-- Kiểm tra ràng buộc thời gian
		IF NOT EXISTS (SELECT * FROM LICHLAMVIEC WHERE IDNHANVIEN = @BACSI AND NGAY = DAY(@NGAYHEN) AND THANG = MONTH(@NGAYHEN) AND NAM = YEAR(@NGAYHEN))
		BEGIN
			RAISERROR(N'Không thể thêm lịch hẹn. Nhân viên không có lịch làm việc cho ngày này.', 16, 1)
			ROLLBACK TRAN
			RETURN
		END

		-- Kiểm tra ràng buộc trùng lặp
		IF EXISTS (SELECT * FROM LICHHEN WHERE NGAYHEN = @NGAYHEN AND THOIGIANHEN = @THOIGIANHEN AND BACSI = @BACSI AND TROKHAM = @TROKHAM AND TINHTRANG = @TINHTRANG)
		BEGIN
			RAISERROR(N'Không thể thêm lịch hẹn. Lịch hẹn trùng lặp.', 16, 1)
			ROLLBACK TRAN
			RETURN
		END

		-- Kiểm tra ràng buộc số lượng lịch hẹn
		IF EXISTS (SELECT * FROM LICHHEN WHERE NGAYHEN = @NGAYHEN AND THOIGIANHEN = @THOIGIANHEN AND BENHNHAN = @BENHNHAN)
		BEGIN
			RAISERROR(N'Không thể thêm lịch hẹn. Bệnh nhân đã có lịch hẹn trong khung giờ này.', 16, 1)
			ROLLBACK TRAN
			RETURN
		END

		-- Kiểm tra tình trạng
		IF @TINHTRANG NOT IN (N'CUỘC HẸN MỚI', N'TÁI KHÁM')
		BEGIN
			PRINT N'TÌNH TRẠNG KHÔNG HỢP LỆ'
			ROLLBACK TRAN
			RETURN 1
		END 

		-- Thêm lịch hẹn
		INSERT INTO LICHHEN (NGAYHEN, THOIGIANHEN, TINHTRANG, PHONG, GHICHULICHHEN, BACSI, BENHNHAN,TROKHAM)
		VALUES (@NGAYHEN, @THOIGIANHEN, @TINHTRANG, @PHONG, @GHICHU, @BACSI, @BENHNHAN, @TROKHAM)
	END TRY
	BEGIN CATCH
		SELECT ERROR_MESSAGE() AS errormessage
		ROLLBACK TRAN
		RETURN 1
	END CATCH
COMMIT TRAN
RETURN 0
GO

-- 5. Xóa 1 lịch hẹn 
CREATE OR ALTER PROC SP_XOA_LICH_HEN
	@NGAYHEN DATE,
	@THOIGIANHEN TIME,
	@BACSI CHAR(8),
	@BENHNHAN CHAR(8)
AS
BEGIN
	BEGIN TRAN
	BEGIN TRY
		-- Kiểm tra sự tồn tại của lịch hẹn
		IF NOT EXISTS (SELECT * FROM LICHHEN WHERE BENHNHAN = @BENHNHAN AND BACSI = @BACSI AND NGAYHEN = @NGAYHEN AND THOIGIANHEN = @THOIGIANHEN)
		BEGIN
			PRINT N'Không tìm thấy lịch hẹn.'
			ROLLBACK TRAN
			RETURN 1
		END

		-- Xóa lịch hẹn
		DELETE FROM LICHHEN WHERE BENHNHAN = @BENHNHAN AND BACSI = @BACSI AND NGAYHEN = @NGAYHEN AND THOIGIANHEN = @THOIGIANHEN

	END TRY
	BEGIN CATCH
		SELECT ERROR_MESSAGE() AS errormessage
		ROLLBACK TRAN
		RETURN 1
	END CATCH
	COMMIT TRAN
	RETURN 0
END
GO

-- 6. Xem danh sách lịch hẹn từ ngày A -> ngày B 
CREATE OR ALTER PROC SP_XEM_LICH_HEN_THEO_NGAY
	@NGAY_A DATE,
	@NGAY_B DATE
AS
BEGIN TRAN
	BEGIN TRY
		IF @NGAY_A > @NGAY_B
		BEGIN
			DECLARE @TEMP DATE
			SET @TEMP = @NGAY_A
			SET @NGAY_A = @NGAY_B
			SET @NGAY_B = @TEMP
		END
		
		-- Xem danh sách lịch hẹn
		SELECT *
		FROM LICHHEN
		WHERE NGAYHEN BETWEEN @NGAY_A AND @NGAY_B OR NGAYHEN = @NGAY_A OR NGAYHEN = @NGAY_B 
		ORDER BY LICHHEN.NGAYHEN DESC, LICHHEN.THOIGIANHEN DESC
	END TRY
	BEGIN CATCH
		SELECT ERROR_MESSAGE() AS errormessage
		ROLLBACK TRAN
		RETURN 1
	END CATCH
COMMIT TRAN
RETURN 0

EXEC SP_XEM_LICH_HEN_THEO_NGAY '2023-12-09','2023-12-01'