   SET SERVEROUTPUT ON;

-- ======================================================
-- INSERT TEST: Add client, add game, place order
-- ======================================================
DECLARE
  V_CLIENT_ID NUMBER;
  V_GAME_ID   NUMBER;
BEGIN
  SAVEPOINT INSERT_TEST;
  PKG_SHOP.ADD_CLIENT(
    'testusercrud',
    'Password1',
    0
  );
  SELECT MAX(CID)
    INTO V_CLIENT_ID
    FROM CLIENTS
   WHERE USRNME = 'testusercrud';

  PKG_SHOP.ADD_GAME(
    'CRUD_Game',
    49.99,
    10,
    SYSDATE - 1,
    'Game for CRUD tests',
    1
  );
  SELECT MAX(GID)
    INTO V_GAME_ID
    FROM GAMES
   WHERE GAME_NAME = 'CRUD_Game';

  PKG_SHOP.PLACE_ORDER(
    V_CLIENT_ID,
    V_GAME_ID,
    2
  );
  DBMS_OUTPUT.PUT_LINE('✅ Insert test passed: Client, Game, and Order added successfully.');
  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('❌ Insert test failed - ' || SQLERRM);
    ROLLBACK TO INSERT_TEST;
END;
/
-- ======================================================
-- READ TEST: Retrieve client, game, order details
-- ======================================================
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
   WHERE USRNME = 'testusercrud';

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
       WHERE USRNME = 'testusercrud'
    )
     AND GAMES_GID = (
    SELECT GID
      FROM GAMES
     WHERE GAME_NAME = 'CRUD_Game'
  );

  DBMS_OUTPUT.PUT_LINE('✅ Read test passed:');
  DBMS_OUTPUT.PUT_LINE('   Client Username = ' || V_USERNAME);
  DBMS_OUTPUT.PUT_LINE('   Game Name = ' || V_GAME_NAME);
  DBMS_OUTPUT.PUT_LINE('   Game STOCK = ' || V_GAME_STOCK);
  DBMS_OUTPUT.PUT_LINE('   Game PRICE = ' || V_GAME_PRICE);
  DBMS_OUTPUT.PUT_LINE('   Order Quantity = ' || V_QUANTITY);
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    DBMS_OUTPUT.PUT_LINE('❌ Read test failed: Data not found.');
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('❌ Read test failed - ' || SQLERRM);
END;
/

-- ======================================================
-- UPDATE TEST: Increase game stock, change game price
-- ======================================================
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

  DBMS_OUTPUT.PUT_LINE('✅ Update test passed: Stock and price updated for CRUD_Game.');
  DBMS_OUTPUT.PUT_LINE('   Game Name = ' || V_GAME_NAME);
  DBMS_OUTPUT.PUT_LINE('   Game STOCK = ' || V_GAME_STOCK);
  DBMS_OUTPUT.PUT_LINE('   Game PRICE = ' || V_GAME_PRICE);
EXCEPTION
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('❌ Update test failed - ' || SQLERRM);
    ROLLBACK TO UPDATE_TEST;
END;
/
-- ======================================================
-- DELETE TEST: Cancel order, delete game and client
-- ======================================================
DECLARE
  V_ORDER_ID  ORDERS.ORID%TYPE;
  V_CLIENT_ID CLIENTS.CID%TYPE;
  V_GAME_ID   GAMES.GID%TYPE;
BEGIN
  SAVEPOINT DELETE_TEST;
  SELECT ORID
    INTO V_ORDER_ID
    FROM ORDERS
   WHERE CLIENTS_CID = (
      SELECT CID
        FROM CLIENTS
       WHERE USRNME = 'testusercrud'
    )
     AND GAMES_GID = (
    SELECT GID
      FROM GAMES
     WHERE GAME_NAME = 'CRUD_Game'
  );

  PKG_SHOP.CANCEL_ORDER(V_ORDER_ID);
  SELECT CID
    INTO V_CLIENT_ID
    FROM CLIENTS
   WHERE USRNME = 'testusercrud';
  DELETE FROM CLIENTS
   WHERE CID = V_CLIENT_ID;

  SELECT GID
    INTO V_GAME_ID
    FROM GAMES
   WHERE GAME_NAME = 'CRUD_Game';
  DELETE FROM GAMES
   WHERE GID = V_GAME_ID;

  COMMIT;
  DBMS_OUTPUT.PUT_LINE('✅ Delete test passed: Order cancelled, client and game removed.');
EXCEPTION
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('❌ Delete test failed - ' || SQLERRM);
    ROLLBACK TO DELETE_TEST;
END;
/

-- ======================================================
-- TEST 1: Invalid username format (contains special char)
-- ======================================================
BEGIN
  SAVEPOINT TEST1;
  PKG_SHOP.ADD_CLIENT(
    'invalid@user',
    'Password123',
    0
  );
  DBMS_OUTPUT.PUT_LINE('❌ Test 1 Failed: Username format accepted incorrectly.');
  ROLLBACK TO TEST1;
EXCEPTION
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('✅ Test 1 Passed: Caught invalid username - ' || SQLERRM);
    ROLLBACK TO TEST1;
END;
/

-- ======================================================
-- TEST 2: Invalid password format (contains special char)
-- ======================================================
BEGIN
  SAVEPOINT TEST2;
  PKG_SHOP.ADD_CLIENT(
    'validuser2',
    'pass@word',
    0
  );
  DBMS_OUTPUT.PUT_LINE('❌ Test 2 Failed: Password format accepted incorrectly.');
  ROLLBACK TO TEST2;
EXCEPTION
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('✅ Test 2 Passed: Caught invalid password - ' || SQLERRM);
    ROLLBACK TO TEST2;
END;
/

-- ======================================================
-- TEST 3: Duplicate username check
-- ======================================================
DECLARE
  V_USERNAME VARCHAR2(20) := 'duplicateuser';
BEGIN
  SAVEPOINT TEST3;
  PKG_SHOP.ADD_CLIENT(
    V_USERNAME,
    'Valid123',
    0
  );
  PKG_SHOP.ADD_CLIENT(
    V_USERNAME,
    'Valid123',
    0
  );
  DBMS_OUTPUT.PUT_LINE('❌ Test 3 Failed: Duplicate username allowed.');
  ROLLBACK TO TEST3;
EXCEPTION
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('✅ Test 3 Passed: Caught duplicate username - ' || SQLERRM);
    ROLLBACK TO TEST3;
END;
/

-- ======================================================
-- TEST 4: Order exceeding stock
-- ======================================================
DECLARE
  V_CLIENT_ID NUMBER;
  V_GAME_ID   NUMBER;
BEGIN
  SAVEPOINT TEST4;

  -- Add client
  PKG_SHOP.ADD_CLIENT(
    'orderuser',
    'Order123',
    0
  );
  SELECT MAX(CID)
    INTO V_CLIENT_ID
    FROM CLIENTS;

  PKG_SHOP.ADD_GAME(
    'TestGame',
    50,
    3,
    SYSDATE - 1,
    'Demo game',
    1
  );

  SELECT MAX(GID)
    INTO V_GAME_ID
    FROM GAMES;

  PKG_SHOP.PLACE_ORDER(
    V_CLIENT_ID,
    V_GAME_ID,
    10
  );
  DBMS_OUTPUT.PUT_LINE('❌ Test 4 Failed: Order exceeding stock was accepted.');
  ROLLBACK TO TEST4;
EXCEPTION
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('✅ Test 4 Passed: Caught excessive order quantity - ' || SQLERRM);
    ROLLBACK TO TEST4;
END;
/

-- ======================================================
-- TEST 5: Adding a game with future release date
-- ======================================================
BEGIN
  SAVEPOINT TEST5;
  PKG_SHOP.ADD_GAME(
    'FutureGame',
    60,
    5,
    SYSDATE + 10,
    'Game from the future',
    1
  );

  DBMS_OUTPUT.PUT_LINE('❌ Test 5 Failed: Future release date accepted.');
  ROLLBACK TO TEST5;
EXCEPTION
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('✅ Test 5 Passed: Caught future release date - ' || SQLERRM);
    ROLLBACK TO TEST5;
END;
/

-- ======================================================
-- TEST 6: Cancelling a non-existent order
-- ======================================================
BEGIN
  SAVEPOINT TEST6;
  PKG_SHOP.CANCEL_ORDER(9999);
  DBMS_OUTPUT.PUT_LINE('❌ Test 6 Failed: Non-existent order cancelled.');
  ROLLBACK TO TEST6;
EXCEPTION
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('✅ Test 6 Passed: Caught invalid order cancellation - ' || SQLERRM);
    ROLLBACK TO TEST6;
END;
/

-- ======================================================
-- TEST 7: Trigger on ORDER blocks stock overflow
-- ======================================================
DECLARE
  V_CLIENT_ID NUMBER;
  V_GAME_ID   NUMBER;
BEGIN
  SAVEPOINT TEST7;
  PKG_SHOP.ADD_CLIENT(
    'triggeruser',
    'Trigger123',
    0
  );
  SELECT MAX(CID)
    INTO V_CLIENT_ID
    FROM CLIENTS;

  PKG_SHOP.ADD_GAME(
    'TriggerGame',
    80,
    2,
    SYSDATE,
    'Trigger test game',
    1
  );
  SELECT MAX(GID)
    INTO V_GAME_ID
    FROM GAMES;

  INSERT INTO ORDERS (
    CLIENTS_CID,
    GAMES_GID,
    GQUANTITY
  ) VALUES ( V_CLIENT_ID,
             V_GAME_ID,
             10 ); -- exceeds stock

  DBMS_OUTPUT.PUT_LINE('❌ Test 7 Failed: Trigger did not prevent stock overflow.');
  ROLLBACK TO TEST7;
EXCEPTION
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('✅ Test 7 Passed: Trigger prevented stock overflow - ' || SQLERRM);
    ROLLBACK TO TEST7;
END;
/

-- ======================================================
-- Clean up test entries (if any committed)
-- ======================================================
BEGIN
  DELETE FROM ORDERS
   WHERE GAMES_GID IN (
    SELECT GID
      FROM GAMES
     WHERE GAME_NAME IN ( 'TestGame',
                          'TriggerGame',
                          'FutureGame' )
  );
  DELETE FROM GAMES
   WHERE GAME_NAME IN ( 'TestGame',
                        'TriggerGame',
                        'FutureGame' );
  DELETE FROM CLIENTS
   WHERE USRNME IN ( 'duplicateuser',
                     'validuser2',
                     'invalid@user',
                     'orderuser',
                     'triggeruser' );
  COMMIT;
  DBMS_OUTPUT.PUT_LINE('✅ Cleanup complete.');
END;
/