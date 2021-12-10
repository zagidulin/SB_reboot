--task1  (lesson9)
-- oracle: https://www.hackerrank.com/challenges/the-report/problem

/* Null специально в кавычки взят, т.к. именно так и требуют по условию.
Если просто Null указать, то не принимается ответ.
*/
select
case when Grade >= 8 
then Name 
else 'NULL' 
end Name, 
Grade, 
Marks 
from Students 
join Grades 
on Marks between Min_Mark and Max_Mark 
order by Grade desc, Name, Marks;

--task2  (lesson9)
-- oracle: https://www.hackerrank.com/challenges/occupations/problem

/* Код громоздкий несколько получился, но результат выдаёт, насколько вижу, такой как и описан в задаче,
но не принимается. Посмотрите, пожалуйста, в чём может быть проблема.
Null специально в кавычки взяты, т.к., насколько понял, именно так и требуется по условию (как в предыдущей задаче)
Но если просто Null указать, то всё равно не принимается ответ.
*/
select
    case
        when D is not Null then D else 'Null'
    end as Doctor,
    case
        when P is not Null then P else 'Null'
    end as Professor,
    case
        when S is not Null then S else 'Null'
    end as Singer,
    case
        when A is not Null then A else 'Null'
    end as Actor
from
(select d.Name D, p.Name P, s.Name S, a.Name A
from
    (select distinct row_number() over(partition by Occupation order by Occupation) rn from Occupations) n
full join
    (select row_number() over(order by Name) rn, Name
    from Occupations where Occupation = 'Doctor') d
on n.rn = d.rn
full join
    (select row_number() over(order by Name) rn, Name
    from Occupations where Occupation = 'Professor') p
on n.rn = p.rn
full join
    (select row_number() over(order by Name) rn, Name
    from Occupations where Occupation = 'Singer') s
on n.rn = s.rn
full join
    (select row_number() over(order by Name) rn, Name
    from Occupations where Occupation = 'Actor') a
on n.rn = a.rn
order by n.rn) q;

--task3  (lesson9)
-- oracle: https://www.hackerrank.com/challenges/weather-observation-station-9/problem

select distinct CITY from STATION where LEFT(CITY,1) not in ('A','E','I','O','U');

--task4  (lesson9)
-- oracle: https://www.hackerrank.com/challenges/weather-observation-station-10/problem

select distinct CITY from STATION where RIGHT(CITY,1) not in ('a','e','i','o','u');

--task5  (lesson9)
-- oracle: https://www.hackerrank.com/challenges/weather-observation-station-11/problem

select distinct CITY from STATION where LEFT(CITY,1) not in ('A','E','I','O','U') or RIGHT(CITY,1) not in ('a','e','i','o','u');

--task6  (lesson9)
-- oracle: https://www.hackerrank.com/challenges/weather-observation-station-12/problem

select distinct CITY from STATION
where LEFT(CITY,1) not in ('A','E','I','O','U')
	and RIGHT(CITY,1) not in ('a','e','i','o','u');

--task7  (lesson9)
-- oracle: https://www.hackerrank.com/challenges/salary-of-employees/problem

select name from Employee
where salary > 2000 and months < 10
order by employee_id;

--task8  (lesson9)
-- oracle: https://www.hackerrank.com/challenges/the-report/problem

select
case when Grade >= 8 
then Name 
else 'NULL' 
end Name, 
Grade, 
Marks 
from Students 
join Grades 
on Marks between Min_Mark and Max_Mark 
order by Grade desc, Name, Marks;