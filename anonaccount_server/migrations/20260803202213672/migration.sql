BEGIN;

--
-- ACTION ALTER TABLE
--
ALTER TABLE "group_member" ADD COLUMN "roleChangedAt" timestamp without time zone;
ALTER TABLE "group_member" ADD COLUMN "roleChangedByAttestorPublicKeyHex" text;
ALTER TABLE "group_member" ADD COLUMN "roleChangedByAttestation" text;

--
-- MIGRATION VERSION FOR anonaccount
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('anonaccount', '20260803202213672', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20260803202213672', "timestamp" = now();

--
-- MIGRATION VERSION FOR serverpod
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('serverpod', '20260129180959368', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20260129180959368', "timestamp" = now();

--
-- MIGRATION VERSION FOR serverpod_auth_idp
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('serverpod_auth_idp', '20260213194423028', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20260213194423028', "timestamp" = now();

--
-- MIGRATION VERSION FOR serverpod_auth_core
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('serverpod_auth_core', '20260129181112269', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20260129181112269', "timestamp" = now();


COMMIT;
