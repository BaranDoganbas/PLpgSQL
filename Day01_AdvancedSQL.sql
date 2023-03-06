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






