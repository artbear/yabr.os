// ----------------------------------------------------------
// This Source Code Form is subject to the terms of the
// Mozilla Public License, v.2.0. If a copy of the MPL
// was not distributed with this file, You can obtain one
// at http://mozilla.org/MPL/2.0/.
// ----------------------------------------------------------
// Codebase: https://github.com/ArKuznetsov/yabr.os/
// ----------------------------------------------------------

Перем Лог;

Процедура ОписаниеКоманды(Команда) Экспорт

	Команда.Опция("s start-row", 1, "начальная строка для чтения")
				.ТЧисло()
				.ПоУмолчанию(1);
	
	Команда.Опция("r mesure-rate", "", "частота замера скорости выполнения")
				.ТЧисло()
				.ПоУмолчанию(100);
КонецПроцедуры

Процедура ВыполнитьКоманду(Знач Команда) Экспорт
	
	Лог = ПараметрыПриложения.Лог();

	ВыводОтладочнойИнформации = Команда.ЗначениеОпции("verbose");
	Данные                    = Команда.ЗначениеАргумента("PATH");
	НачальнаяСтрока           = Команда.ЗначениеОпции("start-row");
	ЧастотаЗамера             = Команда.ЗначениеОпции("mesure-rate");

	ПараметрыПриложения.УстановитьРежимОтладкиПриНеобходимости(ВыводОтладочнойИнформации);
						
	ПараметрыОбработки = Новый Структура();
	ПараметрыОбработки.Вставить("НачальнаяСтрока"                , НачальнаяСтрока);
	ПараметрыОбработки.Вставить("ЧастотаЗамераСкоростиВыполнения", ЧастотаЗамера);

	Чтение = Новый ЧтениеСкобкоФайла();

	Чтение.УстановитьПараметрыОбработкиДанных(ПараметрыОбработки);

	Чтение.УстановитьДанные(Данные);

	Чтение.ОбработатьДанные();

	РезультатОбработки = Чтение.РезультатОбработки();

	УдалитьДанныеНеСовместимыеСJSON(РезультатОбработки);
	
	Сообщить(ЗаписатьДанныеВJSON(РезультатОбработки));

	Если ЧастотаЗамера > 0 Тогда
		Сообщить(Символы.ПС + ЗаписатьДанныеВJSON(Чтение.ЗамерСкоростиВыполнения()));
	КонецЕсли;

КонецПроцедуры // ВыполнитьКоманду

#Область СлужебныеПроцедурыИФункции

// Процедура - удаляет из состава структуры циклические ссылки и соответствия номеров строк
// 
// Параметры:
// 	Данные    - Структура    - даныые для обработки
//
Процедура УдалитьДанныеНесовместимыеСJSON(Данные)

	Если НЕ ТипЗнч(Данные) = Тип("Структура") Тогда
		Возврат;
	КонецЕсли;

	Если Данные.Свойство("Родитель") Тогда
		Данные.Удалить("Родитель");
	КонецЕсли;
	
	Если Данные.Свойство("НомераСтрок") Тогда
		Данные.Удалить("НомераСтрок");
	КонецЕсли;
		
	Если Данные.Свойство("Значения") И ТипЗнч(Данные.Значения) = Тип("Массив") Тогда
		Для Каждого ТекЭлемент Из Данные.Значения Цикл
			УдалитьДанныеНесовместимыеСJSON(ТекЭлемент);
		КонецЦикла;
	КонецЕсли;
	
КонецПроцедуры // УдалитьДанныеНесовместимыеСJSON()

// Функция - возвращает представление данных в текстовом формате JSON
//
// Параметры:
//  Данные	 - Структура, Массив(Структура)	 - данные для преобразования
// 
// Возвращаемое значение:
//  Строка - представление данных в текстовом формате JSON
//
Функция ЗаписатьДанныеВJSON(Знач Данные)
	
	Запись = Новый ЗаписьJSON();
	Запись.УстановитьСтроку(Новый ПараметрыЗаписиJSON(ПереносСтрокJSON.Unix, Символы.Таб));
	
	Попытка
		ЗаписатьJSON(Запись, Данные);
	Исключение
		ТекстОшибки = ПодробноеПредставлениеОшибки(ИнформацияОбОшибке());
		ВызватьИсключение ТекстОшибки;
	КонецПопытки;
	
	Возврат Запись.Закрыть();
	
КонецФункции // ЗаписатьДанныеВJSON()

#КонецОбласти // СлужебныеПроцедурыИФункции
