-- Insert Publishers
INSERT INTO publish ( publisher_name ) VALUES ( 'Ubisoft' );
INSERT INTO publish ( publisher_name ) VALUES ( 'Electronic Arts' );
INSERT INTO publish ( publisher_name ) VALUES ( 'Rockstar Games' );
INSERT INTO publish ( publisher_name ) VALUES ( 'CD Projekt' );
   INSERT INTO publish ( publisher_name ) VALUES ( 'Bethesda' );
/
COMMIT;
/

-- Insert Clients
BEGIN
   pkg_store.add_client(
      'alice01',
      'pass123',
      '0712345678',
      'alice01@email.com',
      0
   );
   pkg_store.add_client(
      'bob92',
      'secure456',
      '0723456789',
      'bob92@email.com',
      0
   );
   pkg_store.add_client(
      'charlie',
      'char789',
      '0734567890',
      'charlie@email.com',
      1
   );
   pkg_store.add_client(
      'dana',
      'dana321',
      '0745678901',
      'dana@email.com',
      0
   );
   pkg_store.add_client(
      'eva',
      'evapass',
      '0756789012',
      'eva@email.com',
      0
   );
   pkg_store.add_client(
      'frank',
      'frank77',
      '0767890123',
      'frank@email.com',
      0
   );
   pkg_store.add_client(
      'gina',
      'gina456',
      '0778901234',
      'gina@email.com',
      0
   );
   pkg_store.add_client(
      'harry',
      'hpass88',
      '0789012345',
      'harry@email.com',
      0
   );
   pkg_store.add_client(
      'irene',
      'ipass99',
      '0790123456',
      'irene@email.com',
      0
   );
   pkg_store.add_client(
      'johnny',
      'jpass00',
      '0701234567',
      'johnny@email.com',
      0
   );
   COMMIT;
END;
/

-- Insert Games
BEGIN
   pkg_store.add_game(
      'Assassin''s Creed',
      60,
      15,
      TO_DATE('2018-11-10',
                      'YYYY-MM-DD'),
      'Action-adventure game.',
      1
   );
   pkg_store.add_game(
      'FIFA 22',
      50,
      20,
      TO_DATE('2021-10-01',
                      'YYYY-MM-DD'),
      'Football simulator.',
      2
   );
   pkg_store.add_game(
      'GTA V',
      40,
      25,
      TO_DATE('2015-04-14',
                      'YYYY-MM-DD'),
      'Open world crime game.',
      3
   );
   pkg_store.add_game(
      'The Witcher 3',
      45,
      30,
      TO_DATE('2015-05-19',
                      'YYYY-MM-DD'),
      'Fantasy RPG.',
      4
   );
   pkg_store.add_game(
      'Skyrim',
      35,
      12,
      TO_DATE('2011-11-11',
                      'YYYY-MM-DD'),
      'Elder Scrolls adventure.',
      5
   );
   pkg_store.add_game(
      'Watch Dogs',
      30,
      10,
      TO_DATE('2014-05-27',
                      'YYYY-MM-DD'),
      'Hack the system.',
      1
   );
   pkg_store.add_game(
      'Battlefield V',
      55,
      14,
      TO_DATE('2018-11-20',
                      'YYYY-MM-DD'),
      'WW2 FPS.',
      2
   );
   pkg_store.add_game(
      'Red Dead Redemption 2',
      60,
      18,
      TO_DATE('2018-10-26',
                      'YYYY-MM-DD'),
      'Western epic.',
      3
   );
   pkg_store.add_game(
      'Cyberpunk 2077',
      65,
      20,
      TO_DATE('2020-12-10',
                      'YYYY-MM-DD'),
      'Dystopian future RPG.',
      4
   );
   pkg_store.add_game(
      'DOOM Eternal',
      50,
      17,
      TO_DATE('2020-03-20',
                      'YYYY-MM-DD'),
      'Fast-paced shooter.',
      5
   );
END;
/
COMMIT;
/

-- Insert Orders
BEGIN
   pkg_store.place_order(
      1,
      1,
      2
   );
   pkg_store.place_order(
      2,
      3,
      1
   );
   pkg_store.place_order(
      3,
      4,
      3
   );
   pkg_store.place_order(
      4,
      2,
      1
   );
   pkg_store.place_order(
      5,
      5,
      2
   );
   pkg_store.place_order(
      6,
      6,
      1
   );
   pkg_store.place_order(
      7,
      7,
      2
   );
   pkg_store.place_order(
      8,
      8,
      1
   );
   pkg_store.place_order(
      9,
      9,
      2
   );
   pkg_store.place_order(
      10,
      10,
      1
   );
   pkg_store.place_order(
      1,
      3,
      1
   );
   pkg_store.place_order(
      2,
      4,
      2
   );
END;
/
COMMIT;
/