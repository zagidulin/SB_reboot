--task1  (lesson8)
-- oracle: https://leetcode.com/problems/department-top-three-salaries/

with q as
(
    select
        name as Employee,
        salary as Salary,
        departmentId,
        dense_rank() over(partition by departmentId order by salary desc) as rnk
    from Employee
)
select name as Department, Employee, Salary
from Department
join q
on departmentId = id
where rnk <= 3;

--task2  (lesson8)
-- https://sql-academy.org/ru/trainer/tasks/17

select f.member_name, f.status, sum(p.unit_price*p.amount) as costs
from FamilyMembers f
join Payments p
on f.member_id = p.family_member
where year(p.date) = 2005
group by f.member_name, f.status;

--task3  (lesson8)
-- https://sql-academy.org/ru/trainer/tasks/13

select distinct p1.name
from Passenger p1
join Passenger p2
on p1.name = p2.name
where p1.id <> p2.id;

--task4  (lesson8)
-- https://sql-academy.org/ru/trainer/tasks/38

select count(first_name) as count
from Student
where first_name = 'Anna';

--task5  (lesson8)
-- https://sql-academy.org/ru/trainer/tasks/35

select count(distinct classroom) as count
from Schedule
where date(date) = '2019-09-02';

--task6  (lesson8)
-- https://sql-academy.org/ru/trainer/tasks/38

select count(first_name) as count
from Student
where first_name = 'Anna';

--task7  (lesson8)
-- https://sql-academy.org/ru/trainer/tasks/32

with q as 
(
    select 
        case
            when MONTH(birthday) < MONTH(CURDATE())
            then YEAR(CURDATE()) - YEAR(birthday)
            when MONTH(birthday) = MONTH(CURDATE()) and
                DAYOFMONTH(birthday) <= DAYOFMONTH(CURDATE())
            then YEAR(CURDATE()) - YEAR(birthday)
            else YEAR(CURDATE()) - YEAR(birthday) - 1
        end age
    from FamilyMembers
)
select FLOOR(AVG(age)) as age from q 

--task8  (lesson8)
-- https://sql-academy.org/ru/trainer/tasks/27

with q as
(
    select good_id, good_type_name
    from Goods
    join GoodTypes
    on Goods.type = GoodTypes.good_type_id
)
select good_type_name, sum(unit_price*amount) as costs
from q
join Payments
on q.good_id = Payments.good
where year(date) = 2005
group by good_type_name;

--task9  (lesson8)
-- https://sql-academy.org/ru/trainer/tasks/37

with q as
(
    select birthday from Student
    order by birthday desc
    limit 1
)
select 
    case
        when MONTH(birthday) < MONTH(CURDATE())
        then YEAR(CURDATE()) - YEAR(birthday)
        when MONTH(birthday) = MONTH(CURDATE()) and
            DAYOFMONTH(birthday) <= DAYOFMONTH(CURDATE())
        then YEAR(CURDATE()) - YEAR(birthday)
        else YEAR(CURDATE()) - YEAR(birthday) - 1
    end year
from q

--task10  (lesson8)
-- https://sql-academy.org/ru/trainer/tasks/44

with q as
(
    select birthday
    from Student
    join Student_in_class
    on Student.id = Student_in_class.student
    where Student_in_class.class in 
        (select id from Class where name like '10%')
    order by birthday
    limit 1
)
select 
    case
        when MONTH(birthday) < MONTH(CURDATE())
        then YEAR(CURDATE()) - YEAR(birthday)
        when MONTH(birthday) = MONTH(CURDATE()) and
            DAYOFMONTH(birthday) <= DAYOFMONTH(CURDATE())
        then YEAR(CURDATE()) - YEAR(birthday)
        else YEAR(CURDATE()) - YEAR(birthday) - 1
    end max_year
from q

--task11 (lesson8)
-- https://sql-academy.org/ru/trainer/tasks/20

select f.status, f.member_name, sum(p.unit_price*p.amount) as costs
from FamilyMembers f
join Payments p
on f.member_id = p.family_member
where p.good in 
    (
        select good_id from Goods
        join GoodTypes
        on good_type_id = type
        where good_type_name = 'entertainment'
    )
group by f.member_name, f.status;

--task12  (lesson8)
-- https://sql-academy.org/ru/trainer/tasks/55

with q as 
(
    select company, dense_rank() over(order by count(company)) as rnk from Trip
    group by company
)
delete from Company
where id in (select company from q where rnk = 1);

--task13  (lesson8)
-- https://sql-academy.org/ru/trainer/tasks/45

with q as 
(
    select classroom, dense_rank() over(order by count(classroom) desc) rnk
    from Schedule
    group by classroom
)
select classroom from q
where rnk = 1;

--task14  (lesson8)
-- https://sql-academy.org/ru/trainer/tasks/43

select t.last_name
from Teacher t
join Schedule s
on t.id = s.teacher
where s.subject in 
    (
        select id from Subject
        where name = 'Physical Culture'
    )
order by t.last_name;

--task15  (lesson8)
-- https://sql-academy.org/ru/trainer/tasks/63

select CONCAT(
            last_name, 
            '.', 
            SUBSTRING(first_name, 1, 1), 
            '.', SUBSTRING(middle_name, 1, 1), 
            '.') as name
from Student
order by name;
