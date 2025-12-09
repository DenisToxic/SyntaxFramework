-- Existing Accounts
CREATE TABLE IF NOT EXISTS `syntax_accounts` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `identifier` varchar(60) NOT NULL,
  `license` varchar(60) DEFAULT NULL,
  `name` varchar(255) DEFAULT NULL,
  `last_seen` timestamp NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `identifier` (`identifier`)
);

-- Characters (Phase 2)
CREATE TABLE IF NOT EXISTS `syntax_characters` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `account_id` int(11) NOT NULL,
  `first_name` varchar(50) NOT NULL,
  `last_name` varchar(50) NOT NULL,
  `dob` varchar(10) NOT NULL,
  `gender` varchar(10) NOT NULL,
  `position` longtext DEFAULT '{"x":-1037.74,"y":-2738.04,"z":20.169}',
  `job` varchar(50) DEFAULT 'unemployed',
  `job_grade` int(11) DEFAULT 0,
  `cash` int(11) DEFAULT 0,
  `bank` int(11) DEFAULT 5000,
  `skin` longtext DEFAULT '{}',
  `is_deleted` tinyint(1) DEFAULT 0,
  PRIMARY KEY (`id`),
  KEY `account_id` (`account_id`),
  CONSTRAINT `fk_account` FOREIGN KEY (`account_id`) REFERENCES `syntax_accounts` (`id`) ON DELETE CASCADE
);

-- Inventory (Phase 3)
CREATE TABLE IF NOT EXISTS `syntax_inventory` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `owner_type` varchar(50) NOT NULL, -- 'player', 'trunk', 'glovebox', 'stash'
  `owner_id` varchar(100) NOT NULL, -- char_id OR plate OR stash_name
  `slot` int(11) NOT NULL,
  `item` varchar(50) NOT NULL,
  `count` int(11) NOT NULL DEFAULT 1,
  `metadata` longtext DEFAULT '{}',
  PRIMARY KEY (`id`),
  UNIQUE KEY `unique_slot` (`owner_type`, `owner_id`, `slot`)
);