# Дипломная работа к курсу Системный администратор - `Алифанов Сергей`

## Задача
Ключевая задача — разработать отказоустойчивую инфраструктуру для сайта, включающую мониторинг, сбор логов и резервное копирование основных данных. Инфраструктура должна размещаться в [Yandex Cloud](https://cloud.yandex.com/) и отвечать минимальным стандартам безопасности: запрещается выкладывать токен от облака в git. Используйте [инструкцию](https://cloud.yandex.ru/docs/tutorials/infrastructure-management/terraform-quickstart#get-credentials).

### Пошаговое выполнение

1. Конфигурационный файл [main.tf](https://github.com/Adrenokrome72/alifanov-sys-diplom/blob/main/test-terraform/terraform/main.tf) содержит в себе следующие установки:
  Настройки сети:
- 1 сеть, 4 подсети, 1 NAT-шлюз, 6 security-group под каждый сервис, 1 target group, содержащая в себе backend group, http-router и balancer.
  Настройки виртуальных машин:
- 7 виртуальных машин: vm1 и vm2 для размещения web-серверов, prometheus vm, elasticsearch vm, grafana vm, kibana vm - сервисы, bastion vm - управление хостами.
2. Запускаем развертывание инфраструктуры при помощи команды : `terraform apply -var-file=terraform.tfvars`
3. По завершении получаем сообщение об успешном развертывании и адреса созданых машин:
![Результат команды](https://github.com/Adrenokrome72/alifanov-sys-diplom/blob/main/img/1.jpg)
4. Теперь всё готово для развертывания самих сервисов с помощью Ansible.
5. Для улучшения автоматизации мною был добавлен отдельный [playbook](https://github.com/Adrenokrome72/alifanov-sys-diplom/blob/main/test-terraform/terraform/ansible/0_deploy_all.yaml) для развертывания сразу всех сервисов в определенном порядке, необходмым для правильного создания зависимостей между сервисами.
6. Запускаем его и дожидаемся окончания установки всех сервисов. В случае успешной установки увидим следующее сообщение:
![Завершение установки Ansible playbook](https://github.com/Adrenokrome72/alifanov-sys-diplom/blob/main/img/2.jpg)
7. После завершения используем также заранее подготовленный [Bash-скрипт](https://github.com/Adrenokrome72/alifanov-sys-diplom/blob/main/test-terraform/terraform/ansible/check_status.sh) для проверки статуса сервисов, а также информации о запущенных виртуальных машинах, сетей и снэпшотов.
8. В результате получим следующее:
![Статус сервиса kibana](https://github.com/Adrenokrome72/alifanov-sys-diplom/blob/main/img/3.jpg )
![Статус сервиса nginx](https://github.com/Adrenokrome72/alifanov-sys-diplom/blob/main/img/4.jpg )
![Статус сервиса elasticsearch](https://github.com/Adrenokrome72/alifanov-sys-diplom/blob/main/img/5.jpg )
![Статус сервиса prometheus](https://github.com/Adrenokrome72/alifanov-sys-diplom/blob/main/img/6.jpg )
![Статус сервиса grafana](https://github.com/Adrenokrome72/alifanov-sys-diplom/blob/main/img/10.jpg )
![yc compute instance list](https://github.com/Adrenokrome72/alifanov-sys-diplom/blob/main/img/8.jpg )
![yc compute snapshot-schedule list](https://github.com/Adrenokrome72/alifanov-sys-diplom/blob/main/img/9.jpg )
![curl -v](https://github.com/Adrenokrome72/alifanov-sys-diplom/blob/main/img/11.jpg )
9. Видим, что всё работает исправно, следовательно можем проверить web-страницы доступных сервисов, а именно:
- Работающие дашборды [Grafana](http://51.250.39.4:3000):
![Grafana Dashboard 1](https://github.com/Adrenokrome72/alifanov-sys-diplom/blob/main/img/13.jpg )
![Grafana Dashboard 2](https://github.com/Adrenokrome72/alifanov-sys-diplom/blob/main/img/14.jpg )
- Приходящие логи через filebeat в [elasticsearch](http://51.250.38.197:5601/app/discover#/?_g=()&_a=(columns:!(),filters:!(),index:'filebeat-*',interval:auto,query:(language:kuery,query:''),sort:!(!('@timestamp',desc)))):
![Elasticsearch](https://github.com/Adrenokrome72/alifanov-sys-diplom/blob/main/img/15.jpg )
![Elasticsearch1](https://github.com/Adrenokrome72/alifanov-sys-diplom/blob/main/img/16.jpg )
![Elasticsearch2](https://github.com/Adrenokrome72/alifanov-sys-diplom/blob/main/img/17.jpg )
- Работающий balancer и [web-странцицы](http://158.160.133.203:80): 
![web](https://github.com/Adrenokrome72/alifanov-sys-diplom/blob/main/img/12.jpg )
