# Дипломная работа к курсу Системный администратор - `Алифанов Сергей`

## Задача
Ключевая задача — разработать отказоустойчивую инфраструктуру для сайта, включающую мониторинг, сбор логов и резервное копирование основных данных. Инфраструктура должна размещаться в [Yandex Cloud](https://cloud.yandex.com/) и отвечать минимальным стандартам безопасности: запрещается выкладывать токен от облака в git. Используйте [инструкцию](https://cloud.yandex.ru/docs/tutorials/infrastructure-management/terraform-quickstart#get-credentials).

### Пошаговое выполнение


2. Файлы терраформа и плейбуки размещены в настоящем репозитории.

3. Развернем инфраструктуру с помощью terraform. Запускаем построение при помощи команд:

- Инициализируем систему:

`terraform init`

- Проверяем правильность файлов:

`terraform plan`

- Запускаем построение инфраструктуры:

`terraform apply`

4. По итогу мы видим, что построение прошло успешно и мы можем видеть назначенные IP-адреса всем хостам

5. Тестируем сайт командой 


`curl -v <публичный IP балансера>:80`

- получим:

![Результат команды](https://github.com/Adrenokrome72/alifanov-sys-diplom/blob/main/img/2.jpg )

6. Подключаемся через ssh  к хосту `bastion_host_public`:

`ssh alifanov@<ip>`

- пароль `admin`

![Результат команды](https://github.com/Adrenokrome72/alifanov-sys-diplom/blob/main/img/3.jpg )

7. Сперва нам нужно настроить на данном хосте видимость остальных хостов в сети, поэтому переходим к настройке 

`sudo nano /etc/hosts`

8. После чего нам необходимо создать ключ ssh и расшарить его по остальным хостам с помощью команды:

`ssh-keygen`

`ssh-copy-id <название хоста>`

![Результат команды](https://github.com/Adrenokrome72/alifanov-sys-diplom/blob/main/img/4.jpg )

9. Добавляем ранее подготовленный репозиторий git с сервисами и конфигами для того чтобы расшарить между хостами необходимые сервисы.

`git clone https://github.com/Adrenokrome72/config_and_install`

10. Запускаем по очереди все плейбуки:

`ansible-playbook web.yaml`
`ansible-playbook ELK.yaml`
`ansible-playbook monitor.yaml`

- по завершении убеждаемся, что всё установилось без ошибок, видя сообщения :

![Результат команды web](https://github.com/Adrenokrome72/alifanov-sys-diplom/blob/main/img/5.jpg )
![Результат команды ELK](https://github.com/Adrenokrome72/alifanov-sys-diplom/blob/main/img/6.jpg )
![Результат команды monitor](https://github.com/Adrenokrome72/alifanov-sys-diplom/blob/main/img/7.jpg )

11. Переходим на elasticsearch хост:

`ssh alifanov@elastic`

12. Устанавливаем пароль для elastic и kibana:

![Смена пароля](https://github.com/Adrenokrome72/alifanov-sys-diplom/blob/main/img/8.jpg )

13. Раскомментируем Network в `sudo nano /etc/elasticsearch/elasticsearch.yml` и впишем IP elastic хоста

![Настройка](https://github.com/Adrenokrome72/alifanov-sys-diplom/blob/main/img/9.jpg )

14. После чего нам необходимо получить сертификат для соединения с kibana:

![Получаем сертификат](https://github.com/Adrenokrome72/alifanov-sys-diplom/blob/main/img/10.jpg )

15. Копируем сертификат, переходим на хоста с kibana, и вставляем:

![Вставляем сертификат](https://github.com/Adrenokrome72/alifanov-sys-diplom/blob/main/img/11.jpg )

16. Редактируем `sudo nano /etc/kibana/kibana.yml` и перезагружаем сервис.

![Отредактировали1](https://github.com/Adrenokrome72/alifanov-sys-diplom/blob/main/img/12.jpg )
![Отредактировали2](https://github.com/Adrenokrome72/alifanov-sys-diplom/blob/main/img/13.jpg)

17. Переходим на хосты web1 и web2 для настройки передачи логов аналогичным образом, не перепутав адреса хостов:

![Отредактировали3](https://github.com/Adrenokrome72/alifanov-sys-diplom/blob/main/img/14.jpg )
![Отредактировали4](https://github.com/Adrenokrome72/alifanov-sys-diplom/blob/main/img/15.jpg )
![Отредактировали5](https://github.com/Adrenokrome72/alifanov-sys-diplom/blob/main/img/16.jpg )

18. По завершении работы с веб серверами, переходим хосту с prometheus и соединяем хосты между собой и перезагружаем:

![Объединили хосты](https://github.com/Adrenokrome72/alifanov-sys-diplom/blob/main/img/17.jpg )
![Перезагрузили](https://github.com/Adrenokrome72/alifanov-sys-diplom/blob/main/img/18.jpg )

19. После успешного завершения настроек, мы можем подключиться к веб форме grafana и проверяем подключение и импортируем самый популярный дэшборд, который включает в себя всё самое для нас необходимое:

![Grafana](https://github.com/Adrenokrome72/alifanov-sys-diplom/blob/main/img/19.jpg )

20. Проверяем, что снэпшоты активированы:

![Snaps](https://github.com/Adrenokrome72/alifanov-sys-diplom/blob/main/img/20.jpg )

21. В заключении проверяем всё на работоспособность:

[Grafana](http://158.160.11.45:3000/)

![Elastic](https://github.com/Adrenokrome72/alifanov-sys-diplom/blob/main/img/21.jpg)

![logstash](https://github.com/Adrenokrome72/alifanov-sys-diplom/blob/main/img/22.jpg)

terraform apply -var-file="testing.tfvars"

[Kibana](http://130.193.40.20:5601) - login: elastic; pass:Elastic555 

[Web1 and 2](http://51.250.109.241/)
