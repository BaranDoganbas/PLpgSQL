CREATE TABLE film
(
id int ,
title VARCHAR(50),
type VARCHAR(50),
length int
);

INSERT INTO film VALUES (1, 'Kuzuların Sessizliği', 'Korku',130);
INSERT INTO film VALUES (2, 'Esaretin Bedeli', 'Macera', 125);
INSERT INTO film VALUES (3, 'Kısa Film', 'Macera',40);
INSERT INTO film VALUES (4, 'Shrek', 'Animasyon',85);

SELECT * FROM film;

CREATE TABLE actor
(
id int ,
isim VARCHAR(50),
soyisim VARCHAR(50)
);
INSERT INTO actor VALUES (1, 'Christian', 'Bale');
INSERT INTO actor VALUES (2, 'Kevin', 'Spacey');
INSERT INTO actor VALUES (3, 'Edward', 'Norton');

DO $$

DECLARE
	film_count integer :=0;

BEGIN
	SELECT COUNT(*)  -- Kac tane film varsa sayisini getirir.
	INTO film_count  -- Query'den gelen neticeyi film_count isimli degiskene atar.
	FROM film;  	 -- Tabloyu seciyorum.
	
	RAISE NOTICE 'The number of films is %', film_count; --  % isareti yer tutucu olarak kullaniliyor.

END $$ ;

--**************************************************************
--***********************VARIABLES - CONSTANT*******************
--**************************************************************

DO $$
DECLARE
	counter		integer :=1;
	first_name	varchar(50)	 := 'John';
	last_name	varchar(50)	 := 'Doe';
	payment		numeric(4,2) :=  20.5;
BEGIN

	RAISE NOTICE '% % % has been paid % USD', 
				 counter,
				 first_name,
				 last_name,
				 payment;		 
END $$;

-- Task 1 : değişkenler oluşturarak ekrana " Ahmet ve Mehmet beyler 120 tl ye bilet aldılar. "" cümlesini ekrana basınız

DO $$
DECLARE
	first_person  varchar(30):= 'Ahmet';
	second_person varchar(30):= 'Mehmet';
	payment		  numeric (3) := 120;
BEGIN

	RAISE NOTICE '% ve % beyler % TL ye bilet aldilar',
					first_person,
					second_person,
					payment;
END $$

-- ********************* BEKLETME KOMUDU *********************

DO $$
DECLARE
	created_at time := now();
BEGIN
	RAISE NOTICE '%', created_at;
	PERFORM pg_sleep(10);		-- 10 saniye bekleniyor.
	RAISE NOTICE '%', created_at;	-- Ciktida ayni deger gorunecek
END $$

-- ********************* TABLODAN DATA TIPINI KOPYALAMA *********************

	/*
		-> variable_name  table_name.column_name%type;
		->( Tablodaki datanın aynı data türünde variable oluşturmaya yarıyor)
	*/
	
DO $$
DECLARE
	film_title film.title%TYPE;  -- varchar;
BEGIN
	-- 1 id'li film'in ismini getirelim
	SELECT title
	FROM film
	INTO film_title  -- film_title = 'Kuzularin Sessizligi'
	WHERE id=1;
	
	RAISE NOTICE 'Film title id 1 : %', film_title;
END $$;	
	
--************************* IC ICE BLOK YAPILARI *************************

DO $$
<<outher_block>>
DECLARE
	counter integer :=0;
BEGIN
	counter := counter + 1;
	RAISE NOTICE 'The current value of counter is %', counter;
	
	DECLARE
		counter integer :=0;
		
	BEGIN
		counter := counter + 10;
		RAISE NOTICE 'Counter in the subBlock is %', counter;
		RAISE NOTICE 'Counter in the OutherBlock is %', outher_block.counter;
	END;
	
	RAISE NOTICE 'Counter in the outherBlock is %', counter;

END outher_block $$;

-- ******************* Row Type *******************

DO $$
DECLARE
	selected_actor	actor%ROWTYPE;
BEGIN
	SELECT *	--	id, isim, soyisim
	FROM actor
	INTO selected_actor	 -- id,isim ,soyisim
	WHERE id=1;
	
	RAISE NOTICE 'The actor name is % %',
					selected_actor.isim,
					selected_actor.soyisim;
END $$;

-- ****************** Record Type ******************

	/*
	 -> Row Type gibi çalışır ama record un tamamı değilde belli başlıkları almak
		istersek kullanılabilir
	*/
	
DO $$
DECLARE
	rec record;	--	record data turunde rec isminde variable olusturuldu
BEGIN
	SELECT id,title,type
	INTO rec
	FROM film
	WHERE id = 1;

	RAISE NOTICE '% % %', rec.id, rec.title, rec.type;
	
END $$;

-- **************** Constant ****************

DO $$
DECLARE
	vat CONSTANT numeric := 0.1;
	net_price	numeric := 20.5;

BEGIN
	RAISE NOTICE 'Satis fiyati : %' , net_price*(1+vat);
	-- vat := 0.05; -- constant bir ifadeyi ilk setleme isleminden sonra degistirmeye calisirsak hata aliriz.

END $$;

-- Constant bir ifadeye RT da deger verebilir miyiz ???

DO $$
DECLARE
	start_at CONSTANT time := now();
	
BEGIN
	RAISE NOTICE 'Blogun calisma zamani : %', start_at;
	
END $$;


--  ////////////////// Control Structures //////////////////

--  ***************** If Statement *****************

-- syntax :
/*

	if condition then
				statement;
	end if;
	
*/

-- Task : 0 id'li filmi bulalim eger yoksa ekrana uyari yazisi verelim

DO $$
DECLARE
	istenen_film film%ROWTYPE;
	istenen_film_id film.id%TYPE := 10;

BEGIN
	SELECT * FROM film
	INTO istenen_film
	WHERE id = istenen_film_id;

	IF NOT FOUND THEN
		RAISE NOTICE 'Girdiginiz id li film bulunamadi: %', istenen_film_id;
	END IF;
end $$;


-- ***************** IF-THEN-ELSE *****************

/*
	IF condition THEN
			statement;
	ELSE
			alternative statement;
	END IF
*/

-- TASK : 1 id'li film varsa title bilgisini yaziniz, yoksa uyari yazisini ekrana basiniz.

DO $$
DECLARE
	selected_film film%ROWTYPE;
	input_film_id film.id%TYPE := 10;

BEGIN
	SELECT * FROM film
	INTO selected_film
	WHERE id = input_film_id;
	
	IF NOT FOUND THEN
		RAISE NOTICE 'Girmis oldugunuz id li film bulunamadi. %', input_film_id;
	ELSE
		RAISE NOTICE 'Filmin ismi : %', selected_film.title;
	END IF;

END $$;

-- ************* IF-THEN-ELSE-IF ************************

-- syntax : 

/*
	IF condition_1 THEN
				statement_1;
		ELSEIF condition_2 THEN
				statement_2;
	    ELSEIF condition_3 THEN
				statement_3;
		ELSE 
				statement_final;
	END IF ;
*/

/*
Task : 1 id li film varsa ;
			süresi 50 dakikanın altında ise Short,
			50<length<120 ise Medium,
			length>120 ise Long yazalım
*/


DO $$
DECLARE
	v_film film%ROWTYPE;
	len_description varchar(50);

BEGIN
	SELECT * FROM film
	INTO v_film	  --	v_film.id = 1	/	v_film.title = 'Kuzularin Sessizligi'
	WHERE id = 30;

	IF NOT FOUND THEN
		RAISE NOTICE 'Film bulunamadi...';
	ELSE
		IF v_film.length > 0 AND v_film.length <= 50 THEN
				len_description = 'Short';
			ELSEIF v_film.length > 50 AND v_film.length < 120 THEN
				len_description = 'Medium';
			ELSEIF v_film.length > 120 THEN
				len_description = 'Long';
			ELSE
				len_description = 'Undefined!';
		END IF;
	RAISE NOTICE ' % filminin suresi : %', v_film.title, v_film.length;
	END IF;

END $$;

-- *************** Case Statement ***************

-- syntax :
 
 /*
 	CASE search-expression
	WHEN expression_1 [, expression_2,...] THEN
		statement
	[..]
	ELSE
		else-statement
	END case;
 */

-- Task : Filmin türüne göre çocuklara uygun olup olmadığını ekrana yazalım

DO $$
DECLARE
	uyari varchar(50);
	tur film.type%TYPE;
BEGIN
	SELECT TYPE FROM film
	INTO tur
	WHERE id = 4;

	IF FOUND THEN
		CASE tur
			WHEN 'Korku' THEN uyari = 'Cocuklar icin uygun degildir.';
			WHEN 'Macera' THEN uyari = 'Cocuklar icin uygundur.';
			WHEN 'Animasyon' THEN uyari = 'Cocuklar icin tavsiye edilir.';
			ELSE 
				uyari = 'Tanimlanamadi...';
		END CASE;
		RAISE NOTICE '%', uyari;
	END IF;

END $$;







