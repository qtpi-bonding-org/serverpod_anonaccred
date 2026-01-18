BEGIN;

--
-- ACTION ALTER TABLE
--
ALTER TABLE "transaction_payment" DROP COLUMN "transactionHash";
ALTER TABLE "transaction_payment" ADD COLUMN "transactionTimestamp" timestamp without time zone;

--
-- MIGRATION VERSION FOR anonaccred
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('anonaccred', '20260118054126498', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20260118054126498', "timestamp" = now();

--
-- MIGRATION VERSION FOR serverpod
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('serverpod', '20251208110333922-v3-0-0', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20251208110333922-v3-0-0', "timestamp" = now();


COMMIT;
