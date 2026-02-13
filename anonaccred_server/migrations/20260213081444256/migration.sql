BEGIN;

--
-- ACTION CREATE TABLE
--
CREATE TABLE "apple_consumable_delivery" (
    "id" bigserial PRIMARY KEY,
    "transactionId" text NOT NULL,
    "originalTransactionId" text NOT NULL,
    "productId" text NOT NULL,
    "accountId" bigint NOT NULL,
    "consumableType" text NOT NULL,
    "quantity" double precision NOT NULL,
    "orderId" text NOT NULL,
    "deliveredAt" timestamp without time zone NOT NULL
);

-- Indexes
CREATE UNIQUE INDEX "apple_consumable_delivery_transaction_id_idx" ON "apple_consumable_delivery" USING btree ("transactionId");
CREATE INDEX "apple_consumable_delivery_account_idx" ON "apple_consumable_delivery" USING btree ("accountId");
CREATE INDEX "apple_consumable_delivery_original_transaction_idx" ON "apple_consumable_delivery" USING btree ("originalTransactionId");

--
-- ACTION CREATE TABLE
--
CREATE TABLE "consumable_delivery" (
    "id" bigserial PRIMARY KEY,
    "purchaseToken" text NOT NULL,
    "productId" text NOT NULL,
    "accountId" bigint NOT NULL,
    "consumableType" text NOT NULL,
    "quantity" double precision NOT NULL,
    "orderId" text NOT NULL,
    "deliveredAt" timestamp without time zone NOT NULL
);

-- Indexes
CREATE UNIQUE INDEX "consumable_delivery_purchase_token_idx" ON "consumable_delivery" USING btree ("purchaseToken");
CREATE INDEX "consumable_delivery_account_idx" ON "consumable_delivery" USING btree ("accountId");


--
-- MIGRATION VERSION FOR anonaccred
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('anonaccred', '20260213081444256', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20260213081444256', "timestamp" = now();

--
-- MIGRATION VERSION FOR serverpod
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('serverpod', '20251208110333922-v3-0-0', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20251208110333922-v3-0-0', "timestamp" = now();


COMMIT;
