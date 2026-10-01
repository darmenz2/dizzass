# D-01: диагностический запуск ARM без доступа к оборудованию

**Это не cgminer, не прошивка и не майнер.** Проверяются запуск ELF, `uname`,
монотонные часы и чистые кодировщики. Хешрейт и шары не создаются. Проверка не
подтверждает готовность T21-драйвера, libc/pthread, Stratum, БП, датчиков и защит.

## Состав и ограничения

Из базы `bf8cd0513440f91f8a34c69137d0436e6fc30c8a` без изменений используются
`integration/work_tx88.c`, кодировщик `integration/bm1368_control.c` и
`reconstruction/support/crc5.c`. Восемь файлов проверяются по SHA-256 из manifest.
Неиспользуемый reset удаляется линкером; проверка ELF требует его отсутствия.
CRC, транспорт и майнинговое ядро повторно не создаются.

2275 утверждений: известные CRC, точные TX88 для всех 32 слотов, границы,
сохранение входа и выходов при ошибке, перекрытие буферов, шесть команд BM1368.
Часть утверждений проверяет защитные байты; это не 2275 независимых сценариев.
Пакеты формируются только в памяти и не передаются оборудованию.

Два статических файла без libc и динамического загрузчика: ARMv7 LE Linux EABI
(soft-float, без FPU) и AArch64 LE (без SIMD/FPU). Четыре фиксированных syscall:
`write` только в stdout (fd 1), `uname`, `clock_gettime(CLOCK_MONOTONIC)`, `exit`.
Нет открытия файлов, устройств, ioctl, сети, потоков, UART/GPIO/I2C, изменения
сервисов и автозапуска. Имя хоста, полученное вместе с uname, не выводится.
Пароли, конфигурация и ключи не читаются и не выводятся.

`verify.py` проверяет ELF, отсутствие загрузчика, W+X, исполняемого стека,
неразрешённых символов, дополнительных SVC и точные инструкции syscall-обёрток.
Это структурный аудит, **не seccomp и не формальное доказательство**. Запускать
только файл с совпавшим SHA-256. Блокирующий stdout способен задержать процесс;
это не watchdog. Выводить в обычный терминал, не в устройство или зависший канал.

## Ручной запуск на тестовой плате

В существующей SSH-сессии сначала:

```sh
uname -m
uname -r
```

`armv7l` / `armv8l` — файл `dizzass-noio-armv7`; `aarch64` — файл
`dizzass-noio-aarch64`. При другом результате не угадывать. Сведения с конкретной
платы пока не получены. Название T21 и ARM32 reference ELF не доказывают ABI
всей установленной системы. Reference изучается только как данные, не исполняется.

На компьютере распаковать пакет. Создать на плате новую пустую папку:

```sh
mktemp -d /tmp/dizzass-noio.XXXXXX
```

Скопировать в созданную папку только два `dizzass-noio-*` и `SHA256SUMS`.
Перейти именно в эту папку. Не перезаписывать существующие файлы.
Останавливать или заменять штатный майнер не требуется.

```sh
sha256sum -c SHA256SUMS
```

Продолжать только при двух `OK`. Если команды нет — проверить те же SHA-256
другим доступным средством на плате, не пропускать проверку.
Выполнить только один подходящий вариант:

```sh
# Только armv7l / armv8l
chmod 700 ./dizzass-noio-armv7
./dizzass-noio-armv7
rc=$?
printf 'exit=%s\n' "$rc"
```

```sh
# Только aarch64
chmod 700 ./dizzass-noio-aarch64
./dizzass-noio-aarch64
rc=$?
printf 'exit=%s\n' "$rc"
```

Ожидается `CLOCK_MONOTONIC=PASS`, `CHECKS=0x000008e3`, `SELFTEST=PASS`,
`HARDWARE_NOT_TESTED=1`, `POOL_ACCEPTED_SHARES=0`, `exit=0`.
Сохранить весь вывод, включая KERNEL_MACHINE / KERNEL_RELEASE.

При зависании — Ctrl+C в этой сессии. При Permission denied, Exec format error,
Illegal instruction или ненулевом exit прекратить пробу и передать точный вывод.
Не перемонтировать разделы, не отключать защиты, не заменять библиотеки.
Нет install-скрипта, NAND-записи, смены пула и фонового процесса. Удалять впоследствии
только свои три файла и созданную временную папку; не применять широкие маски.

## Воспроизведение на компьютере

Нужны Clang/LLD, readelf, Python 3, GCC и QEMU user mode. QEMU нужен компьютеру
разработчика, не ASIC. Из корня исходников, каждый выходной каталог новый:

```sh
python3 integration/diagnostics/t21_noio/build.py --cc clang --out build/d01
python3 integration/diagnostics/t21_noio/verify.py build/d01/dizzass-noio-*
python3 integration/diagnostics/t21_noio/test_verify.py --build build/d01
python3 integration/diagnostics/t21_noio/check_vectors.py
python3 integration/diagnostics/t21_noio/test.py --cc gcc --out build/d01-gcc
python3 integration/diagnostics/t21_noio/test.py --cc clang --out build/d01-clang
python3 integration/diagnostics/t21_noio/test.py --cc gcc --sanitize --out build/d01-gcc-san
python3 integration/diagnostics/t21_noio/test.py --cc clang --sanitize --out build/d01-clang-san
python3 integration/diagnostics/t21_noio/qemu_test.py --build build/d01 --out build/d01-qemu
```

Сборщик не скачивает зависимости и не запускает майнер. Сохраняет команды,
логи, версии и хеши. Разные Clang/LLD могут дать другие бинарные SHA-256;
проверять именно полученные файлы, не переносить успешность между версиями.

Host-тесты моделируют эффекты syscall для ошибок/вывода. ASan/UBSan выполняются
для host-сборки, не внутри freestanding ARM. Четыре изменения кодировщиков должны
скомпилироваться и быть отвергнуты содержательно. 18 искажений ELF проверяются
без исполнения. Эталоны независимо пересчитываются через binascii и GF(2)-деление.

QEMU исполняет ARM-код, но обращения к ядру обслуживает ядро компьютера.
Пять моделей CPU × три режима = 15 прогонов; это не полная плата T21 и не её
периферия. Проверка на настоящей контрольной плате остаётся отдельным шагом.

Новые файлы GPL-3.0-only, лицензии зависимостей сохранены; см. корневой COPYING.
Reference firmware и его бинарники в диагностический пакет не включаются.
