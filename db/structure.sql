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
-- Name: differential_expression_tests; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE differential_expression_tests (
    id bigint NOT NULL,
    sample1 character varying(255) NOT NULL,
    sample2 character varying(255) NOT NULL,
    test_status_name character varying(255) NOT NULL,
    fpkm_x numeric NOT NULL,
    fpkm_y numeric NOT NULL,
    log2_y_over_x numeric NOT NULL,
    test_stat numeric NOT NULL,
    p_value numeric NOT NULL,
    q_value numeric NOT NULL,
    is_significant boolean NOT NULL,
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
    sample_number smallint NOT NULL,
    q_fpkm numeric NOT NULL,
    q_fpkm_hi numeric NOT NULL,
    q_fpkm_lo numeric NOT NULL,
    q_status character varying(255) NOT NULL,
    transcript_id integer NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: genes; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE genes (
    id bigint NOT NULL,
    differential_expression_test_id bigint NOT NULL,
    job_id bigint NOT NULL,
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
-- Name: job_statuses; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE job_statuses (
    name character varying(255) NOT NULL,
    description character varying(255) NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: jobs; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE jobs (
    id bigint NOT NULL,
    current_job_status character varying(255),
    current_program_status character varying(255),
    eid_of_owner character varying(255),
    workflow_step_id integer,
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
-- Name: program_statuses; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE program_statuses (
    internal_name character varying(255) NOT NULL,
    display_name character varying(255) NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: programs; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE programs (
    internal_name character varying(255) NOT NULL,
    display_name character varying(255),
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: samples; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE samples (
    id integer NOT NULL,
    sample_id integer,
    job_id integer,
    status character varying(255),
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
-- Name: test_statuses; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE test_statuses (
    name character varying(255) NOT NULL,
    description text,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: transcripts; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE transcripts (
    id bigint NOT NULL,
    differential_expression_test_id bigint NOT NULL,
    job_id bigint NOT NULL,
    gene_id bigint,
    fasta_sequence text NOT NULL,
    name_from_program character varying(255) NOT NULL,
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
    eid character varying(255) NOT NULL,
    email character varying(255) NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: workflow_steps; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE workflow_steps (
    id integer NOT NULL,
    workflow_id integer,
    program_internal_name character varying(255),
    step integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: workflow_steps_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE workflow_steps_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: workflow_steps_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE workflow_steps_id_seq OWNED BY workflow_steps.id;


--
-- Name: workflows; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE workflows (
    id integer NOT NULL,
    display_name character varying(255),
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: workflows_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE workflows_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: workflows_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE workflows_id_seq OWNED BY workflows.id;


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY differential_expression_tests ALTER COLUMN id SET DEFAULT nextval('differential_expression_tests_id_seq'::regclass);


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

ALTER TABLE ONLY workflow_steps ALTER COLUMN id SET DEFAULT nextval('workflow_steps_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY workflows ALTER COLUMN id SET DEFAULT nextval('workflows_id_seq'::regclass);


--
-- Name: differential_expression_tests_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY differential_expression_tests
    ADD CONSTRAINT differential_expression_tests_pkey PRIMARY KEY (id);


--
-- Name: fpkm_samples_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY fpkm_samples
    ADD CONSTRAINT fpkm_samples_pkey PRIMARY KEY (sample_number, transcript_id);


--
-- Name: genes_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY genes
    ADD CONSTRAINT genes_pkey PRIMARY KEY (id);


--
-- Name: job2s_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY job2s
    ADD CONSTRAINT job2s_pkey PRIMARY KEY (id);


--
-- Name: job_statuses_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY job_statuses
    ADD CONSTRAINT job_statuses_pkey PRIMARY KEY (name);


--
-- Name: jobs_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY jobs
    ADD CONSTRAINT jobs_pkey PRIMARY KEY (id);


--
-- Name: program_statuses_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY program_statuses
    ADD CONSTRAINT program_statuses_pkey PRIMARY KEY (internal_name);


--
-- Name: programs_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY programs
    ADD CONSTRAINT programs_pkey PRIMARY KEY (internal_name);


--
-- Name: samples_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY samples
    ADD CONSTRAINT samples_pkey PRIMARY KEY (id);


--
-- Name: test_statuses_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY test_statuses
    ADD CONSTRAINT test_statuses_pkey PRIMARY KEY (name);


--
-- Name: transcripts_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY transcripts
    ADD CONSTRAINT transcripts_pkey PRIMARY KEY (id);


--
-- Name: users_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY users
    ADD CONSTRAINT users_pkey PRIMARY KEY (eid);


--
-- Name: workflow_steps_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY workflow_steps
    ADD CONSTRAINT workflow_steps_pkey PRIMARY KEY (id);


--
-- Name: workflows_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY workflows
    ADD CONSTRAINT workflows_pkey PRIMARY KEY (id);


--
-- Name: unique_schema_migrations; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX unique_schema_migrations ON schema_migrations USING btree (version);


--
-- Name: programs_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY workflow_steps
    ADD CONSTRAINT programs_fk FOREIGN KEY (program_internal_name) REFERENCES programs(internal_name) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: workflows_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY workflow_steps
    ADD CONSTRAINT workflows_fk FOREIGN KEY (workflow_id) REFERENCES workflows(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- PostgreSQL database dump complete
--

INSERT INTO schema_migrations (version) VALUES ('20120918175550');

INSERT INTO schema_migrations (version) VALUES ('20121001194311');

INSERT INTO schema_migrations (version) VALUES ('20121001194456');

INSERT INTO schema_migrations (version) VALUES ('20121007022600');

INSERT INTO schema_migrations (version) VALUES ('20121007022942');

INSERT INTO schema_migrations (version) VALUES ('20121007023053');

INSERT INTO schema_migrations (version) VALUES ('20121007023055');

INSERT INTO schema_migrations (version) VALUES ('20121007023056');

INSERT INTO schema_migrations (version) VALUES ('20121007023057');

INSERT INTO schema_migrations (version) VALUES ('20121007023058');

INSERT INTO schema_migrations (version) VALUES ('20121007023059');

INSERT INTO schema_migrations (version) VALUES ('20121007023060');

INSERT INTO schema_migrations (version) VALUES ('20121007023061');

INSERT INTO schema_migrations (version) VALUES ('20121007023062');