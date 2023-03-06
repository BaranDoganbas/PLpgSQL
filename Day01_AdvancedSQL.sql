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


