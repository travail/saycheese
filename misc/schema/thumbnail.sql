CREATE TABLE thumbnail (
    id          INT NOT NULL AUTO_INCREMENT,
    created_on  DATETIME NOT NULL,
    modified_on DATETIME NOT NULL,
    url         VARCHAR(512) NOT NULL,
    digest      VARCHAR(256) DEFAULT NULL,
    is_finished TINYINT(1) UNSIGNED DEFAULT 0,
    PRIMARY KEY (id),
    UNIQUE unique_url (url)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
