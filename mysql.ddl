CREATE DATABASE piwik;
CREATE USER 'piwik'@'localhost' IDENTIFIED BY 'password';
GRANT ALL PRIVILEGES ON piwik_db_name_here.* TO 'piwik'@'localhost' WITH GRANT OPTION;