-- DROP DATABASE IF EXISTS sql_blog_hierarchy;
CREATE DATABASE IF NOT EXISTS sql_blog_hierarchy;

USE sql_blog_hierarchy;

-- DROP TABLE IF EXISTS member;
CREATE TABLE IF NOT EXISTS member (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    first_name TEXT NOT NULL,
    middle_name TEXT DEFAULT '',
    last_name TEXT DEFAULT '',
    suffix TEXT DEFAULT '',
    UNIQUE(first_name, last_name, suffix)
) ENGINE = InnoDB;

-- DROP TABLE IF EXISTS parent_child;
CREATE TABLE IF NOT EXISTS parent_child (
    parent_id BIGINT,
    child_id BIGINT,
    FOREIGN KEY (parent_id) REFERENCES member(id),
    FOREIGN KEY (child_id) REFERENCES member(id),
    PRIMARY KEY(parent_id, child_id),
    CONSTRAINT check_parent_self CHECK (parent_id <> child_id)
) ENGINE = InnoDB;

-- DELETE FROM member
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

-- DELETE FROM parent_child
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

-- DELETE FROM member
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

-- DELETE FROM parent_child
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

-- DROP TRIGGER validate_parent_child_insert
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

-- DROP TRIGGER validate_parent_child_update
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

-- DORP TRIGGER validate_circular_reference_insert
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

-- DROP TRIGGER validate_circular_reference_update
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