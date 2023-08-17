# Домашнее задание к занятию "`12.4 SQL. Часть 2`" - `Алифанов Сергей`

### Задание 1

Одним запросом получите информацию о магазине, в котором обслуживается более 300 покупателей, и выведите в результат следующую информацию: 
- фамилия и имя сотрудника из этого магазина;
- город нахождения магазина;
- количество пользователей, закреплённых в этом магазине.

```
SELECT CONCAT(s.first_name, ' ' , s.last_name) AS Employee, c.city AS City, COUNT(c2.store_id) AS Customers
FROM staff s
JOIN store s2 ON s.store_id = s2.store_id
JOIN address a ON s2.address_id = a.address_id
JOIN city c ON a.city_id = c.city_id
JOIN customer c2 ON s2.store_id = c2.store_id
GROUP BY s.staff_id
HAVING  COUNT(c2.store_id) > 300

```

![Название скриншота 1](https://github.com/Adrenokrome72/alifanov-hw-12-04/blob/main/1.jpg)

### Задание 2

Получите количество фильмов, продолжительность которых больше средней продолжительности всех фильмов.

```

SELECT AVG(`length`) FROM film f2


SELECT COUNT(film_id) AS 'Хронометраж больше 115 мин.'  
FROM film f
WHERE `length` > (SELECT AVG(`length`) FROM film f2)

```

![Название скриншота 2](https://github.com/Adrenokrome72/alifanov-hw-12-04/blob/main/2.jpg)

![Название скриншота 3](https://github.com/Adrenokrome72/alifanov-hw-12-04/blob/main/3.jpg)

### Задание 3

Получите информацию, за какой месяц была получена наибольшая сумма платежей, и добавьте информацию по количеству аренд за этот месяц.

```

SELECT DATE_FORMAT(p.payment_date, '%m.%Y') AS 'Самый доходный месяц', count(r.rental_id) 'Количество аренд'  
FROM payment p INNER JOIN 
     rental r ON p.rental_id = r.rental_id 
GROUP BY DATE_FORMAT(p.payment_date, '%m.%Y') 
ORDER BY  sum(p.amount) DESC
LIMIT 1

```

![Название скриншота 4](https://github.com/Adrenokrome72/alifanov-hw-12-04/blob/main/4.jpg)

