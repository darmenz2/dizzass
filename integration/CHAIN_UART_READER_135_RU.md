# B-11: UART reader одной цепи `c36e8`

Задача #40, координация #2. Восстановлен полный control flow `c36e8`
(`c36e8..c3983`, литералы до `c39a7`) и его ожидание `5b150` с вычислением
`d20b4` и счётчиком `d20ac`. Это offline comparison, не production driver.
Нативное ядро cgminer, старые FIFO/UART, общие интерфейсы и ожидающие review
PR не изменены и не импортированы. `c36e8` — entry из `c33d0`, отдельный
от более высокого RX-worker `c4054`; не путать его с публикацией `c3148`.

## Источник и исправление гипотезы

Свежий ELF из пользовательского `vnishnet-t21-aml-nand-v1.3.5.tar.gz`:
6228004 байта, SHA256
`b2663b3aa753cc14ae9d3b11a14d3d93c74b605a3e433b02101c3c17c69d95e9`.
Его не запускают как процесс хоста. Реальный запуск Ghidra 12.1.4 сохранён
со script/C/ASM/headless log в `integration/evidence/chain_uart_reader_135.json`.
Проверка фиксирует 29 byte ranges, 21 литерал, 26 Ghidra artifacts и 45
ограниченных запусков инициализатора. Общий A32-интерпретатор не изменён.
Путь worker `/tmp/build/src/backend/work-gen/work-gen.c` декодируется XOR09
из `5e962e`; размещение helper5b150 в vendor-файле здесь не утверждается.

Предварительное название «wait-space» было ошибочным. В `d20b4`:

```text
stride = queue[6]
if stride == 0: return 0
return uint32(queue.end - queue.begin) / stride
```

Это полная ёмкость по геометрии, не `capacity-count`. Оригинальный unsigned
делитель `590e28` также исполняется в oracle. `5b150` читает геометрию под
mutex, отпускает его и возвращает сохранённый ненулевой результат; при нуле
спит 5 и повторяет. Running здесь не проверяется. Полная очередь не блокирует
UART-чтение: `d1bc8` принимает только помещающиеся элементы, а worker игнорирует
число принятых элементов и может потерять остаток прочитанного буфера.

## Наблюдаемый порядок

`fdfbc` читает BSS654b0c (model selector), `fdfac` — BSS654b08 (controller).
Порог выбирается один раз до первого внешнего callback:

| Условие | Порог |
| --- | --- |
| byte BSS654b24 ненулевой | 9 |
| иначе controller=0 либо model=6/controller=4 | 9 |
| иначе model=7 | 10 |
| остальные сочетания | 11 |

Это значения из инструкций, не доказательство chip/model dispatch для T21.
Выбор делегирован существующей `vn135_work_rx_policy_init`: её `frame_size`
равен наблюдаемому порогу для всех проверенных selector/byte значений.
Helper принимает ненулевой local output, поэтому его единственный API guard
здесь не меняет поведение. Результат кэшируется до первого OS callback.
Тестовая сборка компилирует неизменённый work-gen.c в hidden function sections;
линкер сохраняет нужный policy и удаляет неиспользуемые nonce/SHA зависимости.
Symbol-check подтверждает policy=present, nonce/SHA=absent. Sanitizer-сборка
инструментирует и этот policy object. Никакой копии алгоритма выбора нет.

1. Setter `5a6b2c(1,NULL)`, format `59f558(name,64,5e973e,live index18)`,
   name operation `593af8(15,name,0,0,0)`, затем byte318=1.
2. Хотя бы одна итерация: ждать ненулевой ёмкости, сохранить результат;
   setter `5a6b2c(0,&old)`, ограничить request unsigned значением 256;
   вызвать live method из BSS654c28 с UART+2b8, buffer256 и request.
3. Восстановить setter из `old`, затем проверить signed результат read.
   Ноль или отрицательный результат: delay5, проверка running в хвосте.
4. Положительный: lock chain+2e0, bulk push queue+2f8, live count queue+14.
   Если unsigned count>=порог: lock653410, signal653428, unlock653410.
   Затем unlock chainmutex и проверка running. Ошибка push не добавляет
   fail-fast, положительный read не обрезается до request повторно.
5. После нулевого running — обязательный terminal callback `5a52d0(0)`.

Неактивные повторные ветви opaque predicate исключены по uint32-свойству
`x*(x-1)&1==0`. Случайные значения opaque-слов входят в тесты.

Read thunk `fef1c` выбирает BSS654c28. `fb994` записывает его в `fbc50`:
controller0 ->116fa8, controller1..4 ->10e938. 45 probes для controller0..4,
model0/4/7, subtype0/1/UINT32_MAX останавливаются на этой записи после96steps,
до platform effects. Это не выполнение всего initializer или Xil read body.

## API, границы и повторное использование

`vn135_chain_uart_reader_135(view, ops, ctx, scratch)` имеет void-интерфейс.
`vn135_chain_uart_wait_capacity_135(view, ops, ctx)` возвращает source word
и отдельно тестируется. Никакого синтетического успеха или timeout нет.
После возврата из injected exit callback управление возвращается test harness;
это граница сравнения, не новый способ возврата исходного pthread-worker.

Поля именованы; numeric begin/end — ARM identities для modulo32-разности,
не указатели хоста. Все field pointers, object identities и callback identities
фиксированы. Только pointed-to values изменяются синхронно; concurrency и
подмена view в callback не входят в контракт. Scratch принадлежит вызывающему,
инициализирован, не пересекается с полями view; callbacks не сохраняют его
указатели. Format обязан ограничить/завершить имя, setter — записать old даже
при injected error. Положительный read <=256, все используемые байты
инициализированы. Наблюдаемое отсутствие второго clamp сохранено.
Для конечного теста callbacks обеспечивают ненулевую ёмкость и последующий
нулевой running; это preconditions harness, не новые guards оригинала.

По Ghidra `5a6b2c` проверяет value<=2, при ненулевом old сохраняет байт
TLS-0x50, пишет новый байт и возвращает0; иначе22. Старое название
cancel-type не используется как доказательство точного host POSIX API.
Здесь только required callback по установленным аргументам и порядку.

`vn135_uart_read` уже существует. Nested oracle исполняет исходный `10e938`
и использует готовый helper с ioctl/read injection, включая ошибку ioctl,
ноль/отрицательное available и повторное чтение fd после ioctl. Helper имеет
дополнительные guards; Xil116fa8 остаётся отдельной required boundary.

`d1bc8` — bulk push, существующий `vn135_fifo_push` — один элемент. В nested
тестах они сравниваются через последовательные вызовы готового single-element
helper, до full/конца входа. Домены: выделенная корректная byte FIFO, стабильный
stride, без изменения её полей во время memcpy. Сравниваются исходные bulk
инструкции и вся память очереди, включая wrap/full/частичный приём. Ни нового
FIFO-алгоритма, ни автоматического production bulk adapter здесь нет. Сырые
невалидные geometry/null-base случаи могут не завершаться в оригинале и
не объявлены эквивалентными guard-логике готового FIFO.

Из upstream реально прочитаны `util.c::RenameThread` и `cgsleep_ms`.
RenameThread добавляет `cg@` и форматирует16bytes, тогда как источник имеет
64bytes и другую format identity; это не прямая замена. Host sleep/потоки
сохранены явными границами. Нативный core и build-policy остаются прежними.

## Выполненные проверки

```sh
make -f integration/chain-uart-reader-135.mk CC=gcc CHAIN_READER_DIR=build/b11-gcc all sanitize negative regressions
make -f integration/chain-uart-reader-135.mk CC=clang CHAIN_READER_DIR=build/b11-clang all sanitize negative regressions
clang --analyze -I. -Iinclude -std=c11 -Wall -Wextra -Wpedantic -Xanalyzer -analyzer-output=text src/backend/work-gen/chain-uart-reader.c
```

Original/C oracle: 637 сценариев,13382 события,205533 ARM steps,318 PCs;
44 сценария с nested FIFO/UART (не каждый делает низкоуровневый read).
Сравниваются trace/args, полные800bytes chain и2048bytes backing, guard bytes,
все328bytes scratch, selectors/slots/mode, helper return. 45 init probes отдельно.
Есть разные пороги/ёмкости/stride, uint32 wrap, capacity0/retry, full/partial,
ошибки read, многократные итерации и изменения fields в callbacks.

Native и ASan/UBSan:1332 сценария/327099 assertions, реальная host heap,
существующие FIFO/UART, lock order, ignored returns, cached thresholds,
реальный full/wrap и освобождение тестовой памяти. 24 скомпилированных mutants
должны семантически расходиться с637 original fixtures; baseline проходит,
compile failure/crash/timeout не считается обнаружением.

Старые проверки отдельно: route7/16/10/2, TX88 packets128/CRC36,
sanitized bounds11225; UART3248/AML689; ring8748/queue2977 плюс72 producer
compositions. Legacy Python/shared-library тесты не sanitized; неизменённые
копии используют отдельные каталоги для каждого компилятора. Non-PIE только
для sanitizer test executables из-за ранее установленного WSL PIE-ASan сбоя.
Логи — build/b11-logs, Ghidra — build/b11-ghidra. Workflow проверяет actual
PR head; подтверждённый CI/artifact статус публикуется в #40 и PR.

Реальные pthread/TLS/fd/ASIC, асинхронная композиция, production native adapter,
готовый образ и принятые пулом шары не проверены. Lower callbacks обязательны;
это не работающий транспорт на оборудовании. fe218/58d08, A-04 и частоты,
напряжения, защиты, пулы, 32-slot barrier не изменяются.
