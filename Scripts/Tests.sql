   SET SERVEROUTPUT ON;

INSERT INTO PUBLISH ( PUBLISHER_NAME ) VALUES ( 'Test' );
COMMIT;

-- 2. TESTE PENTRU PROCEDURA ADD_CLIENT
-- Test 1: Adaugare client valid
BEGIN
  PKG_STORE.ADD_CLIENT(
    P_USRNME  => 'testuser1',
    P_PASSWRD => 'password123',
    P_PNUMBER => '0712345678',
    P_EMAIL   => 'test1@email.com',
    P_ISADM   => 0
  );
  DBMS_OUTPUT.PUT_LINE('✓ Test 1 ADD_CLIENT: Client adaugat cu succes');
EXCEPTION
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('✗ Test 1 ADD_CLIENT: ' || SQLERRM);
END;
/

-- Test 2: Username duplicat
BEGIN
  PKG_STORE.ADD_CLIENT(
    P_USRNME  => 'testuser1',
    P_PASSWRD => 'password456',
    P_PNUMBER => '0787654321',
    P_EMAIL   => 'test2@email.com',
    P_ISADM   => 0
  );
  DBMS_OUTPUT.PUT_LINE('✗ Test 3 ADD_CLIENT: Nu ar fi trebuit sa reuseasca (username duplicat)');
EXCEPTION
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('✓ Test 3 ADD_CLIENT: Corect - username duplicat detectat');
END;
/

-- Test 3: Format telefon invalid
BEGIN
  PKG_STORE.ADD_CLIENT(
    P_USRNME  => 'testuser3',
    P_PASSWRD => 'password789',
    P_PNUMBER => '123456789',  -- format invalid
    P_EMAIL   => 'test3@email.com',
    P_ISADM   => 0
  );
  DBMS_OUTPUT.PUT_LINE('✗ Test 4 ADD_CLIENT: Nu ar fi trebuit sa reuseasca (telefon invalid)');
EXCEPTION
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('✓ Test 4 ADD_CLIENT: Corect - format telefon invalid detectat');
END;
/

-- Test 4: Format email invalid
BEGIN
  PKG_STORE.ADD_CLIENT(
    P_USRNME  => 'testuser4',
    P_PASSWRD => 'password789',
    P_PNUMBER => '0787654321',
    P_EMAIL   => 'emailinvalid',
    P_ISADM   => 0
  );
  DBMS_OUTPUT.PUT_LINE('✗ Test 5 ADD_CLIENT: Nu ar fi trebuit sa reuseasca (email invalid)');
EXCEPTION
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('✓ Test 5 ADD_CLIENT: Corect - format email invalid detectat');
END;
/

-- 3. TESTE PENTRU PROCEDURA UPDATE_CLIENT
-- Test 1: Update valid
DECLARE
  V_CLIENT_ID CLIENTS.CID%TYPE;
BEGIN
  SELECT CID
    INTO V_CLIENT_ID
    FROM CLIENTS
   WHERE USRNME = 'testuser1';

  PKG_STORE.UPDATE_CLIENT(
    P_CID     => V_CLIENT_ID,
    P_USRNME  => 'testuser1updated',
    P_PASSWRD => 'newpassword',
    P_PNUMBER => '0712345679',
    P_EMAIL   => 'updated@email.com'
  );
  DBMS_OUTPUT.PUT_LINE('✓ Test 1 UPDATE_CLIENT: Client actualizat cu succes');
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    DBMS_OUTPUT.PUT_LINE('✗ Test 1 UPDATE_CLIENT: Client nu gasit pentru update');
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('✗ Test 1 UPDATE_CLIENT: ' || SQLERRM);
END;
/

-- Test 2: Update client inexistent
BEGIN
  PKG_STORE.UPDATE_CLIENT(
    P_CID     => 999999,
    P_USRNME  => 'inexistent',
    P_PASSWRD => 'password',
    P_PNUMBER => '0787654321',
    P_EMAIL   => 'inexistent@email.com'
  );
  DBMS_OUTPUT.PUT_LINE('✓ Test 2 UPDATE_CLIENT: Update completat (client inexistent)');
EXCEPTION
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('✗ Test 2 UPDATE_CLIENT: ' || SQLERRM);
END;
/

-- 4. TESTE PENTRU PROCEDURA ADD_GAME
-- Test 1: Adaugare joc valid
DECLARE
  V_PID PUBLISH.PID%TYPE;
BEGIN
  SELECT PID
    INTO V_PID
    FROM PUBLISH
   WHERE PUBLISHER_NAME = 'Test';

  PKG_STORE.ADD_GAME(
    P_NAME    => 'Test Game 1',
    P_PRICE   => 59.99,
    P_STOCK   => 100,
    P_RELEASE => DATE '2023-09-15',
    P_DESCR   => 'Latest FIFA game',
    P_PID     => V_PID
  );
  DBMS_OUTPUT.PUT_LINE('✓ Test 1 ADD_GAME: Joc adaugat cu succes');
EXCEPTION
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('✗ Test 1 ADD_GAME: ' || SQLERRM);
END;
/

-- Test 2: Data invalida
DECLARE
  V_PID PUBLISH.PID%TYPE;
BEGIN
  SELECT PID
    INTO V_PID
    FROM PUBLISH
   WHERE PUBLISHER_NAME = 'Test';

  PKG_STORE.ADD_GAME(
    P_NAME    => 'Test Game 2',
    P_PRICE   => 69.99,
    P_STOCK   => 25,
    P_RELEASE => DATE '2026-12-31',
    P_DESCR   => 'Game from the future',
    P_PID     => V_PID
  );
  DBMS_OUTPUT.PUT_LINE('✗ Test 2 ADD_GAME: Nu ar fi trebuit sa reuseasca (data viitoare)');
EXCEPTION
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('✓ Test 2 ADD_GAME: Corect - data viitoare detectata');
END;
/

-- Test 3: Nume duplicat
DECLARE
  V_PID PUBLISH.PID%TYPE;
BEGIN
  SELECT PID
    INTO V_PID
    FROM PUBLISH
   WHERE PUBLISHER_NAME = 'Test';

  PKG_STORE.ADD_GAME(
    P_NAME    => 'Test Game 1',
    P_PRICE   => 39.99,
    P_STOCK   => 25,
    P_RELEASE => DATE '2023-10-15',
    P_DESCR   => 'Another FIFA game',
    P_PID     => V_PID
  );
  DBMS_OUTPUT.PUT_LINE('✗ Test 3 ADD_GAME: Nu ar fi trebuit sa reuseasca (nume duplicat)');
EXCEPTION
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('✓ Test 3 ADD_GAME: Corect - nume duplicat detectat');
END;
/

-- 5. TESTE PENTRU PROCEDURA UPDATE_GAME
-- Test 1: Update valid
DECLARE
  V_GAME_ID GAMES.GID%TYPE;
BEGIN
  SELECT GID
    INTO V_GAME_ID
    FROM GAMES
   WHERE GAME_NAME = 'Test Game 1';

  PKG_STORE.UPDATE_GAME(
    P_GID   => V_GAME_ID,
    P_PRICE => 54.99,
    P_STOCK => 120
  );
  DBMS_OUTPUT.PUT_LINE('✓ Test 1 UPDATE_GAME: Joc actualizat cu succes');
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    DBMS_OUTPUT.PUT_LINE('✗ Test 1 UPDATE_GAME: Joc nu gasit pentru update');
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('✗ Test 1 UPDATE_GAME: ' || SQLERRM);
END;
/

-- Test 2: Update joc inexistent
BEGIN
  PKG_STORE.UPDATE_GAME(
    P_GID   => 999999,
    P_PRICE => 29.99,
    P_STOCK => 10
  );
  DBMS_OUTPUT.PUT_LINE('✓ Test 2 UPDATE_GAME: Update completat (joc inexistent)');
EXCEPTION
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('✗ Test 2 UPDATE_GAME: ' || SQLERRM);
END;
/

-- 6. TESTE PENTRU FUNCTIA GET_STOCK
-- Test 1: Get stock pentru joc existent
DECLARE
  V_STOCK   GAMES.STOCK%TYPE;
  V_GAME_ID GAMES.GID%TYPE;
BEGIN
  SELECT GID
    INTO V_GAME_ID
    FROM GAMES
   WHERE GAME_NAME = 'Test Game 1';
  V_STOCK := PKG_STORE.GET_STOCK(V_GAME_ID);
  DBMS_OUTPUT.PUT_LINE('✓ Test 1 GET_STOCK: Stoc gasit = ' || V_STOCK);
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    DBMS_OUTPUT.PUT_LINE('✗ Test 1 GET_STOCK: Joc nu gasit');
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('✗ Test 1 GET_STOCK: ' || SQLERRM);
END;
/

-- Test 2: Get stock pentru joc inexistent
DECLARE
  V_STOCK GAMES.STOCK%TYPE;
BEGIN
  V_STOCK := PKG_STORE.GET_STOCK(999999);
  DBMS_OUTPUT.PUT_LINE('✗ Test 2 GET_STOCK: Nu ar fi trebuit sa reuseasca (joc inexistent)');
EXCEPTION
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('✓ Test 2 GET_STOCK: Corect - joc inexistent detectat');
END;
/

-- 7. TESTE PENTRU PROCEDURA PLACE_ORDER
-- Test 1: Comanda valida
DECLARE
  V_CLIENT_ID CLIENTS.CID%TYPE;
  V_GAME_ID   GAMES.GID%TYPE;
BEGIN
  SELECT CID
    INTO V_CLIENT_ID
    FROM CLIENTS
   WHERE USRNME = 'testuser1updated';
  SELECT GID
    INTO V_GAME_ID
    FROM GAMES
   WHERE GAME_NAME = 'Test Game 1';

  PKG_STORE.PLACE_ORDER(
    P_CLIENT_ID => V_CLIENT_ID,
    P_GAME_ID   => V_GAME_ID,
    P_QUANTITY  => 5
  );
  DBMS_OUTPUT.PUT_LINE('✓ Test 1 PLACE_ORDER: Comanda plasata cu succes');
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    DBMS_OUTPUT.PUT_LINE('✗ Test 1 PLACE_ORDER: Client sau joc nu gasit');
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('✗ Test 1 PLACE_ORDER: ' || SQLERRM);
END;
/

-- Test 3: Cantitate mai mare decat stocul 
DECLARE
  V_CLIENT_ID CLIENTS.CID%TYPE;
  V_GAME_ID   GAMES.GID%TYPE;
BEGIN
  SELECT CID
    INTO V_CLIENT_ID
    FROM CLIENTS
   WHERE USRNME = 'testuser1updated';
  SELECT GID
    INTO V_GAME_ID
    FROM GAMES
   WHERE GAME_NAME = 'Test Game 1';

  PKG_STORE.PLACE_ORDER(
    P_CLIENT_ID => V_CLIENT_ID,
    P_GAME_ID   => V_GAME_ID,
    P_QUANTITY  => 200
  );
  DBMS_OUTPUT.PUT_LINE('✗ Test 3 PLACE_ORDER: Nu ar fi trebuit sa reuseasca (stoc insuficient)');
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    DBMS_OUTPUT.PUT_LINE('✗ Test 3 PLACE_ORDER: Client sau joc nu gasit');
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('✓ Test 3 PLACE_ORDER: Corect - stoc insuficient detectat');
END;
/

-- 8. TESTE PENTRU TRIGGER TRG_ORDERS_STOCK_CHECK
-- Test 1: Insert cu cantitate valida
DECLARE
  V_CLIENT_ID CLIENTS.CID%TYPE;
  V_GAME_ID   GAMES.GID%TYPE;
BEGIN
  SELECT CID
    INTO V_CLIENT_ID
    FROM CLIENTS
   WHERE USRNME = 'testuser1updated';
  SELECT GID
    INTO V_GAME_ID
    FROM GAMES
   WHERE GAME_NAME = 'Test Game 1';

  INSERT INTO ORDERS (
    CLIENTS_CID,
    GAMES_GID,
    GQUANTITY
  ) VALUES ( V_CLIENT_ID,
             V_GAME_ID,
             5 );
  COMMIT;
  DBMS_OUTPUT.PUT_LINE('✓ Test 1 TRIGGER: Insert cu cantitate valida reusit');
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    DBMS_OUTPUT.PUT_LINE('✗ Test 1 TRIGGER: Client sau joc nu gasit');
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('✗ Test 1 TRIGGER: ' || SQLERRM);
    ROLLBACK;
END;
/

-- Test 2: Insert cu cantitate mai mare decat stocul 
DECLARE
  V_CLIENT_ID CLIENTS.CID%TYPE;
  V_GAME_ID   GAMES.GID%TYPE;
BEGIN
  SELECT CID
    INTO V_CLIENT_ID
    FROM CLIENTS
   WHERE USRNME = 'testuser1updated';
  SELECT GID
    INTO V_GAME_ID
    FROM GAMES
   WHERE GAME_NAME = 'Test Game 1';

  INSERT INTO ORDERS (
    CLIENTS_CID,
    GAMES_GID,
    GQUANTITY
  ) VALUES ( V_CLIENT_ID,
             V_GAME_ID,
             1000 );
  COMMIT;
  DBMS_OUTPUT.PUT_LINE('✗ Test 2 TRIGGER: Nu ar fi trebuit sa reuseasca (cantitate > stoc)');
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    DBMS_OUTPUT.PUT_LINE('✗ Test 2 TRIGGER: Client sau joc nu gasit');
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('✓ Test 2 TRIGGER: Corect - cantitate > stoc detectata de trigger');
    ROLLBACK;
END;
/

-- Test 3: Update ORDERS cu cantitate valida
DECLARE
  V_ORDER_ID ORDERS.ORID%TYPE;
BEGIN
  SELECT MIN(ORID)
    INTO V_ORDER_ID
    FROM ORDERS
   WHERE CLIENTS_CID IN (
    SELECT CID
      FROM CLIENTS
     WHERE USRNME LIKE 'test%'
        OR USRNME LIKE 'admin%'
  );

  IF V_ORDER_ID IS NOT NULL THEN
    UPDATE ORDERS
       SET
      GQUANTITY = 2
     WHERE ORID = V_ORDER_ID;
    COMMIT;
    DBMS_OUTPUT.PUT_LINE('✓ Test 3 TRIGGER: Update cu cantitate valida reusit');
  ELSE
    DBMS_OUTPUT.PUT_LINE('⚠ Test 3 TRIGGER: Nu exista comenzi de actualizat');
  END IF;
EXCEPTION
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('✗ Test 3 TRIGGER: ' || SQLERRM);
    ROLLBACK;
END;
/

-- Test 4: Update ORDERS cu cantitate invalida 
DECLARE
  V_ORDER_ID ORDERS.ORID%TYPE;
BEGIN
  SELECT MIN(ORID)
    INTO V_ORDER_ID
    FROM ORDERS
   WHERE CLIENTS_CID IN (
    SELECT CID
      FROM CLIENTS
     WHERE USRNME LIKE 'test%'
        OR USRNME LIKE 'admin%'
  );

  IF V_ORDER_ID IS NOT NULL THEN
    UPDATE ORDERS
       SET
      GQUANTITY = 1000
     WHERE ORID = V_ORDER_ID;
    COMMIT;
    DBMS_OUTPUT.PUT_LINE('✗ Test 4 TRIGGER: Nu ar fi trebuit sa reuseasca (cantitate > stoc)');
  ELSE
    DBMS_OUTPUT.PUT_LINE('⚠ Test 4 TRIGGER: Nu exista comenzi de actualizat');
  END IF;
EXCEPTION
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('✓ Test 4 TRIGGER: Corect - cantitate > stoc detectata la update');
    ROLLBACK;
END;
/

-- 9. TESTE PENTRU PROCEDURA CANCEL_ORDER
-- Test 1: Anulare comanda existenta
DECLARE
  V_ORDER_ID ORDERS.ORID%TYPE;
BEGIN
  SELECT MIN(ORID)
    INTO V_ORDER_ID
    FROM ORDERS
   WHERE CLIENTS_CID IN (
    SELECT CID
      FROM CLIENTS
     WHERE USRNME LIKE 'test%'
        OR USRNME LIKE 'admin%'
  );

  IF V_ORDER_ID IS NOT NULL THEN
    PKG_STORE.CANCEL_ORDER(V_ORDER_ID);
    DBMS_OUTPUT.PUT_LINE('✓ Test 1 CANCEL_ORDER: Comanda anulata cu succes');
  ELSE
    DBMS_OUTPUT.PUT_LINE('⚠ Test 1 CANCEL_ORDER: Nu exista comenzi de anulat');
  END IF;
EXCEPTION
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('✗ Test 1 CANCEL_ORDER: ' || SQLERRM);
END;
/

-- Test 2: Anulare comanda inexistenta
BEGIN
  PKG_STORE.CANCEL_ORDER(999999);
  DBMS_OUTPUT.PUT_LINE('✗ Test 2 CANCEL_ORDER: Comanda inexistenta');
EXCEPTION
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('✓ Test 2 CANCEL_ORDER: Comanda inexistenta detectata');
END;
/

-- 10. TESTE PENTRU FUNCTIA GET_CLIENT_ORDERS
-- Test 1: Obtinere comenzi pentru client 
DECLARE
  V_CURSOR    SYS_REFCURSOR;
  V_ORDER_ID  ORDERS.ORID%TYPE;
  V_GAME_NAME GAMES.GAME_NAME%TYPE;
  V_QUANTITY  ORDERS.GQUANTITY%TYPE;
  V_PRICE     GAMES.PRICE%TYPE;
  V_TOTAL     NUMBER;
  V_COUNT     NUMBER := 0;
  V_CLIENT_ID CLIENTS.CID%TYPE;
BEGIN
  SELECT CID
    INTO V_CLIENT_ID
    FROM CLIENTS
   WHERE USRNME = 'testuser1updated';

  V_CURSOR := PKG_STORE.GET_CLIENT_ORDERS(V_CLIENT_ID);
  LOOP
    FETCH V_CURSOR INTO
      V_ORDER_ID,
      V_GAME_NAME,
      V_QUANTITY,
      V_PRICE,
      V_TOTAL;
    EXIT WHEN V_CURSOR%NOTFOUND;
    V_COUNT := V_COUNT + 1;
    DBMS_OUTPUT.PUT_LINE('  Comanda: '
                         || V_ORDER_ID
                         || ', Joc: '
                         || V_GAME_NAME
                         || ', Cantitate: '
                         || V_QUANTITY
                         || ', Total: '
                         || V_TOTAL);
  END LOOP;
  CLOSE V_CURSOR;
  IF V_COUNT > 0 THEN
    DBMS_OUTPUT.PUT_LINE('✓ Test 1 GET_CLIENT_ORDERS: '
                         || V_COUNT
                         || ' comenzi gasite');
  ELSE
    DBMS_OUTPUT.PUT_LINE('✓ Test 1 GET_CLIENT_ORDERS: Nicio comanda gasita (normal dupa anulare)');
  END IF;
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    DBMS_OUTPUT.PUT_LINE('✗ Test 1 GET_CLIENT_ORDERS: Client nu gasit');
    IF V_CURSOR%ISOPEN THEN
      CLOSE V_CURSOR;
    END IF;
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('✗ Test 1 GET_CLIENT_ORDERS: ' || SQLERRM);
    IF V_CURSOR%ISOPEN THEN
      CLOSE V_CURSOR;
    END IF;
END;
/

-- 11. TESTE PENTRU PROCEDURA DELETE_CLIENT
-- Adaugam un client pentru stergere
BEGIN
  PKG_STORE.ADD_CLIENT(
    P_USRNME  => 'deleteme',
    P_PASSWRD => 'password',
    P_PNUMBER => '0723456789',
    P_EMAIL   => 'delete@email.com',
    P_ISADM   => 0
  );
  DBMS_OUTPUT.PUT_LINE('✓ Client pentru stergere adaugat');
EXCEPTION
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('⚠ Eroare la adaugarea clientului pentru stergere: ' || SQLERRM);
END;
/

-- Test 1: Stergere client fara comenzi
DECLARE
  V_CLIENT_ID CLIENTS.CID%TYPE;
BEGIN
  SELECT CID
    INTO V_CLIENT_ID
    FROM CLIENTS
   WHERE USRNME = 'deleteme';
  PKG_STORE.DELETE_CLIENT(V_CLIENT_ID);
  DBMS_OUTPUT.PUT_LINE('✓ Test 1 DELETE_CLIENT: Client sters cu succes');
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    DBMS_OUTPUT.PUT_LINE('⚠ Test 1 DELETE_CLIENT: Client nu gasit');
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('✗ Test 1 DELETE_CLIENT: ' || SQLERRM);
END;
/

-- Test 2: Stergere client inexistent
BEGIN
  PKG_STORE.DELETE_CLIENT(999999);
  DBMS_OUTPUT.PUT_LINE('✓ Test 2 DELETE_CLIENT: Stergere completata (client inexistent)');
EXCEPTION
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('✗ Test 2 DELETE_CLIENT: ' || SQLERRM);
END;
/

-- 12. TESTE PENTRU PROCEDURA DELETE_GAME
-- Adaugam un joc pentru stergere
DECLARE
  V_PID PUBLISH.PID%TYPE;
BEGIN
  SELECT PID
    INTO V_PID
    FROM PUBLISH
   WHERE PUBLISHER_NAME = 'Test';

  PKG_STORE.ADD_GAME(
    P_NAME    => 'Delete Me Game',
    P_PRICE   => 19.99,
    P_STOCK   => 10,
    P_RELEASE => DATE '2023-01-01',
    P_DESCR   => 'Game to be deleted',
    P_PID     => V_PID
  );
  DBMS_OUTPUT.PUT_LINE('✓ Joc pentru stergere adaugat');
EXCEPTION
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('⚠ Eroare la adaugarea jocului pentru stergere: ' || SQLERRM);
END;
/

-- Test 1: Stergere joc fara comenzi
DECLARE
  V_GAME_ID GAMES.GID%TYPE;
BEGIN
  SELECT GID
    INTO V_GAME_ID
    FROM GAMES
   WHERE GAME_NAME = 'Delete Me Game';
  PKG_STORE.DELETE_GAME(V_GAME_ID);
  DBMS_OUTPUT.PUT_LINE('✓ Test 1 DELETE_GAME: Joc sters cu succes');
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    DBMS_OUTPUT.PUT_LINE('⚠ Test 1 DELETE_GAME: Joc inexistent');
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('✗ Test 1 DELETE_GAME: ' || SQLERRM);
END;
/

-- 14. CLEANUP 
DECLARE
  TYPE T_CLIENT_IDS IS
    TABLE OF CLIENTS.CID%TYPE;
  V_CLIENT_IDS T_CLIENT_IDS;
BEGIN
  SELECT CID
  BULK COLLECT
    INTO V_CLIENT_IDS
    FROM CLIENTS
   WHERE USRNME LIKE 'test%'
      OR USRNME LIKE 'admin%'
      OR USRNME = 'deleteme';

  FORALL I IN 1..V_CLIENT_IDS.COUNT
    DELETE FROM ORDERS
     WHERE CLIENTS_CID = V_CLIENT_IDS(I);

  FORALL I IN 1..V_CLIENT_IDS.COUNT
    DELETE FROM CONTACT
     WHERE CLIENTS_CID = V_CLIENT_IDS(I);

  FORALL I IN 1..V_CLIENT_IDS.COUNT
    DELETE FROM CLIENTS
     WHERE CID = V_CLIENT_IDS(I);

  DELETE FROM GAMES
   WHERE GAME_NAME LIKE 'Test Game%'
      OR GAME_NAME = 'Delete Me Game';

  DELETE FROM PUBLISH
   WHERE PUBLISHER_NAME = 'Test';

  COMMIT;
  DBMS_OUTPUT.PUT_LINE('Toate datele de test au fost sterse cu succes!');
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    DBMS_OUTPUT.PUT_LINE('✗ Eroare la cleanup: ' || SQLERRM);
END;
/