# B-12: публикация шаблона c3148, offline

Задача #42, координация #2. База `12446bed78a060a49364a80bcbfb4340b13f4f27`.
Только десять новых файлов. Production Makefile, cgminer, прежние recovery
функции и общий ARM-интерпретатор не изменены; зависимости от ожидающих PR нет.

## Подтверждённое поведение

`c3148..c338f` из `vnishnet-t21-aml-nand-v1.3.5.tar.gz`:

1. Lock `633af0`.
2. Прочитать указатель `633b40+50`; если ненулевой, free, затем обнулить поле.
3. Аналогично, с новым чтением после предыдущего callback, `+48`, затем `+4`.
4. Вызвать `5cd70(destination=633b40, source=аргумент)`.
5. Записать ready byte `633b38=1`.
6. **Заново** прочитать byte `source+60`; любое ненулевое значение вызывает `fa944`.
7. Broadcast condition `633b08`, затем unlock `633af0`.

Результаты OS-вызовов не проверяются. Нет rollback или статуса успеха.
Обнуление после free перезаписывает даже синхронную запись этого поля внутри
callback. Последующие поля читаются позднее, не снимаются общим snapshot.
`x*(x-1)&1` всегда ноль для 32-битного wrapping x; ложные ветви обфускации
не добавляют повторных free/reset/broadcast. Тесты исполняют исходные инструкции
в том числе с предельными значениями этих глобальных слов.

## API и границы

`vn135_template_publish_135(view, ops, context)` — void. Новый named-field view
не является vendor ABI или `struct work`. Все указатели полей, object и callback
identities фиксированы на время вызова. Callback может синхронно менять только
pointed-to значения. Поля и view/ops не перекрываются, source/destination —
разные стабильные объекты. Все callbacks обязательны, defaults отсутствуют.
OS-операции, освобождение, clone и reset задаёт вызывающая сторона; никакой
производственный allocator, mutex или скрытый hardware stub не установлен.

**5cd70 не реализован этим PR.** Его Ghidra/A32 приложены для проверки границы:
raw memcpy104, malloc coinbase length, запись destination+48 до нового чтения
source+48/+4c, malloc uint32(branch count<<5), запись destination+50 до copy,
затем поздний strdup source+4 или NULL. Нет проверки allocation failure.
Сценарии используют явно заданные эффекты clone, а не утверждают полную
эквивалентность клонирования, aliasing или аварийного выделения памяти.

Прочитан реальный `cgminer.c`: `copy_work_noffset/_copy_work` выделяют родной
work, сохраняют новый id, копируют и дублируют родные строки, умеют менять ntime;
`clean_work` освобождает job_id/ntime/coinbase/nonce1 и обнуляет весь объект;
`_free_work` дополнительно освобождает сам work. Они не эквивалентны raw104
дескриптору и трём освобождениям здесь. При native-интеграции нужны штатные
work-владение и typed adapter. Второй production work/clone не добавлен.

Вложенное `fa944` использует **существующие** `vn135_nonce_fifo_reset` и
`vn135_fifo_reset`. Сравнение ограничено initialized ready1, storage,
capacity4096, stride72, корректными cursors и успешными queue lock/unlock.
Существующие guards/возвраты отличаются от оригинала, который игнорирует ошибки.
Поэтому coordinator оставляет reset обязательной границей без общей fallback.
Проверяется сохранение всех storage bytes, размеров и push_word; меняются только
count/read/write. Ghidra ошибочно включает в fa944 tail-called OS unlock body;
oracle исполняет только `fa944..fa973` и `d212c..d2143`, unlock остаётся callback.

## Доказательства и воспроизводимость

Archive SHA256 `20fabdd66255889315e61ae2a33ff2e4623566ca430f1cb8c90d9b938dc7b43c`.
ELF SHA256 `b2663b3aa753cc14ae9d3b11a14d3d93c74b605a3e433b02101c3c17c69d95e9`.
ELF заново извлечён штатным `tools/extract_reference.py`: U-Boot/gzip/newc
внутри uramdisk.image.gz, только usr/bin/cgminer. Ни один vendor executable не запущен.

Evidence JSON содержит пять хешированных A32/literal slices, десять PC-relative
адресов, восемь actual Ghidra12.1.4 artifacts (script/log/C/ASM). Полный Ghidra
log фиксирует ошибочное включение OS-body; оно не является областью реализации.

```sh
make -f integration/template-publication-135.mk CC=gcc TEMPLATE_DIR=build/b12-gcc all sanitize negative regressions
make -f integration/template-publication-135.mk CC=clang TEMPLATE_DIR=build/b12-clang all sanitize negative regressions
clang --analyze -I. -Iinclude -std=c11 -Wall -Wextra -Wpedantic -Xanalyzer -analyzer-output=text src/backend/work-gen/template-publication.c
```

Original/C: 352 сценария, 2655 событий, 33733 ARM steps, 123 достигнутых PC;
116 сценариев разрешают вложенный reset (не все вызывают его при flag0).
Сравниваются полные 256 bytes global window, 136 bytes source/guards, queue
words, storage и callback traces. Clone остаётся scripted boundary в обеих
сторонах. Native/ASan/UBSan: 240 сценариев с настоящими host malloc/free,
сохранением ownership, callback-порядком и проверкой всех bytes очереди.
22 compiled mutants должны отличаться от кешированных исходных fixtures;
compile failure, signal/crash или timeout не считаются обнаружением ошибки.

Старые Stage13 ring/queue/producer-composition и route/TX88 тесты запускаются
отдельно. Python/shared-library регрессии не instrumented ASan; собственный C
тест и старый C FIFO-тест запускаются с ASan/UBSan. Non-PIE флаги относятся
только к host sanitizer executable (известная проблема PIE-ASan в этой WSL).
Подробные фактические результаты и CI artifacts публикуются по head SHA в PR.

Не проверены: реальная многопоточность, OS-планирование, полный clone/lifecycle,
native T21 adapter, загрузка прошивки, оборудование, пул и принятые шары.
