CREATE DATABASE test;
-- таблица дисциплин, читаемых в вузе
CREATE TABLE courses
(
    -- текстовый номер курса
    -- название курса
    -- целое число лекционных часов
    c_no  text PRIMARY KEY,
    title text,
    hours integer
);

INSERT INTO courses(c_no, title, hours)
VALUES ('CS301', 'Базы данных', 30),
       ('CS305', 'Сети ЭВМ', 60);

CREATE TABLE students
(
    -- номер студенческого билета
    -- имя студента
    -- год поступления
    s_id       integer PRIMARY KEY,
    name       text,
    start_year integer
);

INSERT INTO students(s_id, name, start_year)
VALUES (1451, 'Анна', 2014),
       (1432, 'Виктор', 2014),
       (1556, 'Нина', 2015);

CREATE TABLE exams
(
    -- номер студенческого билета таблицы students
    -- номер курса таблицы courses
    -- оценка, полученная студентом по некоторой дисциплине
    s_id  integer REFERENCES students (s_id),
    c_no  text REFERENCES courses (c_no),
    score integer,
    CONSTRAINT pk PRIMARY KEY (s_id, c_no)
);

INSERT INTO exams(s_id, c_no, score)
VALUES (1451, 'CS301', 5),
       (1556, 'CS301', 5),
       (1451, 'CS305', 5),
       (1432, 'CS305', 4);

SELECT title AS course_title, hours
FROM courses;

SELECT c_no, title, hours
FROM courses;

SELECT start_year
FROM students;

SELECT DISTINCT start_year
FROM students;

SELECT 2 + 2 AS result;

SELECT c_no, title, hours
FROM courses
WHERE hours > 45;

-- Соединения
SELECT *
FROM courses,
     exams;

SELECT courses.title, exams.s_id, exams.score
FROM courses,
     exams
WHERE courses.c_no = exams.c_no;

SELECT students.name, exams.score
FROM students
         JOIN exams
              ON students.s_id = exams.s_id
                  AND exams.c_no = 'CS305';

-- В выборку попадут все студенты, даже те,
-- которые не сдавали экзамен по указанной дисциплине
SELECT students.name, exams.score
FROM students
         LEFT JOIN exams
                   ON students.s_id = exams.s_id
                       AND exams.c_no = 'CS305';

-- Условия во фразе WHERE применяются к уже готовому результату соединений
-- поэтому, если вынести ограничение на дисциплины из условия соединения,
-- Нина не попадет в выборку ведь для нее exams.c_no не определен
SELECT students.name, exams.score
FROM students
         LEFT JOIN exams ON students.s_id = exams.s_id
WHERE exams.c_no = 'CS305';

-- Подзапросы
-- Пример скалярного выражения, возвращающего ровно 1 строку и ровно 1 столбец
SELECT name,
       (SELECT score
        FROM exams
        WHERE exams.s_id = students.s_id
          AND exams.c_no = 'CS305')
FROM students;

-- Пример скалярного подзапроса в условии фильтрации
-- Получим все экзамены, которые сдавали студенты, поступившие после 2014 года:
SELECT s_id, c_no, score
FROM exams
WHERE (SELECT start_year
       FROM students
       WHERE students.s_id = exams.s_id) > 2014;

-- Подзапрос, возвращающий произвольное количество строк
-- Список студентов, получивших какие-нибудь оценки по указанному курсу
SELECT name, start_year
FROM students
WHERE s_id IN (SELECT s_id
               FROM exams
               WHERE c_no = 'CS305');

-- Инвертированный подзапрос
-- Список студентов, не получивших ни одной отличной оценки
-- Такой запрос вернёт и всех студентов, не получивших ВООБЩЕ НИ ОДНОЙ оценки
SELECT name, start_year
FROM students
WHERE s_id NOT IN
      (SELECT s_id FROM exams WHERE score = 5);

-- предикат EXISTS проверяет, что подзапрос возвратил хотя бы 1 строку
SELECT name, start_year
FROM students
WHERE NOT EXISTS(SELECT s_id
                 FROM exams
                 WHERE exams.s_id = students.s_id
                   AND score = 5);

-- Выведем имена студентов и их оценки по предмету «Базы данных»
SELECT s.name, ce.score
FROM students s
         JOIN (SELECT ex.c_no, ex.score, ex.s_id
               FROM courses,
                    exams ex
               WHERE courses.c_no = ex.c_no
                 AND courses.title = 'Базы данных') ce
              ON s.s_id = ce.s_id;

-- Аналогичный запрос без использования подзапросов
SELECT s.name, e.score
FROM students s,
     courses c,
     exams e
WHERE c.c_no = e.c_no
  AND c.title = 'Базы данных'
  AND s.s_id = e.s_id;

-- Сортировка
SELECT s_id, c_no, score
FROM exams
ORDER BY score, s_id, c_no DESC;

-- Группировка
-- общее количество проведенных экзаменов,
-- количество сдававших их студентов и средний балл:
SELECT count(*),
       count(DISTINCT s_id),
       avg(score)
FROM exams;

-- Аналогичная информация с разбивкой по курсам
-- в GROUP BY указываем ключи группировки
SELECT c_no,
       count(*),
       count(DISTINCT s_id),
       avg(score)
FROM exams
GROUP BY c_no;

-- Выберем имена студентов, получивших более одной пятерки по любому предмету
SELECT students.name
FROM students,
     exams
WHERE students.s_id = exams.s_id
  AND exams.score = 5
GROUP BY students.name
HAVING count(*) > 1;

-- Изменение и удаление данных
UPDATE courses
SET hours = hours * 2
WHERE c_no = 'CS301';

DELETE
FROM exams
WHERE score < 5;

-- Транзакции
CREATE TABLE groups
(
    -- имя группы
    -- номер студенческого билета старосты из таблицы students
    g_no    text PRIMARY KEY,
    monitor integer NOT NULL REFERENCES students (s_id)
);

-- Добавим в таблицу students номер группы из таблицы groups
ALTER TABLE students
    ADD g_no text REFERENCES groups (g_no);

-- Создадим теперь группу «A-101» и поместим в нее всех студентов, а старостой сделаем Анну.
-- Тут возникает затруднение. С одной стороны, мы НЕ МОЖЕМ СОЗДАТЬ ГРУППУ, НЕ УКАЗАВ СТАРОСТУ.
-- А с другой, НЕЛЬЗЯ НАЗНАЧИТЬ АННУ СТАРОСТОЙ, ЕСЛИ ОНА ЕЩЕ НЕ ВХОДИТ В ГРУППУ.
-- Это привело бы к появлению в базе данных логически некорректных, несогласованных данных.
-- Мы столкнулись с тем, что две операции надо совершить одновременно,
-- потому что ни одна из них не имеет смысла без другой.
-- Такие операции, составляющие логически неделимую единицу работы, называются транзакцией.

-- начнем транзакцию
BEGIN;
-- добавим группу вместе со старостой
INSERT INTO groups(g_no, monitor)
SELECT 'A-101', s_id
FROM students
WHERE name = 'Анна';
-- Теперь переведем всех студентов в созданную группу:
UPDATE students
SET g_no = 'A-101';
-- завершим транзакцию, зафиксировав все сделанные изменения
COMMIT;

-- Полнотекстовый поиск
-- наброски конспекта лекций преподавателя курсов, разбитые на главы-лекции
CREATE TABLE course_chapters
(
    -- название курса из таблицы courses
    -- номер главы конспекта
    -- содержимое главы
    c_no     text REFERENCES courses (c_no),
    ch_no    text,
    ch_title text,
    txt      text,
    CONSTRAINT pkt_ch PRIMARY KEY (ch_no, c_no)
);

INSERT INTO course_chapters(c_no, ch_no, ch_title, txt)
VALUES ('CS301', 'I', 'Базы данных',
        'С этой главы начинается наше знакомство ' ||
        'с увлекательным миром баз данных'),
       ('CS301', 'II', 'Первые шаги',
        'Продолжаем знакомство с миром баз данных. ' ||
        'Создадим нашу первую текстовую базу данных'),
       ('CS305', 'I', 'Локальные сети',
        'Здесь начнется наше полное приключений ' ||
        'путешествие в интригующий мир сетей');

SELECT ch_no no, ch_title, txt
FROM course_chapters;

-- 0 строк
-- LIKE не знает, что в родительном падеже следует искать «баз данных»
-- или «базу данных» в творительном.
SELECT txt
FROM course_chapters
WHERE txt LIKE '%базы данных%';

-- 1 строка
-- строка из главы I не будет найдена, т.к. в другом падеже
SELECT txt
FROM course_chapters
WHERE txt LIKE '%базу данных%';

ALTER TABLE course_chapters
    ADD txtvector TSVECTOR;

UPDATE course_chapters
SET txtvector = to_tsvector('russian', txt);

-- слова сократились до своих неизменяемых частей (лексем)
-- появились цифры, означающие позицию вхождения слова в текст (некоторые слова вошли 2 раза)
-- в строку не вошли предлоги (союзы, и прочие не значимые для поиска стоп-слова)
SELECT txtvector
FROM course_chapters;

-- Для более продвинутого поиска включим в поисковую область и названия глав.
-- Причем, дабы подчеркнуть их важность, мы наделим их весом при помощи функции setweight.
UPDATE course_chapters
SET txtvector = setweight(to_tsvector('russian', ch_title), 'B') || ' ' ||
                setweight(to_tsvector('russian', txt), 'D');

-- у лексем появился относительный вес - B и D (из 4 возможных A, B, C, D)
-- Это придает дополнительную гибкость при составлении запросов
SELECT txtvector
FROM course_chapters;

-- to_tsquery() приводит символьное выражение к типу данных tsquery, который используют в запросах
-- оператор соответствия @@ выполняет работу, аналогичную LIKE.
-- возвращает true, если tsvector (документ) соответствует tsquery (запросу)
-- Синтаксис оператора не допускает выражение естественного языка с пробелами,
-- такие как «база данных», поэтому слова соединяются логическим оператором «и».
-- Аргумент russian указывает на конфигурацию, которую использует СУБД.
-- Она определяет подключаемые словари и парсер, разбивающий фразу на отдельные лексемы.
SELECT ch_title
FROM course_chapters
WHERE txtvector @@
      to_tsquery('russian', 'базы & данные');

-- Введенные веса позволяют вывести записи по результатам рейтинга:
-- Массив {0.1, 0.0, 1.0, 0.0} задает веса.
-- Это не обязательный аргумент функции ts_rank_cd,
-- по умолчанию массив {0.1, 0.2, 0.4, 1.0} соответствует D, C, B, A.
-- Вес слова влияет на значимость найденной строки
SELECT ch_title,
       ts_rank_cd('{0.1, 0.0, 1.0, 0.0}', txtvector, q) ts_rank_cd
FROM course_chapters,
     to_tsquery('russian', 'базы & данных') q
WHERE txtvector @@ q
ORDER BY ts_rank_cd DESC;

-- модифицируем выдачу.
-- Будем считать, что найденные слова хотим выделить жирным шрифтом в странице html.
-- Функция ts_headline задает наборы символов, обрамляющих слово,
-- а также минимальное и максимальное количество слов в строке:
SELECT ts_headline(
               'russian',
               txt,
               to_tsquery('russian', 'мир'),
               'StartSel=<b>, StopSel=</b>, MaxWords=50, MinWords=5'
           )
FROM course_chapters
WHERE to_tsvector('russian', txt) @@
      to_tsquery('russian', 'мир');

-- Работа с JSON-объектами
CREATE TABLE student_details
(
    de_id   int,
    s_id    int REFERENCES students (s_id),
    details JSON,
    CONSTRAINT pk_d PRIMARY KEY (s_id, de_id)
);

INSERT INTO student_details
    (de_id, s_id, details)
VALUES (1, 1451,
        '{
          "достоинства": "отсутствуют",
          "недостатки": "неумеренное употребление мороженого"
        }'),
       (2, 1432,
        '{
          "хобби": {
            "гитарист": {
              "группа": "Постгрессоры",
              "гитары": [
                "страт",
                "телек"
              ]
            }
          }
        }'),
       (3, 1556,
        '{
          "хобби": "косплей",
          "достоинства": {
            "мать-героиня": {
              "Вася": "м",
              "Семен": "м",
              "Люся": "ж",
              "Макар": "м",
              "Саша": "сведения отсутствуют"
            }
          }
        }'),
       (4, 1451,
        '{
          "статус": "отчислена"
        }');

SELECT s.name, sd.details
FROM student_details sd,
     students s
WHERE s.s_id = sd.s_id;

-- поищем достоинства студентов
-- обратимся к содержанию ключа «достоинство»,
-- используя специальный оператор ->>:
SELECT s.name, sd.details
FROM student_details sd,
     students s
WHERE s.s_id = sd.s_id
  AND sd.details ->> 'достоинства' IS NOT NULL;

SELECT s.name, sd.details
FROM student_details sd,
     students s
WHERE s.s_id = sd.s_id
  AND sd.details ->> 'достоинства' IS NOT NULL
  AND sd.details ->> 'достоинства' != 'отсутствуют';

-- На каких инструментах играет Витя
-- Запрос ничего не выдаст, т.к. пара ключ-значение находится внутри иерархии JSON
-- и вложена в пары более высокого уровня
SELECT sd.de_id, s.name, sd.details
FROM student_details sd,
     students s
WHERE s.s_id = sd.s_id
  AND sd.details ->> 'гитары' IS NOT NULL;

-- оператор #> позволяет спуститься с "хобби" вниз по иерархии
SELECT sd.de_id,
       s.name,
       sd.details #> '{хобби,гитарист,гитары}' AS details
FROM student_details sd,
     students s
WHERE s.s_id = sd.s_id
  AND sd.details #> '{хобби,гитарист,гитары}' IS NOT NULL;

-- Работа с JSONB
-- Такие данные можно плотно упаковать и поиск по ним работает быстрее.
-- Используется чаще, чем JSON
ALTER TABLE student_details
    ADD details_b jsonb;

UPDATE student_details
SET details_b = to_jsonb(details);

SELECT de_id, details_b
FROM student_details;

-- Для работы с jsonb набор операторов больше. Один из
-- полезнейших операторов — оператор вхождения в объект
-- @>. Он напоминает #> для json.
-- найдем запись, где упоминается дочь матери-героини Люся
SELECT s.name,
       jsonb_pretty(sd.details_b) json
FROM student_details sd,
     students s
WHERE s.s_id = sd.s_id
  AND sd.details_b @>
      '{"достоинства":{"мать-героиня":{}}}';

-- jsonb_each() разворачивает пары ключ-значение:
SELECT s.name,
       jsonb_each(sd.details_b) pairs
FROM student_details sd,
     students s
WHERE s.s_id = sd.s_id
  AND sd.details_b @>
      '{"достоинства":{"мать-героиня":{}}}';

-- Запрос с функцией jsonb_path_query() для поиска увлекающихся косплеем
-- $ — текущий контекст элемента
-- выражение с $ задает область JSON, которая подлежит обработке,
-- в том числе фигурирует в фильтре. Остальная часть в этом случае для работы недоступна
-- @ — текущий контекст в выражении-фильтре. Перебираются пути, доступные в выражении с $.
SELECT s_id,
       jsonb_path_query(
               details::jsonb,
               '$.хобби ? (@ == "косплей")'
           )
FROM student_details;

-- иерархия действует внутри выражения $, ОГРАНИЧИВАЮЩЕГО ПОИСК
-- задаем для каждой записи область поиска внутри ветви "хобби.гитарист.группа"
-- которой в JSON соответствует единственное значение "Постгрессоры", так что и перебирать нечего
SELECT s_id,
       jsonb_path_query(
               details::jsonb,
               '$.хобби.гитарист.группа ? (@ =="Постгрессоры")'
           )
FROM student_details;

-- иерахия действует внутри выражения @, ПОДСТАВЛЯЕМОГО ПРИ ПЕРЕБОРЕ
-- перебираем все ветви, идущие от гитариста,
-- в выражении фильтра мы прописали путь-ветвь "группа"
-- В такой синтаксической конструкции нам надо заранее знать иерархию внутри JSON
SELECT s_id,
       jsonb_path_query(
               details::jsonb,
               '$.хобби.гитарист ? (@.группа == "Постгрессоры").группа'
           )
FROM student_details;

-- двойной метасимвол используется, когда иерархия неизвестна
SELECT s_id,
       jsonb_path_exists(
               details::jsonb,
               '$.** ? (@ == "страт")'
           )
FROM student_details;