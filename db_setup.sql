create database hierarchie_test;
use hierarchie_test;

CREATE USER 'expressjs_user' @'localhost' IDENTIFIED BY 'password';

GRANT ALL PRIVILEGES ON hierarchie_test.* TO 'expressjs_user' @'localhost';

CREATE TABLE `tbl_person` (
 `id_person` int(11) NOT NULL AUTO_INCREMENT,
 `vorgesetzter_id` int(11) DEFAULT NULL,
 `name` varchar(50) NOT NULL,
 PRIMARY KEY (`id_person`),
 KEY `fk_constraint_vorgesetzter` (`vorgesetzter_id`),
 CONSTRAINT `fk_constraint_vorgesetzter` FOREIGN KEY (`vorgesetzter_id`) REFERENCES `tbl_person` (`id_person`)
) ENGINE=InnoDB AUTO_INCREMENT=16 DEFAULT CHARSET=utf8mb4


CREATE DEFINER=`root`@`localhost` PROCEDURE `proc_children_tree_as_json`(IN `param_id` INT, OUT `result_json` VARCHAR(1000))
BEGIN
declare cursor_done int default false;
declare param_id_name varchar(100);
declare current_child_id int;
declare current_child_json varchar(1000);
declare cur_children cursor for select id_person from tbl_person where vorgesetzter_id = param_id;
declare continue handler for not found set cursor_done = TRUE;
SELECT name into param_id_name from tbl_person where id_person=param_id;
set result_json = concat("{""id"": ", param_id, ", ""name"": """, param_id_name, """, ""children"": [");
open cur_children;
children_loop: loop
fetch cur_children into current_child_id;
if cursor_done then
leave children_loop;
end if;
call proc_children_tree_as_json(current_child_id, current_child_json);
set result_json = concat(result_json, current_child_json, ',');
end loop;
set result_json =  TRIM(BOTH ',' FROM result_json);
set result_json = concat(result_json, "]}");
close cur_children;
END


CREATE DEFINER=`root`@`localhost` FUNCTION `fun_children_tree_as_json`() RETURNS varchar(1000) CHARSET utf8mb4
   NO SQL
BEGIN
declare proc_result varchar(1000) default '';
call proc_children_tree_as_json(1,proc_result);
return proc_result;
END