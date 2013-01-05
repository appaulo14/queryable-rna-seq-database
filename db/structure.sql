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
-- Name: blast_graphical_summary_locators; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE blast_graphical_summary_locators (
    basename character varying(255) NOT NULL,
    html_output_file_path text NOT NULL,
    dataset_id integer NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: datasets; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE datasets (
    id bigint NOT NULL,
    name character varying(255) NOT NULL,
    blast_db_location character varying(255) NOT NULL,
    user_id integer NOT NULL,
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
    fpkm_sample_1_id bigint NOT NULL,
    fpkm_sample_2_id bigint NOT NULL,
    gene_id bigint,
    transcript_id bigint,
    test_status character varying(255) NOT NULL,
    log_fold_change numeric NOT NULL,
    p_value numeric NOT NULL,
    fdr numeric NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
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
    gene_id bigint,
    transcript_id bigint,
    sample_id bigint NOT NULL,
    fpkm numeric NOT NULL,
    fpkm_hi numeric,
    fpkm_lo numeric,
    status character varying(255),
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
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
    name_from_program character varying(255) NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
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
    term character varying(255),
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: job2s; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE job2s (
    id bigint NOT NULL,
    eid_of_owner character varying(255),
    current_program_display_name character varying(255),
    workflow character varying(255),
    current_step character varying(255),
    next_step character varying(255),
    number_of_samples integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: job2s_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE job2s_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: job2s_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE job2s_id_seq OWNED BY job2s.id;


--
-- Name: jobs; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE jobs (
    id bigint NOT NULL,
    current_job_status character varying(255),
    current_program_status character varying(255),
    user_id integer NOT NULL,
    workflow_step_id integer,
    output_files_type character varying(255),
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: jobs_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE jobs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: jobs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE jobs_id_seq OWNED BY jobs.id;


--
-- Name: sample_comparisons; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE sample_comparisons (
    sample_1_id integer NOT NULL,
    sample_2_id integer NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: samples; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE samples (
    id bigint NOT NULL,
    name character varying(255),
    dataset_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
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
-- Name: transcript_fpkm_tracking_informations; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE transcript_fpkm_tracking_informations (
    transcript_id bigint NOT NULL,
    class_code character varying(255),
    length integer,
    coverage numeric,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: transcript_has_go_terms; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE transcript_has_go_terms (
    transcript_id integer NOT NULL,
    go_term_id character varying(255) NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: transcripts; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE transcripts (
    id bigint NOT NULL,
    dataset_id bigint NOT NULL,
    gene_id bigint,
    fasta_sequence text,
    name_from_program character varying(255) NOT NULL,
    fasta_description character varying(255),
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
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
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    admin boolean
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

ALTER TABLE ONLY job2s ALTER COLUMN id SET DEFAULT nextval('job2s_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY jobs ALTER COLUMN id SET DEFAULT nextval('jobs_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY samples ALTER COLUMN id SET DEFAULT nextval('samples_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY transcripts ALTER COLUMN id SET DEFAULT nextval('transcripts_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY users ALTER COLUMN id SET DEFAULT nextval('users_id_seq'::regclass);


--
-- Name: blast_graphical_summary_locators_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY blast_graphical_summary_locators
    ADD CONSTRAINT blast_graphical_summary_locators_pkey PRIMARY KEY (basename);


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
-- Name: job2s_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY job2s
    ADD CONSTRAINT job2s_pkey PRIMARY KEY (id);


--
-- Name: jobs_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY jobs
    ADD CONSTRAINT jobs_pkey PRIMARY KEY (id);


--
-- Name: sample_comparisons_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY sample_comparisons
    ADD CONSTRAINT sample_comparisons_pkey PRIMARY KEY (sample_1_id, sample_2_id);


--
-- Name: samples_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY samples
    ADD CONSTRAINT samples_pkey PRIMARY KEY (id);


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
-- Name: index_users_on_email; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_users_on_email ON users USING btree (email);


--
-- Name: index_users_on_reset_password_token; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_users_on_reset_password_token ON users USING btree (reset_password_token);


--
-- Name: unique_schema_migrations; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX unique_schema_migrations ON schema_migrations USING btree (version);


--
-- Name: blast_graphical_summary_locators_datasets_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY blast_graphical_summary_locators
    ADD CONSTRAINT blast_graphical_summary_locators_datasets_fk FOREIGN KEY (dataset_id) REFERENCES datasets(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: datasets_users_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY datasets
    ADD CONSTRAINT datasets_users_fk FOREIGN KEY (user_id) REFERENCES users(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: differential_expression_tests_fpkm_sample_1_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY differential_expression_tests
    ADD CONSTRAINT differential_expression_tests_fpkm_sample_1_fk FOREIGN KEY (fpkm_sample_1_id) REFERENCES fpkm_samples(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: differential_expression_tests_fpkm_sample_2_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY differential_expression_tests
    ADD CONSTRAINT differential_expression_tests_fpkm_sample_2_fk FOREIGN KEY (fpkm_sample_2_id) REFERENCES fpkm_samples(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: differential_expression_tests_genes_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY differential_expression_tests
    ADD CONSTRAINT differential_expression_tests_genes_fk FOREIGN KEY (gene_id) REFERENCES genes(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: differential_expression_tests_transcripts_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY differential_expression_tests
    ADD CONSTRAINT differential_expression_tests_transcripts_fk FOREIGN KEY (transcript_id) REFERENCES transcripts(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: fpkm_samples_genes_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY fpkm_samples
    ADD CONSTRAINT fpkm_samples_genes_fk FOREIGN KEY (gene_id) REFERENCES genes(id) ON UPDATE CASCADE ON DELETE CASCADE;


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
-- Name: genes_datasets_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY genes
    ADD CONSTRAINT genes_datasets_fk FOREIGN KEY (dataset_id) REFERENCES datasets(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: jobs_users_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY jobs
    ADD CONSTRAINT jobs_users_fk FOREIGN KEY (user_id) REFERENCES users(id) ON UPDATE CASCADE ON DELETE RESTRICT;


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

INSERT INTO schema_migrations (version) VALUES ('10');

INSERT INTO schema_migrations (version) VALUES ('11');

INSERT INTO schema_migrations (version) VALUES ('12');

INSERT INTO schema_migrations (version) VALUES ('13');

INSERT INTO schema_migrations (version) VALUES ('14');

INSERT INTO schema_migrations (version) VALUES ('15');

INSERT INTO schema_migrations (version) VALUES ('16');

INSERT INTO schema_migrations (version) VALUES ('17');

INSERT INTO schema_migrations (version) VALUES ('2');

INSERT INTO schema_migrations (version) VALUES ('3');

INSERT INTO schema_migrations (version) VALUES ('4');

INSERT INTO schema_migrations (version) VALUES ('5');

INSERT INTO schema_migrations (version) VALUES ('6');

INSERT INTO schema_migrations (version) VALUES ('7');

INSERT INTO schema_migrations (version) VALUES ('8');

INSERT INTO schema_migrations (version) VALUES ('9');