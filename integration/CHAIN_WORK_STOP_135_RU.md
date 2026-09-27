# B-09: остановка work-thread отдельной цепи

Задача #36, координация #2. Восстановлены `c39a8..c3b37`, вложенный
`d2144..d21d3` и dispatch `feeec..feef7` из исходной прошивки 1.3.5.
Это offline comparison; production Makefile.am и native cgminer не изменены.
Зависимостей от ожидающих review PR нет. B-08/#33 — отдельный верхний
coordinator; его код не импортирован и композиция с ним здесь не заявляется.

## Источник

Архив пользователя `vnishnet-t21-aml-nand-v1.3.5.tar.gz`, SHA256
`20fabdd66255889315e61ae2a33ff2e4623566ca430f1cb8c90d9b938dc7b43c`.
Свежая распаковка через `tools/extract_reference.py` дала ELF 6228004 bytes,
SHA256 `b2663b3aa753cc14ae9d3b11a14d3d93c74b605a3e433b02101c3c17c69d95e9`.
Ghidra12.1.4 действительно выполнена; script, C/asm шести функций и log
сохранены в evidence. Проверяются16 диапазонов,14 PC-relative targets,
14 Ghidra artifacts и45 bounded initializer probes. Reference ELF
используется только как данные, не как host executable.

Ghidra initializer `fb994` и method116f00 сохранены как контекст.
Полнота всей инициализации/всех её ветвей не заявляется. Реальные границы
подтверждённого prefix указаны ниже; oracle использует исходные инструкции.

## Порядок исходных действий

| Инструкции | Подтверждённое действие |
|---|---|
| c39b4..c39cc | Cached signed chain+18; отрицательный индекс сразу в log, иначе один fe668 и сравнение cached index/count |
| c3a18..c3a50 | При провале верхней границы index читается снова; log с line2da, severity1, raw uint32 index+1 |
| c39d0..c39d8 | Живой byte318==0 пропускает всё cleanup |
| c3a5c..c3a74 | lock633bf0, head+18=0, tail+1c=0, unlock633bf0 |
| c3a78..c3a8c | Load handle+314; clear byte318; cancel(handle); reload handle; join(handle,NULL) |
| c3a90..c3aa8 | lock(chain+2e0), d2144(chain+2f8), unlock(chain+2e0) |
| c3aac..c3ab0 | feeec(chain+2b8): загрузить живой target из654c1c и tail-call |

Running проверяется один раз; сброс/повторная установка в callback не
добавляет новых проверок. Ошибки lock/cancel/join/cleanup игнорируются.
Handle не обнуляется. Никакой новый успешный return не добавлен:
оригинальный caller не использует incidental r0, поэтому API — void.

`d2144`: load *slot; при non-NULL вызвать release сохранённого pointer,
затем записать NULL в тот же slot. Запись NULL идёт после callback и
перекрывает его замену pointer. При изначальном NULL release отсутствует.
Это очистка одного pointer, не доказательство владения произвольным
native work или полной очистки очереди/цепи.

В log передаются исходные7 аргументов, включая идентичности строк,
а не выдуманный текст. Декодирование строк/логгер остаются внешними.
Opaque `x*(x-1)&1` всегда0 при ARM uint32, включая overflow; Ghidra-only
повторные пути не превращены в повторный free/stop. Oracle исполняет эти
предикаты с исходными инструкциями и разными значениями globals.

## Разрешение feeec и повторное использование UART

`feeec` читает BSS slot654c1c. Оригинальный `fb994` записывает его в fbbfc:
controller0 →116f00; controller1..4 →10e9a0. 45 запусков с controller0..4,
model0/4/7, subtype0/1/UINT32_MAX останавливаются непосредственно при
первой записи этого slot; внешние OS/платформенные функции не выполняются.
Это свидетельство назначения method, не полноценная инициализация
контроллера и не универсальная модельная привязка T21.

В `libbitmain/src/uart.c` уже есть `vn135_uart_destroy` для10e9a0;
переписывать его не нужно. Однако его существующие guard отличаются:

| Исходный10e9a0 | Существующий host helper |
|---|---|
| close для fd!=-1, включая другие отрицательные значения | close только для fd>=0 |
| mutex destroy безусловный | только при mutex_ready=true |
| Нет нового результата успеха | Return0/-2 относится к host API |

Общий coordinator сохраняет обязательный selected-method callback,
читая identity непосредственно перед вызовом. Существующий helper
проверяется во вложенной тестовой связке для первого destroy
инициализированного контекста: fd>=-1, mutex_ready=true, stable UART fields,
без конкурентных пользователей. Native helper вызывается напрямую в
host тестах; original oracle в этих случаях исполняет тело10e9a0.
Это не новый production adapter и не разрешение подменять helper им
вне указанного домена. Method116f00 остаётся явной внешней границей.

Просмотрены `util.c::thr_info_cancel` и `cgminer.c::clean_work/_free_work`.
Первый выбирает по handle, обнуляет его, уничтожает semaphore и не join;
вторые знают native struct work и освобождают его внутренние поля.
Ни один не является молчаливой заменой данного vendor cleanup.
Повторно используется существующий `vn135_shutdown_thread` field type.

## API и домен

`vn135_chain_work_stop_135(view, ops, context)` получает typed host field
views: index, worker, queue head/tail, allocation slot, live UART method,
три object identities. Это не vendor ABI и не новые cgminer work/pool.
Callbacks count/mutex/cancel/join/release/uart_destroy/log обязательны.
Номера адресов — данные; host их не выполняет и не разыменовывает.

Объекты/поля раздельны и валидны. Все field pointers, object identities
и callback pointers в view/ops остаются неизменными. Callbacks могут
синхронно менять значения по этим указателям, но не перенаправлять
проекции и не уничтожать их storage во время вызова.
Не моделируются произвольные aliases, повреждённые pointers, реальные
pthread/OS effects или асинхронные гонки. Проверки не означают, что
cancel/join завершили настоящий поток или устройство перестало работать.

## Выполненные проверки

```sh
make -f integration/chain-work-stop-135.mk CC=gcc CHAIN_STOP_DIR=build/chain-stop-gcc all sanitize negative regressions
make -f integration/chain-work-stop-135.mk CC=clang CHAIN_STOP_DIR=build/chain-stop-clang all sanitize negative regressions
clang --analyze -I. -Iinclude -std=c11 -Wall -Wextra -Wpedantic -Xanalyzer -analyzer-output=text src/backend/work-gen/chain-work-stop.c
```

На GCC11.4 и Clang14:

- Original/C: 613 сценариев /3014 событий /30835 ARM steps /132 PCs.
  Включает56 nested-mode сценариев, из которых40 доходят до original
 10e9a0 и существующего UART helper; остальные проверяют пропуски.
  Возврат incidental r0 не сравнивается, поскольку API void. Сравниваются
  все800 chain bytes,40 queue bytes, guards, callback trace/snapshots и slot.
  45 initializer probes отдельно, не входят в30835 steps.
- Native и ASan+UBSan: 2880 сценариев /47136 assertions каждый, включая
  реальную host allocation/free, canaries, nested UART helper и мутации
  handles/pointers/flags/method. Нет настоящих fd/OS операций.
- 20 отдельно компилируемых semantic mutants отвергнуты original oracle;
  baseline принимает613 fixtures. Compile failure, crash и timeout не
  засчитываются как обнаружение семантической ошибки.
- Старые route/TX88: names7/snapshots16/selections10/worker sets2,
  packets128/CRC36; sanitizer bounds11225.
- Старые Stage5 UART3248 и AML/UART689 original comparisons.
  Их исходные scripts без изменений копируются в отдельную test-root
  каждого compiler; tools/reference используются через symlink.
  Эти Python/shared-library regressions не sanitizer-instrumented.
- Clang analyzer без диагностики; evidence и scoped whitespace проходят.

Non-PIE флаги только у sanitizer test executables: прежний WSL startup
сбой PIE ASan воспроизводился и с пустым main. Production flags не меняются.
CI сохраняет head SHA, версии компиляторов, все логи и semantic-negative
результаты. Локальные логи данного запуска: build/b09-logs/.

Не проверены полный native device_drv, реальная остановка потоков, full
worker composition, UART/ASIC/пул, firmware boot, питание/защиты и принятые
шары. Нет production wiring, slot-barrier изменений, flash или hardware I/O.
