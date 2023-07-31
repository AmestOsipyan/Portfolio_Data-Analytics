# 8. Анализ сервиса вопросов и ответов по программированию
https://github.com/AmestOsipyan/DA_Yandex.projects/blob/main/Project%208/2_sql_tasks.sql


## Задачи проекта:
С помощью SQL посчитать и визуализировать ключевые метрики сервис-системы вопросов и ответов о программировании.

## Описание проекта:
Написаны все сложные SQL-запросы для подсчёта требуемых значений и метрик.

## ER-диаграмма:
![изображение](https://github.com/AmestOsipyan/DA_Yandex.projects/assets/139769461/6abf632b-2b89-4c65-a284-26a76c3a7414)

- stackoverflow.badges - Хранит информацию о значках, которые присуждаются за разные достижения.
Например, пользователь, правильно ответивший на большое количество вопросов
про PostgreSQL, может получить значок postgresql.
- stackoverflow.post_types - Содержит информацию о типе постов
- stackoverflow.posts - Содержит информацию о постах
- stackoverflow.users - Содержит информацию о пользователях
- stackoverflow.vote_types - Содержит информацию о типах голосов. Голос — это метка, которую пользователи ставят посту
- stackoverflow.votes - Содержит информацию о голосах за посты

## Инструменты и навыки:
- SQL
- PostgreSQL