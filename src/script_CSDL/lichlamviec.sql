﻿--FORMAT INPUT: YYYY - MM - DD
-- 1. Xem danh sách lịch làm việc của 1 bác sĩ từ ngày A->B
CREATE OR ALTER PROC XEM_LICH_LAM_VIEC_NGAY
	@ID_NHASI CHAR(8),
	@NGAY_A DATE,
	@NGAY_B DATE
AS
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

EXEC XEM_LICH_LAM_VIEC_NGAY 'NS000005','2021-1-3',  '2021-12-20'
GO
-- 2. Xem danh sách lịch làm việc của 1 bác sĩ trong tuần
CREATE OR ALTER PROC XEM_LICH_LAM_VIEC_TUAN
	@ID_NHASI CHAR(8),
	@TUAN INT,
	@NAM INT
AS
BEGIN TRAN
	BEGIN TRY
	SELECT NS.TENNV,LLV.*, CL.KHUNGGIO
	FROM LICHLAMVIEC LLV
	JOIN NHANVIEN NS ON LLV.IDNHANVIEN = NS.IDNHANVIEN
	JOIN CALAM CL ON LLV.IDCALAM = CL.IDCALAM
	WHERE NS.IDNHANVIEN = @ID_NHASI
		AND DATEPART(WEEK, DATEFROMPARTS(LLV.NAM, LLV.THANG, LLV.NGAY)) = @TUAN
		AND LLV.NAM = @NAM
	END TRY
	BEGIN CATCH
		SELECT ERROR_MESSAGE() AS errormessage
		ROLLBACK TRAN
		RETURN 1
	END CATCH
COMMIT TRAN
RETURN 0
GO

-- 3. Xem danh sách lịch làm việc của 1 bác sĩ trong tháng
CREATE OR ALTER PROC XEM_LICH_LAM_VIEC_THANG
	@ID_NHASI CHAR(8),
	@THANG INT,
	@NAM INT
AS
BEGIN TRAN
	BEGIN TRY
	SELECT NS.TENNV,LLV.*, CL.KHUNGGIO
	FROM LICHLAMVIEC LLV
	JOIN NHANVIEN NS ON LLV.IDNHANVIEN = NS.IDNHANVIEN
	JOIN CALAM CL ON LLV.IDCALAM = CL.IDCALAM
	WHERE NS.IDNHANVIEN = @ID_NHASI
		AND LLV.THANG = @THANG
		AND LLV.NAM = @NAM
	END TRY
	BEGIN CATCH
		SELECT ERROR_MESSAGE() AS errormessage
		ROLLBACK TRAN
		RETURN 1
	END CATCH
COMMIT TRAN
RETURN 0
GO

-- 4. Thêm lịch làm việc cho 1 bác sĩ
CREATE OR ALTER PROC THEM_LICH_LAM_VIEC
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
		RETURN
	END
	-- Kiểm tra ràng buộc ngày làm việc
	IF @NGAY < GETDATE()
	BEGIN
		RAISERROR(N'Không thể thêm lịch làm việc từ ngày hiện tại trở về trước.', 16, 1)
		ROLLBACK TRAN
		RETURN
	END

	-- Kiểm tra ràng buộc trùng lặp
	IF EXISTS (SELECT * FROM LICHLAMVIEC WHERE IDNHANVIEN = @ID_NHANVIEN AND NGAY = DATEPART(DAY,@NGAY) AND THANG = DATEPART(MONTH, @NGAY) AND NAM = DATEPART(YEAR, @NGAY))
	BEGIN
		RAISERROR(N'Không thể thêm lịch làm việc. Nhân viên đã có lịch làm việc trong ngày này.', 16, 1)
		ROLLBACK TRAN
		RETURN
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


-- 5. Xóa lịch làm việc cho 1 bác sĩ
CREATE OR ALTER PROC XOA_LICH_LAM_VIEC
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
		RETURN
	END
	-- Kiểm tra nếu là ca làm việc từ ngày hiện tại trở về trước
	IF NOT EXISTS (SELECT * FROM LICHLAMVIEC WHERE IDNHANVIEN = @ID_NHANVIEN AND NGAY = DATEPART(DAY,@NGAY) AND THANG = DATEPART(MONTH, @NGAY) AND NAM = DATEPART(YEAR, @NGAY) AND IDCALAM = @ID_CALAM)
	BEGIN
		RAISERROR(N'Không tìm thấy lịch làm việc.', 16, 1)
		ROLLBACK TRAN
		RETURN
	END

	-- Xóa lịch làm việc
	DELETE FROM LICHLAMVIEC WHERE IDNHANVIEN = @ID_NHANVIEN AND NGAY = DATEPART(DAY,@NGAY) AND THANG = DATEPART(MONTH, @NGAY) AND NAM = DATEPART(YEAR, @NGAY) AND IDCALAM = @ID_CALAM;
	RETURN 0
	END TRY
	BEGIN CATCH
		SELECT ERROR_MESSAGE() AS errormessage
		ROLLBACK TRAN
		RETURN 1
	END CATCH
COMMIT TRAN
RETURN 0
GO