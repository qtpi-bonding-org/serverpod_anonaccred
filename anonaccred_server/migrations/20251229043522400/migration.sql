BEGIN;

--
-- ACTION DROP TABLE
--
DROP TABLE "anon_account" CASCADE;

--
-- ACTION CREATE TABLE
--
CREATE TABLE "anon_account" (
    "id" bigserial PRIMARY KEY,
    "publicMasterKey" text NOT NULL,
    "encryptedDataKey" text NOT NULL,
    "ultimatePublicKey" text NOT NULL,
    "createdAt" timestamp without time zone NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Indexes
CREATE UNIQUE INDEX "ultimate_key_idx" ON "anon_account" USING btree ("ultimatePublicKey");


--
-- MIGRATION VERSION FOR anonaccred
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('anonaccred', '20251229043522400', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20251229043522400', "timestamp" = now();

--
-- MIGRATION VERSION FOR serverpod
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('serverpod', '20251208110333922-v3-0-0', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20251208110333922-v3-0-0', "timestamp" = now();


COMMIT;
