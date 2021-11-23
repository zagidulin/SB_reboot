--схема БД: https://docs.google.com/document/d/1NVORWgdwlKepKq_b8SPRaSpraltxoMg2SIusTEN6mEQ/edit?usp=sharing
--colab/jupyter: https://colab.research.google.com/drive/1j4XdGIU__NYPVpv74vQa9HUOAkxsgUez?usp=sharing

--task1 (lesson5)
-- Компьютерная фирма: Сделать view (pages_all_products), в которой будет постраничная разбивка всех продуктов (не более двух продуктов на одной странице). Вывод: все данные из laptop, номер страницы, список всех страниц

sample:
1 1
2 1
1 2
2 2
1 3
2 3

create view pages_all_products  as
-- блок with создан вместо объявления переменной, т.к. у меня не включён PL/pgSQL
-- в задании не сказано про переменные, сделал для имитации выбора кол-ва на странице
WITH view_params(itemsOnPage) as (
   values(2))
select *,
case
	when row_number() over() % (SELECT itemsOnPage FROM view_params) != 0
	then row_number() over() % (SELECT itemsOnPage FROM view_params)
	else (SELECT itemsOnPage FROM view_params)
end item,
case
	when row_number() over() % (SELECT itemsOnPage FROM view_params) != 0
	then row_number() over() / (SELECT itemsOnPage FROM view_params) + 1
	else row_number() over() / (SELECT itemsOnPage FROM view_params)
end page
from laptop;

select * from pages_all_products;

--task2 (lesson5)
-- Компьютерная фирма: Сделать view (distribution_by_type), в рамках которого будет процентное соотношение
-- всех товаров по типу устройства. Вывод: производитель, тип, процент (%)

create view distribution_by_type as
with q as
(
	select p."type", count(l.model) from product p
	join laptop l
	on p.model = l.model
	group by p."type"
	union
	select p."type", count(pc.model) from product p
	join pc
	on p.model = pc.model
	group by p."type"
	union
	select p."type", count(pr.model) from product p
	join printer pr
	on p.model = pr.model
	group by p."type"
)
select
	"type",
	(sum("count") over(partition by "type") / sum("count") over()) * 100 as  share_of_products
from q;

select * from distribution_by_type;

--task3 (lesson5)
-- Компьютерная фирма: Сделать на базе предыдущенр view график - круговую диаграмму. Пример https://plotly.com/python/histograms/

-- код для colab
request = """
select *
from distribution_by_type
"""
df = pd.read_sql_query(request, conn)
fig = px.pie(df, values='share_of_products', names='type', title='Products')
# px.bar(x=df.maker.to_list(), y=df.count.to_list(), labels={'x':'maker', 'y':'total products'})
fig.show()

--task4 (lesson5)
-- Корабли: Сделать копию таблицы ships (ships_two_words), но название корабля должно состоять из двух слов

create table ships_two_words as 
select * from ships
where "name" like '% %' and "name" not like '% % %';

select * from ships_two_words;

--task5 (lesson5)
-- Корабли: Вывести список кораблей, у которых class отсутствует (IS NULL) и название начинается с буквы "S"

with q as (
	select X."name", "class" from 
		(
			select "name" from ships
			union
			select ship from outcomes
		) X
	left join ships
	on X."name" = ships."name")
select "name" from q
where "name" like 'S%';


--task6 (lesson5)
-- Компьютерная фирма: Вывести все принтеры производителя = 'A' со стоимостью выше средней по принтерам производителя = 'C' и три самых дорогих (через оконные функции). Вывести model

-- три самых дорогих чего? Принтера вообще или три самых дорогих принтера производителя "А"?
-- т.к. у "А" всего три принтера, то решил, что просто самых дорогих.
-- А ещё среди производителей прнтеров нет "С"
with q as 
(
	select avg(pr.price)
	from printer pr
	join product p
	on pr.model = p.model
	where p.maker = 'D'
)
select pr.model
from printer pr
join product p
on pr.model = p.model
where p.maker = 'A' and pr.price > (select "avg" from q)
union all -- union all, т.к. из задания следует, что вс пр-ля "А" и самые дорогие, они могут пересекаться. Про дубли уточнения нет.
select model from
(
	select *, row_number() over(order by price desc)as rn from printer
) X
where rn <= 3
