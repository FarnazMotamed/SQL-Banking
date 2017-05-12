/*calendar*/
IF OBJECT_ID('tempdb..#dim_dates') IS NOT NULL DROP TABLE #dim_dates
GO

CREATE TABLE #dim_dates (
	day_date date
	primary key (day_date) with (ignore_dup_key = on)
);

/*customers entities*/
IF OBJECT_ID('tempdb..#dim_customers') IS NOT NULL DROP TABLE #dim_customers
GO

CREATE TABLE #dim_customers (
	id int,
	name nvarchar(255)
	primary key (id)
);

/*customer statuses entities*/
IF OBJECT_ID('tempdb..#dim_customer_statuses') IS NOT NULL DROP TABLE #dim_customer_statuses
GO

CREATE TABLE #dim_customer_statuses (
	id int,
	name nvarchar(255)
	primary key (id)
);


DECLARE @Date [date] = '20150101', @DateTo [date] = '20151231';

WHILE @Date <= @DateTo
BEGIN
	INSERT INTO #dim_dates(day_date) SELECT @Date;
	SET @Date = DATEADD(dd, 1, @Date);
END;




MERGE #dim_customer_statuses WITH(HOLDLOCK) AS t
USING (
	SELECT
		v.id
		,v.name
	FROM (VALUES (1, 'Active And Good'), (2, 'Inactive And Good'), (3, 'Active And Bad'), (4, 'Inactive And Bad')) AS v(id, name)
) AS s ON t.id = s.id
WHEN MATCHED THEN UPDATE
SET
	t.name = s.name
WHEN NOT MATCHED BY TARGET THEN
INSERT(id, name) VALUES (s.id, s.name);



MERGE #dim_customers WITH(HOLDLOCK) AS t
USING (
	SELECT
		v.id
		,v.name
	FROM (VALUES (1, 'John Doe'), (2, 'Jane Roe'), (3, 'Aaron A. Aaronson'), (4, 'Alan Poe'), (5, 'Tommy Atkins')) AS v(id, name)
) AS s ON t.id = s.id
WHEN MATCHED THEN UPDATE
SET
	t.name = s.name
WHEN NOT MATCHED BY TARGET THEN
INSERT(id, name) VALUES (s.id, s.name);



IF OBJECT_ID('tempdb..#fact_table') IS NOT NULL DROP TABLE #fact_table
CREATE TABLE #fact_table (
    Dates date,
	Customer_Id INT,
	Customer_Status INT
	FOREIGN key (Customer_Id) REFERENCES #dim_customers(id) ,
	FOREIGN key (Dates) REFERENCES #dim_dates(day_date) ,
	FOREIGN key (Customer_Status) REFERENCES #dim_customer_statuses(id)
);



MERGE #fact_table WITH(HOLDLOCK) AS t
USING (
	SELECT
		v.Dates
		,v.Customer_Id
		,v.Customer_Status
	FROM (VALUES ('20150131',1,1 ), ('20150131', 2,2 ),('20150131',3,2 ),('20150131',4,2 ),('20150131',5 ,2 ),
('20150228', 1,1 ),('20150228', 2,2 ),('20150228',3,1 ),('20150228', 4,2),('20150228', 5,2),
('20150331', 1,1 ),('20150331', 2,1 ),('20150331',3,1 ),('20150331', 4,1 ),('20150331', 5,2 ),
('20150430', 1,1 ),('20150430', 2,1 ),('20150430', 3,1 ),('20150430', 4,3 ),('20150430', 5,1 ),
('20150531', 1,1 ),('20150531', 2,3 ),('20150531', 3,1 ),('20150531', 4,3 ),('20150531', 5,1 ),
('20150630', 1,1 ),('20150630', 2,3 ),('20150630', 3,1 ),('20150630', 4,3 ),('20150630', 5,1 ),
('20150731', 1,2 ),('20150731', 2,3 ) ,('20150731', 3,1 ),('20150731', 4,3 ),('20150731', 5,1 ),
('20150831', 1,2 ),('20150831', 2,3 ),('20150831', 3,1 ),('20150831', 4,3),('20150831', 5,1 ),
('20150930', 1,2 ),('20150930', 2,4 ),('20150930', 3,1 ),('20150930', 4,3 ),('20150930', 5,1 ),
('20151028', 1,2 ),('20151028', 2,4 ),('20151028', 3,1 ),('20151028', 4,3 ),('20151028', 5,1 ),
('20151128', 1,1 ),('20151128', 2,4 ),('20151128', 3,1 ),('20151128', 4,3 ),('20151128', 5,2 ),
('20151231', 1,1 ),('20151231', 2,4 ),('20151231', 3,1 ),('20151231', 4,3),('20151231', 5,2 )) AS v(Dates,Customer_Id ,Customer_Status)
) AS s ON t.Dates = s.Dates
WHEN MATCHED THEN UPDATE
SET
	t.Customer_Id = s.Customer_Id
WHEN NOT MATCHED BY TARGET THEN
INSERT(Dates,Customer_Id ,Customer_Status) VALUES (s.Dates,s.Customer_Id ,s.Customer_Status);


select * from #fact_table;

MERGE #fact_table AS T
 USING #dim_dates AS S
 ON T.Dates = S.day_date
when MATCHED 

select * from #dim_customers;

select * from #dim_customer_statuses;

select top 10 * from #dim_dates;