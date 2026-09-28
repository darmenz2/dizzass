# B-05: полный цикл RX `0xc4054` из VNish 1.3.5

Задача [#19](https://github.com/darmenz2/dizzass/issues/19), координация
[#2](https://github.com/darmenz2/dizzass/issues/2). База:
`12446bed78a060a49364a80bcbfb4340b13f4f27`, ветка `codex/work-rx-worker-135`.
Добавлены только десять новых согласованных файлов. Production-сборка,
общие интерфейсы, старые реализации, `base.c` и файлы других исполнителей
не изменены. Зависимости от ожидающих review PR отсутствуют.

## Источник и метод проверки

Предоставленный архив `vnishnet-t21-aml-nand-v1.3.5.tar.gz`:
SHA-256 `20fabdd66255889315e61ae2a33ff2e4623566ca430f1cb8c90d9b938dc7b43c`.
Извлечённый `usr/bin/cgminer`, 6 228 004 байта:
`b2663b3aa753cc14ae9d3b11a14d3d93c74b605a3e433b02101c3c17c69d95e9`.
Повторное извлечение выполнялось штатным `tools/extract_reference.py`.
Firmware ELF использовался только как данные.

Ghidra 12.1.4/JDK 25.0.4.1 декомпилировала `c4054`, тело
`[c4054,c4aa7]`; A32 objdump использован для проверки порядка инструкций,
адресов и ширины полей. В `integration/evidence/work_rx_worker_135.json`
сохранены скрипт Ghidra, полный вывод C/asm, журнал и хеши исходных диапазонов.
Ghidra выбрала язык ARM:LE:32:v8; это настройка анализа, не доказательство
модели процессора. Типы декомпилятора не принимаются за восстановленный ABI.
IDA Free на этой машине не использовалась для ARM-анализа.

Python-тест исполняет оригинальные инструкции всего `c4054` до возврата.
Также исполняются оригинальные `108b7c`, `109120`, `109170`: SHA не заменена
ответом из новой C-реализации. Интерпретатор и старые oracle-модули не изменены.
Явные внешние границы: scalar getters, cancellation/name/mutex/wait, FIFO
available/byte/payload, chip/core attribution, `108938` и `fa5e0`, memcpy/memset.
Сравниваются порядок и аргументы вызовов, состояние на каждой границе,
определённые поля результатов, содержимое очередей и неизменность job table.

## Сохранённое поведение

- При входе вызовы `fe668`, `fdfbc`, `fdfac`, `fe0b0`, `fdfbc` идут именно
  в таком порядке. Первый chip selector выбирает variant; второй выбирает
  job slot. Они не обязаны возвращать одинаковые значения.
- Начальное минимальное число байтов фиксируется при входе. Режим `fe0b0`
  читается заново перед lock каждой включённой цепи, поэтому последующий
  payload может быть 7 байт даже при сохранённом минимуме 11, и наоборот.
- Признак включения — отдельный byte цепи `+318`, любое ненулевое значение.
  `present` и thermal state здесь не проверяются. Число цепей — signed word.
  `backend+230` читается при переходе к следующей цепи.
- Mutex `+2e0`, FIFO `+2f8`. Недостаток байтов оставляет FIFO нетронутым.
  Шум потребляет один байт; `AA` и неверный второй байт потребляют два,
  в том числе `AA AA`. Следующий AA не сохраняется как новый префикс.
- Payload начинается с нулей. Возврат pop-функций игнорируется, включая
  частичную запись. Один header scratch сохраняется между чтениями.
  Normal last-byte bit 7 выбирает nonce; special mode всегда идёт в register.
- Register filter `d2a84` вызывается после чтения payload. Сравнение с
  адресом регистра остаётся 32-битным, без сужения значения getter до byte.
- Используются существующие `vn135_work_rx_policy_init`, `vn135_work_rx_next`,
  `vn135_work_rx_job_slot`, `vn135_work_nonce_prepare` и SHA helper.
  Новый протокол, CRC, SHA или алгоритм выбора задания не добавлены.
- Любое потребление header означает progress, включая шум и filtered register.
  Только проход без progress вызывает lock `653410`, cancel(0,&old),
  wait(`653428`,`653410`), cancel(old,NULL), unlock. Стоп проверяется после
  этого и после полного прохода всех цепей, не посреди прохода. Возврат — 0.

## API и границы эквивалентности

`vn135_work_rx_worker_135(view, ops, context)` — изолированная field-view
реконструкция. Все достигнутые callbacks обязательны, автоматических
успешных заглушек, OS defaults и реального I/O нет. Положительный count
должен помещаться в переданных массивах. Callbacks обеспечивают завершение.
`653410`, передаваемый через `void *`, — только identity token; разыменовывать
его на host нельзя.

View и per-chain identities стабильны. На синхронных границах допускаются
изменения running, chain index/enabled, FIFO и переключение массива chains;
тесты проверяют моменты их наблюдения. Асинхронные гонки не моделируются.
Выбранный 168-byte job должен быть неизменным во время chip/core attribution
и подготовки nonce: это условие существующего helper. В оригинале некоторые
поля перечитываются после attribution; при изменении job внутри callbacks
эквивалентность **не заявляется**.

`initial_scratch` задаёт исходные старые stack bytes header/cancel_old,
когда функция не записывает свой output. Нулевое значение не выдумывается.
Эти локальные scratch не записываются обратно в view. Payload callbacks
пишут только в пределах запрошенной длины; output callbacks не меняют input.

Register callback получает только определённые исходником поля
chain/chip/register/value/crc5; остальные поля parser message — host metadata.
Исходные незаписанные байты register record `+6..7`, `+14..15` не объявлены ABI.
Nonce callback получает 68 определённых байтов. Очередь оригинала использует
72 байта, последние четыре не восстанавливаются предположением о padding.
Модуль не реализует нижележащие `108938`/`fa5e0` и не меняет A-04 callback table.
Политика свежести 32 work slots из этого цикла не следует.

## Повторение проверок

```sh
make -f integration/work-rx-worker-135.mk CC=gcc RX_DIR=build/b05-gcc all sanitize negative regressions
make -f integration/work-rx-worker-135.mk CC=clang RX_DIR=build/b05-clang all sanitize negative regressions
```

Python whole-worker: 603 сценария, 638 nonce, 258 register replies,
26 390 событий, 3 866 182 ARM-шагов, 820 различных наблюдённых PC.
Проверяются все 256 первых prefix bytes, варианты selector/mode/filter,
32 slot tags, ошибки и частичные outputs, смена цепей и остановка на границах.
Это набор конкретных сравнений, не доказательство всех возможных состояний.

C composition/ownership suite: 2 907 сценариев, 388 854 проверок,
включая неизменность job/state canaries, порядок callbacks, отказ записи
scratch и завершение прохода. Запущен обычный native и ASan/UBSan для обоих
компиляторов. Expected candidate в C использует прежний helper, поэтому
независимая проверка алгоритма находится в Python ARM-oracle, не в этом C-тесте.
Sanitizer executables собираются non-PIE (`-fno-pie -no-pie`), чтобы обойти
воспроизведённый сбой запуска PIE ASan в локальной WSL; production flags не меняются.

Negative suite: 15 семантических мутаций сравниваются с 350 fixtures,
полученными из оригинальных инструкций. Baseline обязан пройти. Каждый
mutant обязан собраться и дать `SEMANTIC_MISMATCH`; crash, timeout и ошибка
компиляции не считаются успешным обнаружением. Включены cached mode,
live minimum, signed available, premature stop/wait, FIFO errors, wrong row,
сужение filter и потеря cancel state.

Старые RX/nonce-регрессии и Clang analyzer выполняются workflow отдельно.
CI сохраняет фактический SHA checkout, compiler version, new/sanitizer/
regression/nonce/RX журналы, JSON и каждый mutant log в artifacts.
Результаты конкретного запуска и ссылки публикуются в PR и issue #19.

Не проверены реальные pthread/очереди/UART, T21, pool submission, accepted
shares, запуск и надёжность полной прошивки. Модуль не подключён к native
production driver; host-проверки не означают готовность образа к прошивке.
