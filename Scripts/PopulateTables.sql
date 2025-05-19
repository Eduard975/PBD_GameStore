-- Insert Publishers
INSERT INTO PUBLISH ( PUBLISHER_NAME ) VALUES ( 'Ubisoft' );
INSERT INTO PUBLISH ( PUBLISHER_NAME ) VALUES ( 'Electronic Arts' );
INSERT INTO PUBLISH ( PUBLISHER_NAME ) VALUES ( 'Rockstar Games' );
INSERT INTO PUBLISH ( PUBLISHER_NAME ) VALUES ( 'CD Projekt' );
  INSERT INTO PUBLISH ( PUBLISHER_NAME ) VALUES ( 'Bethesda' );
/
COMMIT;
/
-- Insert Clients
BEGIN
  PKG_SHOP.ADD_CLIENT(
    'alice01',
    'pass123',
    0
  );
  PKG_SHOP.ADD_CLIENT(
    'bob92',
    'secure456',
    0
  );
  PKG_SHOP.ADD_CLIENT(
    'charlie',
    'char789',
    1
  );
  PKG_SHOP.ADD_CLIENT(
    'dana',
    'dana321',
    0
  );
  PKG_SHOP.ADD_CLIENT(
    'eva',
    'evapass',
    0
  );
  PKG_SHOP.ADD_CLIENT(
    'frank',
    'frank77',
    0
  );
  PKG_SHOP.ADD_CLIENT(
    'gina',
    'gina456',
    0
  );
  PKG_SHOP.ADD_CLIENT(
    'harry',
    'hpass88',
    0
  );
  PKG_SHOP.ADD_CLIENT(
    'irene',
    'ipass99',
    0
  );
  PKG_SHOP.ADD_CLIENT(
    'johnny',
    'jpass00',
    0
  );
END;
/
COMMIT;
/
-- Insert Contact Info
INSERT INTO CONTACT VALUES ( 1,
                             '0712345678',
                             'alice01@email.com' );
INSERT INTO CONTACT VALUES ( 2,
                             '0723456789',
                             'bob92@email.com' );
INSERT INTO CONTACT VALUES ( 3,
                             '0734567890',
                             'charlie@email.com' );
INSERT INTO CONTACT VALUES ( 4,
                             '0745678901',
                             'dana@email.com' );
INSERT INTO CONTACT VALUES ( 5,
                             '0756789012',
                             'eva@email.com' );
INSERT INTO CONTACT VALUES ( 6,
                             '0767890123',
                             'frank@email.com' );
INSERT INTO CONTACT VALUES ( 7,
                             '0778901234',
                             'gina@email.com' );
INSERT INTO CONTACT VALUES ( 8,
                             '0789012345',
                             'harry@email.com' );
INSERT INTO CONTACT VALUES ( 9,
                             '0790123456',
                             'irene@email.com' );
INSERT INTO CONTACT VALUES ( 10,
                             '0701234567',
                             'johnny@email.com' );
COMMIT;
/

-- Insert Games
BEGIN
  PKG_SHOP.ADD_GAME(
    'Assassin''s Creed',
    60,
    15,
    TO_DATE('2018-11-10',
                    'YYYY-MM-DD'),
    'Action-adventure game.',
    1
  );
  PKG_SHOP.ADD_GAME(
    'FIFA 22',
    50,
    20,
    TO_DATE('2021-10-01',
                    'YYYY-MM-DD'),
    'Football simulator.',
    2
  );
  PKG_SHOP.ADD_GAME(
    'GTA V',
    40,
    25,
    TO_DATE('2015-04-14',
                    'YYYY-MM-DD'),
    'Open world crime game.',
    3
  );
  PKG_SHOP.ADD_GAME(
    'The Witcher 3',
    45,
    30,
    TO_DATE('2015-05-19',
                    'YYYY-MM-DD'),
    'Fantasy RPG.',
    4
  );
  PKG_SHOP.ADD_GAME(
    'Skyrim',
    35,
    12,
    TO_DATE('2011-11-11',
                    'YYYY-MM-DD'),
    'Elder Scrolls adventure.',
    5
  );
  PKG_SHOP.ADD_GAME(
    'Watch Dogs',
    30,
    10,
    TO_DATE('2014-05-27',
                    'YYYY-MM-DD'),
    'Hack the system.',
    1
  );
  PKG_SHOP.ADD_GAME(
    'Battlefield V',
    55,
    14,
    TO_DATE('2018-11-20',
                    'YYYY-MM-DD'),
    'WW2 FPS.',
    2
  );
  PKG_SHOP.ADD_GAME(
    'Red Dead Redemption 2',
    60,
    18,
    TO_DATE('2018-10-26',
                    'YYYY-MM-DD'),
    'Western epic.',
    3
  );
  PKG_SHOP.ADD_GAME(
    'Cyberpunk 2077',
    65,
    20,
    TO_DATE('2020-12-10',
                    'YYYY-MM-DD'),
    'Dystopian future RPG.',
    4
  );
  PKG_SHOP.ADD_GAME(
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
  PKG_SHOP.PLACE_ORDER(
    1,
    1,
    2
  );
  PKG_SHOP.PLACE_ORDER(
    2,
    3,
    1
  );
  PKG_SHOP.PLACE_ORDER(
    3,
    4,
    3
  );
  PKG_SHOP.PLACE_ORDER(
    4,
    2,
    1
  );
  PKG_SHOP.PLACE_ORDER(
    5,
    5,
    2
  );
  PKG_SHOP.PLACE_ORDER(
    6,
    6,
    1
  );
  PKG_SHOP.PLACE_ORDER(
    7,
    7,
    2
  );
  PKG_SHOP.PLACE_ORDER(
    8,
    8,
    1
  );
  PKG_SHOP.PLACE_ORDER(
    9,
    9,
    2
  );
  PKG_SHOP.PLACE_ORDER(
    10,
    10,
    1
  );
  PKG_SHOP.PLACE_ORDER(
    1,
    3,
    1
  );
  PKG_SHOP.PLACE_ORDER(
    2,
    4,
    2
  );
END;
/
COMMIT;
/