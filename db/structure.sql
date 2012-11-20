CREATE TABLE `differential_expression_tests` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `fpkm_sample_1_id` bigint(20) unsigned DEFAULT NULL,
  `fpkm_sample_2_id` bigint(20) unsigned DEFAULT NULL,
  `test_status` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `log2_fold_change` decimal(10,0) DEFAULT NULL,
  `p_value` decimal(10,0) DEFAULT NULL,
  `q_value` decimal(10,0) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `fpkm_samples` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `gene_id` bigint(20) unsigned DEFAULT NULL,
  `transcript_id` bigint(20) unsigned DEFAULT NULL,
  `sample_name` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `fpkm` decimal(10,0) NOT NULL,
  `fpkm_hi` decimal(10,0) DEFAULT NULL,
  `fpkm_lo` decimal(10,0) DEFAULT NULL,
  `status` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `genes` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `job_id` bigint(20) unsigned NOT NULL,
  `name_from_program` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `job2s` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `eid_of_owner` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `current_program_display_name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `workflow` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `current_step` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `next_step` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `number_of_samples` int(11) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `job_statuses` (
  `name` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `description` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `jobs` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `current_job_status` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `current_program_status` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `email` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `workflow_step_id` int(11) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `program_statuses` (
  `internal_name` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `display_name` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`internal_name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `programs` (
  `internal_name` varchar(255) COLLATE utf8_unicode_ci NOT NULL DEFAULT '',
  `display_name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`internal_name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `samples` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `sample_id` int(11) DEFAULT NULL,
  `job_id` int(11) DEFAULT NULL,
  `status` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `schema_migrations` (
  `version` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  UNIQUE KEY `unique_schema_migrations` (`version`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `test_statuses` (
  `name` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `description` text COLLATE utf8_unicode_ci,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `transcripts` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `job_id` bigint(20) unsigned NOT NULL,
  `gene_id` bigint(20) unsigned DEFAULT NULL,
  `fasta_sequence` longtext COLLATE utf8_unicode_ci,
  `name_from_program` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `fasta_description` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `users` (
  `eid` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `email` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`eid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `workflow_steps` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `workflow_id` int(11) DEFAULT NULL,
  `program_internal_name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `step` int(11) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `workflows_fk` (`workflow_id`),
  KEY `programs_fk` (`program_internal_name`),
  CONSTRAINT `programs_fk` FOREIGN KEY (`program_internal_name`) REFERENCES `programs` (`internal_name`) ON UPDATE CASCADE,
  CONSTRAINT `workflows_fk` FOREIGN KEY (`workflow_id`) REFERENCES `workflows` (`id`) ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `workflows` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `display_name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

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