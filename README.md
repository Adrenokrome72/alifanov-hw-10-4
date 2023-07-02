# Домашнее задание к занятию "`10.4 «Резервное копирование»`" - `Алифанов Сергей`

### Задание 1

`Основная разница между всеми видами резервного копирования в скорости, надежности и тем, насколько сильно загружается память либо сеть.. Так полное резервное копирование самое медленное, но в то же время самое надежное. В свою очередь дифференциальное и инкрементное в целом похожи, с разницей в точке начала создания бэкапа.`

---

### Задание 2


`Содержимое файлов bacula-dir:`

[bacula-dir](https://github.com/Adrenokrome72/alifanov-hw-10-4/blob/main/bacula-dir.conf)

`bacula-sd:`

[bacula-sd](https://github.com/Adrenokrome72/alifanov-hw-10-4/blob/main/bacula-sd.conf)

`bacula-fd:`

[bacula-fd](https://github.com/Adrenokrome72/alifanov-hw-10-4/blob/main/bacula-fd.conf)


![Скрин 1](https://github.com/Adrenokrome72/alifanov-hw-10-4/blob/main/image.png)

---

### Задание 3

`rsyncd.conf - практически без изменений, за исключение пути папки которая бекапится и дополнения опцией chroot`

```
pid file = /var/run/rsyncd.pid
log file = /var/log/rsyncd.log
transfer logging = true
munge symlinks = yes
use chroot = false
# папка источник для бэкапа
[data]
path = /etc
uid = root
read only = yes
list = yes
comment = Data backup Dir
auth users = backup
secrets file = /etc/rsyncd.scrt


```


`backup-node1.sh :`

[backup-node1.sh](https://github.com/Adrenokrome72/alifanov-hw-10-4/blob/main/backup-node1.sh)
![Screen](https://github.com/Adrenokrome72/alifanov-hw-10-4/blob/main/1111.png)
