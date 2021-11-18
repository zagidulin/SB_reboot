--схема БД: https://docs.google.com/document/d/1NVORWgdwlKepKq_b8SPRaSpraltxoMg2SIusTEN6mEQ/edit?usp=sharing

--task1
--Корабли: Для каждого класса определите число кораблей этого класса, потопленных в сражениях. Вывести: класс и число потопленных кораблей.

with q1 as (select "name", "class" from ships)
select "class", count("name") as sunk from q1
where "name" in
(
	select ship from outcomes
	where "result" = 'sunk'
)
group by "class";

--task2
--Корабли: Для каждого класса определите год, когда был спущен на воду первый корабль этого класса.
--Если год спуска на воду головного корабля неизвестен, определите минимальный год спуска на воду кораблей этого класса. Вывести: класс, год.

-- Данные о спуске на воду есть только в таблице ships. У весх классов в таблице ships есть данные о головном корабле.
-- Немного расширил задание добавив классы из таблицы classes, которые не представлены в таблице ships, но поскольку данны о
-- спеске на воду кораблей этого класса взять негде, то по ним проставляется 0. 
with q1 as -- выборка классов, по которым нет головного корабля (когда класс = имени), год - минимальный из спусков кораблей этого класса
(
	select "class", min(launched) as launched
	from ships
	where "class" not in (select "name" from ships)
	group by "class"
)
select c."class",
	case
		when launched is not null
		then launched
		else 0
	end first_launched
from classes c
left join
( 
select "class", launched
from ships
where "class" = "name" -- выборка классов, по которым есть головной корабля (когда класс = имени), год - спуск головного
union -- присоединяем классы без данных о головном (см выше q1)
select "class", launched
from q1) a
on c."class" = a."class"
order by first_launched;

--task3
--Корабли: Для классов, имеющих потери в виде потопленных кораблей и не менее 3 кораблей в базе данных, вывести имя класса и число потопленных кораблей.

with q1 as
( -- считаем потонувшие корабли по классам
	select "class", count("name") as ships_sunk from ships
	where "name" in
	(
		select ship from outcomes
		where "result" = 'sunk'
	)
	group by "class"
), q2 as
( -- считаем общее количество кораблей по калссам (если меньше 3, то NULL)
	select "class",
	case
		when count("name") >=3
		then count("name")
	end ships_total
	from ships
	group by "class"
)
select q1."class", q1.ships_sunk from q1
join q2
on q1."class" = q2."class"
where q2.ships_total is not null;


--task4
--Корабли: Найдите названия кораблей, имеющих наибольшее число орудий среди всех кораблей такого же водоизмещения (учесть корабли из таблицы Outcomes).

-- У кораблей из outcomes класс не указан, поэтому отнести их классу можно только по имени, предполагая, что
-- имя головного корабля совпадает с именем класса. Попробовал сделать исходя из этого предположения.
with q as 
(
	select displacement, count(displacement), max(numguns) from classes
	group by displacement
)
select ships."name"
from ships
join classes
on ships."class" = classes."class"
where classes.displacement in
(
	select displacement
	from q where "count" > 1
) and classes.numguns = 
(
	select "max" from q
	where displacement = classes.displacement
)
union
select outcomes.ship from outcomes
join classes
on outcomes.ship = classes."class"
where classes.displacement in
(
	select displacement from q
	where "count" > 1
) and classes.numguns =
(
	select "max" from q
	where displacement = classes.displacement
);

--task5
--Компьютерная фирма: Найдите производителей принтеров, которые производят ПК с наименьшим объемом RAM и с самым быстрым процессором 
--среди всех ПК, имеющих наименьший объем RAM. Вывести: Maker

with q as (select ram, max(speed) as max_speed
	from pc
	group by ram
	order by ram)
select product.maker from product
join pc
on product.model = pc.model
where "type" = 'PC' and maker in
(
	select distinct maker from product
	where "type" = 'Printer'
) and pc.ram =
( -- поскольку в подзапросе вывод отсртирован по возрастанию, то сделал через LIMIT, так короче код получается
	select ram from q limit 1
) and pc.speed =
( -- поскольку в подзапросе вывод отсртирован по возрастанию, то сделал через LIMIT, так короче код получается
	select max_speed from q limit 1
);
