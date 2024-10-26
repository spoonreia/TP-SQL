CREATE OR ALTER PROCEDURE spAuroraSA.[InsertarLog]
	@texto VARCHAR(250),
	@modulo VARCHAR(15)
AS
BEGIN
	SET NOCOUNT ON;

	IF LTRIM(RTRIM(@modulo)) = ''
		SET @texto = 'N/A'

	INSERT INTO logAuroraSA.Registro (texto, modulo)
	VALUES (@texto, @modulo)
END
GO