# BM1368 ANALOG_MUX_CTRL, VNish 1.3.5

Восстановлен отдельный обычный метод `cgminer 0xe35c0` / `hwscan 0xf3354`,
слот конструктора `+0x80`. Он передаёт одну широковещательную запись регистра
`0x54`, значение — младшие три бита аргумента. При ошибке возвращает `-1` и
пишет одну диагностику строки 425; при успехе возвращает `0`.

Используются существующие BM1368 writer/encoder/CRC/cache и только чистое
преобразование `vn135_bm1398_analog_mux_word`. Совпадение преобразования не
подтверждает общую модель чипа. Новый заголовок и отдельная translation unit
включаются через `VN135_BM1368_ANALOG_MUX_135`; `Makefile.am` и существующие
production sources не изменены.

Полный контракт, границы и арифметическое доказательство недостижимости
обфусцированных ветвей — в [STATIC_CONTRACT.md](STATIC_CONTRACT.md).
Bounded original bytes, инструкции, строковые и constructor/GOT witnesses
хранятся в `evidence/`. Исходные ELF в публикацию не добавлены.

Из этого каталога на Linux:

```sh
make test sanitize controls CC=gcc
make test sanitize controls CC=clang BUILD_DIR=/tmp/dizzass-analog-mux-clang
make evidence
python3 -O -B verify_evidence.py --hwscan /path/to/exact/original/hwscan
```

Проверенные результаты этого участка — в [validation.json](validation.json).
Тесты выполняют авторский host-код и записывающие callbacks. Оригинальные
инструкции не запускались и не интерпретировались; T21, UART и пулы не
использовались. Аппаратная работоспособность и полный runtime caller остаются
неподтверждёнными.

Дополнительно сохранён ограниченный [аудит callers предыдущего метода
CLOCK_DELAY_CTRL](../bm1368-chip-pulse-width/caller-audit/audit-report.txt).
Он не установил вызывающий путь T21 и не доказывает неиспользуемость метода.
Следующий независимый кандидат после свежей проверки областей — метод
`cgminer 0xe3728` / `hwscan 0xf33ec`, слот `+0x84`; его поведение ещё требуется
исследовать.
