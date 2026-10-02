# BM1368: chain drive strength, VNish 1.3.5

Восстановлен обычный метод `cgminer 0xe3a1c` / `hwscan 0xf34fc`, слот `+0x88`.
Он один раз читает COMMON-кеш регистра `0x58` для chain index устройства,
заменяет биты `12–15` значением `input & 15` и вызывает существующий BM1368
writer с mode `1` и NULL chip pointer. Отказ чтения пропускает запись;
ненулевой результат достигнутого вызова даёт `-1` и отдельную диагностику.

Новый заголовок `integration/bm1368_chain_drive_strength_135.h` и отдельный
`chip1368-chain-drive-strength.c` включаются через
`VN135_BM1368_CHAIN_DRIVE_STRENGTH_135`. Используются существующие
`vn135_reg_cache_get_chain`, BM1368 writer/encoder/CRC и chain cache setter.
Reader имеет типизированный интерфейс без chip argument; структуры logging
переиспользованы из предыдущего per-chip метода. Родное ядро cgminer и кеш
не дублируются; `Makefile.am` и прежние production sources не изменены.

[STATIC_CONTRACT.md](STATIC_CONTRACT.md) содержит точные границы, логирование,
callback domain и доказательство недостижимости двух parity-ветвей. В
`evidence/` сохранены ограниченные байты и свидетельства конструктора,
строк и initializer. Опечатка исходной строки чтения
`Failed to read cached driver strenght register` сохранена буквально.
Полные оригинальные ELF в публикацию не добавлены.

Из этого каталога на Linux:

```sh
make test sanitize controls CC=gcc
make test sanitize controls CC=clang BUILD_DIR=/tmp/dizzass-chain-drive-clang
make evidence
python3 -O -B verify_evidence.py --hwscan /path/to/exact/original/hwscan
```

Фактически выполненные проверки и их ограничения записаны в
[validation.json](validation.json). Host-проверки относятся к возвращаемому
результату, callbacks, полю регистра, cache/send failures и позднему чтению
device index. Существующий chain setter обновляет COMMON и тот же числовой
slot каждого chip table; согласованная раскладка таблиц остаётся условием
композиции. Внутренние диагностики оригинального getter и его access traces
не восстановлены этим методом; структурные guards существующего host API
остаются отдельной границей.

Первый запуск Clang ASan/UBSan завершился signal139 без sanitizer report.
Тот же бинарник затем прошёл повторный и четыре дополнительных запуска;
причина первого сбоя не установлена и отдельно сохранена в validation.json.

Прямой вызов из T21 и аппаратная работоспособность не подтверждены.
Оригинальные инструкции не исполнялись и не интерпретировались; host-код
не доказывает ASIC ACK, принятые пулом шары или безопасную настройку drive.
