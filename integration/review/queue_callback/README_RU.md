# R-12 — настоящий callback queue_full и штатный fill_queue

Основа: R-11 / PR #83, d36e3c1ce82a8b2f7b286dbb06afd8bf03eb7fd4.
Задача #84. Отдельный opt-in кандидат, не зарегистрированный драйвер/прошивка.

`dizzass_queue_full(struct cgpu_info *)` имеет точную сигнатуру
`device_drv.queue_full`. Он использует существующий `dizzass_queued_work_step`
ровно один раз и возвращает true при ошибке или указании завершить проход.
False возможен только после опубликованного результата, разрешающего продолжение.
Новых очередей, копий work, потоков, SHA, парсера или циклов наполнения здесь нет.
Одна binding указывает на один lifecycle; распределение work между несколькими
цепями этим callback не реализуется.

## Привязка к будущему драйверу

Драйвер самостоятельно выделяет/сохраняет `struct dizzass_queue_callback`,
инициализирует через `dizzass_queue_callback_init`, устанавливает собственные
`cgpu->device_data = &binding` и `drv->queue_full = dizzass_queue_full`.
Инициализатор ничего не присваивает драйверу и не регистрирует оборудование.
Нельзя подставлять этот callback к device_data другого типа или перезаписывать
чужой контекст. Указатель должен вести к корректному живому объекту этого типа:
произвольные указатели здесь не валидируются. Драйвер задаёт min_diff/max_diff,
привязку thr/cgpu/io/jobs/порта и, когда нужен строгий RX, заранее создаёт CRC5 IO.

Один последовательный владелец вызывает callback и все work admissions.
Конфигурация binding неизменна во время работы; last читает этот же владелец
или другой поток после синхронизации/join. Одновременное чтение last не защищено.
Перед освобождением binding/native pools/cgpu/IO требуется исключить и соединить
всех пользователей, даже когда lifecycle уже сообщил quiescent.

Для каждого вызова вычисляется новый абсолютный monotonic deadline с проверкой
переполнения now + timeout_ms. Это бюджет одного callback, а не всего fill pass.
В last отдельно указаны status, step_called, receipt_valid, queue_full и вложенный
результат R11. При ошибке предыдущий успешный receipt не выдаётся за новый.
Deferred cancellation исключена до сохранения last. Восстановление отмены может
не вернуть управление: память binding/result должна переживать отмену владельца.
Асинхронная отмена, повторный вход и конкурентное отсоединение не поддерживаются.

## Реальный штатный цикл, без его копии

Стенд вызывает неизменённые fill_queue, get_work/hash_pop, get_queued и
work_completed из cgminer.c. Начальные задания помещаются в настоящий staged_work
через hash_push, с getq/qlock/data_lock, как offline-замена источника готовых work.
Сеть и getwork-производитель пула не запускаются. В get_work не подставлена заглушка.
Volatile-указатели на настоящие статические функции сохраняют их символы при
оптимизации; это не новые тела функций и не неопределённые linker-символы.

27 новых сценариев: матрицы аргументов/состояний, deadline overflow, продолжение
и сброс старого результата; native fill32 плюс сохранение следующего задания;
реальная подготовка thr_id/mined/device_diff; native stale discard; отказ метаданных;
11 фрагментированных ранних CRC-ответов через реальные PTY/A16; 4 copy failures;
частичная запись и поздний полный результат; stop race, отмена callback и
блокировка штатного get_work. Ошибки syscall/барьеры явно внедрены стендом.
Известные nonce — синтетические данные peer, не находки физического ASIC.

## Существенные оставшиеся границы

fill_queue сначала вызывает блокирующий get_work, если unqueued_work пуст,
и только ПОТОМ queue_full. Поэтому даже при заполненных аппаратных слотах
следующий вызов fill_queue может получить ещё одно work и оставить его в
unqueued_work. А при отсутствии готовых заданий он ждёт ДО callback.
Стенд явно показывает: managed IO может остановиться, но этот upstream wait
продолжается; затем hash_push контрольного задания будит реальный hash_pop,
callback отклоняет передачу и только после join можно освобождать окружение.

True завершает один fill pass, но не обеспечивает ожидание/темп scanwork.
Полный queued-device scheduler, обработка work_restart/update/flush,
физическая инициализация и зарегистрированный device_drv ещё не реализованы.
Освобождение core work не освобождает 32-битный wire-slot. Повторное использование
по modulo/таймауту, аппаратный drain/new epoch и ASIC ACK здесь не вводятся.

## Воспроизведение

После получения точного коммита и подготовки host-зависимостей:

```
python3 -B integration/review/queue_callback/test_runner.py
python3 -B -O integration/review/queue_callback/test_runner.py
python3 -B integration/review/queue_callback/run.py --cc gcc-14 --baseline icarus --out build/r12-gcc --mutants
python3 -B integration/review/queue_callback/run.py --cc clang-17 --baseline icarus --out build/r12-clang --mutants
python3 -B integration/review/queue_callback/run.py --cc gcc-14 --baseline icarus --out build/r12-san --sanitize
```

`--groups queue_callback` — только27 новых сценариев, не полный набор523.
Runner импортирует R11 и сохраняет496 прежних сценариев/59 контролей; добавляет
6 новых контролей. Текущие tracked C/headers проверяет прежний compiler-input guard.
Обязательный independent cancellation health предшествует sanitizer-прогону.
Санитайзеры покрывают прямые test/core TU и адаптеры, но не все support-библиотеки.
Runner сам не скачивает данные/пакеты и не меняет refs; out должен быть новым.
Реально завершённые результаты и ошибки записываются отдельно; наличие workflow
не означает успешную приёмку, и local archive anchor — не оригинальная Git-история.
