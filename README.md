# dizzass

Разработка на основе настоящего `ckolivas/cgminer`: переиспользуем его ядро, восстанавливаем только недостающие аппаратные части и подтверждённые отличия VNishNet 1.3.5.

## Рабочая основа

Зафиксированный upstream: `b8491c66e7e22f23a9edf095dd1337ee581e88bd`. История, лицензии и авторство сохранены; чистая база находится в `upstream/ckolivas`. Это выбранная основа, а не доказанный точный предок VNish.

Stage 14 уже импортирован: `migration/STAGE14_IMPORT.json`. Материалы восстановления не удалены.

## Новый подход

Штатные `cgminer.c`, `miner.h`, `util.c`, `sha2.c`, `api.c`, управление заданиями и сетевой обмен остаются основой программы. Не создаём второй cgminer внутри cgminer.

`Makefile.am` возвращён к оригиналу выбранной базы. Массовое подключение восстановленных модулей в production-бинарник отключено. Старый `reconstruction/cgminer-overlay.am` сохранён как исторический материал, но нормальная сборка его больше не включает.

Восстановленные функции и тесты остаются в своих каталогах и собираются отдельно через `Makefile.recovery`. Драйвер, транспорт и автотюн добавляются к нативному ядру по мере готовности, через его API и с явным учётом отличий VNish. Подробная карта: [CGMINER_FIRST_RU.md](integration/CGMINER_FIRST_RU.md). Правила: [AGENTS.md](AGENTS.md).

## Проверка обычного ядра

Пример host-сборки с существующим upstream-драйвером Icarus:

```sh
autoreconf -fi
./configure --enable-icarus --disable-curses CFLAGS='-O2 -fcommon'
make -j2
./cgminer --version
make -s -f Makefile -f integration/native-check.mk dizzass-core-sources > /tmp/dizzass-core-sources.txt
python3 integration/check_native_core.py --sources /tmp/dizzass-core-sources.txt
python3 integration/test_native_core.py
```

Системные зависимости и отдельный CI-прогон описаны в `.github/workflows/cgminer-native.yml`. Наличие workflow не означает успешного прогона; проверяйте результат для нужного commit. Пример не запускает майнинг. Icarus — только конфигурация проверки сборки, не драйвер T21.

## Историческая реконструкция и сравнения

```sh
make -f Makefile.recovery all arm
make -f Makefile.recovery stage14
```

Это отдельные библиотеки/проверки, не новый production runtime. Исходный `overlay-files.json` относится только к импортированному overlay, не ко всему объединённому репозиторию. Старые инструменты импорта/наложения сохранены для воспроизводимости, но не должны возвращать дублирующее ядро в нормальную сборку.

**Поддержка T21, аппаратный запуск, защиты и автотюн пока не завершены. Ни baseline-бинарник, ни recovery-библиотеки не устанавливать вместо штатного `/usr/bin/cgminer`.**
