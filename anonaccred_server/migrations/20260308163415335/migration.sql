BEGIN;

--
-- ACTION ALTER TABLE
--
ALTER TABLE "account_device" DROP CONSTRAINT "account_device_fk_0";
--
-- ACTION ALTER TABLE
--
ALTER TABLE "account_entitlement" DROP CONSTRAINT "account_entitlement_fk_0";
--
-- ACTION ALTER TABLE
--
ALTER TABLE "consumption_log" DROP CONSTRAINT "consumption_log_fk_0";
--
-- ACTION ALTER TABLE
--
ALTER TABLE "ephemeral_accreditation" DROP CONSTRAINT "ephemeral_accreditation_fk_0";
--
-- ACTION CREATE FOREIGN KEY
--
ALTER TABLE ONLY "account_device"
    ADD CONSTRAINT "account_device_fk_0"
    FOREIGN KEY("accountId")
    REFERENCES "anon_account"("id")
    ON DELETE CASCADE
    ON UPDATE NO ACTION;
--
-- ACTION CREATE FOREIGN KEY
--
ALTER TABLE ONLY "account_entitlement"
    ADD CONSTRAINT "account_entitlement_fk_0"
    FOREIGN KEY("accountId")
    REFERENCES "anon_account"("id")
    ON DELETE CASCADE
    ON UPDATE NO ACTION;
--
-- ACTION CREATE FOREIGN KEY
--
ALTER TABLE ONLY "consumption_log"
    ADD CONSTRAINT "consumption_log_fk_0"
    FOREIGN KEY("accountId")
    REFERENCES "anon_account"("id")
    ON DELETE CASCADE
    ON UPDATE NO ACTION;
--
-- ACTION CREATE FOREIGN KEY
--
ALTER TABLE ONLY "ephemeral_accreditation"
    ADD CONSTRAINT "ephemeral_accreditation_fk_0"
    FOREIGN KEY("accountId")
    REFERENCES "anon_account"("id")
    ON DELETE CASCADE
    ON UPDATE NO ACTION;

--
-- MIGRATION VERSION FOR anonaccred
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('anonaccred', '20260308163415335', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20260308163415335', "timestamp" = now();

--
-- MIGRATION VERSION FOR serverpod
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('serverpod', '20260129180959368', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20260129180959368', "timestamp" = now();


COMMIT;
