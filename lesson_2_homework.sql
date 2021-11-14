--схема БД: https://docs.google.com/document/d/1NVORWgdwlKepKq_b8SPRaSpraltxoMg2SIusTEN6mEQ/edit?usp=sharing
--colab/jupyter: https://colab.research.google.com/drive/1j4XdGIU__NYPVpv74vQa9HUOAkxsgUez?usp=sharing

-- Задание 1: Вывести name, class по кораблям, выпущенным после 1920

select "name", "class" from ships
where launched > 1920;

-- Задание 2: Вывести name, class по кораблям, выпущенным после 1920, но не позднее 1942

select "name", "class" from ships
where launched > 1920 and launched <= 1942;

-- Задание 3: Какое количество кораблей в каждом классе. Вывести количество и class

select count(*) as ships_count, "class"
from ships
group by "class";

-- Задание 4: Для классов кораблей, калибр орудий которых не менее 16, укажите класс и страну. (таблица classes)

select "class", country
from classes
where bore >= 16;

-- Задание 5: Укажите корабли, потопленные в сражениях в Северной Атлантике (таблица Outcomes, North Atlantic). Вывод: ship.

select ship from outcomes
where battle = 'North Atlantic' and "result" = 'sunk';

-- Задание 6: Вывести название (ship) последнего потопленного корабля

	-- 6.1. Под последним можно понять нижнию строку в таблице. Тогда:
select * from outcomes
where "result" = 'sunk'
limit 1
offset (select count(*) from outcomes where "result" = 'sunk') - 1;

	-- 6.2. Если последний по дате сражения (правда, м.б. несколько в одну дату), то:
select ship
from outcomes
join battles
on outcomes.battle = battles."name"
where outcomes."result" = 'sunk'
order by "date" desc limit 1

-- Задание 7: Вывести название корабля (ship) и класс (class) последнего потопленного корабля

	-- 7.1. Если нужна нижняя строка в таблице
select o.ship, sh."class" from outcomes o 
join ships sh
on o.ship = sh."name"
where "result" = 'sunk'
limit 1
offset (
	select count(*) from outcomes
	where "result" = 'sunk' and ship in (
		select "name" from ships
	)) - 1;

	-- 7.2. Если ищем крайний по дате
-- Вопрос: такой вариант равнозначен варианту с JOIN в плане скорости выполнения запроса?
select ship, battles."name", "class"
from outcomes, battles, ships
where outcomes.battle = battles."name"
	and outcomes."result" = 'sunk'
	and ships."name" = ship
order by "date" desc limit 1;

-- Задание 8: Вывести все потопленные корабли, у которых калибр орудий не менее 16, и которые потоплены. Вывод: ship, class

select ship, "class"
from outcomes
join ships
on outcomes.ship = ships."name"
where outcomes."result" = 'sunk' and "class" in (
	select "class" from classes
	where bore >= 16
);

-- Задание 9: Вывести все классы кораблей, выпущенные США (таблица classes, country = 'USA'). Вывод: class

select "class" from classes
where country = 'USA';

-- Задание 10: Вывести все корабли, выпущенные США (таблица classes & ships, country = 'USA'). Вывод: name, class

select ships."name", ships."class" from ships, classes
where ships."class" = classes."class" and country = 'USA';
