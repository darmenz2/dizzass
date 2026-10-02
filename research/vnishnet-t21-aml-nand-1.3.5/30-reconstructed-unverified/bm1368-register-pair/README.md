# BM1368: последовательность регистров A8/18, VNish 1.3.5

Восстановлен обычный метод `cgminer 0xe3c04` / `hwscan 0xf3618`, слот `+0x94`.
Он читает COMMON-кеш регистров `0xa8`, затем `0x18`, каждый раз заново берёт
chain index устройства и преобразует оба полученных слова по условию
`flag == 0` или `flag != 0`. Затем существующий BM1368 writer записывает
`0xa8`, и только после успеха — `0x18`, оба раза с mode `1` и NULL chip pointer.
Любой ненулевой результат достигнутого чтения или записи даёт `-1` и
пропускает последующие вызовы. Успех всей последовательности даёт `0`.

Новый заголовок `integration/bm1368_register_pair_135.h` и отдельный
`chip1368-register-pair.c` включаются через `VN135_BM1368_REGISTER_PAIR_135`.
`vn135_bm1368_configure_register_pair_135` использует типизированный COMMON
reader, существующие `vn135_reg_cache_get_chain`, BM1368 writer/encoder/CRC
и chain cache setter. Новый кеш и второе ядро майнера не добавляются;
`Makefile.am` и прежние production sources не изменены.

| Условие | Слово регистра 0xa8 | Слово регистра 0x18 |
| --- | --- | --- |
| Любой ненулевой flag | `cached_a8 \| 0x10f` | `cached_18 & ~0xf00000` |
| Нулевой flag | `cached_a8 & ~0xf0` | `cached_18 \| 0xff0f0000` |

Оригинальный метод не инициализирует output locals до чтения. Каждый
достигнутый reader обязан присвоить output прежде, чем его читать, и вернуть
валидное слово при успехе. При отказе output игнорируется; подстановка нуля
не добавлена. Собственного логирования, ожидания, ACK, retry или rollback
метод не содержит. Внутренние diagnostics/guards существующих нижних API
остаются отдельной границей; ошибка writer может следовать после dispatch.

[STATIC_CONTRACT.md](STATIC_CONTRACT.md) содержит точные границы, порядок
callback effects и разбор шести cgminer products: один TST с неиспользуемыми
flags и пять parity-ветвей. `evidence/` хранит ограниченные оригинальные
байты и свидетельство конструктора. Полные оригинальные ELF не публикуются.

Из этого каталога на Linux:

```sh
make test sanitize controls CC=gcc
make test sanitize controls CC=clang BUILD_DIR=/tmp/dizzass-register-pair-clang
make evidence
python3 -O -B verify_evidence.py --hwscan /path/to/exact/original/hwscan
```

Фактически выполненные проверки и их результаты записаны в
[validation.json](validation.json). Host-проверки относятся к двум ветвям flag,
маскам, fresh index для каждого чтения, пропуску последующих вызовов при
отказах и сохранению захваченных слов при callback mutations. Они не
устанавливают физическое назначение пары регистров, безопасный режим,
ASIC ACK или работоспособность T21. Прямой T21 caller и исходное имя метода
остаются неизвестными. Оригинальные инструкции не исполнялись и не
интерпретировались; production driver не регистрировался.
