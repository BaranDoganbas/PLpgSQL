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


--Task 1 : Film tablosundaki film sayısı 10 dan az ise "Film sayısı az" yazdırın, 10 dan çok ise "Film sayısı yeterli" yazdıralım

DO $$
DECLARE
	sayi integer :=0;
	
BEGIN
	SELECT COUNT(*) FROM film  -- 4
	INTO sayi;	--	sayi=4
	
	IF (sayi<10) THEN
			RAISE NOTICE 'Film sayisi az';
		ELSE
			RAISE NOTICE 'Film sayisi yeterli';
	END IF;
END $$;
		
		
-- Task 2: user_age isminde integer data türünde bir değişken tanımlayıp default 
-- olarak bir değer verelim, If yapısı ile girilen 
-- değer 18 den büyük ise Access Granted, küçük ise Access Denied yazdıralım

DO $$
DECLARE
	user_age integer := 0;
BEGIN
	IF user_age < 18 THEN
		RAISE NOTICE 'Access Denied';
	ELSE
		RAISE NOTICE 'Access Granted';
	END IF;
END $$;

-- Task 3: a ve b isimli integer türünde 2 değişken tanımlayıp default değerlerini verelim, 
-- eğer a nın değeri b den büyükse "a , b den büyüktür" yazalım, 
-- tam tersi durum için "b, a dan büyüktür" yazalım, iki değer birbirine eşit ise " a,  b'ye eşittir" yazalım:

DO $$
DECLARE
	a integer := 2;
	b integer := 3;
BEGIN
	IF (a>b) THEN
		RAISE NOTICE 'a b den buyuktur';
	END IF;
	
	IF (a=b) THEN
		RAISE NOTICE 'a b ye esittir';
	END IF;
	
	IF (a<b) THEN
		RAISE NOTICE 'b a den buyuktur';
	END IF;
END $$;

-- Task 4 : kullaniciYasi isimli bir değişken oluşturup default değerini verin, 
--	girilen yaş 18 den büyükse "Oy kullanabilirsiniz", 18 den küçük ise 
--	"Oy kullanamazsınız" yazısını yazalım.

DO $$
DECLARE
	kullaniciYasi integer :=13;
BEGIN
	IF kullaniciYasi>18 THEN
		RAISE NOTICE 'Oy kullanabilirsiniz';
		ELSE
			RAISE NOTICE 'Oy kullanamazsınız';
	END IF;
END $$ ;


-- *********************** LOOP ***********************

-- syntax

LOOP
	STATEMENT;
END LOOP;

-- loop'u sonlandirmak icin loop'un icine if yapisini kullanabiliriz :

LOOP
	statements;
	IF CONDITION THEN
		EXIT;	--	loop'dan cikmami sagliyor
	END IF;
END LOOP;

-- nested loop

<<outher>>
LOOP
	statements;
	<<inner>>
	LOOP
		.....
		exit <<inner>>
		END LOOP;
END LOOP;
	
-- Task : Fibonacci serisinde, belli bir sıradaki sayıyı ekrana getirelim

-- Fibonacci Serisi : 0,1,1,2,3,5,8,13,...

DO $$
DECLARE
	n integer :=40;
	counter integer :=0;
	i integer :=0;
	j integer :=1;
	fib integer :=0;

BEGIN
	IF(n<1) THEN
		fib:=0;
	END IF;
	LOOP
		EXIT WHEN counter =n;
		counter := counter + 1;
		SELECT j, (i+j) INTO i,j;	
	END LOOP;
	fib:=i;
	RAISE NOTICE '%', fib;
END $$;

-- ************************* WHILE LOOP *************************

syntax :

WHILE condition LOOP
	statements;
END LOOP;

-- Task : 1 dan 4 e kadar counter değerlerini ekrana basalım

DO $$
DECLARE
	n integer :=4;
	counter integer :=0;

BEGIN
	WHILE counter<n LOOP
		counter:=counter+1;
		raise notice '%', counter;
	END LOOP;

END $$;

-- Cevap 2:

DO $$

DECLARE
	counter integer :=0;

BEGIN 
	WHILE counter<5 LOOP
		counter := counter+1;
		raise notice '%', counter;
	END LOOP;	

END $$ ;


-- Task : sayac isminde bir degisken olusturun ve dongu icinde sayaci birer artirin,  
-- her dongude sayacin degerini ekrana basin ve sayac degeri 5 e esit olunca donguden cikin

DO $$
DECLARE
	counter integer :=0;
BEGIN
	LOOP
		RAISE NOTICE '%', counter;
		counter := counter +1;
		EXIT WHEN counter =5;
	END LOOP;
END $$;


-- **************  FOR LOOP *********************
-- syntax
for loop_counter in [reverse] from..to [by step] loop
	statements;
end loop ;


-- **************  FOR LOOP *********************

-- syntax

for loop_counter in [reverse] from..to [by step] loop
	statements;
end loop ;


-- in

do $$
begin
	for counter in 1..6 loop
		raise notice 'counter: %', counter;
	end loop;	

end $$;


-- reverse ( Ornek )

do $$
begin
	for counter in reverse 5..1 loop
		raise notice 'counter : %', counter;
	end loop;
end $$;


-- Task : 10 dan 20 ye kadar 2 ser 2 ser ekrana sayilari basalim :

DO $$
BEGIN
	FOR counter IN 10..20 BY 2 LOOP
		RAISE NOTICE 'counter : %', counter;
	END LOOP;
END $$;


-- Task : olusturulan array'in elemanlarini array seklinde gosterelim :

DO $$
DECLARE
	array_int int[] := array[11,22,33,44,55,66,77,88];
	var int[];

BEGIN
	FOR var IN SELECT array_int LOOP
		RAISE NOTICE '%', var;
	END LOOP;

END $$;

-- DB'de loop kullanimi

-- syntax :

FOR target IN QUERY LOOP
	statement;
END LOOP;

-- Task : Filmleri süresine göre sıraladığımızda en uzun 2 filmi gösterelim

DO $$
DECLARE
	f record;
BEGIN
	FOR f IN SELECT title,length FROM film ORDER BY length DESC LIMIT 2 LOOP
		RAISE NOTICE '% ( % dakika)', f.title, f.length;
	END LOOP;

END $$;


CREATE TABLE employees (
  employee_id serial PRIMARY KEY,
  full_name VARCHAR NOT NULL,
  manager_id INT
);

INSERT INTO employees (
  employee_id,
  full_name,
  manager_id
)
VALUES
  (1, 'M.S Dhoni', NULL),
  (2, 'Sachin Tendulkar', 1),
  (3, 'R. Sharma', 1),
  (4, 'S. Raina', 1),
  (5, 'B. Kumar', 1),
  (6, 'Y. Singh', 2),
  (7, 'Virender Sehwag ', 2),
  (8, 'Ajinkya Rahane', 2),
  (9, 'Shikhar Dhawan', 2),
  (10, 'Mohammed Shami', 3),
  (11, 'Shreyas Iyer', 3),
  (12, 'Mayank Agarwal', 3),
  (13, 'K. L. Rahul', 3),
  (14, 'Hardik Pandya', 4),
  (15, 'Dinesh Karthik', 4),
  (16, 'Jasprit Bumrah', 7),
  (17, 'Kuldeep Yadav', 7),
  (18, 'Yuzvendra Chahal', 8),
  (19, 'Rishabh Pant', 8),
  (20, 'Sanju Samson', 8);

-- Task :  Employee ID si en buyuk ilk 10 kisiyi ekrana yazalim

DO $$
DECLARE
	f record;
BEGIN
	FOR f IN SELECT employee_id, full_name FROM employees ORDER BY employee_id DESC LIMIT 10 LOOP
		RAISE NOTICE '% = %', f.full_name,f.employee_id;
	END LOOP;

END $$;


-- *********** EXIT ***********

EXIT WHEN counter >10 ;

-- yukardakini if ile yazmak istersem
-- alttaki ve ustteki kod ayni isi yapiyor

IF counter > 10 THEN
	EXIT;
END IF;

-- Ornek

DO $$
BEGIN
	<<inner_block>>
	BEGIN
		EXIT inner_block;
		RAISE NOTICE 'Inner block dan Merhaba';
	END;
	
	RAISE NOTICE 'Outher block dan merhaba';
	
END $$;

-- *********** CONTINUE ***********

-- Mevcut iterasyonu atlamak icin kullanilir.

-- syntax :

continue [loop_label] [when condition] -- [] bu kısımlar opsiyoneldir

-- Task : continue yapisi kullanarak 1 dahil 10 a kadar olan tek sayilari ekrana basalim

DO $$
DECLARE
	counter int :=0;
BEGIN
	LOOP
		counter := counter + 1;	-- Loop icinde counter degerim 1 artiriliyor
		EXIT WHEN counter >10;	-- Counter degerim 10'dan buyuk olursa loop'dan cik
		CONTINUE WHEN MOD(counter, 2)=0;	-- counter cift ise bu iterasyonu terk et
		RAISE NOTICE '%', counter;		-- counter degerimi ekrana basiyorum.
	END LOOP;
END $$;


-- **********************************
-- ************ FUNCTION ************
-- **********************************

-- syntax :

create [or replace] function function_name(param_list)
	RETURNS return_type -- donen data turunu belirliyorum.
	LANGUAGE plpgsql 	-- kullanilan prosedurel dili tanimliyor.
	AS
	
	$$
	DECLARE
	BEGIN
	
	END $$;

-- Film tablomuzdaki belirli sure arasindaki filmlerin sayisini getiren bir fonksiyon yazalim

CREATE FUNCTION get_film_count(len_from int, len_to int)
RETURNS int
LANGUAGE plpgsql
AS

	$$
	DECLARE
		film_count integer;
	BEGIN
		SELECT COUNT(*)
		INTO film_count
		FROM film
		WHERE length BETWEEN len_from AND len_to;
		RETURN film_count;
	
	END $$;

-- 1. Yol :	( positional notation )

SELECT get_film_count(40,190);

-- 2. Yol :	( named notation )

SELECT get_film_count(

	len_from:= 40,
	len_to	:= 135
	);

-- HAZIR METHOD

SELECT MIN(length) FROM film;
SELECT MAX(length) FROM film;
SELECT AVG(length) FROM film;


-- Task : parametre olarak girilen iki sayının toplamını veren sayitoplama adında fonksiyon yazalım

CREATE FUNCTION sayi_toplami(sayi1 int, sayi2 int)
RETURNS int
LANGUAGE plpgsql
AS
	$$
	BEGIN
		RETURN sayi1 + sayi2;
	END
	$$
		
SELECT sayi_toplami(5,21);


CREATE FUNCTION uc_sayi_toplama(sayi1 int, sayi2 int, sayi3 int)
RETURNS int
LANGUAGE plpgsql
AS
	$$
	BEGIN
		RETURN sayi1 + sayi2 + sayi3;
	END
	$$

-- Odev : Büyük harfle girilen değeri küçük harfle yazılsın ve içerisinde ı,ş,ç,ö,ğ,ü  
-- geçen harfleri sırasıyla i,s,o,g,u harflerine çeviren bir fonksiyon yazalım
