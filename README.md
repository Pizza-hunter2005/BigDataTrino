# BigDataTrino
Анализ больших данных - лабораторная работа №4 - ETL реализованный с помощью Trino

Одним из самых популярных фреймворков для анализа данных Big Data является Trino. Trino позволяет с помощью SQL анализировать большие объёмы данных.

Что необходимо сделать?

Необходимо реализовать ETL с помощью Trino, который трансформирует данные из источников ClickHouse (первые 5 файлов mock_data.csv) и PostgreSQL (следующие 5 файлов mock_data.csv) в модель данных снежинка/звезда в ClickHouse, а затем на основе модели данных снежинка/звезда создать ряд отчетов по данным в ClickHouse. Каждый отчет представляет собой отдельную таблицу в ClickHouse

Какие отчеты надо создать?
1. Витрина продаж по продуктам
Цель: Анализ выручки, количества продаж и популярности продуктов.
 - Топ-10 самых продаваемых продуктов.
 - Общая выручка по категориям продуктов.
 - Средний рейтинг и количество отзывов для каждого продукта.
2. Витрина продаж по клиентам
Цель: Анализ покупательского поведения и сегментация клиентов.
 - Топ-10 клиентов с наибольшей общей суммой покупок.
 - Распределение клиентов по странам.
 - Средний чек для каждого клиента.
3. Витрина продаж по времени
Цель: Анализ сезонности и трендов продаж.
 - Месячные и годовые тренды продаж.
 - Сравнение выручки за разные периоды.
 - Средний размер заказа по месяцам.
4. Витрина продаж по магазинам
Цель: Анализ эффективности магазинов.
 - Топ-5 магазинов с наибольшей выручкой.
 - Распределение продаж по городам и странам.
 - Средний чек для каждого магазина.
5. Витрина продаж по поставщикам
Цель: Анализ эффективности поставщиков.
 - Топ-5 поставщиков с наибольшей выручкой.
 - Средняя цена товаров от каждого поставщика.
 - Распределение продаж по странам поставщиков.
6. Витрина качества продукции
Цель: Анализ отзывов и рейтингов товаров.
 - Продукты с наивысшим и наименьшим рейтингом.
 - Корреляция между рейтингом и объемом продаж.
 - Продукты с наибольшим количеством отзывов.

![Лабораторная работа №4](https://github.com/user-attachments/assets/8cde5065-780b-46c3-867f-5d4332b42e28)


Алгоритм:
1. Клонируете к себе этот репозиторий.
2. Устанавливаете себе инструмент для работы с запросами SQL (рекомендую DBeaver).
3. Устанавливаете базу данных PostgreSQL (рекомендую установку через docker).
4. Устанавливаете базу данных ClickHouse (рекомендую установку через docker).
5. Устанавливаете Trino (рекомендую установку через Docker).
6. Скачиваете файлы с исходными данными mock_data( * ).csv, где ( * ) номера файлов. Всего 10 файлов, каждый по 1000 строк.
7. Импортируете данные в БД PostgreSQL (например, через механизм импорта csv в DBeaver). Всего в таблице mock_data должно находиться 5000 строк из 5 файлов.
8. Импортируете данные в БД ClickHouse (например, через механизм импорта csv в ClickHouse). Всего в таблице mock_data должно находиться 5000 строк из других 5 файлов.
9. Анализируете исходные данные с помощью запросов.
10. Выявляете сущности фактов и измерений.
11. Реализуете скрипты Trino, которые по аналогии с первой лабораторной работой перекладывают исходные данные из PostgreSQL и ClickHouse в модель снежинку/звезда в ClickHouse. (Убедитесь в коннективности Trino, PostgreSQL, ClickHouse настройте сеть между Trino, PostgreSQL, ClickHouse если используете Docker).
12. Устанавливаете ClickHouse (рекомендую установку через Docker. Убедитесь в коннективности Spark и Clickhouse, настройте сеть между Spark и ClickHouse).
13. Реализуете расчеты на Trino, которые создают все 6 перечисленных выше отчетов в виде 6 отдельных таблиц в ClickHouse.
14. Проверяете отчеты в каждой базе данных средствами языка самой БД (ClickHouse - SQL (DBeaver)).
15. Отправляете работу на проверку лаборантам.

Что должно быть результатом работы?

1. Репозиторий, в котором есть исходные данные mock_data().csv, где () номера файлов. Всего 10 файлов, каждый по 1000 строк.
2. Файл docker-compose.yml с установкой PostgreSQL, Trino, ClickHouse с заполненными данными в PostgreSQL, ClickHouse из файлов mock_data(*).csv.
3. Инструкция, как запускать Trino-скрипты для проверки лабораторной работы.
4. Код Trino трансформации данных из исходной модели в снежинку/звезду в ClickHouse.
5. Код Trino трансформации данных из снежинки/звезды в отчеты в ClickHouse.



## Архитектура

Поток данных:

```text
CSV 1-5 -> ClickHouse.mock_data  --\
                                      -> Trino -> ClickHouse snowflake -> ClickHouse reports
CSV 6-10 -> PostgreSQL.mock_data --/
```

В качестве основы использована модель из лабораторной `BDSnowflake`: данные нормализуются в измерения клиентов, продавцов, магазинов, поставщиков, товаров и факт продаж.

Служебная объединенная таблица:

- `stg_mock_data` - единый слой из PostgreSQL и ClickHouse.


Отчеты:

- `report_product_sales`;
- `report_customer_sales`;
- `report_time_sales`;
- `report_store_sales`;
- `report_supplier_sales`;
- `report_product_quality`.

## Запуск

Перейти в папку проекта:

```bash
cd BigDataTrino
```

Запустить PostgreSQL, ClickHouse и Trino:

```bash
docker compose up -d
```

При первом запуске:

- PostgreSQL автоматически загрузит 5000 строк из последних 5 CSV-файлов;
- ClickHouse автоматически загрузит 5000 строк из первых 5 CSV-файлов;
- Trino подключится к ним через каталоги `postgresql` и `clickhouse`.

Проверить источники:

```bash
docker compose exec postgres psql -U bigdata -d bigdata -c "select count(*) from mock_data;"
docker compose exec clickhouse clickhouse-client --user bigdata --password bigdata --query "select count() from mock_data"
docker compose exec trino trino --execute "show catalogs"
```

## Запуск Trino ETL

Построить модель снежинки в ClickHouse:

```bash
docker compose exec trino trino --file /sql/01_build_snowflake.sql
```

Построить 6 отчетных таблиц:

```bash
docker compose exec trino trino --file /sql/02_build_reports.sql
```


## Проверка результата

Проверить факт продаж и отчеты:

```bash
docker compose exec clickhouse clickhouse-client --user bigdata --password bigdata --query "
select 'fact_sales' as table_name, count() as rows from fact_sales
union all select 'report_product_sales', count() from report_product_sales
union all select 'report_customer_sales', count() from report_customer_sales
union all select 'report_time_sales', count() from report_time_sales
union all select 'report_store_sales', count() from report_store_sales
union all select 'report_supplier_sales', count() from report_supplier_sales
union all select 'report_product_quality', count() from report_product_quality
"
```

Результат:

```text
fact_sales               10000
report_product_sales      1000
report_customer_sales     1000
report_time_sales           12
report_store_sales       10000
report_supplier_sales    10000
report_product_quality    1000
```

Примеры аналитических запросов через Trino:

```bash
docker compose exec trino trino --execute "
select product_name, quantity_sold, revenue
from clickhouse.default.report_product_sales
order by sales_rank
limit 10
"
```

```bash
docker compose exec trino trino --execute "
select customer_first_name, customer_last_name, customer_country, total_spent, avg_check
from clickhouse.default.report_customer_sales
order by customer_rank
limit 10
"
```

```bash
docker compose exec trino trino --execute "
select sale_year, sale_month, revenue, orders_count, avg_order_amount
from clickhouse.default.report_time_sales
order by sale_year, sale_month
"
```

## Подключения

PostgreSQL:

- host: `localhost`
- port: `55432`
- database: `bigdata`
- user: `bigdata`
- password: `bigdata`

ClickHouse HTTP:

- host: `localhost`
- port: `18123`
- user: `bigdata`
- password: `bigdata`

ClickHouse Native:

- host: `localhost`
- port: `19000`
- user: `bigdata`
- password: `bigdata`

Trino:

- host: `localhost`
- port: `8080`
- user: `student`

## Отчет о работе

1. Подготовлен `docker-compose.yml` с PostgreSQL, ClickHouse и Trino.

2. Настроена автоматическая загрузка источников:
   PostgreSQL получает 5 CSV-файлов, ClickHouse получает другие 5 CSV-файлов.

3. Настроены Trino catalogs:
   `postgresql.properties` для PostgreSQL и `clickhouse.properties` для ClickHouse.

4. Реализован Trino ETL `sql/01_build_snowflake.sql`:
   скрипт объединяет источники, строит staging-таблицу и нормализованную модель снежинки/звезды в ClickHouse.

5. Реализован Trino ETL `sql/02_build_reports.sql`:
   скрипт строит 6 отчетных таблиц в ClickHouse на основе факта продаж и измерений.

