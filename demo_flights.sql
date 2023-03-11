-- Кто летел позавчера рейсом Москва (SVO) — Новосибирск (OVB) на месте 1A,
-- и когда он забронировал свой билет?
SELECT passenger_name, book_date
FROM tickets t
         JOIN bookings b
              ON t.book_ref = b.book_ref
         JOIN boarding_passes bp
              ON t.ticket_no = bp.ticket_no
         JOIN flights f
              ON bp.flight_id = f.flight_id
WHERE bp.seat_no = '1A'
  AND f.departure_airport = 'SVO'
  AND f.arrival_airport = 'OVB'
  AND f.scheduled_departure::date =
      bookings.now()::date - INTERVAL '2 day';

-- Сколько мест осталось незанятыми вчера на рейсе PG0404?
-- Аргументом EXISTS является обычный оператор SELECT, т. е. подзапрос.
-- Выполнив запрос, система проверяет, возвращает ли он строки в результате.
-- Если он возвращает минимум одну строку, результатом EXISTS будет «true»,
-- а если не возвращает ни одной - «false»
EXPLAIN ANALYZE
SELECT count(*)
FROM seats s
         JOIN flights f ON s.aircraft_code = f.aircraft_code
WHERE f.flight_no = 'PG0404'
  AND f.scheduled_departure::date = bookings.now()::date - INTERVAL '1 day'
  AND NOT EXISTS(
        SELECT
        FROM boarding_passes bp
        WHERE bp.flight_id = f.flight_id
          AND bp.seat_no = s.seat_no
    );

EXPLAIN ANALYZE
SELECT count(*)
FROM (SELECT s.seat_no
      FROM seats s
      WHERE s.aircraft_code = (SELECT aircraft_code
                               FROM flights
                               WHERE flight_no = 'PG0404'
                                 AND scheduled_departure::date =
                                     bookings.now()::date -
                                     INTERVAL '1 day')
      EXCEPT
      SELECT bp.seat_no
      FROM boarding_passes bp
      WHERE bp.flight_id = (SELECT flight_id
                            FROM flights
                            WHERE flight_no = 'PG0404'
                              AND scheduled_departure::date =
                                  bookings.now()::date -
                                  INTERVAL '1 day')) unoccupied;

-- На каких маршрутах произошли самые длительные задержки рейсов?
-- Выведите список из десяти «лидирующих» рейсов.
SELECT f.flight_no,
       f.scheduled_departure,
       f.actual_departure,
       (f.actual_departure - f.scheduled_departure) delay
FROM flights f
WHERE f.actual_departure IS NOT NULL
ORDER BY delay DESC
LIMIT 10;

SELECT f.flight_no,
       f.scheduled_departure,
       f.actual_departure,
       (f.actual_departure - f.scheduled_departure) delay
FROM flights f
ORDER BY delay DESC NULLS LAST
LIMIT 10;

-- ------------------------------------------------------------------------
--                      Агрегатные функции
-- ------------------------------------------------------------------------
-- Какова минимальная и максимальная продолжительность полета для каждого
-- из возможных рейсов из Москвы в Санкт-Петербург,
-- и сколько раз вылет рейса был задержан больше, чем на час?
SELECT f.flight_no,
       f.scheduled_duration::time,
       min(f.actual_duration)::time,
       max(f.actual_duration)::time,
       sum(CASE
               WHEN f.actual_departure >
                    f.scheduled_departure + INTERVAL '1 hour' THEN 1
               ELSE 0 END) delays_times
FROM flights_v f
WHERE f.departure_city = 'Москва'
  AND f.arrival_city = 'Санкт-Петербург'
  AND f.status = 'Arrived'
GROUP BY f.flight_no, f.scheduled_duration;

-- Найдите самых дисциплинированных пассажиров,
-- которые зарегистрировались на все рейсы первыми.
-- Учтите только тех пассажиров, которые совершали минимум два рейса.
-- Используем тот факт, что номера посадочных талонов выдаются в порядке регистрации.
SELECT t.passenger_name,
       t.ticket_no
FROM tickets t
         JOIN boarding_passes bp ON bp.ticket_no = t.ticket_no
GROUP BY t.passenger_name, t.ticket_no
HAVING max(bp.boarding_no) = 1
   AND count(*) > 1;

-- Сколько человек бывает включено в одно бронирование?

-- 1) количество человек в КАЖДОМ бронировании
SELECT t.book_ref,
       count(*) cnt
FROM tickets t
GROUP BY t.book_ref;
-- 2) Количество бронирований для каждого количества человек
SELECT tt.cnt,
       count(*)
FROM (SELECT t.book_ref,
             count(*) cnt
      FROM tickets t
      GROUP BY t.book_ref) tt
GROUP BY tt.cnt
ORDER BY tt.cnt;

-- ------------------------------------------------------------------------
--                      Оконные функции
-- ------------------------------------------------------------------------
-- Для каждого билета выведите входящие в него перелеты
-- вместе с запасом времени на пересадку на следующий рейс.
-- Ограничьте выборку теми билетами, которые были забронированы неделю назад.

-- Используем оконные функции, чтобы не обращаться к одним и тем же данным два раза.
SELECT tf.ticket_no,
       f.departure_airport,
       f.arrival_airport,
       f.scheduled_arrival,
       lead(f.scheduled_departure) OVER w
           AS next_departure,
       lead(f.scheduled_departure) OVER w -
       f.scheduled_arrival
           AS gap
FROM bookings b
         JOIN tickets t
              ON t.book_ref = b.book_ref
         JOIN ticket_flights tf
              ON tf.ticket_no = t.ticket_no
         JOIN flights f
              ON tf.flight_id = f.flight_id
WHERE b.book_date = bookings.now()::date - INTERVAL '7 day'
    WINDOW w AS (
        PARTITION BY tf.ticket_no
        ORDER BY f.scheduled_departure);

-- Какие сочетания имен и фамилий встречаются чаще всего
-- и какую долю от числа всех пассажиров они составляют?
SELECT passenger_name,
       round(100.0 * cnt / sum(cnt) OVER (), 2)
           AS percent
FROM (SELECT passenger_name,
             count(*) cnt
      FROM tickets
      GROUP BY passenger_name) t
ORDER BY percent DESC;

-- Решить предыдущую задачу отдельно для имен
WITH p AS (SELECT left(passenger_name,
                       position(' ' IN passenger_name))
                      AS passenger_name
           FROM tickets)
SELECT passenger_name,
       round(100.0 * cnt / sum(cnt) OVER (), 2)
           AS percent
FROM (SELECT passenger_name,
             count(*) cnt
      FROM p
      GROUP BY passenger_name) t
ORDER BY percent DESC;

-- ------------------------------------------------------------------------
--                      Массивы
-- ------------------------------------------------------------------------
-- В билете нет указания, в один ли он конец, или туда и обратно.
-- Однако это можно вычислить, сравнив первый пункт отправления с последним пунктом назначения.
-- Выведите для каждого билета аэропорты отправления и
-- назначения без учета пересадок, и признак, взят ли билет
-- туда и обратно.

-- свернём список аэропортов на пути следования в массив
-- с помощью агрегатной функции array_agg и будем работать с ним
WITH t AS (SELECT ticket_no,
                  a,
                  a[1]                      departure,
                  a[cardinality(a)]         last_arrival,
                  a[cardinality(a) / 2 + 1] middle
           FROM (SELECT t.ticket_no,
                        array_agg(f.departure_airport
                                  ORDER BY f.scheduled_departure) ||
                        (array_agg(f.arrival_airport
                                   ORDER BY f.scheduled_departure DESC)
                            )[1] AS a
                 FROM tickets t
                          JOIN ticket_flights tf
                               ON tf.ticket_no = t.ticket_no
                          JOIN flights f
                               ON f.flight_id = tf.flight_id
                 GROUP BY t.ticket_no) t)
SELECT t.ticket_no,
       t.a,
       t.departure,
       CASE
           WHEN t.departure = t.last_arrival
               THEN t.middle
           ELSE t.last_arrival
           END                        arrival,
       (t.departure = t.last_arrival) return_ticket
FROM t;

-- Найдите билеты, взятые туда и обратно, в которых путь «туда» не совпадает с путем «обратно»

-- Найдите такие пары аэропортов, рейсы между которыми в одну и в другую стороны
-- отправляются по разным дням недели.

-- Представление routes содержит массив дней недели
-- && - оператор пересечения массивов
SELECT r1.departure_airport,
       r1.arrival_airport,
       r1.days_of_week dow,
       r2.days_of_week dow_back
FROM routes r1
         JOIN routes r2
              ON r1.arrival_airport = r2.departure_airport
                  AND r1.departure_airport = r2.arrival_airport
WHERE NOT (r1.days_of_week && r2.days_of_week);

-- ------------------------------------------------------------------------
--                      Рекурсивные запросы
-- ------------------------------------------------------------------------
-- Как с помощью минимального числа пересадок
-- можно долететь из Усть-Кута (UKX) в Нерюнгри (CNN),
-- и какое время придется провести в воздухе?

-- Здесь фактически нужно найти кратчайший путь в графе, что делается рекурсивным запросом.
-- https://habr.com/ru/company/postgrespro/blog/318398/
-- Зацикливание предотвращается проверкой по массиву пересадок hops,
-- который строится в процессе выполнения запроса.
-- Т.к. поиск происходит «в ширину», то есть первый же путь,
-- который будет найден, будет кратчайшим по числу пересадок.
-- Чтобы не перебирать остальные пути (которых может быть очень много и которые заведомо
-- длиннее уже найденного), используется признак «маршрут найден» (found).
-- Он рассчитывается с помощью оконной функции bool_or.
WITH RECURSIVE p(
                 last_arrival,
                 destination,
                 hops,
                 flights,
                 flight_time,
                 found
    ) AS (SELECT a_from.airport_code,
                 a_to.airport_code,
                 array [a_from.airport_code],
                 array []::char(6)[],
                 interval '0',
                 a_from.airport_code = a_to.airport_code
          FROM airports a_from,
               airports a_to
          WHERE a_from.airport_code = 'UKX'
            AND a_to.airport_code = 'CNN'
          UNION ALL
          SELECT r.arrival_airport,
                 p.destination,
                 (p.hops || r.arrival_airport)::char(3)[],
                 (p.flights || r.flight_no)::char(6)[],
                 p.flight_time + r.duration,
                 bool_or(r.arrival_airport = p.destination)
                 OVER ()
          FROM p
                   JOIN routes r
                        ON r.departure_airport = p.last_arrival
          WHERE NOT r.arrival_airport = ANY (p.hops)
            AND NOT p.found)
SELECT hops,
       flights,
       flight_time
FROM p
WHERE p.last_arrival = p.destination;

-- Какое максимальное число пересадок может потребоваться,
-- чтобы добраться из одного любого аэропорта в любой другой?

-- теперь начальная итерация должна содержать не одну пару аэропортов,
-- а все возможные пары:
--      каждый аэропорт соединяем с каждым.
-- Для всех таких пар ищем кратчайший путь, а затем выбираем максимальный из них.
-- Конечно, так можно поступить, только если граф маршрутов является связным,
-- но в демонстрационной базе это действительно выполняется.
-- В этом запросе также используется признак «маршрут найден»,
-- но здесь его необходимо рассчитывать отдельно для каждой пары аэропортов.
WITH RECURSIVE p(
                 departure,
                 last_arrival,
                 destination,
                 hops,
                 found
    ) AS (SELECT a_from.airport_code,
                 a_from.airport_code,
                 a_to.airport_code,
                 array [a_from.airport_code],
                 a_from.airport_code = a_to.airport_code
          FROM airports a_from,
               airports a_to
          UNION ALL
          SELECT p.departure,
                 r.arrival_airport,
                 p.destination,
                 (p.hops || r.arrival_airport)::char(3)[],
                 bool_or(r.arrival_airport = p.destination)
                 OVER (PARTITION BY p.departure,
                     p.destination)
          FROM p
                   JOIN routes r
                        ON r.departure_airport = p.last_arrival
          WHERE NOT r.arrival_airport = ANY (p.hops)
            AND NOT p.found)
SELECT max(cardinality(hops) - 1)
FROM p
WHERE p.last_arrival = p.destination;

-- Найдите кратчайший путь, ведущий из Усть-Кута (UKX) в Нерюнгри (CNN),
-- с точки зрения чистого времени перелетов (игнорируя время пересадок).
-- (этот путь может оказаться не оптимальным по числу пересадок.)
WITH RECURSIVE p(
                 last_arrival,
                 destination,
                 hops,
                 flights,
                 flight_time,
                 min_time
    ) AS (SELECT a_from.airport_code,
                 a_to.airport_code,
                 array [a_from.airport_code],
                 array []::char(6)[],
                 interval '0',
                 NULL::interval
          FROM airports a_from,
               airports a_to
          WHERE a_from.airport_code = 'UKX'
            AND a_to.airport_code = 'CNN'
          UNION ALL
          SELECT r.arrival_airport,
                 p.destination,
                 (p.hops || r.arrival_airport)::char(3)[],
                 (p.flights || r.flight_no)::char(6)[],
                 p.flight_time + r.duration,
                 least(
                         p.min_time,
                         min(p.flight_time + r.duration)
                         FILTER (
                             WHERE r.arrival_airport = p.destination
                             ) OVER ()
                     )
          FROM p
                   JOIN routes r
                        ON r.departure_airport = p.last_arrival
          WHERE NOT r.arrival_airport = ANY (p.hops)
            AND p.flight_time + r.duration
              < coalesce(
                        p.min_time,
                        INTERVAL '1 year'
                    ))
SELECT hops,
       flights,
       flight_time
FROM (SELECT hops,
             flights,
             flight_time,
             min(min_time) OVER () min_time
      FROM p
      WHERE p.last_arrival = p.destination) t
WHERE flight_time = min_time;

-- ------------------------------------------------------------------------
--                      Функции и расширения
-- ------------------------------------------------------------------------
-- Найдите расстояние между Калининградом (KGD) и Петропавловском-Камчатским (PKC)

-- В таблице airports имеются координаты аэропортов.
-- Чтобы аккуратно вычислить расстояние между сильно удаленными точками,
-- нужно учесть сферическую форму Земли.
-- Для этого удобно воспользоваться расширением earthdistance
-- (и затем перевести результат из милей в километры)
CREATE EXTENSION IF NOT EXISTS cube;
CREATE EXTENSION IF NOT EXISTS earthdistance;
SELECT round((a_from.coordinates <@> a_to.coordinates) * 1.609344)
FROM airports a_from,
     airports a_to
WHERE a_from.airport_code = 'KGD'
  AND a_to.airport_code = 'PKC';
