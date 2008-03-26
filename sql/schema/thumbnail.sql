CREATE TABLE thumbnail (
    id          INT NOT NULL AUTO_INCREMENT,
    created_on  DATETIME,
    modified_on DATETIME,
    url         VARCHAR(255) NOT NULL,
    digest      VARCHAR(255) DEFAULT NULL,
    is_finished TINYINT(1) UNSIGNED DEFAULT 0,
    PRIMARY KEY (id),
    INDEX index_url (url)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
