USE [Konferencje]
GO
/****** Object:  StoredProcedure [dbo].[ZmienHasloKlienta]    Script Date: 1/12/2015 8:20:15 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--Zmienia haslo dla naszego klienta, brak zabeczpieczen
ALTER PROCEDURE [dbo].[ZmienHasloKlienta] 
@Login varchar(30), 
@OldPassword varchar(20),
@NewPassword varchar(20)
AS BEGIN
SET NOCOUNT ON; 
if (select password from Klienci where login = @login) = @OldPassword
begin
update Klienci
set	Password = @NewPassword
where (select id from Klienci where login = @login) = id
--Koniec
end
END
