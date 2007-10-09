CREATE TABLE thumbnail (
    id             INT NOT NULL AUTO_INCREMENT,
    created_on     DATETIME,
    modified_on    DATETIME,
    url            VARCHAR(256) NOT NULL,
    thumbnail_name VARCHAR(48),
    extention      VARCHAR(8) NOT NULL,
    original       MEDIUMBLOB,
    large          MEDIUMBLOB,
    medium         MEDIUMBLOB,
    small          MEDIUMBLOB,
    PRIMARY KEY (id),
    INDEX index_url (url)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
