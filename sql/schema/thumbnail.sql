CREATE TABLE thumbnail (
    id             INT NOT NULL AUTO_INCREMENT,
    created_on     DATETIME,
    modified_on    DATETIME,
    url            VARCHAR(64),
    thumbnail_name VARCHAR(48),
    extention      VARCHAR(8) NOT NULL,
    filedata       MEDIUMBLOB,
    width          SMALLINT UNSIGNED DEFAULT 0,
    height         SMALLINT UNSIGNED DEFAULT 0,
    filesize       MEDIUMINT UNSIGNED DEFAULT 0,
    PRIMARY KEY (id),
    INDEX index_url (url)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
