-- INSERT TEST: Add client, add publisher, add game, place order
DECLARE
  V_CLIENT_ID    CLIENTS.CID%TYPE;
  V_GAME_ID      GAMES.GID%TYPE;
  V_PUBLISHER_ID PUBLISH.PID%TYPE;
BEGIN
  SAVEPOINT INSERT_TEST;
  PKG_STORE.ADD_CLIENT(
    P_USRNME  => 'testuser1',
    P_PASSWRD => 'pass1234',
    P_PNUMBER => '0712345678',
    P_EMAIL   => 'testuser1@example.com',
    P_ISADM   => 0
  );

  SELECT CID
    INTO V_CLIENT_ID
    FROM CLIENTS
   WHERE USRNME = 'testuser1';

  INSERT INTO PUBLISH ( PUBLISHER_NAME ) VALUES ( 'Test Publisher' );

  SELECT PID
    INTO V_PUBLISHER_ID
    FROM PUBLISH
   WHERE PUBLISHER_NAME = 'Test Publisher';

  PKG_STORE.ADD_GAME(
    P_NAME    => 'CRUD_Game',
    P_PRICE   => 49.99,
    P_STOCK   => 10,
    P_RELEASE => SYSDATE - 1,
    P_DESCR   => 'Game for CRUD tests',
    P_PID     => V_PUBLISHER_ID
  );

  SELECT GID
    INTO V_GAME_ID
    FROM GAMES
   WHERE GAME_NAME = 'CRUD_Game';

  PKG_STORE.PLACE_ORDER(
    P_CLIENT_ID => V_CLIENT_ID,
    P_GAME_ID   => V_GAME_ID,
    P_QUANTITY  => 2
  );

  DBMS_OUTPUT.PUT_LINE('Insert test passed: Client, Publisher, Game, and Order added successfully.');
  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('Insert test failed - ' || SQLERRM);
    ROLLBACK TO INSERT_TEST;
END;
/

-- READ TEST: Retrieve client, game, order details
DECLARE
  V_USERNAME   CLIENTS.USRNME%TYPE;
  V_GAME_NAME  GAMES.GAME_NAME%TYPE;
  V_QUANTITY   ORDERS.GQUANTITY%TYPE;
  V_GAME_STOCK GAMES.STOCK%TYPE;
  V_GAME_PRICE GAMES.PRICE%TYPE;
BEGIN
  SELECT USRNME
    INTO V_USERNAME
    FROM CLIENTS
   WHERE USRNME = 'testuser1';

  SELECT GAME_NAME,
         PRICE,
         STOCK
    INTO
    V_GAME_NAME,
    V_GAME_PRICE,
    V_GAME_STOCK
    FROM GAMES
   WHERE GAME_NAME = 'CRUD_Game';

  SELECT GQUANTITY
    INTO V_QUANTITY
    FROM ORDERS
   WHERE CLIENTS_CID = (
      SELECT CID
        FROM CLIENTS
       WHERE USRNME = 'testuser1'
    )
     AND GAMES_GID = (
    SELECT GID
      FROM GAMES
     WHERE GAME_NAME = 'CRUD_Game'
  );

  DBMS_OUTPUT.PUT_LINE('Read test passed:');
  DBMS_OUTPUT.PUT_LINE('   Client Username = ' || V_USERNAME);
  DBMS_OUTPUT.PUT_LINE('   Game Name = ' || V_GAME_NAME);
  DBMS_OUTPUT.PUT_LINE('   Game STOCK = ' || V_GAME_STOCK);
  DBMS_OUTPUT.PUT_LINE('   Game PRICE = ' || V_GAME_PRICE);
  DBMS_OUTPUT.PUT_LINE('   Order Quantity = ' || V_QUANTITY);
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    DBMS_OUTPUT.PUT_LINE('Read test failed: Data not found.');
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('Read test failed - ' || SQLERRM);
END;
/

-- UPDATE TEST: Increase game stock, change game price
DECLARE
  V_GAME_ID    GAMES.GID%TYPE;
  V_GAME_NAME  GAMES.GAME_NAME%TYPE;
  V_GAME_STOCK GAMES.STOCK%TYPE;
  V_GAME_PRICE GAMES.PRICE%TYPE;
BEGIN
  SAVEPOINT UPDATE_TEST;
  SELECT GID,
         STOCK,
         PRICE
    INTO
    V_GAME_ID,
    V_GAME_STOCK,
    V_GAME_PRICE
    FROM GAMES
   WHERE GAME_NAME = 'CRUD_Game';

  UPDATE GAMES
     SET STOCK = V_GAME_STOCK + 5,
         PRICE = V_GAME_PRICE + 2
   WHERE GID = V_GAME_ID;

  COMMIT;
  SELECT GID,
         GAME_NAME,
         STOCK,
         PRICE
    INTO
    V_GAME_ID,
    V_GAME_NAME,
    V_GAME_STOCK,
    V_GAME_PRICE
    FROM GAMES
   WHERE GAME_NAME = 'CRUD_Game';

  DBMS_OUTPUT.PUT_LINE('Update test passed: Stock and price updated for CRUD_Game.');
  DBMS_OUTPUT.PUT_LINE('   Game Name = ' || V_GAME_NAME);
  DBMS_OUTPUT.PUT_LINE('   Game STOCK = ' || V_GAME_STOCK);
  DBMS_OUTPUT.PUT_LINE('   Game PRICE = ' || V_GAME_PRICE);
EXCEPTION
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('Update test failed - ' || SQLERRM);
    ROLLBACK TO UPDATE_TEST;
END;
/

-- DELETE TEST: Cancel order, delete game, client, and publisher
DECLARE
  V_ORDER_ID     ORDERS.ORID%TYPE;
  V_CLIENT_ID    CLIENTS.CID%TYPE;
  V_GAME_ID      GAMES.GID%TYPE;
  V_PUBLISHER_ID PUBLISH.PID%TYPE;
BEGIN
  SAVEPOINT DELETE_TEST;
  SELECT ORID
    INTO V_ORDER_ID
    FROM ORDERS
   WHERE CLIENTS_CID = (
      SELECT CID
        FROM CLIENTS
       WHERE USRNME = 'testuser1'
    )
     AND GAMES_GID = (
    SELECT GID
      FROM GAMES
     WHERE GAME_NAME = 'CRUD_Game'
  );

  PKG_STORE.CANCEL_ORDER(V_ORDER_ID);
  SELECT CID
    INTO V_CLIENT_ID
    FROM CLIENTS
   WHERE USRNME = 'testuser1';

  DELETE FROM CONTACT
   WHERE CLIENTS_CID = V_CLIENT_ID;

  DELETE FROM CLIENTS
   WHERE CID = V_CLIENT_ID;

  SELECT GID
    INTO V_GAME_ID
    FROM GAMES
   WHERE GAME_NAME = 'CRUD_Game';

  DELETE FROM GAMES
   WHERE GID = V_GAME_ID;

  SELECT PID
    INTO V_PUBLISHER_ID
    FROM PUBLISH
   WHERE PUBLISHER_NAME = 'Test Publisher';

  DELETE FROM PUBLISH
   WHERE PID = V_PUBLISHER_ID;

  COMMIT;
  DBMS_OUTPUT.PUT_LINE('Delete test passed: Order cancelled, client, game, and publisher removed.');
EXCEPTION
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('Delete test failed - ' || SQLERRM);
    ROLLBACK TO DELETE_TEST;
END;
/

-- TEST 1: Invalid username 
BEGIN
  SAVEPOINT TEST1;
  PKG_STORE.ADD_CLIENT(
    'invalid@user',
    'Password123',
    '0741414141',
    'example@exmp.ro',
    0
  );
  DBMS_OUTPUT.PUT_LINE('Test 1 Failed: Username format accepted incorrectly.');
  ROLLBACK TO TEST1;
EXCEPTION
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('Test 1 Passed: Caught invalid username - ' || SQLERRM);
    ROLLBACK TO TEST1;
END;
/

-- TEST 2: Invalid password
BEGIN
  SAVEPOINT TEST2;
  PKG_STORE.ADD_CLIENT(
    'validuser2',
    'pass@word',
    '0712123123',
    'mail@mail.com',
    0
  );
  DBMS_OUTPUT.PUT_LINE('Test 2 Failed: Password format accepted incorrectly.');
  ROLLBACK TO TEST2;
EXCEPTION
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('Test 2 Passed: Caught invalid password - ' || SQLERRM);
    ROLLBACK TO TEST2;
END;
/

-- TEST 3: Duplicate username check
DECLARE
  V_USERNAME VARCHAR2(20) := 'duplicateuser';
BEGIN
  SAVEPOINT TEST3;
  INSERT INTO CLIENTS (
    USRNME,
    PASSWRD,
    ISADM
  ) VALUES ( V_USERNAME,
             'parola1234',
             0 );

  INSERT INTO CLIENTS (
    USRNME,
    PASSWRD,
    ISADM
  ) VALUES ( V_USERNAME,
             'parola1235',
             1 );

  DBMS_OUTPUT.PUT_LINE('Test 3 Failed: Duplicate username allowed.');
  ROLLBACK TO TEST3;
EXCEPTION
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('Test 3 Passed: Caught duplicate username - ' || SQLERRM);
    ROLLBACK TO TEST3;
END;
/

-- TEST 4: Order exceeding stock
DECLARE
  V_CLIENT_ID    CLIENTS.CID%TYPE;
  V_GAME_ID      GAMES.GID%TYPE;
  V_PUBLISHER_ID PUBLISH.PID%TYPE;
BEGIN
  INSERT INTO PUBLISH ( PUBLISHER_NAME ) VALUES ( 'Test Publisher' );

  SELECT PID
    INTO V_PUBLISHER_ID
    FROM PUBLISH
   WHERE PUBLISHER_NAME = 'Test Publisher';

  PKG_STORE.ADD_CLIENT(
    'orderuser',
    'Order123',
    '0712123126',
    'mail6@mail.com',
    0
  );
  SELECT CID
    INTO V_CLIENT_ID
    FROM CLIENTS
   WHERE USRNME = 'orderuser';

  PKG_STORE.ADD_GAME(
    'TestGame',
    50,
    3,
    SYSDATE - 1,
    'Demo game',
    V_PUBLISHER_ID
  );

  SELECT GID
    INTO V_GAME_ID
    FROM GAMES
   WHERE GAME_NAME = 'TestGame';

  PKG_STORE.PLACE_ORDER(
    V_CLIENT_ID,
    V_GAME_ID,
    10
  );
  DBMS_OUTPUT.PUT_LINE('Test 4 Failed: Order exceeding stock was accepted.');
EXCEPTION
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('Test 4 Passed: Caught excessive order quantity - ' || SQLERRM);
    ROLLBACK;
END;
/

-- TEST 5: Adding a unreleased game
BEGIN
  SAVEPOINT TEST5;
  PKG_STORE.ADD_GAME(
    'FutureGame',
    60,
    5,
    SYSDATE + 10,
    'Game from the future',
    1
  );

  DBMS_OUTPUT.PUT_LINE('Test 5 Failed: Future release date accepted.');
  ROLLBACK TO TEST5;
EXCEPTION
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('Test 5 Passed: Caught future release date - ' || SQLERRM);
    ROLLBACK TO TEST5;
END;
/

-- Clean Up after Tests
BEGIN
  DELETE FROM ORDERS
   WHERE GAMES_GID IN (
    SELECT GID
      FROM GAMES
     WHERE GAME_NAME IN ( 'CRUD_Game',
                          'TestGame',
                          'FutureGame' )
  )
      OR CLIENTS_CID IN (
    SELECT CID
      FROM CLIENTS
     WHERE USRNME IN ( 'testuser1',
                       'duplicateuser',
                       'validuser2',
                       'invalid@user',
                       'orderuser' )
  );

  DELETE FROM GAMES
   WHERE GAME_NAME IN ( 'CRUD_Game',
                        'TestGame',
                        'FutureGame' );

  DELETE FROM PUBLISH
   WHERE PUBLISHER_NAME IN ( 'Test Publisher' );

  DELETE FROM CONTACT
   WHERE CLIENTS_CID IN (
    SELECT CID
      FROM CLIENTS
     WHERE USRNME IN ( 'testuser1',
                       'duplicateuser',
                       'validuser2',
                       'invalid@user',
                       'orderuser' )
  );

  DELETE FROM CLIENTS
   WHERE USRNME IN ( 'testuser1',
                     'duplicateuser',
                     'validuser2',
                     'invalid@user',
                     'orderuser' );

  COMMIT;
  DBMS_OUTPUT.PUT_LINE('Full cleanup completed: All test data removed.');
EXCEPTION
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('Cleanup failed - ' || SQLERRM);
    ROLLBACK;
END;
/