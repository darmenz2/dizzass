# B-10: запуск потока UART одной цепи, `c33d0`

Задача #38, координация #2. Восстановлена целиком процедура `c33d0`
(`c33d0..c369b`, литералы до `c36e7`) из предоставленного архива VNish 1.3.5.
Это изолированное сравнение поведения, без включения в production cgminer.
Тело создаваемого worker `c36e8` сюда не входит. `c3148` — публикация шаблона,
а не entry этого потока. PR предыдущих B-задач не импортируются.

Источник — `reference/cgminer.vendor.elf`, SHA256
`b2663b3aa753cc14ae9d3b11a14d3d93c74b605a3e433b02101c3c17c69d95e9`.
Повторное извлечение из пользовательского `.tar.gz` дало тот же ELF.
Ghidra 12.1.4 действительно запускалась: script, C, ASM и headless log сохранены
в `integration/evidence/chain_work_start_135.json`. Проверяются 12 диапазонов,
24 PC-relative литерала, 16 Ghidra-артефактов и 45 запусков инициализатора.
Путь `/tmp/build/src/backend/work-gen/work-gen.c` декодирован из `5e962e`
через XOR `09`. Бинарник никогда не запускается как процесс хоста.

## Наблюдаемое поведение и API

`vn135_chain_work_start_135(view, ops, context)` принимает именованные поля,
переиспользуя существующий `vn135_shutdown_thread`. Ни один адрес ARM
не превращается в исполняемый указатель хоста. UART/FIFO/chain/mutex передаются
как отдельные идентичности объектов; это не native cgminer ABI и не сырые ARM
структуры. Все callbacks обязательны, все field pointers, object identities
и callback identities остаются неизменными. Значения по field pointers могут
меняться синхронно внутри callbacks. Указатели не пересаживаются, асинхронного
исполнения и доказательства безопасности реальных потоков здесь нет.

1. `fe668` вызывается до чтения signed `chain+18`. Отрицательный индекс или
   индекс >= полученному count дают log `2b8` и `-1`; аргумент — index+1 modulo
   2^32. Даже при исходно отрицательном индексе count вызывается.
2. Любой ненулевой byte `318` возвращает 0 без последующей инициализации.
3. Mutex `chain+2e0` инициализируется с NULL attributes, затем FIFO `+2f8`
   с capacity `0x800`, stride 1. Обе возвращаемые величины игнорируются.
4. После init заново читаются index и path-method для `fef3c(index)`. После
   path callback индекс читается ещё раз и записывается в `chain+2d0`.
5. `fee4c` выбирает live open-method, передавая UART `+2b8` и сохранённый path.
   Любой ненулевой результат даёт log `2c8` с тем же path и `-1`.
6. `5a55cc(&handle314, NULL, c36e8, chain)` создаёт поток через явную границу.
   Любой ненулевой результат даёт log `2d0` с новым index+1 и `-1`. Запись
   handle callback-ом сохраняется даже при ошибке. Иначе возвращается 0.

Процедура сама не устанавливает running и не делает rollback/free/destroy.
NULL path не перехватывается новым guard. Возврат 0 не доказывает readiness.
Неактивные повторяющиеся ветви opaque predicate исключены по свойству
`x*(x-1)&1 == 0` в uint32; тесты варьируют исходные opaque-слова.

## Выбор методов и границы повторного использования

Оригинальный `fb994` проверен на controller 0..4, model 0/4/7, subtype
0/1/UINT32_MAX. Каждый из 45 запусков останавливается сразу после обеих
записей, до внешних platform effects. Это доказательство в проверенном домене,
а не полная инициализация оборудования или вывод о модели ASIC.

| controller | path target BSS654b4c | store PC | open target BSS654c18 |
| --- | --- | --- | --- |
| 0 | 115d10 | fc92c | 116dd8 |
| 1 | 11fe2c | fbf00 | 10e0c8 |
| 2 | 11c080 | fc15c | 10e0c8 |
| 3 | 1239a8 | fc3cc | 10e0c8 |
| 4 | 10cf84 | fd37c | 10e0c8 |

Open-slot записывается в `fbbd8`. `fef3c` делает BX через live path slot;
`fee4c` делает BLX через live open slot и возвращает результат. Ghidra считает
тело `fb994` разрывным и не полностью включает его ветви. Поэтому provenance
опирается на ограниченное выполнение исходных инструкций и хэш всего окна
`fb994..fddfb`, а не только на угаданную границу Ghidra-function.

Существующая `vn135_fifo_init` в `reconstruction/support/record_fifo.c`
уже представляет `d19b0`. Она использует индексы элементов и guards для
занятого объекта, размеров/overflow и неудачной аллокации. Оригинал делает
malloc сырого uint32-произведения и пишет семь полей даже при NULL. Поэтому
координатор сохраняет обязательный callback, а nested original/C сравнение
использует готовую FIFO только для пустого объекта и успешной аллокации
2048 байт. Поля FIFO в этой nested-композиции не меняются callbacks извне;
проверяется явное преобразование указателей оригинала в именованные поля.

`vn135_uart_open` уже реализован в `libbitmain/src/uart.c`: ему нужен свежий
объект fd=-1/path=NULL/mutex_ready=false, и диагностика нижнего уровня опущена.
Его тело не дублируется. Native C-композиция проверяет готовый helper при
успешных нижних open/ioctl/duplicate и игнорируемом результате mutex init.
Ошибки внешнего open/create отдельно проверяет полный coordinator oracle.
Старые Stage5-тесты дополнительно сравнивают UART-helper с оригиналом, включая
406 случаев open, в своих документированных границах.

Настоящий `util.c::thr_info_create` cgminer изучен: перед pthread_create
инициализирует cgsem. Это дополнительный эффект, поэтому подменять им
наблюдаемый вызов без адаптера нельзя. Native ядро, Makefile.am, старые
интерфейсы и helpers не меняются. К upper startup/stop, RX/TX, batch producer
из ожидающих review PR этот модуль пока не подключается.

## Проверки

Из корня checkout на Linux/WSL (для Clang заменить `gcc` и каталог):

```sh
make -f integration/chain-work-start-135.mk CC=gcc CHAIN_START_DIR=build/b10-gcc all sanitize negative regressions
clang --analyze -I. -Iinclude -std=c11 -Wall -Wextra -Wpedantic -Xanalyzer -analyzer-output=text src/backend/work-gen/chain-work-start.c
```

Original oracle исполняет неизменённые A32 слова `c33d0/fef3c/fee4c` и в
nested-случаях `d19b0`. Общий интерпретатор не изменён. Проверяются return,
порядок/аргументы callbacks, полные 800 байт chain, guard bytes, snapshots
полей и live method slots. Getter/init/path/open/create/log могут менять
проверяемые значения. Есть signed extremes, ненулевые running bytes, NULL
path, положительные/отрицательные ошибки и детерминированные случайные случаи.

981 original/C сценарий: 98 фактических nested FIFO init, 4357 событий,
85818 ARM steps, 178 различных PC; 45 initializer probes считаются отдельно.
Native C и его ASan/UBSan вариант выполняют 4750 сценариев / 45980 assertions,
включая настоящие host malloc/free, existing FIFO/UART composition, проверку
сохранения выделений при ошибке координатора и явную очистку тестовым harness.
24 отдельно скомпилированных semantic mutants должны дать расхождение с
981 исходным fixture. Compile failure, crash или timeout не считаются успехом.

Релевантные старые регрессии выполняются отдельно: route 7 names/16 snapshots/
10 selections/2 worker sets, TX88 128 packets/36 CRC, sanitized bounds 11225;
Stage5 UART 3248 и AML/UART 689; Stage13 ring 8748, queue 2977 сравнений и
72 producer/queue compositions отдельно. Старые Python/shared-library тесты
не инструментированы санитайзерами. Их неизменённые копии работают в отдельных
каталогах компилятора, чтобы фиксированные пути legacy-тестов не пересекались.
Только тестовые sanitizer executables используют non-PIE: ранее в этой WSL
среде PIE-ASan падал даже на пустом main; production flags не затронуты.

Локальные результаты: `build/b10-logs/`, Ghidra: `build/b10-ghidra/`.
Workflow строит actual PR head двумя компиляторами, сохраняет head, результаты,
analyzer и mutant logs. Фактический CI статус и проверенные artifact hashes
публикуются в #38/PR после завершения, не предполагаются из наличия workflow.

Не проверены реальные pthread, UART fd, ASIC, full c36e8 worker, совместная
асинхронная работа модулей, native T21 adapter, загрузочная прошивка или ответы
пула. Принятые шары этими проверками не подтверждаются. Зарезервированные
fe218/58d08 и заблокированный A-04 payload не затрагиваются.
