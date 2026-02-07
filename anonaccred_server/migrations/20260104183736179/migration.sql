BEGIN;

--
-- ACTION DROP TABLE
--
DROP TABLE "account_device" CASCADE;

--
-- ACTION CREATE TABLE
--
CREATE TABLE "account_device" (
    "id" bigserial PRIMARY KEY,
    "accountId" bigint NOT NULL,
    "deviceSigningPublicKeyHex" text NOT NULL,
    "encryptedDataKey" text NOT NULL,
    "label" text NOT NULL,
    "lastActive" timestamp without time zone NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "isRevoked" boolean NOT NULL DEFAULT false
);

-- Indexes
CREATE INDEX "auth_lookup_idx" ON "account_device" USING btree ("deviceSigningPublicKeyHex", "isRevoked");

--
-- ACTION DROP TABLE
--
DROP TABLE "anon_account" CASCADE;

--
-- ACTION CREATE TABLE
--
CREATE TABLE "anon_account" (
    "id" bigserial PRIMARY KEY,
    "ultimateSigningPublicKeyHex" text NOT NULL,
    "encryptedDataKey" text NOT NULL,
    "ultimatePublicKey" text NOT NULL,
    "createdAt" timestamp without time zone NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Indexes
CREATE UNIQUE INDEX "ultimate_key_idx" ON "anon_account" USING btree ("ultimatePublicKey");

--
-- ACTION CREATE FOREIGN KEY
--
ALTER TABLE ONLY "account_device"
    ADD CONSTRAINT "account_device_fk_0"
    FOREIGN KEY("accountId")
    REFERENCES "anon_account"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION;


--
-- MIGRATION VERSION FOR anonaccred
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('anonaccred', '20260104183736179', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20260104183736179', "timestamp" = now();

--
-- MIGRATION VERSION FOR serverpod
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('serverpod', '20251208110333922-v3-0-0', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20251208110333922-v3-0-0', "timestamp" = now();


COMMIT;
