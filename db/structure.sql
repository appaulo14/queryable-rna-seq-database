CREATE TABLE `datasets` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `user_id` int(11) NOT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `datasets_users_fk` (`user_id`),
  CONSTRAINT `datasets_users_fk` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `differential_expression_tests` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `fpkm_sample_1_id` bigint(20) unsigned NOT NULL,
  `fpkm_sample_2_id` bigint(20) unsigned NOT NULL,
  `gene_id` bigint(20) unsigned DEFAULT NULL,
  `transcript_id` bigint(20) unsigned DEFAULT NULL,
  `test_status` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `log_fold_change` decimal(10,0) DEFAULT NULL,
  `p_value` decimal(10,0) NOT NULL,
  `q_value` decimal(10,0) NOT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `differential_expression_tests_genes_fk` (`gene_id`),
  KEY `differential_expression_tests_transcripts_fk` (`transcript_id`),
  KEY `differential_expression_tests_fpkm_sample_1_fk` (`fpkm_sample_1_id`),
  KEY `differential_expression_tests_fpkm_sample_2_fk` (`fpkm_sample_2_id`),
  CONSTRAINT `differential_expression_tests_fpkm_sample_2_fk` FOREIGN KEY (`fpkm_sample_2_id`) REFERENCES `fpkm_samples` (`id`) ON UPDATE CASCADE,
  CONSTRAINT `differential_expression_tests_fpkm_sample_1_fk` FOREIGN KEY (`fpkm_sample_1_id`) REFERENCES `fpkm_samples` (`id`) ON UPDATE CASCADE,
  CONSTRAINT `differential_expression_tests_genes_fk` FOREIGN KEY (`gene_id`) REFERENCES `genes` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `differential_expression_tests_transcripts_fk` FOREIGN KEY (`transcript_id`) REFERENCES `transcripts` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
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
  PRIMARY KEY (`id`),
  KEY `fpkm_samples_genes_fk` (`gene_id`),
  KEY `fpkm_samples_transcripts_fk` (`transcript_id`),
  CONSTRAINT `fpkm_samples_transcripts_fk` FOREIGN KEY (`transcript_id`) REFERENCES `transcripts` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fpkm_samples_genes_fk` FOREIGN KEY (`gene_id`) REFERENCES `genes` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `gene_has_go_term` (
  `gene_id` int(11) DEFAULT NULL,
  `go_term_id` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `genes` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `dataset_id` bigint(20) unsigned NOT NULL,
  `name_from_program` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `genes_datasets_fk` (`dataset_id`),
  CONSTRAINT `genes_datasets_fk` FOREIGN KEY (`dataset_id`) REFERENCES `datasets` (`id`) ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `go_terms` (
  `id` varchar(255) COLLATE utf8_unicode_ci NOT NULL DEFAULT '',
  `term` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
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

CREATE TABLE `jobs` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `current_job_status` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `current_program_status` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `user_id` int(11) NOT NULL,
  `workflow_step_id` int(11) DEFAULT NULL,
  `output_files_type` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `jobs_users_fk` (`user_id`),
  CONSTRAINT `jobs_users_fk` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `schema_migrations` (
  `version` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  UNIQUE KEY `unique_schema_migrations` (`version`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `transcript_fpkm_tracking_informations` (
  `transcript_id` bigint(20) unsigned NOT NULL DEFAULT '0',
  `class_code` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `length` int(11) DEFAULT NULL,
  `coverage` decimal(10,0) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`transcript_id`),
  CONSTRAINT `transcript_fpkm_tracking_informations_transripts_fk` FOREIGN KEY (`transcript_id`) REFERENCES `transcripts` (`id`) ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `transcripts` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `dataset_id` bigint(20) unsigned NOT NULL,
  `gene_id` bigint(20) unsigned DEFAULT NULL,
  `fasta_sequence` longtext COLLATE utf8_unicode_ci,
  `name_from_program` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `fasta_description` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `transripts_datasets_fk` (`dataset_id`),
  KEY `transripts_genes_fk` (`gene_id`),
  CONSTRAINT `transripts_genes_fk` FOREIGN KEY (`gene_id`) REFERENCES `genes` (`id`) ON UPDATE CASCADE,
  CONSTRAINT `transripts_datasets_fk` FOREIGN KEY (`dataset_id`) REFERENCES `datasets` (`id`) ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `users` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `email` varchar(255) COLLATE utf8_unicode_ci NOT NULL DEFAULT '',
  `encrypted_password` varchar(255) COLLATE utf8_unicode_ci NOT NULL DEFAULT '',
  `reset_password_token` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `reset_password_sent_at` datetime DEFAULT NULL,
  `remember_created_at` datetime DEFAULT NULL,
  `sign_in_count` int(11) DEFAULT '0',
  `current_sign_in_at` datetime DEFAULT NULL,
  `last_sign_in_at` datetime DEFAULT NULL,
  `current_sign_in_ip` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `last_sign_in_ip` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `admin` tinyint(1) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_users_on_email` (`email`),
  UNIQUE KEY `index_users_on_reset_password_token` (`reset_password_token`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

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