BEGIN;

--
-- ACTION DROP TABLE
--
DROP TABLE "transaction_consumable" CASCADE;

--
-- ACTION DROP TABLE
--
DROP TABLE "consumable_delivery" CASCADE;

--
-- ACTION DROP TABLE
--
DROP TABLE "apple_consumable_delivery" CASCADE;

--
-- ACTION DROP TABLE
--
DROP TABLE "account_inventory" CASCADE;

--
-- ACTION CREATE TABLE
--
CREATE TABLE "account_entitlement" (
    "id" bigserial PRIMARY KEY,
    "accountId" bigint NOT NULL,
    "entitlementId" bigint NOT NULL,
    "balance" double precision NOT NULL
);

-- Indexes
CREATE UNIQUE INDEX "account_entitlement_idx" ON "account_entitlement" USING btree ("accountId", "entitlementId");

--
-- ACTION CREATE TABLE
--
CREATE TABLE "consumption_log" (
    "id" bigserial PRIMARY KEY,
    "accountId" bigint NOT NULL,
    "entitlementId" bigint NOT NULL,
    "amount" double precision NOT NULL,
    "reason" text NOT NULL,
    "timestamp" timestamp without time zone NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Indexes
CREATE INDEX "account_idx" ON "consumption_log" USING btree ("accountId");
CREATE INDEX "entitlement_idx" ON "consumption_log" USING btree ("entitlementId");

--
-- ACTION CREATE TABLE
--
CREATE TABLE "entitlement" (
    "id" bigserial PRIMARY KEY,
    "tag" text NOT NULL,
    "name" text NOT NULL,
    "type" text NOT NULL
);

-- Indexes
CREATE UNIQUE INDEX "tag_idx" ON "entitlement" USING btree ("tag");

--
-- ACTION CREATE TABLE
--
CREATE TABLE "ephemeral_accreditation" (
    "id" bigserial PRIMARY KEY,
    "accountId" bigint NOT NULL,
    "transactionTimestamp" timestamp without time zone NOT NULL
);

-- Indexes
CREATE INDEX "lookup_idx" ON "ephemeral_accreditation" USING btree ("transactionTimestamp");

--
-- ACTION CREATE TABLE
--
CREATE TABLE "rail_product" (
    "id" bigserial PRIMARY KEY,
    "rail" text NOT NULL,
    "storeProductId" text NOT NULL,
    "isActive" boolean NOT NULL
);

-- Indexes
CREATE INDEX "store_product_idx" ON "rail_product" USING btree ("rail", "storeProductId");

--
-- ACTION CREATE TABLE
--
CREATE TABLE "rail_product_grant" (
    "id" bigserial PRIMARY KEY,
    "railProductId" bigint NOT NULL,
    "entitlementId" bigint NOT NULL,
    "quantity" double precision NOT NULL
);

--
-- ACTION CREATE TABLE
--
CREATE TABLE "receipt_hash" (
    "id" bigserial PRIMARY KEY,
    "hash" text NOT NULL,
    "paymentRail" text NOT NULL,
    "processedAt" timestamp without time zone NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Indexes
CREATE UNIQUE INDEX "hash_idx" ON "receipt_hash" USING btree ("hash");

--
-- ACTION DROP TABLE
--
DROP TABLE "transaction_payment" CASCADE;

--
-- ACTION CREATE TABLE
--
CREATE TABLE "transaction_payment" (
    "id" bigserial PRIMARY KEY,
    "railProductId" bigint NOT NULL,
    "internalTransactionId" text NOT NULL,
    "priceCurrency" text NOT NULL,
    "price" double precision NOT NULL,
    "paymentRail" text NOT NULL,
    "paymentCurrency" text NOT NULL,
    "paymentAmount" double precision NOT NULL,
    "paymentRef" text,
    "transactionTimestamp" timestamp without time zone NOT NULL,
    "clientReference" text,
    "status" text NOT NULL,
    "railDataJson" text
);

-- Indexes
CREATE UNIQUE INDEX "internal_tx_id_idx" ON "transaction_payment" USING btree ("internalTransactionId");
CREATE INDEX "timestamp_idx" ON "transaction_payment" USING btree ("transactionTimestamp");

--
-- ACTION ALTER TABLE
--
CREATE INDEX "serverpod_session_log_time_idx" ON "serverpod_session_log" USING btree ("time");
--
-- ACTION CREATE FOREIGN KEY
--
ALTER TABLE ONLY "account_entitlement"
    ADD CONSTRAINT "account_entitlement_fk_0"
    FOREIGN KEY("accountId")
    REFERENCES "anon_account"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION;
ALTER TABLE ONLY "account_entitlement"
    ADD CONSTRAINT "account_entitlement_fk_1"
    FOREIGN KEY("entitlementId")
    REFERENCES "entitlement"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION;

--
-- ACTION CREATE FOREIGN KEY
--
ALTER TABLE ONLY "consumption_log"
    ADD CONSTRAINT "consumption_log_fk_0"
    FOREIGN KEY("accountId")
    REFERENCES "anon_account"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION;
ALTER TABLE ONLY "consumption_log"
    ADD CONSTRAINT "consumption_log_fk_1"
    FOREIGN KEY("entitlementId")
    REFERENCES "entitlement"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION;

--
-- ACTION CREATE FOREIGN KEY
--
ALTER TABLE ONLY "ephemeral_accreditation"
    ADD CONSTRAINT "ephemeral_accreditation_fk_0"
    FOREIGN KEY("accountId")
    REFERENCES "anon_account"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION;

--
-- ACTION CREATE FOREIGN KEY
--
ALTER TABLE ONLY "rail_product_grant"
    ADD CONSTRAINT "rail_product_grant_fk_0"
    FOREIGN KEY("railProductId")
    REFERENCES "rail_product"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION;
ALTER TABLE ONLY "rail_product_grant"
    ADD CONSTRAINT "rail_product_grant_fk_1"
    FOREIGN KEY("entitlementId")
    REFERENCES "entitlement"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION;

--
-- ACTION CREATE FOREIGN KEY
--
ALTER TABLE ONLY "transaction_payment"
    ADD CONSTRAINT "transaction_payment_fk_0"
    FOREIGN KEY("railProductId")
    REFERENCES "rail_product"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION;


--
-- MIGRATION VERSION FOR anonaccred
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('anonaccred', '20260301222405705', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20260301222405705', "timestamp" = now();

--
-- MIGRATION VERSION FOR serverpod
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('serverpod', '20260129180959368', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20260129180959368', "timestamp" = now();


COMMIT;
