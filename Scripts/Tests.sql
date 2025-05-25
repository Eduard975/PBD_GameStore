   SET SERVEROUTPUT ON;

-- INSERT TEST: Add client, add game, place order
DECLARE
   v_client_id NUMBER;
   v_game_id   NUMBER;
BEGIN
   SAVEPOINT insert_test;
   pkg_shop.add_client(
      'testusercrud',
      'Password1',
      '0741414141',
      'test@example.ro',
      0
   );
   SELECT MAX(cid)
     INTO v_client_id
     FROM clients
    WHERE usrnme = 'testusercrud';

   pkg_shop.add_game(
      'CRUD_Game',
      49.99,
      10,
      sysdate - 1,
      'Game for CRUD tests',
      1
   );
   SELECT MAX(gid)
     INTO v_game_id
     FROM games
    WHERE game_name = 'CRUD_Game';

   pkg_shop.place_order(
      v_client_id,
      v_game_id,
      2
   );
   dbms_output.put_line('Insert test passed: Client, Game, and Order added successfully.');
   COMMIT;
EXCEPTION
   WHEN OTHERS THEN
      dbms_output.put_line('Insert test failed - ' || sqlerrm);
      ROLLBACK TO insert_test;
END;
/
-- READ TEST: Retrieve client, game, order details
DECLARE
   v_username   clients.usrnme%TYPE;
   v_game_name  games.game_name%TYPE;
   v_quantity   orders.gquantity%TYPE;
   v_game_stock games.stock%TYPE;
   v_game_price games.price%TYPE;
BEGIN
   SELECT usrnme
     INTO v_username
     FROM clients
    WHERE usrnme = 'testusercrud';

   SELECT game_name,
          price,
          stock
     INTO
      v_game_name,
      v_game_price,
      v_game_stock
     FROM games
    WHERE game_name = 'CRUD_Game';

   SELECT gquantity
     INTO v_quantity
     FROM orders
    WHERE clients_cid = (
         SELECT cid
           FROM clients
          WHERE usrnme = 'testusercrud'
      )
      AND games_gid = (
      SELECT gid
        FROM games
       WHERE game_name = 'CRUD_Game'
   );

   dbms_output.put_line('Read test passed:');
   dbms_output.put_line('   Client Username = ' || v_username);
   dbms_output.put_line('   Game Name = ' || v_game_name);
   dbms_output.put_line('   Game STOCK = ' || v_game_stock);
   dbms_output.put_line('   Game PRICE = ' || v_game_price);
   dbms_output.put_line('   Order Quantity = ' || v_quantity);
EXCEPTION
   WHEN no_data_found THEN
      dbms_output.put_line('Read test failed: Data not found.');
   WHEN OTHERS THEN
      dbms_output.put_line('Read test failed - ' || sqlerrm);
END;
/

-- UPDATE TEST: Increase game stock, change game price
DECLARE
   v_game_id    games.gid%TYPE;
   v_game_name  games.game_name%TYPE;
   v_game_stock games.stock%TYPE;
   v_game_price games.price%TYPE;
BEGIN
   SAVEPOINT update_test;
   SELECT gid,
          stock,
          price
     INTO
      v_game_id,
      v_game_stock,
      v_game_price
     FROM games
    WHERE game_name = 'CRUD_Game';

   UPDATE games
      SET stock = v_game_stock + 5,
          price = v_game_price + 2
    WHERE gid = v_game_id;

   COMMIT;
   SELECT gid,
          game_name,
          stock,
          price
     INTO
      v_game_id,
      v_game_name,
      v_game_stock,
      v_game_price
     FROM games
    WHERE game_name = 'CRUD_Game';

   dbms_output.put_line('Update test passed: Stock and price updated for CRUD_Game.');
   dbms_output.put_line('   Game Name = ' || v_game_name);
   dbms_output.put_line('   Game STOCK = ' || v_game_stock);
   dbms_output.put_line('   Game PRICE = ' || v_game_price);
EXCEPTION
   WHEN OTHERS THEN
      dbms_output.put_line('Update test failed - ' || sqlerrm);
      ROLLBACK TO update_test;
END;
/
-- DELETE TEST: Cancel order, delete game and client
DECLARE
   v_order_id  orders.orid%TYPE;
   v_client_id clients.cid%TYPE;
   v_game_id   games.gid%TYPE;
BEGIN
   SAVEPOINT delete_test;
   SELECT orid
     INTO v_order_id
     FROM orders
    WHERE clients_cid = (
         SELECT cid
           FROM clients
          WHERE usrnme = 'testusercrud'
      )
      AND games_gid = (
      SELECT gid
        FROM games
       WHERE game_name = 'CRUD_Game'
   );

   pkg_shop.cancel_order(v_order_id);
   SELECT cid
     INTO v_client_id
     FROM clients
    WHERE usrnme = 'testusercrud';
   DELETE FROM clients
    WHERE cid = v_client_id;

   SELECT gid
     INTO v_game_id
     FROM games
    WHERE game_name = 'CRUD_Game';
   DELETE FROM games
    WHERE gid = v_game_id;

   COMMIT;
   dbms_output.put_line('Delete test passed: Order cancelled, client and game removed.');
EXCEPTION
   WHEN OTHERS THEN
      dbms_output.put_line('Delete test failed - ' || sqlerrm);
      ROLLBACK TO delete_test;
END;
/

-- TEST 1: Invalid username 
BEGIN
   SAVEPOINT test1;
   pkg_shop.add_client(
      'invalid@user',
      'Password123',
      '0741414141',
      'example@exmp.ro',
      0
   );
   dbms_output.put_line('Test 1 Failed: Username format accepted incorrectly.');
   ROLLBACK TO test1;
EXCEPTION
   WHEN OTHERS THEN
      dbms_output.put_line('Test 1 Passed: Caught invalid username - ' || sqlerrm);
      ROLLBACK TO test1;
END;
/

-- TEST 2: Invalid password
BEGIN
   SAVEPOINT test2;
   pkg_shop.add_client(
      'validuser2',
      'pass@word',
      0
   );
   dbms_output.put_line('Test 2 Failed: Password format accepted incorrectly.');
   ROLLBACK TO test2;
EXCEPTION
   WHEN OTHERS THEN
      dbms_output.put_line('Test 2 Passed: Caught invalid password - ' || sqlerrm);
      ROLLBACK TO test2;
END;
/

-- TEST 3: Duplicate username check
DECLARE
   v_username VARCHAR2(20) := 'duplicateuser';
BEGIN
   SAVEPOINT test3;
   pkg_shop.add_client(
      v_username,
      'Valid123',
      0
   );
   pkg_shop.add_client(
      v_username,
      'Valid123',
      0
   );
   dbms_output.put_line('Test 3 Failed: Duplicate username allowed.');
   ROLLBACK TO test3;
EXCEPTION
   WHEN OTHERS THEN
      dbms_output.put_line('Test 3 Passed: Caught duplicate username - ' || sqlerrm);
      ROLLBACK TO test3;
END;
/

-- TEST 4: Order exceeding stock
DECLARE
   v_client_id NUMBER;
   v_game_id   NUMBER;
BEGIN
   SAVEPOINT test4;
   pkg_shop.add_client(
      'orderuser',
      'Order123',
      0
   );
   SELECT MAX(cid)
     INTO v_client_id
     FROM clients;

   pkg_shop.add_game(
      'TestGame',
      50,
      3,
      sysdate - 1,
      'Demo game',
      1
   );

   SELECT MAX(gid)
     INTO v_game_id
     FROM games;

   pkg_shop.place_order(
      v_client_id,
      v_game_id,
      10
   );
   dbms_output.put_line('Test 4 Failed: Order exceeding stock was accepted.');
   ROLLBACK TO test4;
EXCEPTION
   WHEN OTHERS THEN
      dbms_output.put_line('Test 4 Passed: Caught excessive order quantity - ' || sqlerrm);
      ROLLBACK TO test4;
END;
/

-- TEST 5: Adding a unreleased game
BEGIN
   SAVEPOINT test5;
   pkg_shop.add_game(
      'FutureGame',
      60,
      5,
      sysdate + 10,
      'Game from the future',
      1
   );

   dbms_output.put_line('Test 5 Failed: Future release date accepted.');
   ROLLBACK TO test5;
EXCEPTION
   WHEN OTHERS THEN
      dbms_output.put_line('Test 5 Passed: Caught future release date - ' || sqlerrm);
      ROLLBACK TO test5;
END;
/

-- TEST 6: Cancelling a non-existent order
BEGIN
   SAVEPOINT test6;
   pkg_shop.cancel_order(9999);
   dbms_output.put_line('Test 6 Failed: Non-existent order cancelled.');
   ROLLBACK TO test6;
EXCEPTION
   WHEN OTHERS THEN
      dbms_output.put_line('Test 6 Passed: Caught invalid order cancellation - ' || sqlerrm);
      ROLLBACK TO test6;
END;
/

-- Clean up
BEGIN
   DELETE FROM orders
    WHERE games_gid IN (
      SELECT gid
        FROM games
       WHERE game_name IN ( 'TestGame',
                            'TriggerGame',
                            'FutureGame' )
   );
   DELETE FROM games
    WHERE game_name IN ( 'TestGame',
                         'TriggerGame',
                         'FutureGame' );
   DELETE FROM clients
    WHERE usrnme IN ( 'duplicateuser',
                      'validuser2',
                      'invalid@user',
                      'orderuser',
                      'triggeruser' );
   COMMIT;
   dbms_output.put_line('Cleanup complete.');
END;
/