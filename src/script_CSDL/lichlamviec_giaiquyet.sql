﻿--LICHLAMVIEC
-- Xem danh sách lịch làm việc của 1 bác sĩ từ ngày A->B
CREATE OR ALTER PROC SP_XEM_LICH_LAM_VIEC_NGAY
	@ID_NHASI CHAR(8),
	@NGAY_A DATE,
	@NGAY_B DATE
AS
SET TRAN ISOLATION LEVEL REPEATABLE READ
BEGIN TRAN
	BEGIN TRY
	--Kiểm tra
	IF @NGAY_A > @NGAY_B
		BEGIN
			DECLARE @TEMP DATE
			SET @TEMP = @NGAY_A
			SET @NGAY_A = @NGAY_B
			SET @NGAY_B = @TEMP
		END
	IF NOT EXISTS (SELECT * FROM LICHLAMVIEC LLV
					WHERE LLV.IDNHANVIEN = @ID_NHASI	
					AND ( CONVERT(DATE, CONCAT(LLV.NAM, '-', LLV.THANG, '-', LLV.NGAY)) BETWEEN @NGAY_A AND @NGAY_B OR CONVERT(DATE, CONCAT(LLV.NAM, '-', LLV.THANG, '-', LLV.NGAY)) = @NGAY_A OR CONVERT(DATE, CONCAT(LLV.NAM, '-', LLV.THANG, '-', LLV.NGAY)) = @NGAY_B ))
	BEGIN
		RAISERROR(N'Không có lịch làm việc trong ngày.', 16, 1)
		ROLLBACK TRAN
		RETURN 1
	END
	--ĐỂ TEST
		WAITFOR DELAY '0:0:05'
	----------
	--Thực thi
	SELECT NS.TENNV, LLV.*, CL.KHUNGGIO
	FROM LICHLAMVIEC LLV
	JOIN NHANVIEN NS ON LLV.IDNHANVIEN = NS.IDNHANVIEN
	JOIN CALAM CL ON LLV.IDCALAM = CL.IDCALAM
	WHERE NS.IDNHANVIEN = @ID_NHASI	AND ( CONVERT(DATE, CONCAT(LLV.NAM, '-', LLV.THANG, '-', LLV.NGAY)) BETWEEN @NGAY_A AND @NGAY_B OR CONVERT(DATE, CONCAT(LLV.NAM, '-', LLV.THANG, '-', LLV.NGAY)) = @NGAY_A OR CONVERT(DATE, CONCAT(LLV.NAM, '-', LLV.THANG, '-', LLV.NGAY)) = @NGAY_B )
	ORDER BY LLV.NAM DESC, LLV.THANG DESC, LLV.NGAY DESC;
	END TRY
	BEGIN CATCH
		SELECT ERROR_MESSAGE() AS errormessage
		ROLLBACK TRAN
		RETURN 1
	END CATCH
COMMIT TRAN
RETURN 0
GO


--Cập nhật thông tin lịch làm việc
CREATE OR ALTER PROC SP_CAP_NHAT_LICH_LAM_VIEC
	@ID_NHANVIEN CHAR(8),
	@NGAY DATE,
	@ID_CALAM CHAR(2),
	@NGAY_NEW DATE,
	@ID_CALAM_NEW CHAR(2)
AS
BEGIN TRAN
	BEGIN TRY
	--Kiểm tra lịch làm việc
	IF NOT EXISTS (SELECT * FROM LICHLAMVIEC WHERE IDNHANVIEN = @ID_NHANVIEN AND NGAY = DATEPART(DAY,@NGAY) AND THANG = DATEPART(MONTH, @NGAY) AND NAM = DATEPART(YEAR, @NGAY) AND IDCALAM = @ID_CALAM)
	BEGIN
		RAISERROR(N'Lịch làm việc không tồn tại.', 16, 1)
		ROLLBACK TRAN
		RETURN 1
	END
	--Kiểm tra ca làm
	IF NOT EXISTS (SELECT * FROM CALAM WHERE IDCALAM = @ID_CALAM_NEW)
	BEGIN
		RAISERROR(N'Ca làm không tồn tại.', 16, 1)
		ROLLBACK TRAN
		RETURN 1
	END
	-- Kiểm tra ràng buộc ngày làm việc
	IF @NGAY_NEW < GETDATE()
	BEGIN
		RAISERROR(N'Không thể thêm lịch làm việc từ ngày hiện tại trở về trước.', 16, 1)
		ROLLBACK TRAN
		RETURN 1
	END


	-- Cập nhật thông tin lịch làm việc
	UPDATE LICHLAMVIEC
	SET
		NGAY = DATEPART(DAY, @NGAY_NEW),
		THANG = DATEPART(MONTH, @NGAY_NEW),
		NAM = DATEPART(YEAR, @NGAY_NEW),
		IDCALAM = @ID_CALAM_NEW
	WHERE
		IDNHANVIEN = @ID_NHANVIEN
		AND NGAY = DATEPART(DAY, @NGAY)
		AND THANG = DATEPART(MONTH, @NGAY)
		AND NAM = DATEPART(YEAR, @NGAY)
		AND IDCALAM = @ID_CALAM

	END TRY
	BEGIN CATCH
		SELECT ERROR_MESSAGE() AS errormessage
		ROLLBACK TRAN
		RETURN 1
	END CATCH
COMMIT TRAN
RETURN 0
GO

-- Xem danh sách lịch làm việc của 1 bác sĩ từ ngày A->B
CREATE OR ALTER PROC SP_XEM_LICH_LAM_VIEC_NGAY
	@ID_NHASI CHAR(8),
	@NGAY_A DATE,
	@NGAY_B DATE
AS
SET TRAN ISOLATION LEVEL SERIALIZABLE
BEGIN TRAN
	BEGIN TRY
	--Kiểm tra
	IF @NGAY_A > @NGAY_B
		BEGIN
			DECLARE @TEMP DATE
			SET @TEMP = @NGAY_A
			SET @NGAY_A = @NGAY_B
			SET @NGAY_B = @TEMP
		END

	DECLARE @COUNT_LLV INT;
	SELECT @COUNT_LLV = COUNT(*) FROM LICHLAMVIEC LLV
					WHERE LLV.IDNHANVIEN = @ID_NHASI	
					AND ( CONVERT(DATE, CONCAT(LLV.NAM, '-', LLV.THANG, '-', LLV.NGAY)) BETWEEN @NGAY_A AND @NGAY_B OR CONVERT(DATE, CONCAT(LLV.NAM, '-', LLV.THANG, '-', LLV.NGAY)) = @NGAY_A OR CONVERT(DATE, CONCAT(LLV.NAM, '-', LLV.THANG, '-', LLV.NGAY)) = @NGAY_B )
	IF @COUNT_LLV = 0
	BEGIN
		RAISERROR(N'Không có lịch làm việc trong ngày.', 16, 1)
		ROLLBACK TRAN
		RETURN 1
	END
	--ĐỂ TEST
		WAITFOR DELAY '0:0:05'
	---------------------------------
	--Thực thi
	SELECT NS.TENNV, LLV.*, CL.KHUNGGIO
	FROM LICHLAMVIEC LLV
	JOIN NHANVIEN NS ON LLV.IDNHANVIEN = NS.IDNHANVIEN
	JOIN CALAM CL ON LLV.IDCALAM = CL.IDCALAM
	WHERE NS.IDNHANVIEN = @ID_NHASI	AND ( CONVERT(DATE, CONCAT(LLV.NAM, '-', LLV.THANG, '-', LLV.NGAY)) BETWEEN @NGAY_A AND @NGAY_B OR CONVERT(DATE, CONCAT(LLV.NAM, '-', LLV.THANG, '-', LLV.NGAY)) = @NGAY_A OR CONVERT(DATE, CONCAT(LLV.NAM, '-', LLV.THANG, '-', LLV.NGAY)) = @NGAY_B )
	ORDER BY LLV.NAM DESC, LLV.THANG DESC, LLV.NGAY DESC;
	END TRY
	BEGIN CATCH
		SELECT ERROR_MESSAGE() AS errormessage
		ROLLBACK TRAN
		RETURN 1
	END CATCH
COMMIT TRAN
RETURN 0
GO

-- Thêm lịch làm việc cho 1 bác sĩ
CREATE OR ALTER PROC SP_THEM_LICH_LAM_VIEC
	@ID_NHANVIEN CHAR(8),
	@NGAY DATE,
	@ID_CALAM CHAR(2)
AS
BEGIN TRAN
	BEGIN TRY
	--Kiểm tra ca làm
	IF NOT EXISTS (SELECT * FROM CALAM WHERE IDCALAM = @ID_CALAM)
	BEGIN
		RAISERROR(N'Ca làm không tồn tại.', 16, 1)
		ROLLBACK TRAN
		RETURN 1
	END
	-- Kiểm tra ràng buộc ngày làm việc
	IF @NGAY < GETDATE()
	BEGIN
		RAISERROR(N'Không thể thêm lịch làm việc từ ngày hiện tại trở về trước.', 16, 1)
		ROLLBACK TRAN
		RETURN 2
	END

	-- Kiểm tra ràng buộc trùng lặp
	IF EXISTS (SELECT * FROM LICHLAMVIEC WHERE IDNHANVIEN = @ID_NHANVIEN AND NGAY = DATEPART(DAY,@NGAY) AND THANG = DATEPART(MONTH, @NGAY) AND NAM = DATEPART(YEAR, @NGAY) AND IDCALAM = @ID_CALAM)
	BEGIN
		RAISERROR(N'Không thể thêm lịch làm việc. Nhân viên đã có lịch làm việc trong khung giờ này.', 16, 1)
		ROLLBACK TRAN
		RETURN 3
	END

	-- Thêm lịch làm việc
	INSERT INTO LICHLAMVIEC ( IDNHANVIEN, NGAY, THANG, NAM, IDCALAM)
	VALUES ( @ID_NHANVIEN,DATEPART(DAY,@NGAY), DATEPART(MONTH, @NGAY), DATEPART(YEAR, @NGAY), @ID_CALAM)

	END TRY
	BEGIN CATCH
		SELECT ERROR_MESSAGE() AS errormessage
		ROLLBACK TRAN
		RETURN 1
	END CATCH
COMMIT TRAN
RETURN 0
GO