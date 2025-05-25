ALTER TABLE contact DROP CONSTRAINT contact_clients_fk;
ALTER TABLE games DROP CONSTRAINT games_publish_fk;
ALTER TABLE orders DROP CONSTRAINT orders_clients_fk;
ALTER TABLE orders DROP CONSTRAINT orders_games_fk;

DROP TABLE orders;
DROP TABLE contact;
DROP TABLE games;
DROP TABLE clients;
DROP TABLE publish;

DROP SEQUENCE seq_clients;
DROP SEQUENCE seq_games;
DROP SEQUENCE seq_orders;
DROP SEQUENCE seq_publish;

DROP PACKAGE BODY pkg_shop;
DROP PACKAGE pkg_shop;