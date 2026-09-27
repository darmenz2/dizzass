# B-08: остановка work-thread, оригинал 1.3.5

Issue #32; координация #2. Полное тело `0xc3e18..0xc4037`, литералы
`0xc4038..0xc404f`. Это сравнение исходного поведения вне production.
Модуль не включён в Makefile.am и не запускает потоки или ASIC.

## Источник и границы

Архив пользователя `vnishnet-t21-aml-nand-v1.3.5.tar.gz`, SHA256
`20fabdd66255889315e61ae2a33ff2e4623566ca430f1cb8c90d9b938dc7b43c`.
Свежая распаковка через `tools/extract_reference.py` дала ELF SHA256
`b2663b3aa753cc14ae9d3b11a14d3d93c74b605a3e433b02101c3c17c69d95e9`.
ELF читается как данные. Ghidra 12.1.4 выполнена над этим ELF;
скрипт, декомпиляция, дизассемблирование и журнал сохранены в evidence JSON.
Checker проверяет хеш ELF, четыре диапазона, шесть адресных литералов,
финальные инструкции и хеши четырёх артефактов Ghidra.

Ветка основана на `12446bed78a060a49364a80bcbfb4340b13f4f27`.
Ни один ожидающий review PR не импортирован. B-07/#29 описывает запуск,
B-04/#17 и B-05/#22 — рабочие циклы; это отдельные работы, не зависимости
данной проверки. B-06/#26 восстанавливает только внутренний batch producer.

## Подтверждённое поведение

| Участок | Эффект |
|---|---|
| c3e5c | Один вызов fe668, signed count сохраняется до остановки потоков |
| c3e70..c3f10 | producer: handle+1068 / running+106c |
| c3f14..c3f38 | RX: handle+1060 / running+1064 |
| c3f58..c3f90 | TX: handle+1058 / running+105c |
| c3f94..c3fc0 | destroy condition633bc0, mutex633ba8, condition633b08, mutex633af0 |
| c3fc4..c402c | При count>0 обход chain массива с шагом800; base+230 читается заново |
| c4030..c4034 | Всегда return0 |

Каждый поток выбирается по живому байту `running != 0`, независимо от
handle. Перед cancel байт обнуляется, handle передаётся по значению.
Перед join handle читается снова; второй аргумент join равен NULL.
Результаты cancel/join игнорируются, handle не очищается. Callback может
повторно выставить running; повторного сброса и повторной проверки нет.
Порядок producer → RX → TX не меняется при ошибках.

Четыре destroy выполняются безусловно, включая count<=0; их ошибки тоже
игнорируются. При положительном count каждая итерация заново читает base,
проверяет byte+318 выбранной цепи и вызывает живой метод backend+200
с указателем именно на эту цепь. Count больше не запрашивается.
Семантика вызываемого per-chain метода остаётся внешней границей.
Числовые tokens c39a8/bfb94/c1970 в тестах различают вызовы; тест не
исполняет эти тела и не доказывает привязку какого-либо из них к T21.

Ghidra показывает также повторные пути за opaque-проверками.
В ARM uint32 `x*(x-1)&1` всегда0, включая переполнение; такие пути не
перенесены как обычное поведение. Oracle исполняет исходные инструкции,
включая эти проверки, с разными значениями opaque globals.

## API и повторное использование

`vn135_work_stop_135(view, ops, context)` повторно использует существующий
`struct vn135_shutdown_thread` из backend_shutdown_135.h без изменения
общего интерфейса. Chain projection содержит только pointer на byte+318
и соответствующий object identity, а view — живой base/method. Это новые
host-проекции для сравнения, не vendor ABI, native work/pool или runtime
T21 driver. Не заменяют cgminer структуры и не предполагают, что другой
флаг `present` означает тот же byte+318.

Обязательные callbacks: chain_count, cancel, join, destroy, chain.
Адреса функций/объектов передаются как числовые идентификаторы, никогда
не вызываются и не разыменовываются на host. Нет успешных fallback/stub.
Return0 сохраняет оригинал и не означает успешного завершения потоков,
уничтожения mutex/condition или очистки цепей.

Просмотрен upstream `util.c::thr_info_cancel`: он выбирает поток по
ненулевому handle, обнуляет handle, вызывает cgsem_destroy и не делает
join. Это неэквивалентная замена данной функции. Реальный native adapter
должен отдельно согласовать cgminer lifetime/cancellation, а не молча
заменить этот порядок. cgminer core и его production сборка не изменены.

Домен: валидные раздельные объекты, живые callbacks, стабильные thread/ops
identities; coherent descriptors/byte/object pairs и storage живы весь
вызов. Поля потоков, base, method и enabled bytes могут меняться только
в сериализованных callbacks. Положительный count помещается во всех
достигнутых массивах; исходные pointer/800-byte arithmetic не переполняются.
Не моделируются повреждённые указатели, aliasing между полями или
асинхронные гонки. Тестовые массивы имеют до8 цепей; не заявляется
полный перебор пространства count/памяти.

## Выполненные проверки и воспроизведение

```sh
make -f integration/work-stop-135.mk CC=gcc STOP_DIR=build/stop-gcc all sanitize negative regressions backend-regressions
make -f integration/work-stop-135.mk CC=clang STOP_DIR=build/stop-clang all sanitize negative regressions backend-regressions
clang --analyze -I. -Iinclude -std=c11 -Wall -Wextra -Wpedantic -Xanalyzer -analyzer-output=text src/backend/work-gen/work-stop.c
```

GCC11.4 / Clang14, каждый:

- Original ARM oracle: 666 сценариев, 8524 callbacks, 81741 ARM steps,
  108 выполненных instruction addresses. Сравниваются весь backend,
  оба полных массива цепей, guards, аргументы/порядок callbacks и снимки
  памяти на каждой границе; interpreter из общей базы без новых opcodes.
- Host bounds/lifetime: 14000 сценариев / 4577700 проверок; те же тесты
  с ASan+UBSan. Raw flags0/1/2/128/255, zero/high handles, signed counts,
  reassertion running, live join/base/method, ignored failures.
- 19 отдельно собранных semantic mutants отвергнуты; исходная библиотека
  принимает все666 fixtures. Компактные negative fixtures сохраняют все
  memory hashes и callback traces. Ошибка сборки, timeout или crash не
  считаются обнаружением семантического дефекта.
- Старые route/TX88: names7 / caller snapshots16 / selections10 /
  worker sets2; packets128 / CRC36; bounds11225 с ASan+UBSan.
- Старый mining-stop: original1352 / events16795; nested263 /
  backend events12914 / mining1448 / voltage-rescue1002;
  provenance creator6 + worker prefix1; native630 / assertions32316.
  Этот старый набор запускался без sanitizer instrumentation.
- Clang analyzer: без диагностики.

Только test sanitizer executables собираются с `-fno-pie -no-pie`:
в этой WSL среде ранее воспроизведены сбои запуска PIE ASan даже с пустым
main. Production flags не затронуты. CI сохраняет exact checkout SHA,
версии компиляторов, логи, negative logs и mining original/nested JSON.
Локальные логи этого запуска: `build/b08-logs/`.

Не проверены реальные pthread/cond/mutex, конкурентная остановка,
per-chain callback bodies, полная композиция workers, native device_drv,
контроллер/ASIC/пул, firmware boot и принятые шары. Это отдельные
требования; host/CI результаты не заменяют их.
