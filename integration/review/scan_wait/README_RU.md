# R-17 — ожидание в настоящем scanwork без выдуманного хешрейта

Основа: R16 / PR #97, `3724f7ce894ffa9fa6ca2a04a280b2a0f82406dd`.
Новая реализация — opt-in callbacks, а не прошивка или зарегистрированный драйвер.

`dizzass_scanwork` имеет штатную сигнатуру `device_drv.scanwork`. Он использует
один condition variable с `CLOCK_MONOTONIC` и фиксированным абсолютным сроком.
Ложное пробуждение не продлевает этот срок. При нормальном heartbeat и остановке
возвращается **0 хешей**: ожидание не является измерением проделанной ASIC работы.
Существующий RX/submitter работает независимо. Производственное измерение
хешрейта, полный scheduler, update/flush/restart и освобождение слотов не добавлены.

`dizzass_scan_stop_wake` устанавливает односторонний флаг до broadcast под тем же
mutex, который участвует в ожидании. Запрос до засыпания сохраняется, повторные
запросы безопасны. Нет дополнительного thread, очереди, work, таймера или
накопления semaphore-токенов. R13 пробуждает get_work, R14 пробуждает нативную
паузу, а этот callback — собственное ожидание scanwork. R16 вызывает их вместе
с managed I/O stop. Ранее допущенная операция может завершиться.

Перед и после ожидания проверяется связанный lifecycle. Отсутствие старта,
остановленный или завершившийся RX дают -1 с диагностикой, а не бесконечный
нулевой успешный цикл. I/O-only отказ обнаруживается на очередном heartbeat;
без задержки следует вызывать согласованный R16 stop. Срок 1..1000 мс — период
программного ожидания, НЕ частота ASIC и НЕ жёсткий предел остановки: mutex,
планировщик ОС и другие callbacks могут задерживаться.

## Подключение и владение

Хранилище `struct dizzass_scan_wait` принадлежит вызывающему коду, не копируется.
Инициализировать через `dizzass_scan_wait_init` до публикации; ошибка не оставляет
принадлежащих модулю ресурсов. Сам init не присваивает поля драйвера и не начинает
никакого I/O. Один полностью инициализированный queue-owner: `cgpu->threads=1`,
`cgpu->thr[0]` указывает на этот же thr с живым native semaphore.

На собственном стабильном driver object явно установить:

```c
/* After successful initialization and before starting the native worker. */
thr->cgpu_data = &scan;
cgpu->drv->scanwork = dizzass_scanwork;
cgpu->drv->queued_stop_wake = dizzass_scan_stop_wake;
```

R12 `cgpu->device_data` с queue_full-binding остаётся отдельным и не меняется.
Нельзя перезаписывать данные другого драйвера. Связь thr/cgpu/IO/пулов и выбор
strict CRC задаёт интегратор; произвольные чужие указатели не валидируются.
Это один queue-owner, не распределение задач между несколькими hashboards.

Deferred cancellation исключена на время scanwork до выхода из mutex и публикации
отчёта. Доставка отмены при восстановлении состояния может помешать return.
Память отчёта и binding остаётся живой. Snapshot берётся под mutex; чтение полей
структуры напрямую из конкурентного потока не поддерживается. EBUSY при активном
scanwork защищает destroy от одного очевидного неправильного порядка, но
`active=false` НЕ означает, что все внешние callers уже вернулись.

Перед detach/destroy нужно запретить новые обращения, запросить stop и выполнить
join всех worker/wake/snapshot/управляющих потоков. Нет async cancellation,
конкурентного init/destroy/hotplug, reentry, signal-context или caller-held locks.
Нет автоматического resume/reset. Поле stop не сбрасывать вручную.

## Проверки

20 новых случаев: аргументы/привязка, три периода, pre-stop, повторный stop,
ложные пробуждения, остановка/отмена активного ожидания, active/destroy guard,
16 управляемых pre-wait расписаний в одном регрессионном случае, четыре состояния
I/O (включая явно внедрённый read EIO), ошибка wait, настоящий hash_queued_work с
32 реальными PTY-передачами и сохранением 33-го задания, CRC/native submit,
пустая общая очередь и нативная пауза. В hash_queued_work вызывается НОВЫЙ
рабочий callback, не тестовый scan14. Потоки, condition/semaphore, очередь core,
TX/RX и submit настоящие; nonce от тестового собеседника, не от ASIC/пула.

8 отдельно компилируемых контролей изменяют latch, broadcast, deadline, I/O
проверку, число хешей, cancellation, completion и clock. Засчитывается только
ожидаемый assertion/exit1, не build error, timeout или crash.

```sh
python3 -B integration/review/scan_wait/test_runner.py
python3 -B integration/review/scan_wait/run.py --cc gcc-14 --baseline icarus --out build/r17-normal --mutants
python3 -B integration/review/scan_wait/run.py --cc clang-17 --baseline icarus --out build/r17-sanitized --sanitize
```

Полный runner сохраняет все 588 прежних случаев и 89 контролей: всего **608/97**.
`--groups scan_wait` означает ТОЛЬКО 20 новых случаев. Проверяется текущее tracked
дерево, а не старые зависимости. Нужны committed inputs и новый output directory.
Runner не fetch/install/update-ref. Санитайзеры покрывают прямые test/core TU и
адаптеры, не все библиотеки поддержки. Нет TSan/полного перебора расписаний.

Точный объём выполненных локальных/CI проверок фиксируется отдельно. Ни
аппаратное выключение/drain, ни новая epoch, ни safe slot reuse не доказаны.
Лимит32, частоты/напряжения/защиты/devfee и production registration не меняются.
