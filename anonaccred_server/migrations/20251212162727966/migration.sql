BEGIN;

--
-- ACTION CREATE TABLE
--
CREATE TABLE "account_device" (
    "id" bigserial PRIMARY KEY,
    "accountId" bigint NOT NULL,
    "publicSubKey" text NOT NULL,
    "encryptedDataKey" text NOT NULL,
    "label" text NOT NULL,
    "lastActive" timestamp without time zone NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "isRevoked" boolean NOT NULL DEFAULT false
);

-- Indexes
CREATE INDEX "auth_lookup_idx" ON "account_device" USING btree ("publicSubKey", "isRevoked");

--
-- ACTION CREATE TABLE
--
CREATE TABLE "account_inventory" (
    "id" bigserial PRIMARY KEY,
    "accountId" bigint NOT NULL,
    "consumableType" text NOT NULL,
    "quantity" double precision NOT NULL,
    "lastUpdated" timestamp without time zone NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Indexes
CREATE UNIQUE INDEX "inventory_idx" ON "account_inventory" USING btree ("accountId", "consumableType");

--
-- ACTION CREATE TABLE
--
CREATE TABLE "anon_account" (
    "id" bigserial PRIMARY KEY,
    "publicMasterKey" text NOT NULL,
    "encryptedDataKey" text NOT NULL,
    "createdAt" timestamp without time zone NOT NULL DEFAULT CURRENT_TIMESTAMP
);

--
-- ACTION CREATE TABLE
--
CREATE TABLE "transaction_consumable" (
    "id" bigserial PRIMARY KEY,
    "transactionId" bigint NOT NULL,
    "consumableType" text NOT NULL,
    "quantity" double precision NOT NULL
);

--
-- ACTION CREATE TABLE
--
CREATE TABLE "transaction_payment" (
    "id" bigserial PRIMARY KEY,
    "externalId" text NOT NULL,
    "accountId" bigint NOT NULL,
    "priceCurrency" text NOT NULL,
    "price" double precision NOT NULL,
    "paymentRail" text NOT NULL,
    "paymentCurrency" text NOT NULL,
    "paymentAmount" double precision NOT NULL,
    "paymentRef" text,
    "status" text NOT NULL DEFAULT 'pending'::text,
    "timestamp" timestamp without time zone NOT NULL DEFAULT CURRENT_TIMESTAMP
);

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
-- ACTION CREATE FOREIGN KEY
--
ALTER TABLE ONLY "account_inventory"
    ADD CONSTRAINT "account_inventory_fk_0"
    FOREIGN KEY("accountId")
    REFERENCES "anon_account"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION;

--
-- ACTION CREATE FOREIGN KEY
--
ALTER TABLE ONLY "transaction_consumable"
    ADD CONSTRAINT "transaction_consumable_fk_0"
    FOREIGN KEY("transactionId")
    REFERENCES "transaction_payment"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION;

--
-- ACTION CREATE FOREIGN KEY
--
ALTER TABLE ONLY "transaction_payment"
    ADD CONSTRAINT "transaction_payment_fk_0"
    FOREIGN KEY("accountId")
    REFERENCES "anon_account"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION;


--
-- MIGRATION VERSION FOR anonaccred
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('anonaccred', '20251212162727966', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20251212162727966', "timestamp" = now();

--
-- MIGRATION VERSION FOR serverpod
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('serverpod', '20251208110333922-v3-0-0', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20251208110333922-v3-0-0', "timestamp" = now();


COMMIT;
