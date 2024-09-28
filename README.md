# ToDoList
Это тестовое задание для компании EffectiveMobile. Реализован TodoList с загрузкой напоминаний с сервера (dummyjson API) при первом запуске. Присутствует возможность добавлять, редактировать и удалять напоминания. Приложение использует архитектуру VIPER, потому что это является требованием ТЗ. Поддержка многопоточности (GCD) и фоновая работа CoreData. 

# Оглавление
[Особенности](#features)  
[Приложение в работе](#workingApp)

<a name="features"></a>
## Особенности
* Архитектура VIPER;
* UITableView с кастомными ячейками;
* фоновая работа CoreData, используя private queue context;
* кастомные ячейки с динамической высотой;
* обработка всех ошибок проекта;
* паттерн builder для сборки модулей;
* разделение проекта на слои;
* кастомный UISegmentedControl;
* кастомный PaddingLabel;
* кнопка с увеличенным hitbox;
* UserDefaults;
* UIDatePicker;
* использование SFSymbols.

<a name="workingApp"></a>
## Приложение в работе
<span> <img src="https://github.com/VladislavGolovachev/ToDoList/blob/main/ToDoListWorking.gif" alt="drawing" width="400">
