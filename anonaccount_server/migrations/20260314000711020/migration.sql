BEGIN;

--
-- ACTION CREATE TABLE
--
CREATE TABLE "public_challenges" (
    "id" bigserial PRIMARY KEY,
    "challenge" text NOT NULL,
    "expiresAt" timestamp without time zone NOT NULL
);

-- Indexes
CREATE UNIQUE INDEX "public_challenges_challenge_idx" ON "public_challenges" USING btree ("challenge");
CREATE INDEX "public_challenges_expires_idx" ON "public_challenges" USING btree ("expiresAt");


--
-- MIGRATION VERSION FOR anonaccount
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('anonaccount', '20260314000711020', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20260314000711020', "timestamp" = now();

--
-- MIGRATION VERSION FOR serverpod
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('serverpod', '20260129180959368', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20260129180959368', "timestamp" = now();


COMMIT;
