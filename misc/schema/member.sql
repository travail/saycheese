CREATE TABLE member (
    id          INT UNSIGNED NOT NULL AUTO_INCREMENT,
    created_on  DATETIME NOT NULL,
    modified_on TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    member_id   VARCHAR(64) BINARY NOT NULL,
    password    VARCHAR(64) NOT NULL,
    email       VARCHAR(255) DEFAULT NULL,
    PRIMARY KEY (id),
    UNIQUE unique_mina_id (member_id),
    UNIQUE unique_email (email)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
