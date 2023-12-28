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
RETURN 0
GO

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
			print 'loi'
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
RETURN 0
GO 
EXEC SP_THEM1LOAITHUOC 'DC000060','Novocain 3%','Procain HCl','g','10.0'
GO
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
		IF (@GIATHUOC < 0 AND @GIATHUOC IS NOT NULL )
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
RETURN 0
GO

CREATE OR ALTER PROC SP_TIM1LOAITHUOC
	@TENTHUOC NCHAR(30)
AS
BEGIN TRAN
	BEGIN TRY
	SELECT * FROM THUOC WHERE TENTHUOC LIKE '%' + @TENTHUOC + '%'
	END TRY
	BEGIN CATCH
		ROLLBACK TRAN
		RETURN 2
	END CATCH
COMMIT TRAN
RETURN 0
GO

exec SP_TIM1LOAITHUOC 'HCL'