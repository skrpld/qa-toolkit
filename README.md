# qa-toolkit

Набор независимых инструментов для QA/инфраструктурных проверок ВМ и окружений.
Каждый инструмент — отдельная папка в `tools/` со своим README.

## Инструменты

| Инструмент | Описание |
| --- | --- |
| [`nvme-iops-bench`](tools/nvme-iops-bench/README.md) | Проверка того, что провайдер реально отдаёт заявленные в тарифе IOPS. Собирается офлайн-ISO с fio для VM без интернета. |

## Структура репозитория

```
qa-toolkit/
├── .github/workflows/    # CI-workflow'ы (у GitHub Actions видны только отсюда)
├── tools/
│   └── nvme-iops-bench/
└── README.md             # этот файл
```

## Добавление нового инструмента

См. [CONTRIBUTING.md](CONTRIBUTING.md).
