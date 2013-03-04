--
-- PostgreSQL database dump
--

SET statement_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;

--
-- Name: plpgsql; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;


--
-- Name: EXTENSION plpgsql; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';


SET search_path = public, pg_catalog;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: datasets; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE datasets (
    id bigint NOT NULL,
    name character varying(255) NOT NULL,
    has_transcript_diff_exp boolean NOT NULL,
    has_transcript_isoforms boolean NOT NULL,
    has_gene_diff_exp boolean NOT NULL,
    blast_db_location character varying(255) NOT NULL,
    user_id integer NOT NULL,
    when_last_queried timestamp without time zone,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: datasets_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE datasets_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: datasets_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE datasets_id_seq OWNED BY datasets.id;


--
-- Name: differential_expression_tests; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE differential_expression_tests (
    id bigint NOT NULL,
    gene_id bigint,
    transcript_id bigint,
    sample_comparison_id bigint NOT NULL,
    test_status character varying(255) NOT NULL,
    sample_1_fpkm double precision NOT NULL,
    sample_2_fpkm double precision NOT NULL,
    log_fold_change double precision NOT NULL,
    test_statistic double precision NOT NULL,
    p_value double precision NOT NULL,
    fdr double precision NOT NULL
);


--
-- Name: differential_expression_tests_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE differential_expression_tests_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: differential_expression_tests_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE differential_expression_tests_id_seq OWNED BY differential_expression_tests.id;


--
-- Name: fpkm_samples; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE fpkm_samples (
    id bigint NOT NULL,
    transcript_id bigint NOT NULL,
    sample_id bigint NOT NULL,
    fpkm double precision NOT NULL,
    fpkm_hi double precision,
    fpkm_lo double precision,
    status character varying(255)
);


--
-- Name: fpkm_samples_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE fpkm_samples_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: fpkm_samples_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE fpkm_samples_id_seq OWNED BY fpkm_samples.id;


--
-- Name: genes; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE genes (
    id bigint NOT NULL,
    dataset_id bigint NOT NULL,
    name_from_program character varying(255) NOT NULL
);


--
-- Name: genes_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE genes_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: genes_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE genes_id_seq OWNED BY genes.id;


--
-- Name: go_terms; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE go_terms (
    id character varying(255) NOT NULL,
    term character varying(255) NOT NULL
);


--
-- Name: sample_comparisons; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE sample_comparisons (
    id integer NOT NULL,
    sample_1_id integer NOT NULL,
    sample_2_id integer NOT NULL
);


--
-- Name: sample_comparisons_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE sample_comparisons_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: sample_comparisons_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE sample_comparisons_id_seq OWNED BY sample_comparisons.id;


--
-- Name: samples; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE samples (
    id bigint NOT NULL,
    name character varying(255) NOT NULL,
    dataset_id integer NOT NULL
);


--
-- Name: samples_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE samples_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: samples_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE samples_id_seq OWNED BY samples.id;


--
-- Name: schema_migrations; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE schema_migrations (
    version character varying(255) NOT NULL
);


--
-- Name: simple_captcha_data; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE simple_captcha_data (
    id integer NOT NULL,
    key character varying(40),
    value character varying(6),
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: simple_captcha_data_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE simple_captcha_data_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: simple_captcha_data_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE simple_captcha_data_id_seq OWNED BY simple_captcha_data.id;


--
-- Name: transcript_fpkm_tracking_informations; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE transcript_fpkm_tracking_informations (
    transcript_id bigint NOT NULL,
    class_code character varying(255) NOT NULL,
    length integer NOT NULL,
    coverage character varying(255)
);


--
-- Name: transcript_has_go_terms; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE transcript_has_go_terms (
    transcript_id integer NOT NULL,
    go_term_id character varying(255) NOT NULL
);


--
-- Name: transcripts; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE transcripts (
    id bigint NOT NULL,
    dataset_id bigint NOT NULL,
    gene_id bigint,
    name_from_program character varying(255) NOT NULL
);


--
-- Name: transcripts_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE transcripts_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: transcripts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE transcripts_id_seq OWNED BY transcripts.id;


--
-- Name: users; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE users (
    id integer NOT NULL,
    email character varying(255) DEFAULT ''::character varying NOT NULL,
    encrypted_password character varying(255) DEFAULT ''::character varying NOT NULL,
    reset_password_token character varying(255),
    reset_password_sent_at timestamp without time zone,
    remember_created_at timestamp without time zone,
    sign_in_count integer DEFAULT 0,
    current_sign_in_at timestamp without time zone,
    last_sign_in_at timestamp without time zone,
    current_sign_in_ip character varying(255),
    last_sign_in_ip character varying(255),
    confirmation_token character varying(255),
    confirmed_at timestamp without time zone,
    confirmation_sent_at timestamp without time zone,
    unconfirmed_email character varying(255),
    failed_attempts integer DEFAULT 0,
    unlock_token character varying(255),
    locked_at timestamp without time zone,
    name character varying(255) NOT NULL,
    description text NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    admin boolean DEFAULT false NOT NULL
);


--
-- Name: users_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE users_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE users_id_seq OWNED BY users.id;


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY datasets ALTER COLUMN id SET DEFAULT nextval('datasets_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY differential_expression_tests ALTER COLUMN id SET DEFAULT nextval('differential_expression_tests_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY fpkm_samples ALTER COLUMN id SET DEFAULT nextval('fpkm_samples_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY genes ALTER COLUMN id SET DEFAULT nextval('genes_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY sample_comparisons ALTER COLUMN id SET DEFAULT nextval('sample_comparisons_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY samples ALTER COLUMN id SET DEFAULT nextval('samples_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY simple_captcha_data ALTER COLUMN id SET DEFAULT nextval('simple_captcha_data_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY transcripts ALTER COLUMN id SET DEFAULT nextval('transcripts_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY users ALTER COLUMN id SET DEFAULT nextval('users_id_seq'::regclass);


--
-- Name: datasets_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY datasets
    ADD CONSTRAINT datasets_pkey PRIMARY KEY (id);


--
-- Name: differential_expression_tests_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY differential_expression_tests
    ADD CONSTRAINT differential_expression_tests_pkey PRIMARY KEY (id);


--
-- Name: fpkm_samples_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY fpkm_samples
    ADD CONSTRAINT fpkm_samples_pkey PRIMARY KEY (id);


--
-- Name: genes_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY genes
    ADD CONSTRAINT genes_pkey PRIMARY KEY (id);


--
-- Name: go_terms_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY go_terms
    ADD CONSTRAINT go_terms_pkey PRIMARY KEY (id);


--
-- Name: sample_comparisons_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY sample_comparisons
    ADD CONSTRAINT sample_comparisons_pkey PRIMARY KEY (id);


--
-- Name: samples_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY samples
    ADD CONSTRAINT samples_pkey PRIMARY KEY (id);


--
-- Name: simple_captcha_data_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY simple_captcha_data
    ADD CONSTRAINT simple_captcha_data_pkey PRIMARY KEY (id);


--
-- Name: transcript_fpkm_tracking_informations_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY transcript_fpkm_tracking_informations
    ADD CONSTRAINT transcript_fpkm_tracking_informations_pkey PRIMARY KEY (transcript_id);


--
-- Name: transcript_has_go_terms_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY transcript_has_go_terms
    ADD CONSTRAINT transcript_has_go_terms_pkey PRIMARY KEY (transcript_id, go_term_id);


--
-- Name: transcripts_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY transcripts
    ADD CONSTRAINT transcripts_pkey PRIMARY KEY (id);


--
-- Name: users_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: idx_key; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX idx_key ON simple_captcha_data USING btree (key);


--
-- Name: index_users_on_confirmation_token; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_users_on_confirmation_token ON users USING btree (confirmation_token);


--
-- Name: index_users_on_email; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_users_on_email ON users USING btree (email);


--
-- Name: index_users_on_reset_password_token; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_users_on_reset_password_token ON users USING btree (reset_password_token);


--
-- Name: index_users_on_unlock_token; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_users_on_unlock_token ON users USING btree (unlock_token);


--
-- Name: unique_schema_migrations; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX unique_schema_migrations ON schema_migrations USING btree (version);


--
-- Name: datasets_users_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY datasets
    ADD CONSTRAINT datasets_users_fk FOREIGN KEY (user_id) REFERENCES users(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: differential_expression_tests_genes_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY differential_expression_tests
    ADD CONSTRAINT differential_expression_tests_genes_fk FOREIGN KEY (gene_id) REFERENCES genes(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: differential_expression_tests_sample_comparisons_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY differential_expression_tests
    ADD CONSTRAINT differential_expression_tests_sample_comparisons_fk FOREIGN KEY (sample_comparison_id) REFERENCES sample_comparisons(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: differential_expression_tests_transcripts_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY differential_expression_tests
    ADD CONSTRAINT differential_expression_tests_transcripts_fk FOREIGN KEY (transcript_id) REFERENCES transcripts(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: fpkm_samples_samples_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY fpkm_samples
    ADD CONSTRAINT fpkm_samples_samples_fk FOREIGN KEY (sample_id) REFERENCES samples(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: fpkm_samples_transcripts_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY fpkm_samples
    ADD CONSTRAINT fpkm_samples_transcripts_fk FOREIGN KEY (transcript_id) REFERENCES transcripts(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: ftranscript_has_go_terms_go_terms_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY transcript_has_go_terms
    ADD CONSTRAINT ftranscript_has_go_terms_go_terms_fk FOREIGN KEY (go_term_id) REFERENCES go_terms(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: ftranscript_has_go_terms_transcripts_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY transcript_has_go_terms
    ADD CONSTRAINT ftranscript_has_go_terms_transcripts_fk FOREIGN KEY (transcript_id) REFERENCES transcripts(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: genes_datasets_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY genes
    ADD CONSTRAINT genes_datasets_fk FOREIGN KEY (dataset_id) REFERENCES datasets(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: transcript_fpkm_tracking_informations_transripts_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY transcript_fpkm_tracking_informations
    ADD CONSTRAINT transcript_fpkm_tracking_informations_transripts_fk FOREIGN KEY (transcript_id) REFERENCES transcripts(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: transripts_datasets_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY transcripts
    ADD CONSTRAINT transripts_datasets_fk FOREIGN KEY (dataset_id) REFERENCES datasets(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: transripts_genes_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY transcripts
    ADD CONSTRAINT transripts_genes_fk FOREIGN KEY (gene_id) REFERENCES genes(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- PostgreSQL database dump complete
--

INSERT INTO schema_migrations (version) VALUES ('1');

INSERT INTO schema_migrations (version) VALUES ('10');

INSERT INTO schema_migrations (version) VALUES ('11');

INSERT INTO schema_migrations (version) VALUES ('12');

INSERT INTO schema_migrations (version) VALUES ('13');

INSERT INTO schema_migrations (version) VALUES ('14');

INSERT INTO schema_migrations (version) VALUES ('2');

INSERT INTO schema_migrations (version) VALUES ('3');

INSERT INTO schema_migrations (version) VALUES ('4');

INSERT INTO schema_migrations (version) VALUES ('5');

INSERT INTO schema_migrations (version) VALUES ('6');

INSERT INTO schema_migrations (version) VALUES ('7');

INSERT INTO schema_migrations (version) VALUES ('8');

INSERT INTO schema_migrations (version) VALUES ('9');