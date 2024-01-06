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

--EXEC SP_XEM_LICH_HEN_BN 'BN005521', '2020-10-04'
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

GO
-- 3. Xem danh sách lịch hẹn của 1 nha sĩ theo ngày
CREATE OR ALTER PROC SP_XEM_LICH_HEN_NS
	@ID_NHASI CHAR(8),
	@NGAY DATE
AS
BEGIN
	BEGIN TRY
		SELECT R.TENNV, R.IDNHANVIEN, R.NGAYHEN, R.THOIGIANHEN, R.TINHTRANG, R.PHONG, R.GHICHULICHHEN, R.BENHNHAN
		FROM (  SELECT NS.TENNV, NS.IDNHANVIEN, LH.*
				FROM LICHHEN LH
				JOIN NHANVIEN NS ON LH.BACSI = NS.IDNHANVIEN OR LH.TROKHAM = NS.IDNHANVIEN
				WHERE 
					LH.NGAYHEN = @NGAY 
					AND (LH.TROKHAM = @ID_NHASI OR LH.BACSI = @ID_NHASI	)) R
		WHERE R.IDNHANVIEN = @ID_NHASI
	END TRY
	BEGIN CATCH
		SELECT ERROR_MESSAGE() AS errormessage
		RETURN 1
	END CATCH
	RETURN 0
END
GO

EXEC SP_XEM_LICH_HEN_NS 'NS000003', '2023-12-09'

GO
EXEC SP_XEM_LICH_HEN_NS 'NS000003','2022-10-11'
GO
-- 4. Thêm lịch hẹn
CREATE OR ALTER PROC SP_THEM_LICH_HEN
	@NGAYHEN DATE,
	@THOIGIANHEN TIME,
	@TINHTRANG NCHAR(15),
	@PHONG CHAR(3),
	@GHICHU NVARCHAR(100),
	@BACSI CHAR(8),
	@BENHNHAN CHAR(8),
	@TROKHAM CHAR(8)
AS
BEGIN TRAN
	BEGIN TRY
		-- Kiểm tra khám chính có tồn tại không
		IF NOT EXISTS (SELECT * FROM NHANVIEN WHERE IDNHANVIEN = @BACSI )
		BEGIN
			RAISERROR(N'Nha sĩ không tồn tại.', 16, 1)
			ROLLBACK TRAN
			RETURN
		END

		-- Kiểm tra trợ khám có tồn tại không
		
		IF @TROKHAM IS NOT NULL AND @TROKHAM != ''
		BEGIN
			IF NOT EXISTS (SELECT * FROM NHANVIEN WHERE IDNHANVIEN = @TROKHAM )
			BEGIN
				RAISERROR(N'Trợ khám không tồn tại.', 16, 1)
				ROLLBACK TRAN
				RETURN
			END
		END

		-- Kiểm tra ràng buộc số lượng lịch hẹn
		IF EXISTS (SELECT * FROM LICHHEN WHERE NGAYHEN = @NGAYHEN  AND BENHNHAN = @BENHNHAN)
		BEGIN
			RAISERROR(N'Không thể thêm lịch hẹn. Bệnh nhân đã có lịch hẹn trong ngày này.', 16, 1)
			ROLLBACK TRAN
			RETURN
		END

		-- Kiểm tra ràng buộc lịch làm việc nha sĩ và trợ khám
		DECLARE @CA1 TIME
		DECLARE @CA2 TIME
		DECLARE @CA3 TIME
		DECLARE @CA4 TIME
		DECLARE @CALAM CHAR(20)
		SET @CA1 = '00:00:00'
		SET @CA2 = '06:00:00'
		SET @CA3 = '12:00:00'
		SET @CA4 = '18:00:00'
		
		IF NOT EXISTS (SELECT * FROM LICHLAMVIEC L INNER JOIN NHANVIEN N ON L.IDNHANVIEN = N.IDNHANVIEN WHERE N.IDNHANVIEN = @BACSI AND L.NGAY = DAY(@NGAYHEN) AND L.THANG = MONTH(@NGAYHEN) AND L.NAM = YEAR(@NGAYHEN))
		BEGIN
			RAISERROR(N'Không thể thêm lịch hẹn. Nha sĩ không có lịch làm việc cho ngày này.', 16, 1)
			ROLLBACK TRAN
			RETURN
		END
		ELSE
		BEGIN
			IF @THOIGIANHEN > @CA1 AND @THOIGIANHEN < @CA2
			SET @CALAM = 'C1'

			IF @THOIGIANHEN > @CA2 AND @THOIGIANHEN < @CA3
			SET @CALAM ='C2'
			
			IF @THOIGIANHEN > @CA3 AND @THOIGIANHEN < @CA4
			SET @CALAM ='C3'

			IF @THOIGIANHEN > @CA4
			SET @CALAM ='C4'

			IF NOT EXISTS (SELECT * FROM LICHLAMVIEC L INNER JOIN NHANVIEN N ON L.IDNHANVIEN = N.IDNHANVIEN WHERE N.IDNHANVIEN = @BACSI AND L.NGAY = DAY(@NGAYHEN) AND L.THANG = MONTH(@NGAYHEN) AND L.NAM = YEAR(@NGAYHEN) AND L.IDCALAM = @CALAM)
			BEGIN
				RAISERROR(N'Không thể thêm lịch hẹn. Nha sĩ không có ca làm cho khung giờ này.', 16, 1)
				ROLLBACK TRAN
				RETURN
			END

		END

		IF @TROKHAM IS NOT NULL AND @TROKHAM != ''
		BEGIN
			IF NOT EXISTS (SELECT * FROM LICHLAMVIEC L INNER JOIN NHANVIEN N ON L.IDNHANVIEN = N.IDNHANVIEN WHERE N.IDNHANVIEN = @TROKHAM AND L.NGAY = DAY(@NGAYHEN) AND L.THANG = MONTH(@NGAYHEN) AND L.NAM = YEAR(@NGAYHEN))
			BEGIN
				RAISERROR(N'Không thể thêm lịch hẹn. Trợ khám không có lịch làm việc cho ngày này.', 16, 1)
				ROLLBACK TRAN
				RETURN
			END
			ELSE
			BEGIN
				IF @THOIGIANHEN > @CA1 AND @THOIGIANHEN < @CA2
				SET @CALAM = 'C1'

				IF @THOIGIANHEN > @CA2 AND @THOIGIANHEN < @CA3
				SET @CALAM ='C2'
			
				IF @THOIGIANHEN > @CA3 AND @THOIGIANHEN < @CA4
				SET @CALAM ='C3'

				IF @THOIGIANHEN > @CA4
				SET @CALAM ='C4'

				IF NOT EXISTS (SELECT * FROM LICHLAMVIEC L INNER JOIN NHANVIEN N ON L.IDNHANVIEN = N.IDNHANVIEN WHERE N.IDNHANVIEN = @TROKHAM AND L.NGAY = DAY(@NGAYHEN) AND L.THANG = MONTH(@NGAYHEN) AND L.NAM = YEAR(@NGAYHEN) AND L.IDCALAM = @CALAM)
				BEGIN
					RAISERROR(N'Không thể thêm lịch hẹn. Trợ khám không có ca làm cho khung giờ này.', 16, 1)
					ROLLBACK TRAN
					RETURN
				END
			END
		END
		--Kiểm tra trùng giờ hẹn
		IF EXISTS (SELECT * FROM LICHHEN lh WHERE lh.NGAYHEN = @NGAYHEN AND lh.THOIGIANHEN = @THOIGIANHEN AND (lh.BACSI = @BACSI OR lh.TROKHAM  = @BACSI))
		BEGIN
			RAISERROR(N'Không thể thêm lịch hẹn. Bác sĩ đã có lịch hẹn.', 16, 1)
			ROLLBACK TRAN
			RETURN
		END
		IF EXISTS (SELECT * FROM LICHHEN lh WHERE lh.NGAYHEN = @NGAYHEN AND lh.THOIGIANHEN = @THOIGIANHEN AND (lh.BACSI = @TROKHAM OR lh.TROKHAM  = @TROKHAM))
		BEGIN
			RAISERROR(N'Không thể thêm lịch hẹn. Trợ khám đã có lịch hẹn.', 16, 1)
			ROLLBACK TRAN
			RETURN
		END
		PRINT(1)
		-- Thêm lịch hẹn
		INSERT INTO LICHHEN (NGAYHEN, THOIGIANHEN, TINHTRANG, PHONG, GHICHULICHHEN, BACSI, BENHNHAN,TROKHAM)
		VALUES (@NGAYHEN, @THOIGIANHEN, @TINHTRANG, @PHONG, @GHICHU, @BACSI, @BENHNHAN, @TROKHAM)
		PRINT('DONE')
	END TRY
	BEGIN CATCH
		SELECT ERROR_MESSAGE() AS errormessage
		ROLLBACK TRAN
		RETURN 1
	END CATCH
COMMIT TRAN
RETURN 0
GO

--EXEC SP_THEM_LICH_HEN '2023-12-08','19:15:00',N'CUỘC HẸN MỚI','P01','TEST FEATURE','NS000003','BN000500',''
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
			RAISERROR(N'Không tìm thấy lịch hẹn.', 16, 1) 
			ROLLBACK TRAN
			RETURN 2
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

--EXEC SP_XOA_LICH_HEN '2023-12-08','21:01:00','NS000003','BN000027'
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
GO
--EXEC SP_XEM_LICH_HEN_THEO_NGAY '2023-12-01','2023-12-01'