DELETE FROM items WHERE name = 'bleachwipes';
DELETE FROM items WHERE name = 'uvlight';


INSERT INTO `items` (`name`, `label`, `limit`) VALUES
	('bleachwipes', 'Bleach Wipes', 10),
	('uvlight', 'UV Light', 10)
;