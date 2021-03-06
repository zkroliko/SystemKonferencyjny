USE [Konferencje]
GO
/****** Object:  StoredProcedure [dbo].[FakturaNaKonf]    Script Date: 2015-01-18 10:25:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[FakturaNaKonf] 
@rezerwacjaID int



AS BEGIN
SET NOCOUNT ON; 
declare @DoZplacenia money
declare @Zplacono money
declare @klientID int
set @klientID=(select KlientID from [Rezerwacje konferencji] where id = @rezerwacjaID)
set @DoZplacenia=(select  dbo.PodliczRezerwacjafun(@rezerwacjaID))
set @Zplacono=isnull((select sum(Kwota) from Oplaty where [Rezerwacja konferencji]=@rezerwacjaID),0)

select (select imie from Osoby where id=(select osobaID from Klienci where id=@klientID))as imie,(select nazwisko from Osoby where id=(select osobaID from Klienci where id=@klientID))as nazwisko,@DoZplacenia as należność,@Zplacono as Zapłacono,@DoZplacenia-@Zplacono as saldo
END
