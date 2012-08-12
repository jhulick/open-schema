--  *********************************************************************
--  Update Database Script
--  *********************************************************************
--  Change Log: open-schema.liquibase.xml
--  Ran at: 8/12/12 11:33 AM
--  Against: blueserf_snshah@pool-173-66-0-134.washdc.fios.verizon.net@jdbc:mysql://box666.bluehost.com/blueserf_devl_bfelob_oge_admin
--  Liquibase version: 2.0.5
--  *********************************************************************

--  Create Database Lock Table
CREATE TABLE `DB_CHANGE_LOG_SEMAPHORE` (`ID` INT NOT NULL, `LOCKED` TINYINT(1) NOT NULL, `LOCKGRANTED` DATETIME NULL, `LOCKEDBY` VARCHAR(255) NULL, CONSTRAINT `PK_DB_CHANGE_LOG_SEMAPHORE` PRIMARY KEY (`ID`));

INSERT INTO `DB_CHANGE_LOG_SEMAPHORE` (`ID`, `LOCKED`) VALUES (1, 0);

--  Lock Database
--  Create Database Change Log Table
CREATE TABLE `DB_CHANGE_LOG` (`ID` VARCHAR(63) NOT NULL, `AUTHOR` VARCHAR(63) NOT NULL, `FILENAME` VARCHAR(200) NOT NULL, `DATEEXECUTED` DATETIME NOT NULL, `ORDEREXECUTED` INT NOT NULL, `EXECTYPE` VARCHAR(10) NOT NULL, `MD5SUM` VARCHAR(35) NULL, `DESCRIPTION` VARCHAR(255) NULL, `COMMENTS` VARCHAR(255) NULL, `TAG` VARCHAR(255) NULL, `LIQUIBASE` VARCHAR(20) NULL, CONSTRAINT `PK_DB_CHANGE_LOG` PRIMARY KEY (`ID`, `AUTHOR`, `FILENAME`));

--  Changeset change-sets/schema/001-schema-master.liquibase.xml::001-schema-master::Shahid N. Shah::(Checksum: 3:91357e355ebd471cae91885d9d0db7ef)
CREATE TABLE `directory` (`directory_id` INT NOT NULL, `parent_id` INT NULL, `name` VARCHAR(255) NOT NULL, `qualified_name` VARCHAR(255) NOT NULL, CONSTRAINT `PK_DIRECTORY` PRIMARY KEY (`directory_id`), CONSTRAINT `FK_directory_directory_id` FOREIGN KEY (`parent_id`) REFERENCES directory.directory_id, UNIQUE (`qualified_name`));

CREATE TABLE `relationship_type` (`relationship_type_id` INT NOT NULL, `parent_id` INT NULL, `direction` VARCHAR(255) NOT NULL, CONSTRAINT `PK_RELATIONSHIP_TYPE` PRIMARY KEY (`relationship_type_id`), CONSTRAINT `FK_relationship_relationship_type_id` FOREIGN KEY (`parent_id`) REFERENCES relationship.relationship_type_id, UNIQUE (`direction`));

CREATE TABLE `value_type` (`value_type_id` INT NOT NULL, `parent_id` INT NULL, `name` VARCHAR(255) NOT NULL, `table_name` VARCHAR(255) NOT NULL, `qualified_name` VARCHAR(255) NOT NULL, `is_domain_constrained` TINYINT(1) NULL, CONSTRAINT `PK_VALUE_TYPE` PRIMARY KEY (`value_type_id`), CONSTRAINT `FK_value_type_value_type_id` FOREIGN KEY (`parent_id`) REFERENCES value_type.value_type_id, UNIQUE (`qualified_name`));

CREATE TABLE `value_type_domain_item` (`value_type_domain_item_id` INT NOT NULL, `value_type_id` INT NULL, `parent_id` INT NULL, `position` INT NULL, `name` VARCHAR(255) NOT NULL, `abbrev` VARCHAR(255) NULL, CONSTRAINT `PK_VALUE_TYPE_DOMAIN_ITEM` PRIMARY KEY (`value_type_domain_item_id`), CONSTRAINT `FK_value_type_domain_item_value_type_id` FOREIGN KEY (`value_type_id`) REFERENCES value_type.value_type_id, CONSTRAINT `FK_value_type_domain_item_id` FOREIGN KEY (`parent_id`) REFERENCES value_type_domain_item.value_type_domain_item_id);

CREATE TABLE `entity_type` (`entity_type_id` INT NOT NULL, `directory_id` INT NOT NULL, `parent_id` INT NULL, `name` VARCHAR(255) NOT NULL, `qualified_name` VARCHAR(255) NOT NULL, CONSTRAINT `PK_ENTITY_TYPE` PRIMARY KEY (`entity_type_id`), CONSTRAINT `FK_entity_directory_id` FOREIGN KEY (`directory_id`) REFERENCES directory.directory_id, CONSTRAINT `FK_entity_type_entity_type_id` FOREIGN KEY (`parent_id`) REFERENCES entity_type.entity_type_id, UNIQUE (`qualified_name`));

CREATE TABLE `attr_type` (`attr_type_id` INT NOT NULL, `entity_type_id` INT NOT NULL, `value_type_id` INT NOT NULL, `parent_id` INT NULL, `name` VARCHAR(255) NOT NULL, `qualified_name` VARCHAR(255) NOT NULL, CONSTRAINT `PK_ATTR_TYPE` PRIMARY KEY (`attr_type_id`), CONSTRAINT `FK_attr_type_attr_type_id` FOREIGN KEY (`parent_id`) REFERENCES attr_type.attr_type_id, CONSTRAINT `FK_entity_type_id` FOREIGN KEY (`entity_type_id`) REFERENCES entity_type.entity_type_id, CONSTRAINT `FK_attr_type_value_type_id` FOREIGN KEY (`value_type_id`) REFERENCES value_type.value_type_id, UNIQUE (`qualified_name`));

CREATE TABLE `activity_type` (`activity_type_id` INT NOT NULL, `parent_id` INT NULL, `name` VARCHAR(255) NOT NULL, `qualified_name` VARCHAR(255) NOT NULL, CONSTRAINT `PK_ACTIVITY_TYPE` PRIMARY KEY (`activity_type_id`), CONSTRAINT `FK_activity_type_activity_type_id` FOREIGN KEY (`parent_id`) REFERENCES activity_type.activity_type_id, UNIQUE (`qualified_name`));

CREATE TABLE `entity` (`entity_id` INT AUTO_INCREMENT NOT NULL, `entity_type_id` INT NOT NULL, `directory_id` INT NOT NULL, `identity` VARCHAR(255) NOT NULL, CONSTRAINT `PK_ENTITY` PRIMARY KEY (`entity_id`), CONSTRAINT `FK_entity_type_id` FOREIGN KEY (`entity_type_id`) REFERENCES entity_type.entity_type_id, CONSTRAINT `FK_entity_directory_id` FOREIGN KEY (`directory_id`) REFERENCES directory.directory_id);

CREATE TABLE `entity_relationship` (`entity_relationship_id` INT AUTO_INCREMENT NOT NULL, `relationship_type_id` INT NOT NULL, `entity_id` INT NOT NULL, `related_id` INT NOT NULL, `name` VARCHAR(255) NULL, CONSTRAINT `PK_ENTITY_RELATIONSHIP` PRIMARY KEY (`entity_relationship_id`), CONSTRAINT `FK_entity_relationship_entity_id` FOREIGN KEY (`entity_id`) REFERENCES entity.entity_id, CONSTRAINT `FK_entity_relationship_id` FOREIGN KEY (`relationship_type_id`) REFERENCES relationship.relationship_type_id, CONSTRAINT `FK_entity_relationship_related_id` FOREIGN KEY (`related_id`) REFERENCES entity.entity_id);

CREATE TABLE `entity_attr` (`entity_attr_id` INT AUTO_INCREMENT NOT NULL, `entity_attr_type_id` INT NOT NULL, `parent_id` INT NULL, `entity_id` INT NOT NULL, `relationship_id` INT NOT NULL, `name` VARCHAR(255) NULL, CONSTRAINT `PK_ENTITY_ATTR` PRIMARY KEY (`entity_attr_id`), CONSTRAINT `FK_entity_attr_entity_id` FOREIGN KEY (`entity_id`) REFERENCES entity.entity_id, CONSTRAINT `FK_entity_attr_entity_relationship_id` FOREIGN KEY (`relationship_id`) REFERENCES entity_relationship.entity_relationship_id, CONSTRAINT `FK_entity_attr_type_id` FOREIGN KEY (`entity_attr_type_id`) REFERENCES attr_type.attr_type_id, CONSTRAINT `FK_entity_attr_parent_id` FOREIGN KEY (`parent_id`) REFERENCES entity_attr.entity_attr_id);

CREATE TABLE `entity_attr_value` (`entity_attr_value_id` INT AUTO_INCREMENT NOT NULL, `entity_id` INT NOT NULL, `entity_attr_id` INT NOT NULL, `position` INT NULL, CONSTRAINT `PK_ENTITY_ATTR_VALUE` PRIMARY KEY (`entity_attr_value_id`), CONSTRAINT `FK_entity_attr_value_entity_id` FOREIGN KEY (`entity_id`) REFERENCES entity.entity_id, CONSTRAINT `FK_entity_attr_value_attr_id` FOREIGN KEY (`entity_attr_id`) REFERENCES entity.entity_attr_id);

CREATE TABLE `entity_attr_value_text` (`entity_attr_value_text_id` INT AUTO_INCREMENT NOT NULL, `entity_id` INT NOT NULL, `entity_attr_id` INT NOT NULL, `entity_attr_value_id` INT NOT NULL, `value_type_domain_item_id` INT NULL, `value` VARCHAR(4096) NOT NULL, CONSTRAINT `PK_ENTITY_ATTR_VALUE_TEXT` PRIMARY KEY (`entity_attr_value_text_id`), CONSTRAINT `FK_entity_attr_value_entity_attr_value_id` FOREIGN KEY (`entity_attr_value_id`) REFERENCES entity_attr_value.entity_attr_value_id, CONSTRAINT `FK_value_type_domain_item.value_type_domain_item_id` FOREIGN KEY (`value_type_domain_item_id`) REFERENCES value_type_domain_item.value_type_domain_item_id, CONSTRAINT `FK_entity_attr_value_entity_id` FOREIGN KEY (`entity_id`) REFERENCES entity.entity_id, CONSTRAINT `FK_entity_attr_value_attr_id` FOREIGN KEY (`entity_attr_id`) REFERENCES entity.entity_attr_id);

CREATE TABLE `entity_attr_value_date` (`entity_attr_value_text_id` INT AUTO_INCREMENT NOT NULL, `entity_id` INT NOT NULL, `entity_attr_id` INT NOT NULL, `entity_attr_value_id` INT NOT NULL, `value` DATE NOT NULL, CONSTRAINT `PK_ENTITY_ATTR_VALUE_DATE` PRIMARY KEY (`entity_attr_value_text_id`), CONSTRAINT `FK_entity_attr_value_attr_id` FOREIGN KEY (`entity_attr_id`) REFERENCES entity.entity_attr_id, CONSTRAINT `FK_entity_attr_value_entity_attr_value_id` FOREIGN KEY (`entity_attr_value_id`) REFERENCES entity_attr_value.entity_attr_value_id, CONSTRAINT `FK_entity_attr_value_entity_id` FOREIGN KEY (`entity_id`) REFERENCES entity.entity_id);

INSERT INTO `DB_CHANGE_LOG` (`AUTHOR`, `COMMENTS`, `DATEEXECUTED`, `DESCRIPTION`, `EXECTYPE`, `FILENAME`, `ID`, `LIQUIBASE`, `MD5SUM`, `ORDEREXECUTED`) VALUES ('Shahid N. Shah', '', NOW(), 'Create Table (x13)', 'EXECUTED', 'change-sets/schema/001-schema-master.liquibase.xml', '001-schema-master', '2.0.5', '3:91357e355ebd471cae91885d9d0db7ef', 1);

--  Changeset change-sets/eav-structure/001-OGE-admin-utility.liquibase.xml::001-OGE-admin-utility::Shahid N. Shah::(Checksum: 3:f3ff5b9c0f64b0a3b2e2eb4ec05e4ac9)
insert into directory (directory_id, qualified_name, name) values (0, 'Prime', 'Prime');

insert into relationship_type (relationship_type_id, direction) values (0, 'NULL');

insert into relationship_type (relationship_type_id, direction) values (100, 'Party.Person -> Party.Organization');

insert into relationship_type (relationship_type_id, direction) values (200, 'Party.Person.Filer -> Document : owns');

insert into relationship_type (relationship_type_id, direction) values (210, 'Party.Person.User -> Document : uploaded');

insert into value_type (value_type_id, qualified_name, name, table_name) values (0, 'Text', 'Text', 'entity_attr_value_text');

insert into value_type (value_type_id, qualified_name, name, table_name) values (1, 'Date', 'Date', 'entity_attr_value_date');

insert into value_type (value_type_id, qualified_name, name, table_name) values (100, 'File System Reference', 'File System Reference', 'entity_attr_value_text');

insert into value_type (value_type_id, qualified_name, name, is_domain_constrained, table_name) values (110, 'Form Type', 'Form Type', true, 'entity_attr_value_text');

insert into value_type_domain_item (value_type_domain_item_id, value_type_id, position, name, abbrev) values (11000, 110, 0, '278NEW', '278NEW');

insert into value_type_domain_item (value_type_domain_item_id, value_type_id, position, name, abbrev) values (11001, 110, 1, '278TERM', '278TERM');

insert into value_type_domain_item (value_type_domain_item_id, value_type_id, position, name, abbrev) values (11002, 110, 2, '278ANN', '278ANN');

insert into value_type_domain_item (value_type_domain_item_id, value_type_id, position, name, abbrev) values (11003, 110, 3, '278TRnn', '278TRnn');

INSERT INTO `entity_type` (`directory_id`, `entity_type_id`, `name`, `parent_id`, `qualified_name`) VALUES ((select directory_id from directory where qualified_name = 'Prime'), 0, 'Any', NULL, 'Any');

INSERT INTO `entity_type` (`directory_id`, `entity_type_id`, `name`, `parent_id`, `qualified_name`) VALUES ((select directory_id from directory where qualified_name = 'Prime'), 1000, 'Party', NULL, 'Party');

INSERT INTO `entity_type` (`directory_id`, `entity_type_id`, `name`, `parent_id`, `qualified_name`) VALUES ((select directory_id from (select directory_id from entity_type where qualified_name = 'Party') as parent_directory_id), 1001, 'Person', (select entity_type_id from (select entity_type_id from entity_type where qualified_name = 'Party') as parent_id), 'Party.Person');

INSERT INTO `attr_type` (`attr_type_id`, `entity_type_id`, `name`, `qualified_name`, `value_type_id`) VALUES (1001, 1001, 'Last Name', 'Party.Person.Last Name', (select value_type_id from value_type where qualified_name = 'Text'));

INSERT INTO `attr_type` (`attr_type_id`, `entity_type_id`, `name`, `qualified_name`, `value_type_id`) VALUES (1002, 1001, 'First Name', 'Party.Person.First Name', (select value_type_id from value_type where qualified_name = 'Text'));

INSERT INTO `attr_type` (`attr_type_id`, `entity_type_id`, `name`, `qualified_name`, `value_type_id`) VALUES (1003, 1001, 'Middle Name', 'Party.Person.Middle Name', (select value_type_id from value_type where qualified_name = 'Text'));

INSERT INTO `entity_type` (`directory_id`, `entity_type_id`, `name`, `parent_id`, `qualified_name`) VALUES ((select directory_id from (select directory_id from entity_type where qualified_name = 'Party.Person') as parent_directory_id), 1010, 'Filer', (select entity_type_id from (select entity_type_id from entity_type where qualified_name = 'Party.Person') as parent_id), 'Party.Person.Filer');

INSERT INTO `attr_type` (`attr_type_id`, `entity_type_id`, `name`, `qualified_name`, `value_type_id`) VALUES (1010, 1010, 'Position Title', 'Party.Person.Filer.Position Title', (select value_type_id from value_type where qualified_name = 'Text'));

INSERT INTO `entity_type` (`directory_id`, `entity_type_id`, `name`, `parent_id`, `qualified_name`) VALUES ((select directory_id from (select directory_id from entity_type where qualified_name = 'Party.Person') as parent_directory_id), 1020, 'User', (select entity_type_id from (select entity_type_id from entity_type where qualified_name = 'Party.Person') as parent_id), 'Party.Person.User');

INSERT INTO `entity_type` (`directory_id`, `entity_type_id`, `name`, `parent_id`, `qualified_name`) VALUES ((select directory_id from (select directory_id from entity_type where qualified_name = 'Party') as parent_directory_id), 2000, 'Organization', (select entity_type_id from (select entity_type_id from entity_type where qualified_name = 'Party') as parent_id), 'Party.Organization');

INSERT INTO `attr_type` (`attr_type_id`, `entity_type_id`, `name`, `qualified_name`, `value_type_id`) VALUES (2000, 2000, 'Name', 'Party.Organization.Name', (select value_type_id from value_type where qualified_name = 'Text'));

INSERT INTO `entity_type` (`directory_id`, `entity_type_id`, `name`, `parent_id`, `qualified_name`) VALUES ((select directory_id from (select directory_id from entity_type where qualified_name = 'Party.Organization') as parent_directory_id), 2010, 'Agency/Department', (select entity_type_id from (select entity_type_id from entity_type where qualified_name = 'Party.Organization') as parent_id), 'Party.Organization.Agency/Department');

INSERT INTO `entity_type` (`directory_id`, `entity_type_id`, `name`, `parent_id`, `qualified_name`) VALUES ((select directory_id from (select directory_id from entity_type where qualified_name = 'Party.Organization.Agency/Department') as parent_directory_id), 2020, 'Component', (select entity_type_id from (select entity_type_id from entity_type where qualified_name = 'Party.Organization.Agency/Department') as parent_id), 'Party.Organization.Agency/Department.Component');

INSERT INTO `attr_type` (`attr_type_id`, `entity_type_id`, `name`, `qualified_name`, `value_type_id`) VALUES (2020, 2020, 'MAX Community Group', 'Party.Organization.Agency/Department.Component.MAX Community Group', (select value_type_id from value_type where qualified_name = 'Text'));

INSERT INTO `entity_type` (`directory_id`, `entity_type_id`, `name`, `parent_id`, `qualified_name`) VALUES ((select directory_id from (select directory_id from entity_type where qualified_name = 'Party') as parent_directory_id), 3000, 'Activity', (select entity_type_id from (select entity_type_id from entity_type where qualified_name = 'Party') as parent_id), 'Party.Activity');

INSERT INTO `entity_type` (`directory_id`, `entity_type_id`, `name`, `parent_id`, `qualified_name`) VALUES ((select directory_id from directory where qualified_name = 'Prime'), 5000, 'Document', NULL, 'Document');

INSERT INTO `attr_type` (`attr_type_id`, `entity_type_id`, `name`, `qualified_name`, `value_type_id`) VALUES (5000, 5000, 'Name', 'Document.Name', (select value_type_id from value_type where qualified_name = 'Text'));

INSERT INTO `attr_type` (`attr_type_id`, `entity_type_id`, `name`, `qualified_name`, `value_type_id`) VALUES (5001, 5000, 'File System Path', 'Document.File System Path', (select value_type_id from value_type where qualified_name = 'File System Reference'));

INSERT INTO `DB_CHANGE_LOG` (`AUTHOR`, `COMMENTS`, `DATEEXECUTED`, `DESCRIPTION`, `EXECTYPE`, `FILENAME`, `ID`, `LIQUIBASE`, `MD5SUM`, `ORDEREXECUTED`) VALUES ('Shahid N. Shah', '', NOW(), 'Custom SQL, Create a new open-schema entity (x10)', 'EXECUTED', 'change-sets/eav-structure/001-OGE-admin-utility.liquibase.xml', '001-OGE-admin-utility', '2.0.5', '3:f3ff5b9c0f64b0a3b2e2eb4ec05e4ac9', 2);

