CREATE DATABASE piwik;
CREATE USER 'piwik'@'localhost';
GRANT ALL PRIVILEGES ON piwik.* TO 'piwik'@'localhost' WITH GRANT OPTION;
