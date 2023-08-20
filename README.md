# Домашнее задание к занятию "`12.5 SQL. Часть 2`" - `Алифанов Сергей`

### Задание 1

Напишите запрос к учебной базе данных, который вернёт процентное отношение общего размера всех индексов к общему размеру всех таблиц.

```
select  TABLE_SCHEMA as 'Database',  
    sum(DATA_LENGTH + INDEX_LENGTH) as 'Общий размер всех таблиц', 
    sum(INDEX_LENGTH) as 'Общий размер всех индексов', 
    round(sum(INDEX_LENGTH) / sum(DATA_LENGTH + INDEX_LENGTH) * 100, 0) as '% отношение индексов ко всем таблицам'
from information_schema.tables
where TABLE_SCHEMA = 'sakila'
group by TABLE_SCHEMA

```


![Название скриншота 1](https://github.com/Adrenokrome72/alifanov-hw-12-05/blob/main/1.jpg)


### Задание 2

Выполните explain analyze следующего запроса:
```sql
select distinct concat(c.last_name, ' ', c.first_name), sum(p.amount) over (partition by c.customer_id, f.title)
from payment p, rental r, customer c, inventory i, film f
where date(p.payment_date) = '2005-07-30' and p.payment_date = r.rental_date and r.customer_id = c.customer_id and i.inventory_id = r.inventory_id
```
Смотрим explain analyze:

```
explain analyze
select distinct concat(c.last_name, ' ', c.first_name),
       sum(p.amount) over (partition by c.customer_id, f.title)
from payment p, rental r, customer c, inventory i, film f
where date(p.payment_date) = '2005-07-30' and
      p.payment_date = r.rental_date and
      r.customer_id = c.customer_id and
      i.inventory_id = r.inventory_id;

```
Получаем:

```
-> Limit: 200 row(s)  (cost=0..0 rows=0) (actual time=6774..6774 rows=200 loops=1)
    -> Table scan on <temporary>  (cost=2.5..2.5 rows=0) (actual time=6774..6774 rows=200 loops=1)
        -> Temporary table with deduplication  (cost=0..0 rows=0) (actual time=6774..6774 rows=391 loops=1)
            -> Window aggregate with buffering: sum(payment.amount) OVER (PARTITION BY c.customer_id,f.title )   (actual time=2855..6522 rows=642000 loops=1)
                -> Sort: c.customer_id, f.title  (actual time=2855..2938 rows=642000 loops=1)
                    -> Stream results  (cost=23.1e+6 rows=16.5e+6) (actual time=7.63..2075 rows=642000 loops=1)
                        -> Nested loop inner join  (cost=23.1e+6 rows=16.5e+6) (actual time=7.61..1817 rows=642000 loops=1)
                            -> Nested loop inner join  (cost=21.5e+6 rows=16.5e+6) (actual time=6.55..1600 rows=642000 loops=1)
                                -> Nested loop inner join  (cost=19.8e+6 rows=16.5e+6) (actual time=5.37..1349 rows=642000 loops=1)
                                    -> Inner hash join (no condition)  (cost=1.65e+6 rows=16.5e+6) (actual time=4.15..82.6 rows=634000 loops=1)
                                        -> Filter: (cast(p.payment_date as date) = '2005-07-30')  (cost=1.94 rows=16500) (actual time=1.13..22.9 rows=634 loops=1)
                                            -> Table scan on p  (cost=1.94 rows=16500) (actual time=1.11..19.4 rows=16044 loops=1)
                                        -> Hash
                                            -> Covering index scan on f using idx_title  (cost=112 rows=1000) (actual time=2.29..2.87 rows=1000 loops=1)
                                    -> Covering index lookup on r using rental_date (rental_date=p.payment_date)  (cost=1 rows=1) (actual time=0.00128..0.00184 rows=1.01 loops=634000)
                                -> Single-row index lookup on c using PRIMARY (customer_id=r.customer_id)  (cost=0.001 rows=1) (actual time=191e-6..218e-6 rows=1 loops=642000)
                            -> Single-row covering index lookup on i using PRIMARY (inventory_id=r.inventory_id)  (cost=0.001 rows=1) (actual time=132e-6..161e-6 rows=1 loops=642000)

```

Ответ:

- перечислите узкие места;

Проведя анализ, можно понять, что в данном запросе, явно лишние действия выполняются при обращении к таблицам `rental` и `inventory`, которые в результате никак не используются, следовательно,  от них можно избавиться. Следовательно, после оператора `where`, избавляемся от лишних условий, а также видим ошибку в условии `r.customer_id = c.customer_id` и исправляем её на `p.customer_id = c.customer_id`, чтобы было корректное обращение к таблице, которая используется. 


- оптимизируйте запрос: внесите корректировки по использованию операторов, при необходимости добавьте индексы.

Оптимизировав запрос, получаем следующее:

```
select distinct concat(c.last_name, ' ', c.first_name),
       sum(p.amount) over (partition by c.customer_id)
from payment p, customer c
where date(p.payment_date) = '2005-07-30' and p.customer_id = c.customer_id

```

Проведя снова `explain analyze` видим следующее:

```
-> Limit: 200 row(s)  (cost=0..0 rows=0) (actual time=9.01..9.04 rows=200 loops=1)
    -> Table scan on <temporary>  (cost=2.5..2.5 rows=0) (actual time=9.01..9.03 rows=200 loops=1)
        -> Temporary table with deduplication  (cost=0..0 rows=0) (actual time=9..9 rows=391 loops=1)
            -> Window aggregate with buffering: sum(payment.amount) OVER (PARTITION BY c.customer_id )   (actual time=7.65..8.8 rows=634 loops=1)
                -> Sort: c.customer_id  (actual time=7.62..7.68 rows=634 loops=1)
                    -> Stream results  (cost=7449 rows=16500) (actual time=0.0795..7.48 rows=634 loops=1)
                        -> Nested loop inner join  (cost=7449 rows=16500) (actual time=0.0731..7.29 rows=634 loops=1)
                            -> Filter: (cast(p.payment_date as date) = '2005-07-30')  (cost=1674 rows=16500) (actual time=0.0608..6.63 rows=634 loops=1)
                                -> Table scan on p  (cost=1674 rows=16500) (actual time=0.0504..5.37 rows=16044 loops=1)
                            -> Single-row index lookup on c using PRIMARY (customer_id=p.customer_id)  (cost=0.25 rows=1) (actual time=865e-6..893e-6 rows=1 loops=634)


```
Сразу видно, что время выполнения запроса существенно изменилось. Было - 6774, стало - 9.03
 

