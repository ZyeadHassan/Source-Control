
--1.Create a stored procedure without parameters to show the number of students per department name.
create procedure p1 as
begin
select COUNT(s.St_Id) as 'NO.of students',
		d.Dept_Name
from student s,Department d
where s.Dept_Id=d.Dept_Id
group by d.Dept_Name
end

exec p1
--........................................................................
--2.Create a stored procedure that will check for the # of employees in the project p1 if they are more than 3 print message to the user “'The number of employees in the project p1 is 3 or more'” if they are less display a message to the user “'The following employees work for the project p1'” in addition to the first name and last name of each one. [Company DB] 
alter procedure p2(@p varchar(30)) as
begin 
declare @n int 
set @n = (select COUNT(w.ESSn) from Project p,Works_for w 
where p.Pnumber=w.Pno and p.Pname=@p)
if @n >=3
select 'The number of employees in the project ' + @p +' is 3 or more'
else 
select 'The following employees work for the project ' + @p ,e.Fname,e.Lname
from Project p,Employee e,Works_for w
where p.Pnumber=w.Pno and e.SSN=w.ESSn and p.Pname=@p
end

exec p2 'Al Rawdah'
exec p2 'AL Solimaniah'
--3.Create a stored procedure that will be used in case there is an old employee has left the project and a new one become instead of him. The procedure should take 3 parameters (old Emp. number, new Emp. number and the project number) and it will be used to update works_on table. [Company DB]
create procedure p3(@oid int,@nid int ,@p int) as
begin
if exists (select * from Works_for where ESSn=@oid and Pno=@p)
update Works_for
set ESSn=@nid
where ESSn=@oid and Pno=@p
else 
select 'Data not found'

end

exec p3 968574,112233,700
exec p3 999999,112233,700

/*4.add column budget in project table and insert any draft values in it then 
then Create an Audit table with the following structure 
ProjectNo 	UserName 	ModifiedDate 	Budget_Old 	Budget_New 
p2 	Dbo 	2008-01-31	95000 	200000 

This table will be used to audit the update trials on the Budget column (Project table, Company DB)
Example:
If a user updated the budget column then the project number, user name that made that update, the date of the modification and the value of the old and the new budget wi ll be inserted into the Audit table
Note: This process will take place only if the user updated the budget column*/

alter table project
add  Budget int

create table audit(
ProjectNo 	varchar(30),
UserName 	varchar(30),
ModifiedDate 	datetime,
Budget_Old  int,
Budget_New int)

create trigger trg1 on project
after update as
begin
if update (Budget)
insert into audit
select i.Pnumber,suser_sname(),getdate(),d.Budget,i.Budget
from inserted i,deleted d
end

update Project
set Budget =200000
where Pnumber=100

/*5.Create a trigger to prevent anyone from inserting a new record in the Department table [ITI DB]
“Print a message for user to tell him that he can’t insert a new record in that table”*/

create trigger trg2 on department 
instead of insert as
begin
select 'You are not authorized to insert values'
end


insert into Department
values(100,'scjasjk','jcasjk','sajcg',125,GETDATE())

--6.Create a trigger that prevents the insertion Process for Employee table in March [Company DB].
create trigger trg3 on employee
after insert as
begin
if month(getdate())=3
select 'You cannot insert values in march!'
end

/*7.Create a trigger on student table after insert to add Row in Student Audit table (Server User Name , Date, Note) where note will be “[username] Insert New Row with Key=[Key Value] in table [table name]”
Server User Name		Date 
	Note */

ALTER TABLE st_audit
ALTER COLUMN Note varchar(250) 



alter trigger trg4 on student
after insert as
begin
insert into st_audit
select suser_sname(),GETDATE(), suser_sname()+' insert New Row with Key= '+ cast(St_id as varchar)+' in table student' 
from inserted
end

		
insert into Student
values (100,'Zyead','Hassan','zagazig',25,10,null)

insert into Student
values (200,'ahmed','mohamed','zagazig',25,10,null)

--8.Create a trigger on student table instead of delete to add Row in Student Audit table (Server User Name, Date, Note) where note will be“ try to delete Row with Key=[Key Value]”
alter trigger trg5 on student
instead of delete as
begin
insert into st_audit
select suser_sname(),GETDATE(), suser_sname()+' try to delete Row with '+ cast(St_id as varchar)+' in table student' 
from deleted
end


delete from student 
where St_Id=200




