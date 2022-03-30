# sql-blog-hierarchy (github.com/antonio-alexander/sql-blog-hierarchy)

This repo is an attempt for me to experiment on some basic use cases and try to provide sample queries to answer questions. I'll try to go through each and provide my thoughts and try to describe how I figured out the query at all. Although I have an ulterior motive to learn how to do recursive queries as well.

As an aside, there's also a lot of commentary on queries and an attempt to describe the limitation of SQL; like this is where SQL is a great tool for and this is something you probably wouldn't do with SQL.

## Bibliography

These are some links that helped me:

- [Recursion in SQL Explained Visually](https://medium.com/swlh/recursion-in-sql-explained-graphically-679f6a0f143b)
- [https://www.mysqltutorial.org/mysql-recursive-cte/](https://www.mysqltutorial.org/mysql-recursive-cte/)
- [https://dev.mysql.com/blog-archive/a-new-simple-way-to-figure-out-why-your-recursive-cte-is-running-away/](https://dev.mysql.com/blog-archive/a-new-simple-way-to-figure-out-why-your-recursive-cte-is-running-away/)
- [https://stackoverflow.com/questions/20215744/how-to-create-a-mysql-hierarchical-recursive-query](https://stackoverflow.com/questions/20215744/how-to-create-a-mysql-hierarchical-recursive-query)
- [https://dev.mysql.com/blog-archive/mysql-8-0-labs-recursive-common-table-expressions-in-mysql-ctes-part-three-hierarchies/](https://dev.mysql.com/blog-archive/mysql-8-0-labs-recursive-common-table-expressions-in-mysql-ctes-part-three-hierarchies/)
- [https://stackoverflow.com/questions/35248217/multiple-cte-in-single-query](https://stackoverflow.com/questions/35248217/multiple-cte-in-single-query)

## Family tree

This family tree is implemented using two tables, a family table and a parent table. We attempt to maintain normalization by having a separate table to show the parent/child relationship. Family is a bit unique in that you can have more than one parent and although you would normally have two, in an actual database, you may also have to deal with step parents which would mean that the "number" of parents could be 1 __or more__.

Also, it may not be obvious, but the following things are not guaranteed/obvious: (1) that all members are present/associated in the parent_child table, (2) that the family trees represented in the parent_child table are contiguous and (3) that the existing family trees are consistent and free of circular references [...and i'm my own grandpaaaa](https://www.youtube.com/watch?v=eYlJH81dSiw).

```sql
CREATE TABLE IF NOT EXISTS member (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    first_name TEXT NOT NULL,
    middle_name TEXT DEFAULT '',
    last_name TEXT DEFAULT '',
    suffix TEXT DEFAULT '',
    UNIQUE(first_name, last_name, suffix)
) ENGINE = InnoDB;

CREATE TABLE IF NOT EXISTS parent_child (
    parent_id BIGINT,
    child_id BIGINT,
    FOREIGN KEY (parent_id) REFERENCES member(id),
    FOREIGN KEY (child_id) REFERENCES member(id),
    -- CONSTRAINT check_parent_self CHECK (parent_id <> child_id),
    PRIMARY KEY(parent_id, child_id)
) ENGINE = InnoDB;
```

Some interesting things to point out:

- Only the first name must be present while all others can be ommitted (with a default of ''), also note that none of these columns can be NULL (so we don't have to worry about differentiating between empty and NULL)
- The parent_child table is used to model the one-to-many relationships between children and parents
- We enforce data consistency between the member table and the parent_child table by having the foreign key constraint on id

I populated the tables with the family tree for the Kurosaki family because I'm a [Bleach](https://en.wikipedia.org/wiki/Bleach_(manga)) fan, spoiler alert below, please avert your eyes...and stop reading this document.

```sql
INSERT INTO
    member(first_name, last_name)
VALUES
    ('Isshin', 'Kurosaki'),
    ('Masaki', 'Kurosaki'),
    ('Ichigo', 'Kurosaki'),
    ('Karin', 'Kurosaki'),
    ('Yuzu', 'Kurosaki'),
    ('Orihime', 'Inoue'),
    ('Kazui', 'Kurosaki');

INSERT INTO
    parent_child(parent_id, child_id)
VALUES
    ((SELECT id FROM member WHERE first_name = 'Isshin' AND last_name = 'Kurosaki'),
        (SELECT id FROM member WHERE first_name = 'Ichigo' AND last_name = 'Kurosaki' )),
    ((SELECT id FROM member WHERE first_name = 'Masaki' AND last_name = 'Kurosaki'),
        (SELECT id FROM member WHERE first_name = 'Ichigo' AND last_name = 'Kurosaki')),
    ((SELECT id FROM member WHERE first_name = 'Isshin' AND last_name = 'Kurosaki'),
        (SELECT id FROM member WHERE first_name = 'Yuzu' AND last_name = 'Kurosaki')),
    ((SELECT id FROM member WHERE first_name = 'Masaki' AND last_name = 'Kurosaki'),
        (SELECT id FROM member WHERE first_name = 'Yuzu' AND last_name = 'Kurosaki')),
    ((SELECT id FROM member WHERE first_name = 'Isshin' AND last_name = 'Kurosaki'),
        (SELECT id FROM member WHERE first_name = 'Karin' AND last_name = 'Kurosaki')),
    ((SELECT id FROM member WHERE first_name = 'Masaki' AND last_name = 'Kurosaki'),
        (SELECT id FROM member WHERE first_name = 'Karin' AND last_name = 'Kurosaki')),
    ((SELECT id FROM member WHERE first_name = 'Ichigo' AND last_name = 'Kurosaki'),
        (SELECT id FROM member WHERE first_name = 'Kazui' AND last_name = 'Kurosaki')),
    ((SELECT id FROM member WHERE first_name = 'Orihime' AND last_name = 'Inoue'),
        (SELECT id FROM member WHERE first_name = 'Kazui' AND last_name = 'Kurosaki'));
```

I've also populated the database with the Joestar family tree from [JoJo's Bizzare Adventure](https://en.wikipedia.org/wiki/JoJo%27s_Bizarre_Adventure), see the family tree here: [https://jojo.fandom.com/wiki/Joestar_Family](https://jojo.fandom.com/wiki/Joestar_Family). There are SOME spoilers, but again...stop here if you're worried about spoilers from revealing the JoJo's family tree.

```sql
INSERT INTO
    member(first_name, middle_name, last_name, suffix)
VALUES
    ('George', '', 'Joestar', ''),
    ('Mary', '', 'Joestar', ''),
    ('Jonathan', '', 'Joestar', ''),
    ('Erina', '', 'Joestar', ''),
    ('DIO', '', '', ''),
    ('George', '', 'Joestar', 'II'),
    ('Elizabeth', '', 'Joestar', ''),
    ('Giorno', '', 'Giovanna', ''),
    ('Donatello', '', 'Versus', ''),
    ('Rikiel', '', '', ''),
    ('Ungalo', '', '', ''),
    ('Tomoko', '', 'Higashikata', ''),
    ('Joseph', '', 'Joestar', ''),
    ('Suzie', 'Q', 'Joestar', ''),
    ('Josuke', '', 'Higashikata', ''),
    ('Sadao', '', 'Kujo', ''),
    ('Holy', '', 'Kujo', ''),
    ('Shizuka', '', 'Joestar', ''),
    ('Jotaro', '', 'Kujo', ''),
    ('Jolyne', '', 'Cujoh', '');

INSERT INTO
    parent_child(parent_id, child_id)
VALUES
    ((SELECT id FROM member WHERE first_name = 'George' AND last_name = 'Joestar' AND suffix = ''),
        (SELECT id FROM member WHERE first_name = 'Jonathan' AND last_name = 'Joestar')),
    ((SELECT id FROM member WHERE first_name = 'Mary' AND last_name = 'Joestar'),
        (SELECT id FROM member WHERE first_name = 'Jonathan' AND last_name = 'Joestar')),
    ((SELECT id FROM member WHERE first_name = 'George' AND last_name = 'Joestar' AND suffix = ''),
        (SELECT id FROM member WHERE first_name = 'DIO')),
    ((SELECT id FROM member WHERE first_name = 'Mary' AND last_name = 'Joestar'),
        (SELECT id FROM member WHERE first_name = 'DIO')),
    ((SELECT id FROM member WHERE first_name = 'Jonathan' AND last_name = 'Joestar'),
        (SELECT id FROM member WHERE first_name = 'George' AND last_name = 'Joestar' AND suffix = 'II')),
    ((SELECT id FROM member WHERE first_name = 'Erina' AND last_name = 'Joestar'),
        (SELECT id FROM member WHERE first_name = 'George' AND last_name = 'Joestar' AND suffix = 'II')),
    ((SELECT id FROM member WHERE first_name = 'DIO'),
        (SELECT id FROM member WHERE first_name = 'Giorno' AND last_name = 'Giovanna')),
    ((SELECT id FROM member WHERE first_name = 'DIO'),
        (SELECT id FROM member WHERE first_name = 'Donatello' AND last_name = 'Versus')),
    ((SELECT id FROM member WHERE first_name = 'DIO'),
        (SELECT id FROM member WHERE first_name = 'Rikiel')),
    ((SELECT id FROM member WHERE first_name = 'DIO'),
        (SELECT id FROM member WHERE first_name = 'Ungalo')),
    ((SELECT id FROM member WHERE first_name = 'George' AND last_name = 'Joestar' AND suffix = 'II'),
        (SELECT id FROM member WHERE first_name = 'Joseph' AND last_name = 'Joestar')),
    ((SELECT id FROM member WHERE first_name = 'Elizabeth' AND last_name = 'Joestar'),
        (SELECT id FROM member WHERE first_name = 'Joseph' AND last_name = 'Joestar')),
    ((SELECT id FROM member WHERE first_name = 'Tomoko' AND last_name = 'Higashikata'),
        (SELECT id FROM member WHERE first_name = 'Josuke' AND last_name = 'Higashikata')),
    ((SELECT id FROM member WHERE first_name = 'Joseph' AND last_name = 'Joestar'),
        (SELECT id FROM member WHERE first_name = 'Josuke' AND last_name = 'Higashikata')),
    ((SELECT id FROM member WHERE first_name = 'Suzie' AND middle_name = 'Q' AND last_name = 'Joestar'),
        (SELECT id FROM member WHERE first_name = 'Holy' AND last_name = 'Kujo')),
    ((SELECT id FROM member WHERE first_name = 'Joseph' AND last_name = 'Joestar'),
        (SELECT id FROM member WHERE first_name = 'Holy' AND last_name = 'Kujo')),
    ((SELECT id FROM member WHERE first_name = 'Suzie' AND middle_name = 'Q' AND last_name = 'Joestar'),
        (SELECT id FROM member WHERE first_name = 'Shizuka' AND last_name = 'Joestar')),
    ((SELECT id FROM member WHERE first_name = 'Joseph' AND last_name = 'Joestar'),
        (SELECT id FROM member WHERE first_name = 'Shizuka' AND last_name = 'Joestar')),
    ((SELECT id FROM member WHERE first_name = 'Sadao' AND last_name = 'Kujo'),
        (SELECT id FROM member WHERE first_name = 'Jotaro' AND last_name = 'Kujo')),
    ((SELECT id FROM member WHERE first_name = 'Holy' AND last_name = 'Kujo'),
        (SELECT id FROM member WHERE first_name = 'Jotaro' AND last_name = 'Kujo')),
    ((SELECT id FROM member WHERE first_name = 'Jotaro' AND last_name = 'Kujo'),
        (SELECT id FROM member WHERE first_name = 'Jolyne' AND last_name = 'Cujoh'));
```

## Questions we can answer with straight SQL

These questions are very "common" sql questions; you could call them regular; they don't require any real magic, just basic relational queries.

### What if you wanted to know who someone's children were?

This is a really straight forward query, knowing the schema this query should almost write itself. In order to make this work, we'll get the id for that "someone" and query the parent_child table for rows where that "someone" is the parent_id. Although we can do this without a join, it just gives us an id rather than an actual name. We can also do a subquery so we can use names rather than ids.

```sql
-- Isshin Kurosaki
SET @first_name := 'Isshin';
SET @last_name := 'Kurosaki';
SET @suffix = '';
SELECT first_name, last_name, suffix FROM member JOIN parent_child ON child_id=id WHERE parent_id=(SELECT id FROM member WHERE first_name=@first_name and last_name=@last_name AND suffix=@suffix);
-- Joseph Joestar
SET @first_name := 'Joseph';
SET @last_name := 'Joestar';
SET @suffix = '';
SELECT first_name, last_name, suffix FROM member JOIN parent_child ON child_id=id WHERE parent_id=(SELECT id FROM member WHERE first_name=@first_name and last_name=@last_name AND suffix=@suffix);
```

```mysql
MariaDB [sql_blog_hierarchy]> SET @first_name := 'Isshin';
Query OK, 0 rows affected (0.001 sec)

MariaDB [sql_blog_hierarchy]> SET @last_name := 'Kurosaki';
Query OK, 0 rows affected (0.000 sec)

MariaDB [sql_blog_hierarchy]> SET @suffix = '';
Query OK, 0 rows affected (0.000 sec)

MariaDB [sql_blog_hierarchy]> SELECT first_name, last_name, suffix FROM member JOIN parent_child ON child_id=id WHERE parent_id=(SELECT id FROM member WHERE first_name=@first_name and last_name=@last_name AND suffix=@suffix);
+------------+-----------+--------+
| first_name | last_name | suffix |
+------------+-----------+--------+
| Ichigo     | Kurosaki  |        |
| Karin      | Kurosaki  |        |
| Yuzu       | Kurosaki  |        |
+------------+-----------+--------+
3 rows in set (0.002 sec)

MariaDB [sql_blog_hierarchy]> SET @first_name := 'Joseph';
Query OK, 0 rows affected (0.000 sec)

MariaDB [sql_blog_hierarchy]> SET @last_name := 'Joestar';
Query OK, 0 rows affected (0.000 sec)

MariaDB [sql_blog_hierarchy]> SET @suffix = '';
Query OK, 0 rows affected (0.000 sec)

MariaDB [sql_blog_hierarchy]> SELECT first_name, last_name, suffix FROM member JOIN parent_child ON child_id=id WHERE parent_id=(SELECT id FROM member WHERE first_name=@first_name and last_name=@last_name AND suffix=@suffix);
+------------+-------------+--------+
| first_name | last_name   | suffix |
+------------+-------------+--------+
| Josuke     | Higashikata |        |
| Holy       | Kujo        |        |
| Shizuka    | Joestar     |        |
+------------+-------------+--------+
3 rows in set (0.001 sec)
```

### What if you wanted to know who someone's parents were?

This is the converse (?) of the above query, it should also write itself. We simply query the parent_child table to find parents associated with a given child and then join with the members table to get their names. You may be asking yourself...what if I wanted to know someone's grand parents?...I'll answer it below.

```sql
-- Ichigo Kurosaki
SET @first_name := 'Ichigo';
SET @last_name := 'Kurosaki';
SET @suffix = '';
SELECT first_name, last_name, suffix FROM member JOIN parent_child ON parent_id=id WHERE child_id=(SELECT id FROM member WHERE first_name=@first_name AND last_name=@last_name AND suffix=@suffix);
-- George Joestar
SET @first_name := 'George';
SET @last_name := 'Joestar';
SET @suffix = '';
SELECT first_name, last_name, suffix FROM member JOIN parent_child ON parent_id=id WHERE child_id=(SELECT id FROM member WHERE first_name=@first_name AND last_name=@last_name AND suffix=@suffix);
-- Jotaro Kujo
SET @first_name := 'Jotaro';
SET @last_name := 'Kujo';
SET @suffix = '';
SELECT first_name, last_name, suffix FROM member JOIN parent_child ON parent_id=id WHERE child_id=(SELECT id FROM member WHERE first_name=@first_name AND last_name=@last_name AND suffix=@suffix);
```

```mysql
MariaDB [sql_blog_hierarchy]> SET @first_name := 'Ichigo';
Query OK, 0 rows affected (0.000 sec)

MariaDB [sql_blog_hierarchy]> SET @last_name := 'Kurosaki';
Query OK, 0 rows affected (0.000 sec)

MariaDB [sql_blog_hierarchy]> SET @suffix = '';
Query OK, 0 rows affected (0.000 sec)

MariaDB [sql_blog_hierarchy]> SELECT first_name, last_name, suffix FROM member JOIN parent_child ON parent_id=id WHERE child_id=(SELECT id FROM member WHERE first_name=@first_name AND last_name=@last_name AND suffix=@suffix);
+------------+-----------+--------+
| first_name | last_name | suffix |
+------------+-----------+--------+
| Isshin     | Kurosaki  |        |
| Masaki     | Kurosaki  |        |
+------------+-----------+--------+
2 rows in set (0.001 sec)

MariaDB [sql_blog_hierarchy]> SET @first_name := 'George';
Query OK, 0 rows affected (0.000 sec)

MariaDB [sql_blog_hierarchy]> SET @last_name := 'Joestar';
Query OK, 0 rows affected (0.000 sec)

MariaDB [sql_blog_hierarchy]> SET @suffix = '';
Query OK, 0 rows affected (0.000 sec)

MariaDB [sql_blog_hierarchy]> SELECT first_name, last_name, suffix FROM member JOIN parent_child ON parent_id=id WHERE child_id=(SELECT id FROM member WHERE first_name=@first_name AND last_name=@last_name AND suffix=@suffix);
Empty set (0.001 sec)

MariaDB [sql_blog_hierarchy]> SET @first_name := 'Jotaro';
Query OK, 0 rows affected (0.000 sec)

MariaDB [sql_blog_hierarchy]> SET @last_name := 'Kujo';
Query OK, 0 rows affected (0.000 sec)

MariaDB [sql_blog_hierarchy]> SET @suffix = '';
Query OK, 0 rows affected (0.000 sec)

MariaDB [sql_blog_hierarchy]> SELECT first_name, last_name, suffix FROM member JOIN parent_child ON parent_id=id WHERE child_id=(SELECT id FROM member WHERE first_name=@first_name AND last_name=@last_name AND suffix=@suffix);
+------------+-----------+--------+
| first_name | last_name | suffix |
+------------+-----------+--------+
| Sadao      | Kujo      |        |
| Holy       | Kujo      |        |
+------------+-----------+--------+
2 rows in set (0.001 sec)
```

### What if you wanted to know who someone's grand parents were?

Although this is alluding to the meat and potatoes of this document, it's a given ask to determine who someone's grand parents are. This query can be answered with regular SQL specifically because we know the number of generations to query: We want a childrens parents parents. See. Simple. Obviously this doesn't scale well.

This query is a bit ugly and could probably be a bit nicer, but generally, we're doing three joins: member -> parent_child -> parent_child and taking the resulting relationship from member and the second parent_child. We also use a subquery to make the query a bit easier to read. Keep in mind the Kazui is the only member who has actual grandparents, for anyone else this query should return an empty set (they have no grand parents).

Keep in mind that the statement "They have no grand parents" is generally not true in reality (except for Adam and Eve if you believe in that kind of thing), but in terms of the data we have, is 100% only true for Kazui.

```sql
-- Kazui Kurosaki
SET @first_name := 'Kazui';
SET @last_name := 'Kurosaki';
SET @suffix = '';
SELECT first_name, last_name, suffix FROM member JOIN (SELECT pc2.parent_id grand_parent_id FROM parent_child pc1 JOIN parent_child pc2 ON pc1.parent_id=pc2.child_id WHERE pc1.child_id=(SELECT id FROM member WHERE first_name=@first_name AND last_name=@last_name AND suffix=@suffix)) AS grand_parent ON grand_parent_id=id;
-- George Joestar II
SET @first_name := 'George';
SET @last_name := 'Joestar';
SET @suffix = 'II';
SELECT first_name, last_name, suffix FROM member JOIN (SELECT pc2.parent_id grand_parent_id FROM parent_child pc1 JOIN parent_child pc2 ON pc1.parent_id=pc2.child_id WHERE pc1.child_id=(SELECT id FROM member WHERE first_name=@first_name AND last_name=@last_name AND suffix=@suffix)) AS grand_parent ON grand_parent_id=id;
```

Keep in mind that certain sub queries REQUIRE that you give them a name.

```mysql
MariaDB [sql_blog_hierarchy]> SET @first_name := 'Kazui';
Query OK, 0 rows affected (0.000 sec)

MariaDB [sql_blog_hierarchy]> SET @last_name := 'Kurosaki';
Query OK, 0 rows affected (0.000 sec)

MariaDB [sql_blog_hierarchy]> SET @suffix = '';
Query OK, 0 rows affected (0.000 sec)

MariaDB [sql_blog_hierarchy]> SELECT first_name, last_name, suffix FROM member JOIN (SELECT pc2.parent_id grand_parent_id FROM parent_child pc1 JOIN parent_child pc2 ON pc1.parent_id=pc2.child_id WHERE pc1.child_id=(SELECT id FROM member WHERE first_name=@first_name AND last_name=@last_name AND suffix=@suffix)) AS grand_parent ON grand_parent_id=id;
+------------+-----------+--------+
| first_name | last_name | suffix |
+------------+-----------+--------+
| Isshin     | Kurosaki  |        |
| Masaki     | Kurosaki  |        |
+------------+-----------+--------+
2 rows in set (0.001 sec)

MariaDB [sql_blog_hierarchy]> SET @first_name := 'George';
Query OK, 0 rows affected (0.000 sec)

MariaDB [sql_blog_hierarchy]> SET @last_name := 'Joestar';
Query OK, 0 rows affected (0.000 sec)

MariaDB [sql_blog_hierarchy]> SET @suffix = 'II';
Query OK, 0 rows affected (0.000 sec)

MariaDB [sql_blog_hierarchy]> SELECT first_name, last_name, suffix FROM member JOIN (SELECT pc2.parent_id grand_parent_id FROM parent_child pc1 JOIN parent_child pc2 ON pc1.parent_id=pc2.child_id WHERE pc1.child_id=(SELECT id FROM member WHERE first_name=@first_name AND last_name=@last_name AND suffix=@suffix)) AS grand_parent ON grand_parent_id=id;
+------------+-----------+--------+
| first_name | last_name | suffix |
+------------+-----------+--------+
| George     | Joestar   |        |
| Mary       | Joestar   |        |
+------------+-----------+--------+
2 rows in set (0.001 sec)
```

### What if you wanted to know how many children someone had?

The question is easy, but gives a great example of how to use the count functionality. We simple query the children associated with a given parent and then count the number of rows.

```sql
-- Isshin Kurosaki
SET @first_name := 'Isshin';
SET @last_name := 'Kurosaki';
SET @suffix = '';
SELECT count(child_id) number_of_children FROM parent_child WHERE parent_id=(SELECT id FROM member WHERE first_name=@first_name AND last_name=@last_name AND suffix=@suffix);
-- DIO
SET @first_name := 'DIO';
SET @last_name := '';
SET @suffix = '';
SELECT count(child_id) number_of_children FROM parent_child WHERE parent_id=(SELECT id FROM member WHERE first_name=@first_name AND last_name=@last_name AND suffix=@suffix);
```

```mysql
ariaDB [sql_blog_hierarchy]> SET @first_name := 'Isshin';
Query OK, 0 rows affected (0.000 sec)

MariaDB [sql_blog_hierarchy]> SET @last_name := 'Kurosaki';
Query OK, 0 rows affected (0.000 sec)

MariaDB [sql_blog_hierarchy]> SET @suffix = '';
Query OK, 0 rows affected (0.000 sec)

MariaDB [sql_blog_hierarchy]> SELECT count(child_id) number_of_children FROM parent_child WHERE parent_id=(SELECT id FROM member WHERE first_name=@first_name AND last_name=@last_name AND suffix=@suffix);
+--------------------+
| number_of_children |
+--------------------+
|                  3 |
+--------------------+
1 row in set (0.001 sec)

MariaDB [sql_blog_hierarchy]> SET @first_name := 'DIO';
Query OK, 0 rows affected (0.000 sec)

MariaDB [sql_blog_hierarchy]> SET @last_name := '';
Query OK, 0 rows affected (0.000 sec)

MariaDB [sql_blog_hierarchy]> SET @suffix = '';
Query OK, 0 rows affected (0.000 sec)

MariaDB [sql_blog_hierarchy]> SELECT count(child_id) number_of_children FROM parent_child WHERE parent_id=(SELECT id FROM member WHERE first_name=@first_name AND last_name=@last_name AND suffix=@suffix);
+--------------------+
| number_of_children |
+--------------------+
|                  4 |
+--------------------+
1 row in set (0.001 sec)
```

### What if you wanted to know who someone's siblings were?

This question can be answered by combining the information contained in the member and parent_child tables.

> A sibling is simply a member who shares on or more parents with any other members.

Obviously in terms of step parents this is something that could "change" from an academic perspective in contrast with biological parents. This query is a bit interesting because it casts a wide net and will return duplicates (because of the IN with subquery) so we need to use the GROUP BY clause to return a unique result set. We add in some additional (ugly) magic to ensure that we exclude the sibling we're using to create the perspective of who the siblings were.

```sql
-- Ichigo Kurosaki
SET @first_name := 'Ichigo';
SET @last_name := 'Kurosaki';
SET @suffix = '';
SELECT first_name, last_name, suffix FROM member JOIN parent_child ON id=child_id WHERE parent_id IN (SELECT parent_id from parent_child WHERE child_id=(SELECT id FROM member WHERE first_name=@first_name AND last_name=@last_name AND suffix=@suffix)) AND id <> (SELECT id FROM member WHERE first_name=@first_name AND last_name=@last_name AND suffix=@suffix) GROUP BY id;
-- Holy Kujo
SET @first_name := 'Holy';
SET @last_name := 'Kujo';
SET @suffix = '';
SELECT first_name, last_name, suffix FROM member JOIN parent_child ON id=child_id WHERE parent_id IN (SELECT parent_id from parent_child WHERE child_id=(SELECT id FROM member WHERE first_name=@first_name AND last_name=@last_name AND suffix=@suffix)) AND id <> (SELECT id FROM member WHERE first_name=@first_name AND last_name=@last_name AND suffix=@suffix) GROUP BY id;
```

```mysql
ariaDB [sql_blog_hierarchy]> SET @first_name := 'Ichigo';
Query OK, 0 rows affected (0.000 sec)

MariaDB [sql_blog_hierarchy]> SET @last_name := 'Kurosaki';
Query OK, 0 rows affected (0.000 sec)

MariaDB [sql_blog_hierarchy]> SET @suffix = '';
Query OK, 0 rows affected (0.000 sec)

MariaDB [sql_blog_hierarchy]> SELECT first_name, last_name, suffix FROM member JOIN parent_child ON id=child_id WHERE parent_id IN (SELECT parent_id from parent_child WHERE child_id=(SELECT id FROM member WHERE first_name=@first_name AND last_name=@last_name AND suffix=@suffix)) AND id <> (SELECT id FROM member WHERE first_name=@first_name AND last_name=@last_name AND suffix=@suffix) GROUP BY id;
+------------+-----------+--------+
| first_name | last_name | suffix |
+------------+-----------+--------+
| Karin      | Kurosaki  |        |
| Yuzu       | Kurosaki  |        |
+------------+-----------+--------+
2 rows in set (0.005 sec)

MariaDB [sql_blog_hierarchy]> SET @first_name := 'Holy';
Query OK, 0 rows affected (0.000 sec)

MariaDB [sql_blog_hierarchy]> SET @last_name := 'Kujo';
Query OK, 0 rows affected (0.000 sec)

MariaDB [sql_blog_hierarchy]> SET @suffix = '';
Query OK, 0 rows affected (0.000 sec)

MariaDB [sql_blog_hierarchy]> SELECT first_name, last_name, suffix FROM member JOIN parent_child ON id=child_id WHERE parent_id IN (SELECT parent_id from parent_child WHERE child_id=(SELECT id FROM member WHERE first_name=@first_name AND last_name=@last_name AND suffix=@suffix)) AND id <> (SELECT id FROM member WHERE first_name=@first_name AND last_name=@last_name AND suffix=@suffix) GROUP BY id;
+------------+-------------+--------+
| first_name | last_name   | suffix |
+------------+-------------+--------+
| Josuke     | Higashikata |        |
| Shizuka    | Joestar     |        |
+------------+-------------+--------+
2 rows in set (0.002 sec)
```

As a follow up, if you wanted to know how many siblings a person has, you could modify the above query slightly:

```sql
SET @first_name := 'Ichigo';
SET @last_name := 'Kurosaki';
SET @suffix = '';
SELECT COUNT(id) number_of_siblings FROM (SELECT id, first_name, last_name FROM member JOIN parent_child ON id=child_id WHERE parent_id IN (SELECT parent_id from parent_child WHERE child_id=(SELECT id FROM member WHERE first_name=@first_name AND last_name=@last_name AND suffix=@suffix)) AND id <> (SELECT id FROM member WHERE first_name=@first_name AND last_name=@last_name AND suffix=@suffix) GROUP BY id) AS siblings;
```

```mysql
MariaDB [sql_blog_hierarchy]> SET @first_name := 'Ichigo';
Query OK, 0 rows affected (0.000 sec)

MariaDB [sql_blog_hierarchy]> SET @last_name := 'Kurosaki';
Query OK, 0 rows affected (0.000 sec)

MariaDB [sql_blog_hierarchy]> SET @suffix = '';
Query OK, 0 rows affected (0.000 sec)

MariaDB [sql_blog_hierarchy]> SELECT COUNT(id) number_of_siblings FROM (SELECT id, first_name, last_name FROM member JOIN parent_child ON id=child_id WHERE parent_id IN (SELECT parent_id from parent_child WHERE child_id=(SELECT id FROM member WHERE first_name=@first_name AND last_name=@last_name AND suffix=@suffix)) AND id <> (SELECT id FROM member WHERE first_name=@first_name AND last_name=@last_name AND suffix=@suffix) GROUP BY id) AS siblings;
+--------------------+
| number_of_siblings |
+--------------------+
|                  2 |
+--------------------+
1 row in set (0.003 sec)
```

## Recursive Queries (Common Table Expressions)

I'm paraphrasing/combining a lot of the information I gleamed from the above links. So far, the opinion I've read and agree with is that SQL (in general) isn't REALLY meant to solve hierchical queries. And not so much that it _can't_ but rather that although there are "solutions" for hierarchical queries, a lot of the brunt of enforcing data consistency and normalcy is left up to the architect and is a relatively recent tool (MySQL 8.0, 2018). More succinctly: you can't use constraints or checks to enforce data consistency for hierarchically related data.

Recursive queries using Common Table Expressions (CTE), have three parts:

1. Anchoring expression: the expression that creates the "starting" point of the query
2. Recursive expression: the expression that is executed over and over again (and can reference itself)
3. Termination expression: the expression that determines when to "stop" the recursive expression
4. Query using the CTE: the actual query that initiates the entire expression

```sql
WITH RECURSIVE cte_count (n) 
AS (
      SELECT 1
      UNION ALL
      SELECT n + 1 
      FROM cte_count 
      WHERE n < 3
    )
SELECT n 
FROM cte_count;
```

The above expression is a simple example that wasn't super helpful for me (haha), this is its output:

```mysql
MariaDB [sql_blog_tree]> WITH RECURSIVE cte_count (n) 
    -> AS (
    ->       SELECT 1
    ->       UNION ALL
    ->       SELECT n + 1 
    ->       FROM cte_count 
    ->       WHERE n < 3
    ->     )
    -> SELECT n 
    -> FROM cte_count;
+------+
| n    |
+------+
|    1 |
|    2 |
|    3 |
+------+
3 rows in set (0.001 sec)
```

In general, this is almost the same as a for loop that executes four times (until n is greater than 3). Below in the examples we create, there are (I think) much better examples of how to put together hierarchical queries.

## Questions we have to answer with recursion

These questions either MUST or are BEST answered using some kind of recursive query (for a variety of reasons). The most common reason why we have to use recursive queries is because a given query doesn't scale without adding more...query. The deeper your queries, the more joins you need to do and the more you need to "know" the quantity of what you're trying to query which isn't always feasible.

### What if you wanted to know all the descendents of a given parent/person

This, like mentioned above, is an open-ended question, it doesn't scale well. To answer this question with straight SQL you'd have to already know the answer to the question. For example, it's easier to answer the question who's someone's grand parents or great grand parents, but you couldn't answer (or even ask) the question of who are all someone's descendents.

```sql
-- George Joestar
SET @first_name := 'George';
SET @last_name := 'Joestar';
SET @suffix := '';
WITH RECURSIVE cte_descendents 
AS (
    SELECT id, 0 gen FROM member WHERE first_name=@first_name AND last_name=@last_name AND suffix=@suffix
    UNION ALL
    SELECT child_id, gen+1 FROM parent_child p INNER JOIN cte_descendents ON p.parent_id=id
)
SELECT f.first_name, f.last_name, c.gen FROM member f RIGHT JOIN cte_descendents c ON f.id=c.id WHERE c.id <> (SELECT id FROM member WHERE first_name=@first_name AND last_name=@last_name AND suffix=@suffix);
-- Isshin Kurosaki
SET @first_name := 'Isshin';
SET @last_name := 'Kurosaki';
SET @suffix := '';
WITH RECURSIVE cte_descendents 
AS (
    SELECT id, 0 gen FROM member WHERE first_name=@first_name AND last_name=@last_name AND suffix=@suffix
    UNION ALL
    SELECT child_id, gen+1 FROM parent_child p INNER JOIN cte_descendents ON p.parent_id=id
)
SELECT f.first_name, f.last_name, c.gen FROM member f RIGHT JOIN cte_descendents c ON f.id=c.id WHERE c.id <> (SELECT id FROM member WHERE first_name=@first_name AND last_name=@last_name AND suffix=@suffix);
```

```mysql
MariaDB [sql_blog_hierarchy]> SET @first_name := 'George';
Query OK, 0 rows affected (0.000 sec)

MariaDB [sql_blog_hierarchy]> SET @last_name := 'Joestar';
Query OK, 0 rows affected (0.000 sec)

MariaDB [sql_blog_hierarchy]> SET @suffix := '';
Query OK, 0 rows affected (0.000 sec)

MariaDB [sql_blog_hierarchy]> WITH RECURSIVE cte_descendents 
    -> AS (
    ->     SELECT id, 0 gen FROM member WHERE first_name=@first_name AND last_name=@last_name AND suffix=@suffix
    ->     UNION ALL
    ->     SELECT child_id, gen+1 FROM parent_child p INNER JOIN cte_descendents ON p.parent_id=id
    -> )
    -> SELECT f.first_name, f.last_name, c.gen FROM member f RIGHT JOIN cte_descendents c ON f.id=c.id WHERE c.id <> (SELECT id FROM member WHERE first_name=@first_name AND last_name=@last_name AND suffix=@suffix);
+------------+-------------+------+
| first_name | last_name   | gen  |
+------------+-------------+------+
| Jonathan   | Joestar     |    1 |
| DIO        |             |    1 |
| George     | Joestar     |    2 |
| Giorno     | Giovanna    |    2 |
| Donatello  | Versus      |    2 |
| Rikiel     |             |    2 |
| Ungalo     |             |    2 |
| Joseph     | Joestar     |    3 |
| Josuke     | Higashikata |    4 |
| Holy       | Kujo        |    4 |
| Shizuka    | Joestar     |    4 |
| Jotaro     | Kujo        |    5 |
| Jolyne     | Cujoh       |    6 |
+------------+-------------+------+
13 rows in set (0.003 sec)

MariaDB [sql_blog_hierarchy]> SET @first_name := 'Isshin';
Query OK, 0 rows affected (0.000 sec)

MariaDB [sql_blog_hierarchy]> SET @last_name := 'Kurosaki';
Query OK, 0 rows affected (0.000 sec)

MariaDB [sql_blog_hierarchy]> SET @suffix := '';
Query OK, 0 rows affected (0.000 sec)

MariaDB [sql_blog_hierarchy]> WITH RECURSIVE cte_descendents 
    -> AS (
    ->     SELECT id, 0 gen FROM member WHERE first_name=@first_name AND last_name=@last_name AND suffix=@suffix
    ->     UNION ALL
    ->     SELECT child_id, gen+1 FROM parent_child p INNER JOIN cte_descendents ON p.parent_id=id
    -> )
    -> SELECT f.first_name, f.last_name, c.gen FROM member f RIGHT JOIN cte_descendents c ON f.id=c.id WHERE c.id <> (SELECT id FROM member WHERE first_name=@first_name AND last_name=@last_name AND suffix=@suffix);
+------------+-----------+------+
| first_name | last_name | gen  |
+------------+-----------+------+
| Ichigo     | Kurosaki  |    1 |
| Karin      | Kurosaki  |    1 |
| Yuzu       | Kurosaki  |    1 |
| Kazui      | Kurosaki  |    2 |
+------------+-----------+------+
4 rows in set (0.003 sec)
```

### What if you wanted to know the ascendents of a given person (keep in mind that this will exclude any brothers and sisters)

This is identical to the above query, except that it goes up from the child rather than down from the parent. I make gen (generation), start at 0 and thengo negative to try to communicate that it's going up the family tree rather than down. I also omit the 0 generation since it's irrelavant to our query and the scalar starting point HAS to be Kazui.

```sql
-- Kazui Kurosaki
SET @first_name := 'Kazui';
SET @last_name := 'Kurosaki';
SET @suffix := '';
WITH RECURSIVE cte_ascendents 
AS (
    SELECT id, 0 gen FROM member WHERE first_name=@first_name AND last_name=@last_name AND suffix=@suffix
    UNION ALL
    SELECT parent_id, gen-1 FROM parent_child p INNER JOIN cte_ascendents ON p.child_id=id
)
SELECT f.first_name, f.last_name, c.gen FROM member f RIGHT JOIN cte_ascendents c on f.id=c.id WHERE c.id <> (SELECT id FROM member WHERE first_name=@first_name AND last_name=@last_name AND suffix=@suffix);
-- Jotaro Kujo
SET @first_name := 'Jotaro';
SET @last_name := 'Kujo';
SET @suffix := '';
WITH RECURSIVE cte_ascendents 
AS (
    SELECT id, 0 gen FROM member WHERE first_name=@first_name AND last_name=@last_name AND suffix=@suffix
    UNION ALL
    SELECT parent_id, gen-1 FROM parent_child p INNER JOIN cte_ascendents ON p.child_id=id
)
SELECT f.first_name, f.last_name, c.gen FROM member f JOIN cte_ascendents c on f.id=c.id WHERE c.id <> (SELECT id FROM member WHERE first_name=@first_name AND last_name=@last_name AND suffix=@suffix);
```

```mysql
MariaDB [sql_blog_hierarchy]> SET @first_name := 'Kazui';
Query OK, 0 rows affected (0.000 sec)

MariaDB [sql_blog_hierarchy]> SET @last_name := 'Kurosaki';
Query OK, 0 rows affected (0.000 sec)

MariaDB [sql_blog_hierarchy]> SET @suffix := '';
Query OK, 0 rows affected (0.000 sec)

MariaDB [sql_blog_hierarchy]> WITH RECURSIVE cte_ascendents 
    -> AS (
    ->     SELECT id, 0 gen FROM member WHERE first_name=@first_name AND last_name=@last_name AND suffix=@suffix
    ->     UNION ALL
    ->     SELECT parent_id, gen-1 FROM parent_child p INNER JOIN cte_ascendents ON p.child_id=id
    -> )
    -> SELECT f.first_name, f.last_name, c.gen FROM member f RIGHT JOIN cte_ascendents c on f.id=c.id WHERE c.id <> (SELECT id FROM member WHERE first_name=@first_name AND last_name=@last_name AND suffix=@suffix);
+------------+-----------+------+
| first_name | last_name | gen  |
+------------+-----------+------+
| Ichigo     | Kurosaki  |   -1 |
| Orihime    | Inoue     |   -1 |
| Isshin     | Kurosaki  |   -2 |
| Masaki     | Kurosaki  |   -2 |
+------------+-----------+------+
4 rows in set (0.003 sec)

MariaDB [sql_blog_hierarchy]> SET @first_name := 'Jotaro';
Query OK, 0 rows affected (0.000 sec)

MariaDB [sql_blog_hierarchy]> SET @last_name := 'Kujo';
Query OK, 0 rows affected (0.000 sec)

MariaDB [sql_blog_hierarchy]> SET @suffix := '';
Query OK, 0 rows affected (0.000 sec)

MariaDB [sql_blog_hierarchy]> WITH RECURSIVE cte_ascendents 
    -> AS (
    ->     SELECT id, 0 gen FROM member WHERE first_name=@first_name AND last_name=@last_name AND suffix=@suffix
    ->     UNION ALL
    ->     SELECT parent_id, gen-1 FROM parent_child p INNER JOIN cte_ascendents ON p.child_id=id
    -> )
    -> SELECT f.first_name, f.last_name, c.gen FROM member f JOIN cte_ascendents c on f.id=c.id WHERE c.id <> (SELECT id FROM member WHERE first_name=@first_name AND last_name=@last_name AND suffix=@suffix);
+------------+-----------+------+
| first_name | last_name | gen  |
+------------+-----------+------+
| George     | Joestar   |   -5 |
| Mary       | Joestar   |   -5 |
| Jonathan   | Joestar   |   -4 |
| Erina      | Joestar   |   -4 |
| George     | Joestar   |   -3 |
| Elizabeth  | Joestar   |   -3 |
| Joseph     | Joestar   |   -2 |
| Suzie      | Joestar   |   -2 |
| Sadao      | Kujo      |   -1 |
| Holy       | Kujo      |   -1 |
+------------+-----------+------+
10 rows in set (0.004 sec)
```

### How can we validate that there are no circular references?

Circular references can occur since hiearchies aren't __really__ relational, although we can enforce certain relations, we have to get creative in how we do it. Some circular references can be identified via relation so can be enforced via checks/constraints, but some cannot. Three examples below show how circular references can be created:

```sql
-- Kazui can't be her own parent
INSERT INTO parent_child(parent_id, child_id) VALUES 
    ((SELECT id FROM member WHERE first_name = 'Kazui' AND last_name = 'Kurosaki'),
        (SELECT id FROM member WHERE first_name = 'Kazui' AND last_name = 'Kurosaki'));
-- circular reference, but only a generation apart, Inoui is Kazui's mother, Kazui can't
--  also be Inoue's mother
INSERT INTO parent_child(parent_id, child_id) VALUES 
    ((SELECT id FROM member WHERE first_name = 'Kazui' AND last_name = 'Kurosaki'),
        (SELECT id FROM member WHERE first_name = 'Orihime' AND last_name = 'Inoue'));
-- circular reference, Kazui is Isshin's grand daughter, she is not Isshin's mother
--  (two generations apart)
INSERT INTO parent_child(parent_id, child_id) VALUES 
    ((SELECT id FROM member WHERE first_name = 'Kazui' AND last_name = 'Kurosaki'),
        (SELECT id FROM member WHERE first_name = 'Isshin' AND last_name = 'Kurosaki'));
```

Keep in mind, that with the table as-is sans the constraint and any triggers, all of these inserts should be successful even though we have three __very obvious__ circular references:

- Isshin is Kazui's grandfather, but we've added a row where Kazui is Isshin's Father
- Orihime is Kazui's mother, but we've added a row where Kazui is Orihime's father
- Kazui can't be her own mother

Some of these kinds of circular references can be resolved by updating the schema:

```sql
CREATE TABLE IF NOT EXISTS parent_child (
    parent_id BIGINT,
    child_id BIGINT,
    FOREIGN KEY (parent_id) REFERENCES member(id),
    FOREIGN KEY (child_id) REFERENCES member(id),
    PRIMARY KEY(parent_id, child_id),
    CONSTRAINT check_parent_self CHECK (parent_id <> child_id)
) ENGINE = InnoDB;

-- ALTER TABLE parent_child DROP CONSTRAINT check_parent_self;
ALTER TABLE parent_child ADD CONSTRAINT check_parent_self CHECK (parent_id <> child_id);
```

```mysql
MariaDB [sql_blog_hierarchy]> ALTER TABLE parent_child ADD CONSTRAINT check_parent_self CHECK (parent_id <> child_id);
Query OK, 29 rows affected (0.029 sec)             
Records: 29  Duplicates: 0  Warnings: 0

MariaDB [sql_blog_hierarchy]> INSERT INTO parent_child(parent_id, child_id) VALUES 
    ->     ((SELECT id FROM member WHERE first_name = 'Kazui' AND last_name = 'Kurosaki'),
    ->         (SELECT id FROM member WHERE first_name = 'Kazui' AND last_name = 'Kurosaki'));
ERROR 4025 (23000): CONSTRAINT `check_parent_self` failed for `sql_blog_hierarchy`.`parent_child`
```

This will fix ONE circular reference where a child can be their own parent. Unfortuantely, the other circular references can't be solved with a check. We have to fix it with a trigger. We can validate that this circular reference exists with the following query:

```sql
-- insert circular reference
-- DELETE FROM parent_child WHERE parent_id=(SELECT id FROM member WHERE first_name = 'Kazui' AND last_name = 'Kurosaki') AND child_id=(SELECT id FROM member WHERE first_name = 'Orihime' AND last_name = 'Inoue');
INSERT IGNORE INTO parent_child(parent_id, child_id) VALUES 
    ((SELECT id FROM member WHERE first_name = 'Kazui' AND last_name = 'Kurosaki'),
        (SELECT id FROM member WHERE first_name = 'Orihime' AND last_name = 'Inoue'));
-- validate circular reference
SELECT COUNT(*) FROM (SELECT pc1.parent_id, pc1.child_id FROM parent_child pc1 JOIN parent_child pc2 ON pc1.parent_id=pc2.child_id AND pc1.child_id=pc2.parent_id) AS parent_child_swap;
```

```mysql
MariaDB [sql_blog_hierarchy]> INSERT INTO parent_child(parent_id, child_id) VALUES 
    ->     ((SELECT id FROM member WHERE first_name = 'Kazui' AND last_name = 'Kurosaki'),
    ->         (SELECT id FROM member WHERE first_name = 'Kazui' AND last_name = 'Kurosaki'));
ERROR 4025 (23000): CONSTRAINT `check_parent_self` failed for `sql_blog_hierarchy`.`parent_child`
MariaDB [sql_blog_hierarchy]> 
MariaDB [sql_blog_hierarchy]> INSERT INTO parent_child(parent_id, child_id) VALUES 
    ->     ((SELECT id FROM member WHERE first_name = 'Kazui' AND last_name = 'Kurosaki'),
    ->         (SELECT id FROM member WHERE first_name = 'Orihime' AND last_name = 'Inoue'));
Query OK, 1 row affected (0.004 sec)ECT pc1.parent_id, pc1.child_id FROM parent_child 

MariaDB [sql_blog_hierarchy]> SELECT COUNT(*) FROM (SELECT pc1.parent_id, pc1.child_id FROM parent_child pc1 JOIN parent_child pc2 ON pc1.parent_id=pc2.child_id AND pc1.child_id=pc2.parent_id) AS parent_child_swap;
+----------+
| COUNT(*) |
+----------+
|        2 |
+----------+
1 row in set (0.001 sec)
```

The query above tells us that we should enforce the uniqueness between every row such that there is only ever ONE combination of parent/child. The converse can __NEVER__ be true. Keep in mind that this is something that's REALLY easy to solve on the front-end, but nearly impossible to solve on the back-end. For rows that already exists, you'll need something else to determine which to remove/maintain. This trigger, as configured will CHECK and prevent an insert/update but can do nothing for rows that already exist.

```sql
DELIMITER $$
CREATE TRIGGER validate_parent_child_insert
AFTER INSERT
    ON parent_child FOR EACH ROW BEGIN
        IF (SELECT COUNT(*) FROM (SELECT pc1.parent_id, pc1.child_id FROM parent_child pc1 JOIN parent_child pc2 ON pc1.parent_id=pc2.child_id AND pc1.child_id=pc2.parent_id) AS parent_child_swap) > 0
        THEN
             SIGNAL SQLSTATE '45000'
                  SET MESSAGE_TEXT = 'Cannot insert row, relationship already exists between family members';
        END IF;
END$$
DELIMITER ;

DELIMITER $$
CREATE TRIGGER validate_parent_child_update
AFTER UPDATE
    ON parent_child FOR EACH ROW BEGIN
        IF (SELECT COUNT(*) FROM (SELECT pc1.parent_id, pc1.child_id FROM parent_child pc1 JOIN parent_child pc2 ON pc1.parent_id=pc2.child_id AND pc1.child_id=pc2.parent_id) AS parent_child_swap) > 0
        THEN
             SIGNAL SQLSTATE '45000'
                  SET MESSAGE_TEXT = 'Cannot insert row, relationship already exists between family members';
        END IF;
END$$
DELIMITER ;
```

These two triggers will rollback any transaction for insert/update where a relationship already exists between two ids, meaning that in order to add that "vice versa" relationship, you'll have to delete the previous relationship. Assume below that the triggers have been added.

```mysql
MariaDB [sql_blog_hierarchy]> DELETE FROM parent_child WHERE parent_id=(SELECT id FROM member WHERE first_name = 'Kazui' AND last_name = 'Kurosaki') AND child_id=(SELECT id FROM member WHERE first_name = 'Orihime' AND last_name = 'Inoue');
Query OK, 0 rows affected (0.002 sec)

MariaDB [sql_blog_hierarchy]> INSERT IGNORE INTO parent_child(parent_id, child_id) VALUES 
    ->     ((SELECT id FROM member WHERE first_name = 'Kazui' AND last_name = 'Kurosaki'),
    ->         (SELECT id FROM member WHERE first_name = 'Orihime' AND last_name = 'Inoue'));
ERROR 1644 (45000): Cannot insert row, relationship already exists between family members
```

Notice that after we add the triggers, we'll be prevented from inserting (or updating) rows with relationships that don't make any sense. But we still have the problem of validating a circular reference that's a generation apart. First we'll have to create a query to validate that we've created a circular reference. This is a bit difficult, since we have to do it BEFORE inserting/updating to avoid the circular reference (and running forever).

In general, this "problem" can be summarized by: a descendent cannot be an ascendent (and vice versa). Logically, we can confirm whether there's a circular reference by doing the following:

- ensuring that the parent_id is NOT a descendent of the child_id
- ensuring that the child_id is NOT an ascendent of the parent_id

To confirm that the parent isn't a descendent of the child, we can query the descendents of the child and confirm if the parent is within that result.

```sql
SET @first_name := 'Kazui';
SET @last_name := 'Kurosaki';
SET @suffix = '';
SET @parent_first_name := 'Isshin';
SET @parent_last_name := 'Kurosaki';
SET @parent_suffix = '';
WITH RECURSIVE cte_descendents 
AS (
    SELECT id FROM member WHERE first_name=@first_name AND last_name=@last_name AND suffix=@suffix
    UNION ALL
    SELECT child_id FROM parent_child p INNER JOIN cte_descendents ON p.parent_id=id
)
SELECT COUNT(*) FROM (SELECT f.id FROM member f RIGHT JOIN cte_descendents c ON f.id=c.id WHERE c.id = (SELECT id FROM member WHERE first_name=@parent_first_name AND last_name=@parent_last_name AND suffix=@parent_suffix)) AS validate_descendents;
```

```mysql
MariaDB [sql_blog_hierarchy]> SET @first_name := 'Kazui';
Query OK, 0 rows affected (0.001 sec)

MariaDB [sql_blog_hierarchy]> SET @last_name := 'Kurosaki';
Query OK, 0 rows affected (0.000 sec)

MariaDB [sql_blog_hierarchy]> SET @suffix = '';
Query OK, 0 rows affected (0.001 sec)

MariaDB [sql_blog_hierarchy]> SET @parent_first_name := 'Isshin';
Query OK, 0 rows affected (0.000 sec)

MariaDB [sql_blog_hierarchy]> SET @parent_last_name := 'Kurosaki';
Query OK, 0 rows affected (0.000 sec)

MariaDB [sql_blog_hierarchy]> SET @parent_suffix = '';
Query OK, 0 rows affected (0.000 sec)

MariaDB [sql_blog_hierarchy]> WITH RECURSIVE cte_descendents 
    -> AS (
    ->     SELECT id FROM member WHERE first_name=@first_name AND last_name=@last_name AND suffix=@suffix
    ->     UNION ALL
    ->     SELECT child_id FROM parent_child p INNER JOIN cte_descendents ON p.parent_id=id
    -> )
    -> SELECT COUNT(*) FROM (SELECT f.id FROM member f RIGHT JOIN cte_descendents c ON f.id=c.id WHERE c.id = (SELECT id FROM member WHERE first_name=@parent_first_name AND last_name=@parent_last_name AND suffix=@parent_suffix)) AS validate_descendents;
+----------+
| COUNT(*) |
+----------+
|        0 |
+----------+
1 row in set (0.001 sec)
```

This query returns a count of 0 because Isshin is not a descendent of Kazui (the result set is empty/only contains Kazui). In this case, it would be valid, we've confirmed that Isshin, if used as a parent to a child Kazui, is valid because Isshin is NOT a descendent of Kazui. Conversely, we need to also confirm that Kazui is NOT an ascendent of Kazui, or rather that Kazui is NOT a descendent of Isshin. We can use the exact same query, but swap the values for the parameter:

```sql
SET @first_name := 'Isshin';
SET @last_name := 'Kurosaki';
SET @suffix = '';
SET @parent_first_name := 'Kazui';
SET @parent_last_name := 'Kurosaki';
SET @parent_suffix = '';
WITH RECURSIVE cte_descendents 
AS (
    SELECT id FROM member WHERE first_name=@first_name AND last_name=@last_name AND suffix=@suffix
    UNION ALL
    SELECT child_id FROM parent_child p INNER JOIN cte_descendents ON p.parent_id=id
)
SELECT COUNT(*) FROM (SELECT f.id FROM member f RIGHT JOIN cte_descendents c ON f.id=c.id WHERE c.id = (SELECT id FROM member WHERE first_name=@parent_first_name AND last_name=@parent_last_name AND suffix=@parent_suffix)) AS validate_descendents;
```

```mysql
MariaDB [sql_blog_hierarchy]> SET @first_name := 'Isshin';
Query OK, 0 rows affected (0.000 sec)

MariaDB [sql_blog_hierarchy]> SET @last_name := 'Kurosaki';
Query OK, 0 rows affected (0.000 sec)

MariaDB [sql_blog_hierarchy]> SET @suffix = '';
Query OK, 0 rows affected (0.000 sec)

MariaDB [sql_blog_hierarchy]> SET @parent_first_name := 'Kazui';
Query OK, 0 rows affected (0.000 sec)

MariaDB [sql_blog_hierarchy]> SET @parent_last_name := 'Kurosaki';
Query OK, 0 rows affected (0.000 sec)

MariaDB [sql_blog_hierarchy]> SET @parent_suffix = '';
Query OK, 0 rows affected (0.000 sec)

MariaDB [sql_blog_hierarchy]> WITH RECURSIVE cte_descendents 
    -> AS (
    ->     SELECT id FROM member WHERE first_name=@first_name AND last_name=@last_name AND suffix=@suffix
    ->     UNION ALL
    ->     SELECT child_id FROM parent_child p INNER JOIN cte_descendents ON p.parent_id=id
    -> )
    -> SELECT COUNT(*) FROM (SELECT f.id FROM member f RIGHT JOIN cte_descendents c ON f.id=c.id WHERE c.id = (SELECT id FROM member WHERE first_name=@parent_first_name AND last_name=@parent_last_name AND suffix=@parent_suffix)) AS validate_descendents;
+----------+
| COUNT(*) |
+----------+
|        1 |
+----------+
1 row in set (0.006 sec)
```

Because this returns a count of 1, we can be sure that Kazui is a descendent of Isshin and thus Isshin can't ALSO be Kazui's father given the current family tree, we can also simplify the query significantly by not using sub queries (just the perspective of the parent_child table). We'll solve this problem similar to the previous situation by using a trigger:

```sql
DELIMITER $$
CREATE TRIGGER validate_circular_reference_insert
BEFORE INSERT
    ON parent_child FOR EACH ROW BEGIN
        IF (WITH RECURSIVE cte_descendents 
        AS (
            SELECT new.child_id id
            UNION ALL
            SELECT child_id FROM parent_child p INNER JOIN cte_descendents ON p.parent_id=id
        )
        SELECT COUNT(*) if_parent_child_descendent FROM (SELECT f.id FROM member f RIGHT JOIN cte_descendents c ON f.id=c.id WHERE c.id = new.parent_id) AS validate_descendents) > 0
        THEN
             SIGNAL SQLSTATE '45000'
                  SET MESSAGE_TEXT = 'Cannot insert row, circular reference, parent is descendent of child';
        ELSEIF (WITH RECURSIVE cte_descendents 
        AS (
            SELECT new.parent_id id
            UNION ALL
            SELECT child_id FROM parent_child p INNER JOIN cte_descendents ON p.parent_id=id
        )
        SELECT COUNT(*) if_parent_child_descendent FROM (SELECT f.id FROM member f RIGHT JOIN cte_descendents c ON f.id=c.id WHERE c.id = new.child_id) AS validate_descendents) > 0
        THEN
             SIGNAL SQLSTATE '45000'
                  SET MESSAGE_TEXT = 'Cannot insert row, circular reference, child is descendent of parent';
        END IF;
END$$
DELIMITER ;

DELIMITER $$
CREATE TRIGGER validate_circular_reference_update
BEFORE UPDATE
    ON parent_child FOR EACH ROW BEGIN
        IF (WITH RECURSIVE cte_descendents 
        AS (
            SELECT new.child_id id
            UNION ALL
            SELECT child_id FROM parent_child p INNER JOIN cte_descendents ON p.parent_id=id
        )
        SELECT COUNT(*) if_parent_child_descendent FROM (SELECT f.id FROM member f RIGHT JOIN cte_descendents c ON f.id=c.id WHERE c.id = new.parent_id) AS validate_descendents) > 0
        THEN
             SIGNAL SQLSTATE '45000'
                  SET MESSAGE_TEXT = 'Cannot insert row, circular reference, parent is descendent of child';
        ELSEIF (WITH RECURSIVE cte_descendents 
        AS (
            SELECT new.parent_id id
            UNION ALL
            SELECT child_id FROM parent_child p INNER JOIN cte_descendents ON p.parent_id=id
        )
        SELECT COUNT(*) if_parent_child_descendent FROM (SELECT f.id FROM member f RIGHT JOIN cte_descendents c ON f.id=c.id WHERE c.id = new.child_id) AS validate_descendents) > 0
        THEN
             SIGNAL SQLSTATE '45000'
                  SET MESSAGE_TEXT = 'Cannot insert row, circular reference, child is descendent of parent';
        END IF;
END$$
DELIMITER ;
```

Now with these triggers created, the following inserts should fail:

```sql
DELETE FROM parent_child WHERE parent_id=(SELECT id FROM member WHERE first_name = 'Kazui' AND last_name = 'Kurosaki') AND child_id=(SELECT id FROM member WHERE first_name = 'Isshin' AND last_name = 'Kurosaki');
INSERT INTO parent_child(parent_id, child_id) VALUES 
    ((SELECT id FROM member WHERE first_name = 'Kazui' AND last_name = 'Kurosaki'),
        (SELECT id FROM member WHERE first_name = 'Isshin' AND last_name = 'Kurosaki'));
```

```mysql
MariaDB [sql_blog_hierarchy]> DELETE FROM parent_child WHERE parent_id=(SELECT id FROM member WHERE first_name = 'Kazui' AND last_name = 'Kurosaki') AND child_id=(SELECT id FROM member WHERE first_name = 'Isshin' AND last_name = 'Kurosaki');
Query OK, 0 rows affected (0.003 sec)

MariaDB [sql_blog_hierarchy]> INSERT INTO parent_child(parent_id, child_id) VALUES 
    ->     ((SELECT id FROM member WHERE first_name = 'Kazui' AND last_name = 'Kurosaki'),
    ->         (SELECT id FROM member WHERE first_name = 'Isshin' AND last_name = 'Kurosaki'));
ERROR 1644 (45000): Cannot insert row, circular reference, parent is descendent of child
```

## Next steps; how could we extend the functionality of the tables?

This is here mostly to round out the remainder of the conversation. Even after you've successfully implemented an idea and have confirmed its functionality, you should be looking into the future and __recording__ things related to the architecture/schema so future developers can know when a refactor is needed. Your documentation should communicate the following:

- At what point are we going against the intentions of the architecture?
- At what point do non functional requirements exceed the ability of the architecture?
- What questions can this architecture absolutely not answer?

With that in mind, this architecture will generally be extensible by adding additional metadata to the columns, think of the following questions:

- What if you wanted to differentiate between biological and adoptive parents?
- What if you wanted to know which children were adopted versus not?
- What if you also wanted to know someone's maiden name?

These are some questions with easy answers (I'll leave this to you to go, oh yeh...you're right):

- What if someone wanted to change their name?
- What if you got more information that changed the parent -> child relationship?

I think in general, if you follow the rules of [normalization](https://en.wikipedia.org/wiki/Database_normalization), most queries will not only write themselves, but be great indicators as to whether the architecture/schema has outlived its intention/use.
