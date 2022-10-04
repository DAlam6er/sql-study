-- База данных перелётов
CREATE DATABASE flight_repository;
-- airport (аэропорт)
--         code (уникальный код аэропорта)
--         country (страна)
--         city (город)
CREATE TABLE airport
(
    code    CHAR(3) PRIMARY KEY,
    country VARCHAR(256) NOT NULL,
    city    VARCHAR(128) NOT NULL
);

-- aircraft (самолет)
--     id
--     model (модель самолета - unique)
CREATE TABLE aircraft
(
    id    SERIAL PRIMARY KEY,
    model VARCHAR(128) NOT NULL
);

-- seat (место в самолете)
--      aircraft_id (самолет)
--      seat_no (номер места в самолете)
CREATE TABLE seat
(
    aircraft_id INT REFERENCES aircraft (id),
    seat_no     VARCHAR(4) NOT NULL,
    PRIMARY KEY (aircraft_id, seat_no)
);

-- flight (рейс)
--         id (номер рейса не уникальный, поэтому нужен id)
--         flight_no (номер рейса)
--         departure_date (дата вылета)
--         departure_airport_code (аэропорт вылета)
--         arrival_date (дата прибытия)
--         arrival_airport_code (аэропорт прибытия)
--         aircraft_id (самолет)
--         status (статус рейса: cancelled, arrived, departed, scheduled)
CREATE TABLE flight
(
    id                     BIGSERIAL PRIMARY KEY,
    flight_no              VARCHAR(16)                       NOT NULL,
    departure_date         TIMESTAMP                         NOT NULL,
    departure_airport_code CHAR(3) REFERENCES airport (code) NOT NULL,
    arrival_date           TIMESTAMP                         NOT NULL,
    arrival_airport_code   CHAR(3) REFERENCES airport (code) NOT NULL,
    aircraft_id            INT REFERENCES aircraft (id)      NOT NULL,
    status                 VARCHAR(32)                       NOT NULL
);

-- ticket (билет на самолет)
--      id
--      passenger_no (номер паспорта пассажира)
--  	passenger_name (имя и фамилия пассажира)
--  	flight_id (рейс)
--  	seat_no (номер места в самолете – flight_id + seat-no - unique)
--  	cost (стоимость)
CREATE TABLE ticket
(
    id             BIGSERIAL PRIMARY KEY,
    passenger_no   VARCHAR(32)                   NOT NULL,
    passenger_name VARCHAR(128)                  NOT NULL,
    flight_id      BIGINT REFERENCES flight (id) NOT NULL,
    seat_no        VARCHAR(4)                    NOT NULL,
    cost           NUMERIC(8, 2)                 NOT NULL
);

-- Вставка данных
INSERT INTO airport (code, country, city)
VALUES ('MNK', 'Беларусь', 'Минск'),
       ('LDN', 'Англия', 'Лондон'),
       ('MSK', 'Россия', 'Москва'),
       ('BSL', 'Испания', 'Барселона');

INSERT INTO aircraft (model)
VALUES ('Боинг 777-300'),
       ('Боинг 737-300'),
       ('Аэробус A320-200'),
       ('Суперджет-100');

-- У всех самолётов будут одинаковые места - декартовое произведение 4x8
INSERT INTO seat (aircraft_id, seat_no)
SELECT id, s.column1
FROM aircraft
         CROSS JOIN (VALUES ('A1'),
                            ('A2'),
                            ('B1'),
                            ('B2'),
                            ('C1'),
                            ('C2'),
                            ('D1'),
                            ('D2')
                     order by 1) s;

INSERT INTO flight (flight_no, departure_date, departure_airport_code,
                    arrival_date, arrival_airport_code, aircraft_id,
                    status)
VALUES ('MN3002', '2020-06-14T14:30', 'MNK', '2020-06-14T18:07', 'LDN', 1,
        'ARRIVED'),
       ('MN3002', '2020-06-16T09:15', 'LDN', '2020-06-16T13:00', 'MNK', 1,
        'ARRIVED'),
       ('BC2801', '2020-07-28T23:25', 'MNK', '2020-07-29T02:43', 'LDN', 2,
        'ARRIVED'),
       ('BC2801', '2020-08-01T11:00', 'LDN', '2020-08-01T14:15', 'MNK', 2,
        'DEPARTED'),
       ('TR3103', '2020-05-03T13:10', 'MSK', '2020-05-03T18:38', 'BSL', 3,
        'ARRIVED'),
       ('TR3103', '2020-05-10T07:15', 'BSL', '2020-05-10T012:44', 'MSK', 3,
        'CANCELLED'),
       ('CV9827', '2020-09-09T18:00', 'MNK', '2020-09-09T19:15', 'MSK', 4,
        'SCHEDULED'),
       ('CV9827', '2020-09-19T08:55', 'MSK', '2020-09-19T10:05', 'MNK', 4,
        'SCHEDULED'),
       ('QS8712', '2020-12-18T03:35', 'MNK', '2020-12-18T06:46', 'LDN', 2,
        'ARRIVED');

INSERT INTO ticket (passenger_no, passenger_name, flight_id, seat_no, cost)
VALUES ('112233', 'Иван Иванов', 1, 'A1', 200),
       ('23234A', 'Петр Петров', 1, 'B1', 180),
       ('SS988D', 'Светлана Светикова', 1, 'B2', 175),
       ('QYASDE', 'Андрей Андреев', 1, 'C2', 175),
       ('POQ234', 'Иван Кожемякин', 1, 'D1', 160),
       ('898123', 'Олег Рубцов', 1, 'A2', 198),
       ('555321', 'Екатерина Петренко', 2, 'A1', 250),
       ('QO23OO', 'Иван Розмаринов', 2, 'B2', 225),
       ('9883IO', 'Иван Кожемякин', 2, 'C1', 217),
       ('123UI2', 'Андрей Буйнов', 2, 'C2', 227),
       ('SS988D', 'Светлана Светикова', 2, 'D2', 277),
       ('EE2344', 'Дмитрий Трусцов', 3, 'А1', 300),
       ('AS23PP', 'Максим Комсомольцев', 3, 'А2', 285),
       ('322349', 'Эдуард Щеглов', 3, 'B1', 99),
       ('DL123S', 'Игорь Беркутов', 3, 'B2', 199),
       ('MVM111', 'Алексей Щербин', 3, 'C1', 299),
       ('ZZZ111', 'Денис Колобков', 3, 'C2', 230),
       ('234444', 'Иван Старовойтов', 3, 'D1', 180),
       ('LLLL12', 'Людмила Старовойтова', 3, 'D2', 224),
       ('RT34TR', 'Степан Дор', 4, 'A1', 129),
       ('999666', 'Анастасия Шепелева', 4, 'A2', 152),
       ('234444', 'Иван Старовойтов', 4, 'B1', 140),
       ('LLLL12', 'Людмила Старовойтова', 4, 'B2', 140),
       ('LLLL12', 'Роман Дронов', 4, 'D2', 109),
       ('112233', 'Иван Иванов', 5, 'С2', 170),
       ('NMNBV2', 'Лариса Тельникова', 5, 'С1', 185),
       ('DSA586', 'Лариса Привольная', 5, 'A1', 204),
       ('DSA583', 'Артур Мирный', 5, 'B1', 189),
       ('DSA581', 'Евгений Кудрявцев', 6, 'A1', 204),
       ('EE2344', 'Дмитрий Трусцов', 6, 'A2', 214),
       ('AS23PP', 'Максим Комсомольцев', 6, 'B2', 176),
       ('112233', 'Иван Иванов', 6, 'B1', 135),
       ('309623', 'Татьяна Крот', 6, 'С1', 155),
       ('319623', 'Юрий Дувинков', 6, 'D1', 125),
       ('322349', 'Эдуард Щеглов', 7, 'A1', 69),
       ('DIOPSL', 'Евгений Безфамильная', 7, 'A2', 58),
       ('DIOPS1', 'Константин Швец', 7, 'D1', 65),
       ('DIOPS2', 'Юлия Швец', 7, 'D2', 65),
       ('1IOPS2', 'Ник Говриленко', 7, 'C2', 73),
       ('999666', 'Анастасия Шепелева', 7, 'B1', 66),
       ('23234A', 'Петр Петров', 7, 'C1', 80),
       ('QYASDE', 'Андрей Андреев', 8, 'A1', 100),
       ('1QAZD2', 'Лариса Потемнкина', 8, 'A2', 89),
       ('5QAZD2', 'Карл Хмелев', 8, 'B2', 79),
       ('2QAZD2', 'Жанна Хмелева', 8, 'С2', 77),
       ('BMXND1', 'Светлана Хмурая', 8, 'В2', 94),
       ('BMXND2', 'Кирилл Сарычев', 8, 'D1', 81),
       ('SS988D', 'Светлана Светикова', 9, 'A2', 222),
       ('SS978D', 'Андрей Желудь', 9, 'A1', 198),
       ('SS968D', 'Дмитрий Воснецов', 9, 'B1', 243),
       ('SS958D', 'Максим Гребцов', 9, 'С1', 251),
       ('112233', 'Иван Иванов', 9, 'С2', 135),
       ('NMNBV2', 'Лариса Тельникова', 9, 'B2', 217),
       ('23234A', 'Петр Петров', 9, 'D1', 189),
       ('123951', 'Полина Зверева', 9, 'D2', 234);

-- Кто летел позавчера рейсом Минск (MNK) - Лондон (LDN) на месте B1?
SELECT *
FROM ticket
         JOIN flight f ON ticket.flight_id = f.id
WHERE seat_no = 'B1'
  AND f.departure_airport_code = 'MNK'
  AND f.arrival_airport_code = 'LDN'
  AND f.departure_date::date = (now() - interval '2 days')::date;

-- * ------- * промежуток времени
SELECT interval '2 years 1 days';
SELECT (now() - interval '2 days') ::date;
SELECT '123'::integer;

-- Сколько мест осталось незанятыми 2020-06-14 на рейсе MN3002?
SELECT t2.count - t1.count
FROM (SELECT f.aircraft_id, count(*)
      FROM ticket t
               JOIN flight f
                    ON t.flight_id = f.id
      WHERE f.flight_no = 'MN3002'
        AND f.departure_date::date = '2020-06-14'
      GROUP BY f.aircraft_id) t1
         JOIN (SELECT aircraft_id, count(*)
               FROM seat
               WHERE aircraft_id = 1
               GROUP BY aircraft_id) t2
              ON t1.aircraft_id = t2.aircraft_id;

SELECT EXISTS(SELECT FROM ticket WHERE id = 2);

-- 2-й вариант NOT EXISTS - не занятые места
-- результат - 2 места, которые не были заняты
SELECT s.seat_no
FROM seat s
WHERE aircraft_id = 1
  AND NOT EXISTS(SELECT t.seat_no
                 FROM ticket t
                          JOIN flight f ON t.flight_id = f.id
                 WHERE f.flight_no = 'MN3002'
                   AND f.departure_date ::date = '2020-06-14'
                   AND s.seat_no = t.seat_no);

-- 3-й вариант с использованием вычитания множеств
SELECT s.aircraft_id,
       s.seat_no
FROM seat s
WHERE s.aircraft_id = 1
EXCEPT
SELECT f.aircraft_id,
       t.seat_no
FROM ticket t
         JOIN flight f ON t.flight_id = f.id
WHERE f.flight_no = 'MN3002'
  AND f.departure_date::date = '2020-06-14';

-- Какие 2 перелета были самые длительные за все время?
SELECT f.id,
       f.arrival_date,
       f.departure_date,
       f.arrival_date - f.departure_date
FROM flight f
ORDER BY (f.arrival_date - f.departure_date) DESC
LIMIT 2;

-- Какая максимальная и минимальная продолжительность перелетов между Минском и Лондоном
-- и сколько было всего таких перелетов?
SELECT first_value(f.arrival_date - f.departure_date)
       over (ORDER BY (f.arrival_date - f.departure_date) DESC) max_value,
       first_value(f.arrival_date - f.departure_date)
       over (ORDER BY (f.arrival_date - f.departure_date))      min_value,
       count(*) OVER ()
FROM flight f
         JOIN airport a on f.arrival_airport_code = a.code
         JOIN airport d on f.departure_airport_code = d.code
WHERE a.city = 'Лондон'
  AND d.city = 'Минск'
LIMIT 1;

-- Какие имена встречаются чаще всего и какую долю от числа всех пассажиров они составляют?
SELECT t.passenger_name,
       count(*),
       round(100.0 * count(*) / (SELECT count(*) FROM ticket), 2)
FROM ticket t
GROUP BY t.passenger_name
ORDER BY 2 DESC;

-- Вывести имена пассажиров, сколько всего каждый с таким именем купил билетов,
-- а также на сколько это количество меньше от того имени пассажира, кто купил билетов больше всего
SELECT t1.*,
       first_value(t1.cnt) over () - t1.cnt diff
FROM (SELECT t.passenger_no,
             t.passenger_name,
             count(*) cnt
      FROM ticket t
      GROUP BY t.passenger_no, t.passenger_name
      ORDER BY 3 DESC) t1;

-- Вывести стоимость всех маршрутов по убыванию.
-- Отобразить разницу в стоимости между текущим и ближайшими в отсортированном списке маршрутами
-- ищем разницу с лидером (у первого элемента нет лидера)
SELECT t1.*,
       COALESCE(lead(t1.sum_cost) OVER (ORDER BY t1.sum_cost),
                t1.sum_cost) - t1.sum_cost diff
FROM (SELECT t.flight_id,
             sum(t.cost) sum_cost
      FROM ticket t
      GROUP BY flight_id
      ORDER BY 2 DESC) t1;