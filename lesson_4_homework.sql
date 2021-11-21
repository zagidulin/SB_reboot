--схема БД: https://docs.google.com/document/d/1NVORWgdwlKepKq_b8SPRaSpraltxoMg2SIusTEN6mEQ/edit?usp=sharing
--colab/jupyter: https://colab.research.google.com/drive/1j4XdGIU__NYPVpv74vQa9HUOAkxsgUez?usp=sharing

--task13 (lesson3)
--Компьютерная фирма: Вывести список всех продуктов и производителя с указанием типа продукта (pc, printer, laptop). Вывести: model, maker, type

select model, maker, "type" from product;

--task14 (lesson3)
--Компьютерная фирма: При выводе всех значений из таблицы printer дополнительно вывести для тех, у кого цена вышей средней PC - "1", у остальных - "0"

select *,
case
	when price > (select avg(price) from pc)
	then 1
	else 0
end flag
from printer;

--task15 (lesson3)
--Корабли: Вывести список кораблей, у которых class отсутствует (IS NULL)

with q as 
(
	select "name", "class" from ships
	union
	select "ship", null as "class" from outcomes
)
select "name" from q where "class" is null;

--task16 (lesson3)
--Корабли: Укажите сражения, которые произошли в годы, не совпадающие ни с одним из годов спуска кораблей на воду.

select distinct "name" from battles
where extract(year from "date") not in (select launched from ships); 

--task17 (lesson3)
--Корабли: Найдите сражения, в которых участвовали корабли класса Kongo из таблицы Ships.

select distinct battle from outcomes
where ship in
(
	select "name" from ships
	where "class" = 'Kongo'
);

--task1  (lesson4)
-- Компьютерная фирма: Сделать view (название all_products_flag_300) для всех товаров (pc, printer, laptop) с флагом, если стоимость больше > 300. Во view три колонки: model, price, flag

create view all_products_flag_300 as
select model, price,
case
	when price > 300
	then 1
	else 0
end flag
from pc
union
select model, price,
case
	when price > 300
	then 1
	else 0
end flag
from printer
union
select model, price,
case
	when price > 300
	then 1
	else 0
end flag
from laptop;

select * from all_products_flag_300;

--task2  (lesson4)
-- Компьютерная фирма: Сделать view (название all_products_flag_avg_price) для всех товаров (pc, printer, laptop) с флагом, если стоимость больше cредней . Во view три колонки: model, price, flag

-- Предположил, больше среденей соответствующего типа. В задании не уточняется.
create view all_products_flag_avg_price as
select model, price,
case
	when price > (select avg(price) from pc)
	then 1
	else 0
end flag
from pc
union
select model, price,
case
	when price > (select avg(price) from printer)
	then 1
	else 0
end flag
from printer
union
select model, price,
case
	when price > (select avg(price) from laptop)
	then 1
	else 0
end flag
from laptop;

select * from all_products_flag_avg_price;

--task3  (lesson4)
-- Компьютерная фирма: Вывести все принтеры производителя = 'A' со стоимостью выше средней по принтерам производителя = 'D' и 'C'. Вывести model

with q as 
(
	select printer.model, printer.price
	from printer
	join product
	on printer.model = product.model
	where product.maker = 'D' or product.maker = 'C'
)
select printer.model
from printer
join product
on printer.model = product.model
where product.maker = 'A' and printer.model in
(
	select model from printer
	where price > (select avg(price) from q)
);

--task4 (lesson4)
-- Компьютерная фирма: Вывести все товары производителя = 'A' со стоимостью выше средней по принтерам производителя = 'D' и 'C'. Вывести model

with q as 
(
	select printer.model, printer.price
	from printer
	join product
	on printer.model = product.model
	where product.maker = 'D' or product.maker = 'C'
)
select printer.model
from printer
join product
on printer.model = product.model
where product.maker = 'A' and printer.model in
(
	select model from printer
	where price > (select avg(price) from q)
)
union
select pc.model
from pc
join product
on pc.model = product.model
where product.maker = 'A' and pc.model in
(
	select model from pc
	where price > (select avg(price) from q)
)
union
select laptop.model
from laptop
join product
on laptop.model = product.model
where product.maker = 'A' and laptop.model in
(
	select model from laptop
	where price > (select avg(price) from q)
);

--task5 (lesson4)
-- Компьютерная фирма: Какая средняя цена среди уникальных продуктов производителя = 'A' (printer & laptop & pc)

-- Уникальных типов продуктов в смысле? Сделал в таком предположении, т.е. выводится средняя цена по каждой группе товаров производителя "А"
select p."type", avg(pc.price)
from product p
join pc
on p.model = pc.model
where p.maker = 'A'
group by p."type"
union
select p."type", avg(printer.price)
from product p
join printer
on p.model = printer.model
where p.maker = 'A'
group by p."type"
union
select p."type", avg(laptop.price)
from product p
join laptop
on p.model = laptop.model
where p.maker = 'A'
group by p."type";

--task6 (lesson4)
-- Компьютерная фирма: Сделать view с количеством товаров (название count_products_by_makers) по каждому производителю. Во view: maker, count

create view count_products_by_makers as
select maker, count(model)
from product
group by maker
order by maker;

drop view count_products_by_makers;

select * from count_products_by_makers;

--task7 (lesson4)
-- По предыдущему view (count_products_by_makers) сделать график в colab (X: maker, y: count)

request = """
select * 
from count_products_by_makers
"""
df = pd.read_sql_query(request, conn)
fig = px.bar(x=df.maker.to_list(), y=df.count.to_list(), labels={'x':'maker', 'y':'total products'})
fig.show()

--task8 (lesson4)
-- Компьютерная фирма: Сделать копию таблицы printer (название printer_updated) и удалить из нее все принтеры производителя 'D'

create table printer_updated as
table printer;

select * from printer_updated;

delete from printer_updated
where model in 
(
	select model from product
	where maker = 'D' and "type" = 'Printer'
);

--task9 (lesson4)
-- Компьютерная фирма: Сделать на базе таблицы (printer_updated) view с дополнительной колонкой производителя (название printer_updated_with_makers)

create view printer_updated_with_makers as
select printer_updated.*, product.maker
from printer_updated
join product
on printer_updated.model = product.model;

select * from printer_updated_with_makers;

--task10 (lesson4)
-- Корабли: Сделать view c количеством потопленных кораблей и классом корабля (название sunk_ships_by_classes).
-- Во view: count, class (если значения класса нет/IS NULL, то заменить на 0)

create view sunk_ships_by_classes as
select
case
	when outcomes.ship in (select "name" from ships)
	then (select "class" from ships where "name" = outcomes.ship)
	else '0'
end "class",
count(ship)
from outcomes
where result = 'sunk'
group by "class";

select * from sunk_ships_by_classes;

--task11 (lesson4)
-- Корабли: По предыдущему view (sunk_ships_by_classes) сделать график в colab (X: class, Y: count)

-- код для colab.
-- Не нашёл как заставить plotly воспринимать строго заданные значения для осей (в данном случае "0" и названия классов).
-- Поэтому 0 переделал в No class. Иначе ось X была числовой и текстовые значения класса игнорировались, т.е. на ось X не попадали.
request = """
select
case
	when "class" = '0'
	then 'No class'
	else "class"
end "class",
count
from sunk_ships_by_classes
"""

df = pd.read_sql_query(request, conn)
fig = px.bar(x=df['class'], y=df['count'], labels={'x':'class', 'y':'count'})
fig.show()

--task12 (lesson4)
-- Корабли: Сделать копию таблицы classes (название classes_with_flag) и добавить в нее flag: если количество орудий больше или равно 9 - то 1, иначе 0

create table classes_with_flag as 
select *,
case
	when numguns >= 9
	then 1
	else 0
end flag
from classes;

--task13 (lesson4)
-- Корабли: Сделать график в colab по таблице classes с количеством классов по странам (X: country, Y: count)

select country, count("class")
from classes
group by country

request = """
select country, count("class")
from classes
group by country
"""
df = pd.read_sql_query(request, conn)
fig = px.bar(x=df['country'], y=df['count'], labels={'x':'country', 'y':'count'})
fig.show()

--task14 (lesson4)
-- Корабли: Вернуть количество кораблей, у которых название начинается с буквы "O" или "M".

select count("name") from ships
where "name" like 'O%' or "name" like 'M%';

--task15 (lesson4)
-- Корабли: Вернуть количество кораблей, у которых название состоит из двух слов.

select count("name") from ships
where "name" like '% %' and "name" not like '% % %'; -- not like '% % %' для невключения строк из более, чем двух
 
--task16 (lesson4)
-- Корабли: Построить график с количеством запущенных на воду кораблей и годом запуска (X: year, Y: count)

-- код для colab
request = """
select launched, count("name") from ships
group by launched
order by launched
"""
df = pd.read_sql_query(request, conn)
fig = px.bar(x=df['launched'], y=df['count'], labels={'x':'year', 'y':'ships launched'})
fig.show()
