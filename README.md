# Домашнее задание к занятию "`12.2 Работа с данными (DDL/DML)`" - `Алифанов Сергей`

---
---
### Задание 1
1.1. Поднимите чистый инстанс MySQL версии 8.0+. Можно использовать локальный сервер или контейнер Docker.

1.2. Создайте учётную запись sys_temp. 

1.3. Выполните запрос на получение списка пользователей в базе данных. (скриншот)

![Название скриншота 1](https://github.com/Adrenokrome72/alifanov-hw-12-02/blob/main/1.jpg)`

1.4. Дайте все права для пользователя sys_temp. 

1.5. Выполните запрос на получение списка прав для пользователя sys_temp. (скриншот)

![Название скриншота 2](https://github.com/Adrenokrome72/alifanov-hw-12-02/blob/main/2.jpg)`

1.6. Переподключитесь к базе данных от имени sys_temp.

Для смены типа аутентификации с sha2 используйте запрос: 
```sql
ALTER USER 'sys_test'@'localhost' IDENTIFIED WITH mysql_native_password BY 'password';
```
1.6. По ссылке https://downloads.mysql.com/docs/sakila-db.zip скачайте дамп базы данных.

1.7. Восстановите дамп в базу данных.

1.8. При работе в IDE сформируйте ER-диаграмму получившейся базы данных. При работе в командной строке используйте команду для получения всех таблиц базы данных. (скриншот)

![Название скриншота 3](https://github.com/Adrenokrome72/alifanov-hw-12-02/blob/main/3.jpg)`

*Результатом работы должны быть скриншоты обозначенных заданий, а также простыня со всеми запросами.*

`Простыня:`

```
sudo dpkg -i mysql-apt-config_0.8.26-1_all.deb
sudo apt update
sudo apt upgrade
sudo apt-get install mysql-server
systemctl status mysql
sudo mysql -u root -p
CREATE USER 'sys_temp'@'localhost' IDENTIFIED BY '12345';
SELECT User,Host FROM mysql.user;
GRANT ALL PRIVILEGES ON * . * TO 'sys_temp'@'localhost'
SHOW GRANTS FOR 'sys_temp'@'localhost';
sudo mysql -u sys_temp -p


```


### Задание 2
Составьте таблицу, используя любой текстовый редактор или Excel, в которой должно быть два столбца: в первом должны быть названия таблиц восстановленной базы, во втором названия первичных ключей этих таблиц. Пример: (скриншот/текст)
```
Название таблицы | Название первичного ключа
customer         | customer_id
rental		 | rental_id
payment		 | payment_id
inventory	 | inventory_id
store		 | store_id
staff		 | staff_id
address		 | address_id
city		 | city_id
country		 | country_id
actor		 | actor_id
film_actor	 | actor_id film_id
film		 | film_id
language	 | language_id
film_category	 | film_id category_id
category	 | category_id
sales_by_film_category | -
film_text	 | film_id
sales_by_store	 | -
actor_info	 | -
film_list	 | -
nicer_but_slower_film_list | -
staff_list	 | -
customer_list	 | -
```


