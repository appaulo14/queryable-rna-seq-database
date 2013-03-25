CREATE TABLE `datasets` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `program_used` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `has_transcript_diff_exp` tinyint(1) NOT NULL,
  `has_transcript_isoforms` tinyint(1) NOT NULL,
  `has_gene_diff_exp` tinyint(1) NOT NULL,
  `blast_db_location` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `user_id` int(11) NOT NULL,
  `when_last_queried` datetime DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `datasets_users_fk` (`user_id`),
  CONSTRAINT `datasets_users_fk` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `differential_expression_tests` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `gene_id` bigint(20) unsigned DEFAULT NULL,
  `transcript_id` bigint(20) unsigned DEFAULT NULL,
  `sample_comparison_id` int(11) NOT NULL,
  `test_status` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `sample_1_fpkm` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `sample_2_fpkm` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `log_fold_change` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `test_statistic` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `p_value` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `fdr` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  PRIMARY KEY (`id`),
  KEY `differential_expression_tests_genes_fk` (`gene_id`),
  KEY `differential_expression_tests_transcripts_fk` (`transcript_id`),
  KEY `differential_expression_tests_sample_comparisons_fk` (`sample_comparison_id`),
  CONSTRAINT `differential_expression_tests_sample_comparisons_fk` FOREIGN KEY (`sample_comparison_id`) REFERENCES `sample_comparisons` (`id`) ON UPDATE CASCADE,
  CONSTRAINT `differential_expression_tests_genes_fk` FOREIGN KEY (`gene_id`) REFERENCES `genes` (`id`) ON UPDATE CASCADE,
  CONSTRAINT `differential_expression_tests_transcripts_fk` FOREIGN KEY (`transcript_id`) REFERENCES `transcripts` (`id`) ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `fpkm_samples` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `transcript_id` bigint(20) unsigned NOT NULL,
  `sample_id` int(11) NOT NULL,
  `fpkm` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `fpkm_hi` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `fpkm_lo` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `status` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `fpkm_samples_transcripts_fk` (`transcript_id`),
  KEY `fpkm_samples_samples_fk` (`sample_id`),
  CONSTRAINT `fpkm_samples_samples_fk` FOREIGN KEY (`sample_id`) REFERENCES `samples` (`id`) ON UPDATE CASCADE,
  CONSTRAINT `fpkm_samples_transcripts_fk` FOREIGN KEY (`transcript_id`) REFERENCES `transcripts` (`id`) ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `genes` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `dataset_id` int(11) NOT NULL,
  `name_from_program` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  PRIMARY KEY (`id`),
  KEY `genes_datasets_fk` (`dataset_id`),
  CONSTRAINT `genes_datasets_fk` FOREIGN KEY (`dataset_id`) REFERENCES `datasets` (`id`) ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `go_terms` (
  `id` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `term` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `sample_comparisons` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `sample_1_id` int(11) NOT NULL,
  `sample_2_id` int(11) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `samples` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `sample_type` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `dataset_id` int(11) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `schema_migrations` (
  `version` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  UNIQUE KEY `unique_schema_migrations` (`version`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `simple_captcha_data` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `key` varchar(40) COLLATE utf8_unicode_ci DEFAULT NULL,
  `value` varchar(6) COLLATE utf8_unicode_ci DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `idx_key` (`key`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `transcript_fpkm_tracking_informations` (
  `transcript_id` bigint(20) unsigned NOT NULL,
  `class_code` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `length` int(11) NOT NULL,
  `coverage` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`transcript_id`),
  CONSTRAINT `transcript_fpkm_tracking_informations_transripts_fk` FOREIGN KEY (`transcript_id`) REFERENCES `transcripts` (`id`) ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `transcript_has_go_terms` (
  `transcript_id` bigint(20) unsigned NOT NULL,
  `go_term_id` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  PRIMARY KEY (`transcript_id`,`go_term_id`),
  KEY `transcript_has_go_terms_go_terms_fk` (`go_term_id`),
  CONSTRAINT `transcript_has_go_terms_go_terms_fk` FOREIGN KEY (`go_term_id`) REFERENCES `go_terms` (`id`) ON UPDATE CASCADE,
  CONSTRAINT `transcript_has_go_terms_transcripts_fk` FOREIGN KEY (`transcript_id`) REFERENCES `transcripts` (`id`) ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `transcripts` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `gene_id` bigint(20) unsigned DEFAULT NULL,
  `dataset_id` int(11) NOT NULL,
  `name_from_program` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  PRIMARY KEY (`id`),
  KEY `transripts_datasets_fk` (`dataset_id`),
  KEY `transripts_genes_fk` (`gene_id`),
  CONSTRAINT `transripts_genes_fk` FOREIGN KEY (`gene_id`) REFERENCES `genes` (`id`) ON DELETE SET NULL ON UPDATE CASCADE,
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
  `confirmation_token` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `confirmed_at` datetime DEFAULT NULL,
  `confirmation_sent_at` datetime DEFAULT NULL,
  `unconfirmed_email` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `failed_attempts` int(11) DEFAULT '0',
  `unlock_token` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `locked_at` datetime DEFAULT NULL,
  `name` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `description` text COLLATE utf8_unicode_ci NOT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `admin` tinyint(1) NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_users_on_email` (`email`),
  UNIQUE KEY `index_users_on_reset_password_token` (`reset_password_token`),
  UNIQUE KEY `index_users_on_confirmation_token` (`confirmation_token`),
  UNIQUE KEY `index_users_on_unlock_token` (`unlock_token`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

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