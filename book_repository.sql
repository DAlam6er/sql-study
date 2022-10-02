CREATE DATABASE book_repository;
-- Создать таблицу для хранения данных о книгах со следующими полями:
-- - идентификатор (id)
-- - название
-- - год издания
-- - количество страниц 	
-- - id автора
CREATE TABLE author
(
    id         SERIAL PRIMARY KEY,
    first_name VARCHAR(128) NOT NULL,
    last_name  VARCHAR(128) NOT NULL
);

-- Создать таблицу авторов книг со следующими полями:
-- - идентификатор (id)
-- - имя
-- - фамилия
CREATE TABLE book
(
    id        BIGSERIAL PRIMARY KEY,
    name      VARCHAR(128) NOT NULL,
    year      SMALLINT     NOT NULL,
    pages     SMALLINT     NOT NULL,
    author_id INT REFERENCES author (id) ON DELETE CASCADE
);

INSERT INTO author (first_name, last_name)
VALUES ('Кей', 'Хорстманн'),
       ('Стивен', 'Кови'),
       ('Тони', 'Роббинс'),
       ('Наполеон', 'Хилл'),
       ('Роберт', 'Кийосаки'),
       ('Дейл', 'Карнеги');

SELECT *
FROM author;

-- Внесение данных
INSERT INTO book (name, year, pages, author_id)
values ('Java. Библиотеку профессионала. Том 1', 2010, 1102,
        (SELECT id FROM author WHERE last_name = 'Хорстманн')),
       ('Java. Библиотеку профессионала. Том 2', 2012, 954,
        (SELECT id FROM author WHERE last_name = 'Хорстманн')),
       ('Java SE 8. Вводный курс', 2015, 203,
        (SELECT id FROM author WHERE last_name = 'Хорстманн')),
       ('7 навыков высокоэффективных людей', 1989, 396,
        (SELECT id FROM author WHERE last_name = 'Кови')),
       ('Разбуди в себе исполина', 1991, 576,
        (SELECT id FROM author WHERE last_name = 'Роббинс')),
       ('Думай и богатей', 1937, 336,
        (SELECT id FROM author WHERE last_name = 'Хилл')),
       ('Богатый папа, бедный папа', 1997, 352,
        (SELECT id FROM author WHERE last_name = 'Кийосаки')),
       ('Квадрант денежного потока', 1998, 368,
        (SELECT id FROM author WHERE last_name = 'Кийосаки')),
       ('Как перестать беспокоиться и начать жить', 1948, 368,
        (SELECT id FROM author WHERE last_name = 'Карнеги')),
       ('Как завоевывать друзей и оказывать влияние на людей', 1936, 352,
        (SELECT id FROM author WHERE last_name = 'Карнеги'));

-- Написать запрос, выбирающий: название книги, год и имя автора,
-- отсортированные по году издания книги в возрастающем порядке.
SELECT b.name,
       b.year,
       (SELECT a.first_name FROM author a WHERE a.id = b.author_id)
FROM book b
ORDER BY b.year;

-- Написать тот же запрос, но для убывающего порядка.
SELECT b.name,
       b.year,
       (SELECT a.first_name FROM author a WHERE a.id = b.author_id)
FROM book b
ORDER BY b.year DESC;

-- Написать запрос, выбирающий количество книг у заданного автора.
SELECT count(*)
FROM book
WHERE author_id = (SELECT id FROM author WHERE first_name = 'Кей');

-- Написать запрос, выбирающий книги, у которых количество страниц больше среднего количества страниц по всем книгам
SELECT *
FROM book
WHERE pages > (SELECT avg(pages)
               FROM book);

-- Написать запрос, выбирающий 5 самых старых книг
SELECT *
FROM book
ORDER BY year
LIMIT 5;

-- Дополнить запрос и посчитать суммарное количество страниц среди этих книг
SELECT sum(t.pages)
FROM (SELECT pages
      FROM book
      ORDER BY year
      LIMIT 5) t;

-- Написать запрос, изменяющий количество страниц у одной из книг
UPDATE book
SET pages = 777
WHERE id = 2
RETURNING *;

-- Написать запрос, удаляющий автора, который написал самую большую книгу
DELETE
FROM book
WHERE author_id = (SELECT author_id
                   FROM book
                   WHERE pages = (SELECT max(pages)
                                  FROM book))
RETURNING *;

DELETE
FROM author
WHERE id = 7
RETURNING *;