-- Generated by Oracle SQL Developer Data Modeler 24.3.1.351.0831
--   at:        2025-05-25 23:35:29 EEST
--   site:      Oracle Database 21c
--   type:      Oracle Database 21c

-- predefined type, no DDL - MDSYS.SDO_GEOMETRY

-- predefined type, no DDL - XMLTYPE

CREATE OR REPLACE PACKAGE PKG_STORE AS
  PROCEDURE ADD_CLIENT (
    P_USRNME  VARCHAR2,
    P_PASSWRD VARCHAR2,
    P_PNUMBER VARCHAR2,
    P_EMAIL   VARCHAR2,
    P_ISADM   NUMBER
  );
  PROCEDURE UPDATE_CLIENT (
    P_CID     NUMBER,
    P_USRNME  VARCHAR2,
    P_PASSWRD VARCHAR2,
    P_PNUMBER VARCHAR2,
    P_EMAIL   VARCHAR2
  );
  PROCEDURE DELETE_CLIENT (
    P_CID NUMBER
  );

  PROCEDURE ADD_GAME (
    P_NAME    VARCHAR2,
    P_PRICE   NUMBER,
    P_STOCK   NUMBER,
    P_RELEASE DATE,
    P_DESCR   VARCHAR2,
    P_PID     NUMBER
  );
  PROCEDURE UPDATE_GAME (
    P_GID   NUMBER,
    P_PRICE NUMBER,
    P_STOCK NUMBER
  );
  PROCEDURE DELETE_GAME (
    P_GID NUMBER
  );

  PROCEDURE PLACE_ORDER (
    P_CLIENT_ID NUMBER,
    P_GAME_ID   NUMBER,
    P_QUANTITY  NUMBER
  );
  PROCEDURE CANCEL_ORDER (
    P_ORDER_ID NUMBER
  );

  FUNCTION GET_STOCK (
    P_GAME_ID NUMBER
  ) RETURN NUMBER;
  FUNCTION GET_CLIENT_ORDERS (
    P_CLIENT_ID NUMBER
  ) RETURN SYS_REFCURSOR;
END PKG_STORE;
/

CREATE SEQUENCE SEQ_CLIENTS START WITH 1 INCREMENT BY 1;

CREATE SEQUENCE SEQ_GAMES START WITH 1 INCREMENT BY 1;

CREATE SEQUENCE SEQ_ORDERS START WITH 1 INCREMENT BY 1;

CREATE SEQUENCE SEQ_PUBLISH START WITH 1 INCREMENT BY 1;

CREATE TABLE CLIENTS (
  CID     NUMBER(3) NOT NULL,
  USRNME  VARCHAR2(20) NOT NULL,
  PASSWRD VARCHAR2(20) NOT NULL,
  ISADM   NUMBER(1) DEFAULT 0 NOT NULL
)
LOGGING;

ALTER TABLE CLIENTS
  ADD CONSTRAINT CHK_USRNME_FORMAT CHECK ( REGEXP_LIKE ( USRNME,
                                                         '^[a-zA-Z0-9]+$' ) );

ALTER TABLE CLIENTS
  ADD CONSTRAINT CHK_PASSWRD_FORMAT CHECK ( REGEXP_LIKE ( PASSWRD,
                                                          '^[a-zA-Z0-9]+$' ) );

ALTER TABLE CLIENTS ADD CONSTRAINT CLIENTS_PK PRIMARY KEY ( CID );

ALTER TABLE CLIENTS ADD CONSTRAINT CLIENTS_USRNME_UN UNIQUE ( USRNME );

CREATE TABLE CONTACT (
  CLIENTS_CID NUMBER(3) NOT NULL,
  PNUMBER     CHAR(10) NOT NULL,
  EMAIL       VARCHAR2(30) NOT NULL
)
LOGGING;

ALTER TABLE CONTACT
  ADD CONSTRAINT CHK_PNUMBER_FORMAT CHECK ( REGEXP_LIKE ( PNUMBER,
                                                          '^07[0-9]{8}$' ) );

ALTER TABLE CONTACT ADD CONSTRAINT CHK_EMAIL_FORMAT CHECK ( EMAIL LIKE '%@%.%' );

ALTER TABLE CONTACT ADD CONSTRAINT CONTACT_PK PRIMARY KEY ( CLIENTS_CID );

ALTER TABLE CONTACT
  ADD CONSTRAINT CONTACT_EMAIL_UN UNIQUE ( CLIENTS_CID,
                                           EMAIL,
                                           PNUMBER );

CREATE TABLE GAMES (
  GID              NUMBER(3) NOT NULL,
  GAME_NAME        VARCHAR2(30) NOT NULL,
  PRICE            NUMBER(5) NOT NULL,
  STOCK            NUMBER(5) NOT NULL,
  RELEASE_DATE     DATE NOT NULL,
  GAME_DESCRIPTION VARCHAR2(200),
  PUBLISH_PID      NUMBER(3) NOT NULL
)
LOGGING;

ALTER TABLE GAMES
  ADD CONSTRAINT CHK_RELEASE_DATE_FORMAT
    CHECK ( TO_CHAR(
      RELEASE_DATE,
      'YYYY-MM-DD'
    ) LIKE '____-__-__' );

ALTER TABLE GAMES ADD CONSTRAINT GAMES_PK PRIMARY KEY ( GID );

ALTER TABLE GAMES ADD CONSTRAINT GAMES_GAME_NAME_UN UNIQUE ( GAME_NAME );

CREATE TABLE ORDERS (
  ORID        NUMBER(3) NOT NULL,
  CLIENTS_CID NUMBER(3),
  GAMES_GID   NUMBER(3),
  GQUANTITY   NUMBER(5) NOT NULL
)
LOGGING;

ALTER TABLE ORDERS ADD CONSTRAINT ORDERS_PK PRIMARY KEY ( ORID );

CREATE TABLE PUBLISH (
  PID            NUMBER(3) NOT NULL,
  PUBLISHER_NAME VARCHAR2(30) NOT NULL
)
LOGGING;

ALTER TABLE PUBLISH ADD CONSTRAINT PUBLISH_PK PRIMARY KEY ( PID );

ALTER TABLE PUBLISH ADD CONSTRAINT PUBLISH_PUBLISHER_NAME_UN UNIQUE ( PUBLISHER_NAME );

ALTER TABLE CONTACT
  ADD CONSTRAINT CONTACT_CLIENTS_FK
    FOREIGN KEY ( CLIENTS_CID )
      REFERENCES CLIENTS ( CID )
      NOT DEFERRABLE;

ALTER TABLE GAMES
  ADD CONSTRAINT GAMES_PUBLISH_FK
    FOREIGN KEY ( PUBLISH_PID )
      REFERENCES PUBLISH ( PID )
      NOT DEFERRABLE;

ALTER TABLE ORDERS
  ADD CONSTRAINT ORDERS_CLIENTS_FK
    FOREIGN KEY ( CLIENTS_CID )
      REFERENCES CLIENTS ( CID )
      NOT DEFERRABLE;

ALTER TABLE ORDERS
  ADD CONSTRAINT ORDERS_GAMES_FK
    FOREIGN KEY ( GAMES_GID )
      REFERENCES GAMES ( GID )
      NOT DEFERRABLE;

CREATE OR REPLACE TRIGGER TRG_CLIENTS_BI BEFORE
  INSERT ON CLIENTS
  FOR EACH ROW
BEGIN
  :NEW.CID := SEQ_CLIENTS.NEXTVAL;
END;
/

CREATE OR REPLACE TRIGGER TRG_GAMES_BI BEFORE
  INSERT ON GAMES
  FOR EACH ROW
BEGIN
  :NEW.GID := SEQ_GAMES.NEXTVAL;
END;
/

CREATE OR REPLACE TRIGGER TRG_ORDERS_BI BEFORE
  INSERT ON ORDERS
  FOR EACH ROW
BEGIN
  :NEW.ORID := SEQ_ORDERS.NEXTVAL;
END;
/

CREATE OR REPLACE TRIGGER TRG_ORDERS_STOCK_CHECK BEFORE
  INSERT OR UPDATE ON ORDERS
  FOR EACH ROW
DECLARE
  V_STOCK GAMES.STOCK%TYPE;
BEGIN
  SELECT STOCK
    INTO V_STOCK
    FROM GAMES
   WHERE GID = :NEW.GAMES_GID;
  IF :NEW.GQUANTITY > V_STOCK THEN
    RAISE_APPLICATION_ERROR(
      -20001,
      'Cantitatea ceruta depaseste stocul disponibil.'
    );
  END IF;
END;
/

CREATE OR REPLACE TRIGGER TRG_PUBLISH_BI BEFORE
  INSERT ON PUBLISH
  FOR EACH ROW
BEGIN
  :NEW.PID := SEQ_PUBLISH.NEXTVAL;
END;
/

CREATE OR REPLACE PACKAGE BODY PKG_STORE AS
  PROCEDURE ADD_CLIENT (
    P_USRNME  VARCHAR2,
    P_PASSWRD VARCHAR2,
    P_PNUMBER VARCHAR2,
    P_EMAIL   VARCHAR2,
    P_ISADM   NUMBER
  ) IS
    V_EXISTS NUMBER;
    V_CID    CLIENTS.CID%TYPE;
  BEGIN
    SAVEPOINT SP_ADD_CLIENT;
    INSERT INTO CLIENTS (
      USRNME,
      PASSWRD,
      ISADM
    ) VALUES ( P_USRNME,
               P_PASSWRD,
               NVL(
                 P_ISADM,
                 0
               ) );

    SELECT SEQ_CLIENTS.CURRVAL
      INTO V_CID
      FROM DUAL;

    INSERT INTO CONTACT (
      CLIENTS_CID,
      PNUMBER,
      EMAIL
    ) VALUES ( V_CID,
               P_PNUMBER,
               P_EMAIL );
    COMMIT;
  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK TO SP_ADD_CLIENT;
      RAISE;
  END;

  PROCEDURE UPDATE_CLIENT (
    P_CID     NUMBER,
    P_USRNME  VARCHAR2,
    P_PASSWRD VARCHAR2,
    P_PNUMBER VARCHAR2,
    P_EMAIL   VARCHAR2
  ) IS
    V_CID CLIENTS.CID%TYPE;
  BEGIN
    SAVEPOINT SP_UPDATE_CLIENT;
    UPDATE CLIENTS
       SET USRNME = P_USRNME,
           PASSWRD = P_PASSWRD
     WHERE CID = P_CID;

    UPDATE CONTACT
       SET EMAIL = P_EMAIL,
           PNUMBER = P_PNUMBER
     WHERE CLIENTS_CID = P_CID;

    COMMIT;
  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK TO SP_UPDATE_CLIENT;
      RAISE;
  END;

  PROCEDURE DELETE_CLIENT (
    P_CID NUMBER
  ) IS
  BEGIN
    SAVEPOINT SP_DELETE_CLIENT;
    DELETE FROM CONTACT
     WHERE CLIENTS_CID = P_CID;

    DELETE FROM CLIENTS
     WHERE CID = P_CID;

    COMMIT;
  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK TO SP_DELETE_CLIENT;
      RAISE;
  END;

  PROCEDURE ADD_GAME (
    P_NAME    VARCHAR2,
    P_PRICE   NUMBER,
    P_STOCK   NUMBER,
    P_RELEASE DATE,
    P_DESCR   VARCHAR2,
    P_PID     NUMBER
  ) IS
  BEGIN
    SAVEPOINT SP_ADD_GAME;
    IF P_RELEASE > SYSDATE THEN
      RAISE_APPLICATION_ERROR(
        -20011,
        'Data lansarii nu poate fi in viitor.'
      );
    END IF;
    INSERT INTO GAMES (
      GAME_NAME,
      PRICE,
      STOCK,
      RELEASE_DATE,
      GAME_DESCRIPTION,
      PUBLISH_PID
    ) VALUES ( P_NAME,
               P_PRICE,
               P_STOCK,
               P_RELEASE,
               P_DESCR,
               P_PID );
    COMMIT;
  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK TO SP_ADD_GAME;
      RAISE;
  END;

  PROCEDURE UPDATE_GAME (
    P_GID   NUMBER,
    P_PRICE NUMBER,
    P_STOCK NUMBER
  ) IS
  BEGIN
    SAVEPOINT SP_UPDATE_GAME;
    UPDATE GAMES
       SET PRICE = P_PRICE,
           STOCK = P_STOCK
     WHERE GID = P_GID;
    COMMIT;
  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK TO SP_UPDATE_GAME;
      RAISE;
  END;

  PROCEDURE DELETE_GAME (
    P_GID NUMBER
  ) IS
  BEGIN
    SAVEPOINT SP_DELETE_GAME;
    DELETE FROM GAMES
     WHERE GID = P_GID;
    COMMIT;
  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK TO SP_DELETE_GAME;
      RAISE;
  END;

  PROCEDURE PLACE_ORDER (
    P_CLIENT_ID NUMBER,
    P_GAME_ID   NUMBER,
    P_QUANTITY  NUMBER
  ) IS
    V_STOCK NUMBER;
  BEGIN
    SAVEPOINT SP_PLACE_ORDER;
    V_STOCK := GET_STOCK(P_GAME_ID);
    IF P_QUANTITY > V_STOCK THEN
      RAISE_APPLICATION_ERROR(
        -20013,
        'Stoc insuficient pentru joc.'
      );
    END IF;
    INSERT INTO ORDERS (
      CLIENTS_CID,
      GAMES_GID,
      GQUANTITY
    ) VALUES ( P_CLIENT_ID,
               P_GAME_ID,
               P_QUANTITY );

    UPDATE GAMES
       SET
      STOCK = STOCK - P_QUANTITY
     WHERE GID = P_GAME_ID;

    COMMIT;
  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK TO SP_PLACE_ORDER;
      RAISE;
  END;

  PROCEDURE CANCEL_ORDER (
    P_ORDER_ID NUMBER
  ) IS
    V_GID      GAMES.GID%TYPE;
    V_QUANTITY ORDERS.GQUANTITY%TYPE;
  BEGIN
    SAVEPOINT SP_CANCEL_ORDER;
    SELECT GAMES_GID,
           GQUANTITY
      INTO
      V_GID,
      V_QUANTITY
      FROM ORDERS
     WHERE ORID = P_ORDER_ID;

    DELETE FROM ORDERS
     WHERE ORID = P_ORDER_ID;

    UPDATE GAMES
       SET
      STOCK = STOCK + V_QUANTITY
     WHERE GID = V_GID;

    COMMIT;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      RAISE_APPLICATION_ERROR(
        -20014,
        'Comanda inexistenta.'
      );
    WHEN OTHERS THEN
      ROLLBACK TO SP_CANCEL_ORDER;
      RAISE;
  END;

  FUNCTION GET_STOCK (
    P_GAME_ID NUMBER
  ) RETURN NUMBER IS
    V_STOCK NUMBER;
  BEGIN
    SELECT STOCK
      INTO V_STOCK
      FROM GAMES
     WHERE GID = P_GAME_ID;
    RETURN V_STOCK;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      RAISE_APPLICATION_ERROR(
        -20012,
        'Joc inexistent.'
      );
  END;

  FUNCTION GET_CLIENT_ORDERS (
    P_CLIENT_ID NUMBER
  ) RETURN SYS_REFCURSOR IS
    RC SYS_REFCURSOR;
  BEGIN
    OPEN RC FOR SELECT O.ORID,
                       G.GAME_NAME,
                       O.GQUANTITY,
                       G.PRICE,
                       O.GQUANTITY * G.PRICE AS TOTAL
                              FROM ORDERS O
                              JOIN GAMES G
                            ON O.GAMES_GID = G.GID
                 WHERE O.CLIENTS_CID = P_CLIENT_ID;
    RETURN RC;
  END;

END PKG_STORE;
/



-- Oracle SQL Developer Data Modeler Summary Report: 
-- 
-- CREATE TABLE                             5
-- CREATE INDEX                             0
-- ALTER TABLE                             18
-- CREATE VIEW                              0
-- ALTER VIEW                               0
-- CREATE PACKAGE                           1
-- CREATE PACKAGE BODY                      1
-- CREATE PROCEDURE                         0
-- CREATE FUNCTION                          0
-- CREATE TRIGGER                           5
-- ALTER TRIGGER                            0
-- CREATE COLLECTION TYPE                   0
-- CREATE STRUCTURED TYPE                   0
-- CREATE STRUCTURED TYPE BODY              0
-- CREATE CLUSTER                           0
-- CREATE CONTEXT                           0
-- CREATE DATABASE                          0
-- CREATE DIMENSION                         0
-- CREATE DIRECTORY                         0
-- CREATE DISK GROUP                        0
-- CREATE ROLE                              0
-- CREATE ROLLBACK SEGMENT                  0
-- CREATE SEQUENCE                          4
-- CREATE MATERIALIZED VIEW                 0
-- CREATE MATERIALIZED VIEW LOG             0
-- CREATE SYNONYM                           0
-- CREATE TABLESPACE                        0
-- CREATE USER                              0
-- 
-- DROP TABLESPACE                          0
-- DROP DATABASE                            0
-- 
-- REDACTION POLICY                         0
-- 
-- ORDS DROP SCHEMA                         0
-- ORDS ENABLE SCHEMA                       0
-- ORDS ENABLE OBJECT                       0
-- 
-- ERRORS                                   0
-- WARNINGS                                 0