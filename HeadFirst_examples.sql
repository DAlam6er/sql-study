INSERT INTO my_contacts
(last_name, first_name, email, gender, birthday,
 profession, location, status, interests, seeking)
VALUES ('Андерсон', 'Джиллиан', 'jill_anderson@breakneckpizza.com',
        'Ж', '1980-05-09', 'Писатель', 'Пало-Альто, CA', 'Не замужем',
        'Каяк', 'Друзья');

INSERT INTO my_contacts
    (first_name, email, profession, location)
VALUES ('Пэт', 'patpost@breakneckpizza.com', 'Почтальон', 'Принстон, NJ');

CREATE TABLE my_contacts
(
    last_name  VARCHAR(30)  NOT NULL,
    first_name VARCHAR(20)  NOT NULL,
    email      VARCHAR(50)  NOT NULL,
    gender     CHAR(1)      NOT NULL,
    profession VARCHAR(50)  NOT NULL,
    location   VARCHAR(50)  NOT NULL,
    status     VARCHAR(20)  NOT NULL,
    interests  VARCHAR(100) NOT NULL,
    seeking    VARCHAR(100) NOT NULL
);

CREATE TABLE easy_drinks
(
    drink_name VARCHAR(16)  NOT NULL,
    main       VARCHAR(20)  NOT NULL,
    amount1    DEC(3, 1)    NOT NULL,
    second     VARCHAR(20)  NOT NULL,
    amount2    DEC(4, 2)    NOT NULL,
    directions VARCHAR(250) NOT NULL
);

INSERT INTO easy_drinks
(drink_name, main, amount1, second, amount2, directions)
VALUES ('Терновник', 'тоник', 1.5, 'ананасовый сок', 1,
        'взболтать со льдом, разлить по бокалам, украсить лимонной цедрой'),
       ('Голубая луна', 'содовая', 1.5, 'черничный сок', 0.75,
        'взболтать со льдом, разлить по бокалам, украсить лимонной цедрой'),
       ('Вот тебе на', 'персиковый нектар', 1, 'ананасовый сок', 1,
        'взболтать со льдом, разлить по стаканам'),
       ('Лаймовый физз', 'Спрайт', 1.5, 'сок лайма', 0.75,
        'взболтать со льдом, разлить по бокалам'),
       ('Поцелуй', 'вишневый сок', 2, 'абрикосовый нектар', 7,
        'подавать со льдом и соломинкой'),
       ('Горячее золото', 'персиковый нектар', 3, 'апельсиновый сок', 6,
        'влить в кружку горячий апельсиновый сок, добавить персиковый нектар'),
       ('Одинокое дерево', 'содовая', 1.5, 'вишневый сок', 0.75,
        'взболтать со льдом, разлить по бокалам'),
       ('Борзая', 'содовая', 1.5, 'грейпфрутовый сок', 5,
        'подавать со льдом, тщательно взболтать'),
       ('Бабье лето', 'яблочный сок', 2, 'горячий чай', 6,
        'налить сок в кружку, добавить горячий чай'),
       ('Лягушка', 'холодный чай', 1.5, 'лимонад', 5,
        'подавать на льду с ломтиком лайма'),
       ('Сода плюс', 'содовая', 2, 'виноградный сок', 1,
        'взболтать в бокале, подавать без льда');

INSERT INTO my_contacts
VALUES ('Фанион', 'Стив', 'steve@onionflavoredrings.com', 'М',
        '1970-01-04',
        'Панк', 'Гровер\' Милл, NJ', 'Не женат', 'Бунтарство',
        'Единомышленники, гитаристы');

CREATE TABLE my_contacts
(
    contact_id INT NOT NULL AUTO_INCREMENT,
    last_name  VARCHAR(30)  DEFAULT NULL,
    first_name VARCHAR(20)  DEFAULT NULL,
    email      VARCHAR(50)  DEFAULT NULL,
    gender     CHAR(1)      DEFAULT NULL,
    profession VARCHAR(50)  DEFAULT NULL,
    location   VARCHAR(50)  DEFAULT NULL,
    status     VARCHAR(20)  DEFAULT NULL,
    interests  VARCHAR(100) DEFAULT NULL,
    seeking    VARCHAR(100) DEFAULT NULL,
    PRIMARY KEY (contact_id)
);

CREATE TABLE your_table
(
    id         INT NOT NULL AUTO_INCREMENT,
    first_name VARCHAR(20) DEFAULT NULL,
    last_name  VARCHAR(30) DEFAULT NULL,
    PRIMARY KEY (id)
);

ALTER TABLE my_contacts
    ADD COLUMN contact_id INT NOT NULL AUTO_INCREMENT FIRST,
    ADD PRIMARY KEY (contact_id);

ALTER TABLE hooptie
    RENAME TO car_table,
    ADD COLUMN car_id INT NOT NULL AUTO_INCREMENT FIRST,
    ADD PRIMARY KEY (car_id),
    ADD COLUMN VIN    VARCHAR(17) AFTER car_id,
    MODIFY COLUMN color VARCHAR(20) AFTER model,
    MODIFY COLUMN year INT AFTER price,
    CHANGE COLUMN mo model VARCHAR(20),
    CHANGE COLUMN howmuch price DECIMAL(7, 2);

CREATE TABLE movie_table
(
    movie_id  INT NOT NULL AUTO_INCREMENT,
    title     VARCHAR(100),
    rating    VARCHAR(2),
    drama     CHAR(1),
    comedy    CHAR(1),
    action    CHAR(1),
    gore      CHAR(1),
    scifi     CHAR(1),
    for_kids  CHAR(1),
    cartoon   CHAR(1),
    purchased DATE,
    PRIMARY KEY (movie_id)
);

INSERT INTO movie_table (title, rating, drama, comedy, action, gore, scifi,
                         for_kids, cartoon)
VALUES ('Большое приключение', 'PG', 'Н', 'Н', 'Н', 'Н', 'Н', 'Н', 'Д'),
       ('Грег: Неизвестные истории', 'PG', 'Н', 'Н', 'Д', 'Н', 'Н', 'Н',
        'Н'),
       ('Безумные клоуны', 'R', 'Н', 'Н', 'Н', 'Д', 'Н', 'Н', 'Н'),
       ('Параскеведекатриафобия', 'R', 'Д', 'Д', 'Д', 'Н', 'Д', 'Н', 'Н'),
       ('Крыса по имени Дарси', 'G', 'Н', 'Н', 'Н', 'Н', 'Н', 'Д', 'Н'),
       ('Конец очереди', 'R', 'Д', 'Н', 'Н', 'Д', 'Д', 'Н', 'Д'),
       ('Блестящие вещи', 'PG', 'Д', 'Н', 'Н', 'Н', 'Н', 'Н', 'Н'),
       ('Заберите обратно', 'R', 'Н', 'Д', 'Н', 'Н', 'Н', 'Н', 'Н'),
       ('Наживка для акул', 'G', 'Н', 'Н', 'Н', 'Н', 'Н', 'Д', 'Н'),
       ('Разгневанный пират', 'PG', 'Н', 'Д', 'Н', 'Н', 'Н', 'Н', 'Д'),
       ('Планета пригодна для жизни', 'PG', 'Н', 'Д', 'Н', 'Н', 'Д', 'Н',
        'Н');

ALTER TABLE movie_table
    ADD COLUMN category VARCHAR(20) AFTER cartoon;

UPDATE movie_table
SET category =
        CASE
            WHEN drama = 'Д' THEN 'драма'
            WHEN comedy = 'Д' THEN 'комедия'
            WHEN action = 'Д' THEN 'боевик'
            WHEN gore = 'Д' THEN 'ужасы'
            WHEN scifi = 'Д' THEN 'фантастика'
            WHEN for_kids = 'Д' THEN 'семейное'
            WHEN cartoon = 'Д' AND rating = 'G' THEN 'семейное'
            ELSE 'разное'
            END;

UPDATE movie_table
SET category =
        CASE
            WHEN rating = 'R' AND gore = 'Д' THEN 'ужасы-r'
            WHEN rating = 'R' AND action = 'Д' THEN 'боевик-r'
            WHEN rating = 'R' AND drama = 'Д' THEN 'драма-r'
            WHEN rating = 'R' AND comedy = 'Д' THEN 'комедия-r'
            WHEN rating = 'R' AND scifi = 'Д' THEN 'фантастика-r'
            WHEN rating = 'G' AND category = 'разное' THEN 'семейное'
            ELSE 'разное'
            END;

UPDATE movie_table
SET category =
        CASE
            WHEN category = 'ужасы-r' THEN 'ужасы'
            WHEN category = 'боевик-r' THEN 'боевик'
            WHEN category = 'драма-r' THEN 'драма'
            WHEN category = 'комедия-r' THEN 'комедия'
            WHEN category = 'фантастика-r' THEN 'фантастика'
            END;

ALTER TABLE movie_table
    DROP COLUMN drama,
    DROP COLUMN comedy,
    DROP COLUMN action,
    DROP COLUMN gore,
    DROP COLUMN scifi,
    DROP COLUMN for_kids,
    DROP COLUMN cartoon;

CREATE TABLE test_chars
(
    ch CHAR(1)
);

INSERT INTO test_chars
VALUES ('0'),
       ('1'),
       ('2'),
       ('3'),
       ('A'),
       ('B'),
       ('C'),
       ('D'),
       ('a'),
       ('b'),
       ('c'),
       ('d'),
       ('!'),
       ('@'),
       ('#'),
       ('$'),
       ('%'),
       ('^'),
       ('&'),
       ('*'),
       ('('),
       (')'),
       ('-'),
       ('_'),
       ('+'),
       ('='),
       ('['),
       (']'),
       ('{'),
       ('}'),
       (';'),
       (':'),
       ('\''),
       ('»'),
       ('\\'),
       ('|'),
       ('`'),
       ('~'),
       (','),
       ('.'),
       ('<'),
       ('>'),
       ('/'),
       ('?'),
       (' '),
       (NULL);

INSERT INTO cookie_sales
    (first_name, sales, sale_date)
VALUES ('Линдси', 32.02, '2007-3-6'),
       ('Пэрис', 26.53, '2007-3-6'),
       ('Бритни', 11.25, '2007-3-6'),
       ('Николь', 18.96, '2007-3-6'),
       ('Линдси', 9.16, '2007-3-7'),
       ('Пэрис', 1.52, '2007-3-7'),
       ('Бритни', 43.21, '2007-3-7'),
       ('Николь', 8.05, '2007-3-7'),
       ('Линдси', 17.62, '2007-3-8'),
       ('Пэрис', 24.19, '2007-3-8'),
       ('Бритни', 3.40, '2007-3-8'),
       ('Николь', 15.21, '2007-3-8'),
       ('Линдси', 0, '2007-3-9'),
       ('Пэрис', 31.99, '2007-3-9'),
       ('Бритни', 2.58, '2007-3-9'),
       ('Николь', 0, '2007-3-9'),
       ('Линдси', 2.34, '2007-3-10'),
       ('Пэрис', 13.44, '2007-3-10'),
       ('Бритни', 8.78, '2007-3-10'),
       ('Николь', 26.82, '2007-3-10'),
       ('Линдси', 3.71, '2007-3-11'),
       ('Пэрис', 0.56, '2007-3-11'),
       ('Бритни', 34.19, '2007-3-11'),
       ('Николь', 7.77, '2007-3-11'),
       ('Линдси', 16.23, '2007-3-12'),
       ('Пэрис', 0, '2007-3-12'),
       ('Бритни', 4.50, '2007-3-12'),
       ('Николь', 19.22, '2007-3-12');

INSERT INTO my_contacts
(last_name, first_name, phone, email, gender, birthday, profession, city,
 state, status, interests, seeking)
VALUES ('Мур', 'Найджел', '5552311111', 'nigelmoore@ranchersrule.com', 'М',
        '1975-08-28', 'Фермер', 'Остин', 'TX', 'Не женат',
        'животные, лошади, кино', 'Незамужняя женщина'),
       ('Салливан', 'Реджи', '5552311122', 'me@kathieleeisaflake.com', 'М',
        '1955-03-20', 'Комик', 'Кембридж', 'MA', 'Не женат',
        'животные, коллекционные карточки, геопоиск', 'Женщина');

UPDATE my_contacts
SET interest1 = SUBSTRING_INDEX(interests, ',', 1),

    interests = TRIM(RIGHT(interests, (CHAR_LENGTH(interests) -
                                       CHAR_LENGTH(interest1) - 1))),

    interest2 = SUBSTRING_INDEX(interests, ',', 1),

    interests = TRIM(RIGHT(interests, (CHAR_LENGTH(interests) -
                                       CHAR_LENGTH(interest2) - 1))),

    interest3 = SUBSTRING_INDEX(interests, ',', 1),

    interests = TRIM(RIGHT(interests, (CHAR_LENGTH(interests) -
                                       CHAR_LENGTH(interest3) - 1))),

    interest4 = interests;

ALTER TABLE my_contacts
    DROP COLUMN interests;

-- Старая версия со связью "многие-ко-многим" по отношению к таблице my_contacts
CREATE TABLE interests
(
    int_id     INT         NOT NULL AUTO_INCREMENT PRIMARY KEY,
    interest   VARCHAR(50) NOT NULL,
    contact_id INT         NOT NULL,
    CONSTRAINT my_contacts_contact_id_fk
        FOREIGN KEY (contact_id)
            REFERENCES my_contacts (contact_id)
);

-- Новая версия со связями "один-ко-многим" по отношению к таблице contact_interest
CREATE TABLE interests
(
    interest_id INT         NOT NULL AUTO_INCREMENT PRIMARY KEY,
    interest    VARCHAR(50) NOT NULL
);


CREATE TABLE contact_interest
(
    contact_id  INT NOT NULL,
    interest_id INT NOT NULL,
    CONSTRAINT my_contacts_contact_id_fk
        FOREIGN KEY (contact_id)
            REFERENCES my_contacts (contact_id),
    CONSTRAINT interests_interest_id_fk
        FOREIGN KEY (interest_id)
            REFERENCES interests (interest_id)
);

INSERT INTO interests (interest)
SELECT LOWER(i.interest)
FROM (SELECT interest1 interest
      FROM my_contacts
      UNION
      SELECT interest2 interest
      FROM my_contacts
      UNION
      SELECT interest3 interest
      FROM my_contacts
      UNION
      SELECT interest4 interest
      FROM my_contacts) i
GROUP BY i.interest
HAVING LENGTH(i.interest) > 0
ORDER BY i.interest;

ALTER TABLE my_contacts
    ADD COLUMN prof_id   INT NOT NULL,
    ADD COLUMN zip_code  INT NOT NULL,
    ADD COLUMN status_id INT NOT NULL;

UPDATE my_contacts
SET prof_id   = 1,
    zip_code  = 1,
    status_id = 1;

ALTER TABLE my_contacts
    ADD CONSTRAINT profession_prof_id_fk
        FOREIGN KEY (prof_id)
            REFERENCES profession (prof_id),
    ADD CONSTRAINT zip_code_zip_code_fk
        FOREIGN KEY (zip_code)
            REFERENCES zip_code (zip_code),
    ADD CONSTRAINT status_status_id_fk
        FOREIGN KEY (status_id)
            REFERENCES status (status_id);

CREATE TABLE description
(
    id          INT NOT NULL,
    gender      CHAR(1),
    description VARCHAR(50),
    `when`      DATE,
    CONSTRAINT clown_info_id_fk
        FOREIGN KEY (id)
            REFERENCES clown_info (id)
);

SELECT prof_id
FROM profession
WHERE profession = 'учитель';

SELECT status_id
FROM profession
WHERE status = '---';

INSERT INTO my_contacts
(last_name, first_name, phone, email, gender, birthday, prof_id, zip_code,
 status_id)
VALUES ('Мэрфи', 'Пэт', '5551239', 'patmurphy@someemail.com', 'X',
        '1978-04-15',
        (SELECT prof_id FROM profession WHERE profession = 'учитель'),
        '10087',
        (SELECT status_id
         FROM status
         WHERE status = 'в браке не состоит'));


CREATE VIEW job_raises AS
SELECT mc.first_name,
       mc.last_name,
       mc.email,
       mc.phone,
       jc.salary                          current_salary,
       jd.salary_low                      desired_salary,
       desired_salary - current_salary AS raise
FROM job_current jc
         INNER JOIN job_desired jd
         INNER JOIN my_contacts mc
WHERE jc.contact_id = jd.contact_id
  AND jc.contact_id = mc.contact_id;

CREATE TABLE piggy_bank
(
    id        INT     NOT NULL AUTO_INCREMENT PRIMARY KEY,
    coin      CHAR(1) NOT NULL CHECK (coin IN ('P', 'N', 'D', 'Q')),
    coin_year INT
);

CREATE VIEW pb_quarters AS
SELECT *
FROM piggy_bank
WHERE coin = 'Q';

INSERT INTO piggy_bank
    (coin, coin_year)
VALUES ('Q', 1950),
       ('P', 1972),
       ('N', 2005),
       ('Q', 1999),
       ('Q', 1981),
       ('D', 1940),
       ('Q', 1980),
       ('P', 2001),
       ('D', 1926),
       ('P', 1999);

CREATE VIEW pb_dimes AS
SELECT *
FROM piggy_bank
WHERE coin = 'D'
WITH CHECK OPTION;

-- **********************************************
ALTER USER root@localhost
    IDENTIFIED BY 'newpassword';



