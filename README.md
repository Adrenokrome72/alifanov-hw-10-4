# Домашнее задание к занятию "`12.3 SQL. Часть 1`" - `Алифанов Сергей`

---
### Задание 1

Получите уникальные названия районов из таблицы с адресами, которые начинаются на “K” и заканчиваются на “a” и не содержат пробелов.

```
SELECT DISTINCT district
FROM address
WHERE district LIKE 'K%a' AND district NOT LIKE 'K% %a'
```
![Название скриншота 1](https://github.com/Adrenokrome72/alifanov-hw-12-03/blob/main/1.jpg)


### Задание 2

Получите из таблицы платежей за прокат фильмов информацию по платежам, которые выполнялись в промежуток с 15 июня 2005 года по 18 июня 2005 года **включительно** и стоимость которых превышает 10.00.

`SELECT amount, payment_date FROM payment WHERE amount > 10 AND payment_date BETWEEN '2005-06-15 00:00:00' AND '2005-06-18 23:59:59'`

![Название скриншота 2](https://github.com/Adrenokrome72/alifanov-hw-12-03/blob/main/2.jpg)


### Задание 3

Получите последние пять аренд фильмов.

```
SELECT rental_id, rental_date, inventory_id, customer_id, staff_id 
FROM rental
ORDER BY rental_id DESC LIMIT 5
```
![Название скриншота 3](https://github.com/Adrenokrome72/alifanov-hw-12-03/blob/main/3.jpg)


### Задание 4

Одним запросом получите активных покупателей, имена которых Kelly или Willie. 

Сформируйте вывод в результат таким образом:
- все буквы в фамилии и имени из верхнего регистра переведите в нижний регистр,
- замените буквы 'll' в именах на 'pp'.

```
SELECT LOWER(CONCAT(REPLACE(first_name, 'LL', 'PP'), ' ', last_name)), active
FROM customer
WHERE first_name LIKE 'willie'
OR first_name LIKE 'kelly'
```

![Название скриншота 4](https://github.com/Adrenokrome72/alifanov-hw-12-03/blob/main/4.jpg)
