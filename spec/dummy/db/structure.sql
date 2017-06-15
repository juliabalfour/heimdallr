SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: plpgsql; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;


--
-- Name: EXTENSION plpgsql; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';


--
-- Name: pgcrypto; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS pgcrypto WITH SCHEMA public;


--
-- Name: EXTENSION pgcrypto; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION pgcrypto IS 'cryptographic functions';


--
-- Name: uuid-ossp; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS "uuid-ossp" WITH SCHEMA public;


--
-- Name: EXTENSION "uuid-ossp"; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION "uuid-ossp" IS 'generate universally unique identifiers (UUIDs)';


SET search_path = public, pg_catalog;

--
-- Name: heimdallr_algorithms; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE heimdallr_algorithms AS ENUM (
    'HS256',
    'HS384',
    'HS512',
    'RS256',
    'RS384',
    'RS512'
);


SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: ar_internal_metadata; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE ar_internal_metadata (
    key character varying NOT NULL,
    value character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: heimdallr_applications; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE heimdallr_applications (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    name character varying NOT NULL,
    key character varying NOT NULL,
    scopes character varying[] DEFAULT '{}'::character varying[] NOT NULL,
    algorithm heimdallr_algorithms DEFAULT 'RS256'::heimdallr_algorithms NOT NULL,
    encrypted_secret bytea NOT NULL,
    encrypted_secret_iv bytea NOT NULL,
    encrypted_certificate bytea,
    encrypted_certificate_iv bytea,
    ip inet,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: heimdallr_tokens; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE heimdallr_tokens (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    application_id uuid,
    scopes character varying[] DEFAULT '{}'::character varying[] NOT NULL,
    data jsonb DEFAULT '{}'::jsonb NOT NULL,
    ip inet,
    created_at timestamp without time zone NOT NULL,
    expires_at timestamp without time zone NOT NULL,
    revoked_at timestamp without time zone,
    not_before timestamp without time zone
);


--
-- Name: schema_migrations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE schema_migrations (
    version character varying NOT NULL
);


--
-- Name: ar_internal_metadata ar_internal_metadata_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY ar_internal_metadata
    ADD CONSTRAINT ar_internal_metadata_pkey PRIMARY KEY (key);


--
-- Name: heimdallr_applications heimdallr_applications_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY heimdallr_applications
    ADD CONSTRAINT heimdallr_applications_pkey PRIMARY KEY (id);


--
-- Name: heimdallr_tokens heimdallr_tokens_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY heimdallr_tokens
    ADD CONSTRAINT heimdallr_tokens_pkey PRIMARY KEY (id);


--
-- Name: schema_migrations schema_migrations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY schema_migrations
    ADD CONSTRAINT schema_migrations_pkey PRIMARY KEY (version);


--
-- Name: index_heimdallr_applications_on_key; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_heimdallr_applications_on_key ON heimdallr_applications USING btree (key);


--
-- Name: index_heimdallr_tokens_on_application_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_heimdallr_tokens_on_application_id ON heimdallr_tokens USING btree (application_id);


--
-- PostgreSQL database dump complete
--

SET search_path TO "$user", public;

INSERT INTO "schema_migrations" (version) VALUES
('20170615200909'),
('20170615203031'),
('20170615203032');


