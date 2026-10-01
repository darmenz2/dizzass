# R-16 — совместная программная остановка native cgminer и managed IO

Основа: R15 `6b3ffbd908625108f8bb41b8296568376ba6b32f`. Задача #96.
`dizzass_native_io_stop` проверяет весь список, запрашивает закрытие допуска
на ВСЕХ IO-цепях, затем вызывает настоящий `cgminer_request_queued_stop`, и
после этого собирает результаты полной остановки каждой возвращающейся цепи.
Задержка в driver wake не оставляет остальные перечисленные цепи открытыми
для новых передач. Ошибка native wake не отменяет попытку IO stop.

Отчёт сохраняет отдельно ошибки каждого первоначального запроса, native stop
и полной остановки IO. first_error выбирается в этом порядке; все полные
остановки получают один абсолютный deadline. Ошибки не откатывают stop;
повтор разрешён при сохранении объектов. sequence_complete требует отсутствия
ошибок и managed quiescence каждой цепи. Это НЕ join нативных потоков и не
подтверждение физического выключения оборудования или освобождения слотов.

Отмена контроллера исключена до публикации отчёта. Память отчёта должна пережить
его отмену. Перед освобождением native/IO/pool/queue/fd объектов необходимо
соединить либо исключить ВСЕ внешние вызовы, даже после успешной последовательности.

Список полон только по утверждению вызывающего кода: API не обнаруживает неверные
cgpu/IO/port связи и пропущенные цепи. Нужны готовый getq/stgd_lock, живой driver,
неизменяемый опубликованный набор thr с готовыми sem, правильные IO binding.
Один внешний контроллер, без reentry из callback, hotplug, конкурентного
start/stop/destroy или async cancellation. Все прежние контракты остаются.

Native hook может ждать mutex; deadline ограничивает только прежние TX/queue
ожидания, а не общее время wake/submit/join. Если hook не возвращается, полный
сбор IO тоже не начнётся, хотя всем уже направлен запрос закрытия допуска.
NULL hook не делает произвольный scanwork прерываемым. Нет новых reset/resume,
аппаратных команд, fake work, drain, epoch, slot reuse или сетевого отправителя.

## Проверки

Реальные hash_queued_work/get_work/hash_pop, sem_wait, кооперативное scanwork,
несколько PTY/реестров/RX с одним submitter. 29 новых сценариев: 1/3/16 участников;
10 некорректных аргументов без эффектов; getq/pause/scanwork ожидания; задержка
native wake с обычным/отменённым контроллером; ошибка wake и retry; ошибки IO
в разных позициях; приоритет нескольких ошибок; удержание work_completed с
обычным/отменённым отправителем; явная неисправность scheduler.
Ошибки и задержки вводятся явно и не являются аппаратными событиями.

R14 test.c получает только main-embedding guard; самостоятельные assertions
сохранены. Прежние559 сценариев/82 контроля остаются в runner. Прямые компиляции
используют текущие tracked C/header с прежним контролем входов.

```
python3 -B integration/review/native_io_stop/test_runner.py
python3 -B integration/review/native_io_stop/run.py --cc gcc --groups native_io_stop --out build/r16-focused --mutants
python3 -B integration/review/native_io_stop/run.py --cc clang --out build/r16-all --sanitize
```

Focused — только29 случаев, не весь набор588. По умолчанию host ANTS2/no-libcurl;
--baseline icarus требует стандартных host development packages. cgminer запускается
только с --version; далее offline harness, не аппаратный драйвер. Нужны committed
исходники и новый output; runner не скачивает данные и не изменяет Git refs.
