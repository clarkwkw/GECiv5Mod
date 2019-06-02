CREATE TABLE IDRemapper ( id INTEGER PRIMARY KEY AUTOINCREMENT, Type TEXT );
INSERT INTO IDRemapper (Type) SELECT Type FROM Technologies ORDER BY GridX ASC;
UPDATE Technologies SET ID = ( SELECT IDRemapper.id-1 FROM IDRemapper WHERE Technologies.Type = IDRemapper.Type);

DROP TABLE IDRemapper;
CREATE TABLE IDRemapper ( id INTEGER PRIMARY KEY AUTOINCREMENT, Type TEXT );
INSERT INTO IDRemapper (Type) SELECT Type FROM GenericFunctionalities;
UPDATE GenericFunctionalities SET ID = ( SELECT IDRemapper.id-1 FROM IDRemapper WHERE GenericFunctionalities.Type = IDRemapper.Type);

