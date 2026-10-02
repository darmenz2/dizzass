# BM1368: per-chip drive strength, VNish 1.3.5

Восстановлен обычный метод `cgminer 0xe3728` / `hwscan 0xf33ec`, слот `+0x84`.
Он один раз читает кеш регистра `0x58`, меняет биты `12–15` и вызывает
существующий BM1368 writer для исходного chip pointer. Ошибка чтения
пропускает запись; ошибка записи возвращает `-1` с отдельной диагностикой.

Новый заголовок `integration/bm1368_drive_strength_135.h` и отдельный
`chip1368-drive-strength.c` включаются через `VN135_BM1368_DRIVE_STRENGTH_135`.
Используются существующие `vn135_reg_cache_get_chip` и BM1368 writer/encoder/
CRC/cache setter. Поиск в кеше и родное ядро cgminer не дублируются;
`Makefile.am` и прежние production sources не изменены.

[STATIC_CONTRACT.md](STATIC_CONTRACT.md) содержит точные границы, logging,
callback domain и доказательство недостижимости семи parity-ветвей.
`evidence/` хранит ограниченные оригинальные байты и свидетельства строк,
конструктора и initializer. Оригинальные ELF в эту публикацию не добавлены.

Из этого каталога на Linux:

```sh
make test sanitize controls CC=gcc
make test sanitize controls CC=clang BUILD_DIR=/tmp/dizzass-drive-clang
make evidence
python3 -O -B verify_evidence.py --hwscan /path/to/exact/original/hwscan
```

Фактически выполненные проверки записаны в [validation.json](validation.json).
Тесты проверяют все четыре бита поля, сохранение остальных битов, signed index
границы, NULL writer при отказе чтения, порядок callbacks и поздние изменения
device/chip/cache. Результаты host-кода не подтверждают ASIC ACK или T21 runtime.
Оригинальные инструкции не исполнялись и не интерпретировались.

Следующий кандидат после свежей проверки областей — `cgminer 0xe3a1c` /
`hwscan 0xf34fc`, слот `+0x88`; его полное поведение ещё не восстановлено.
