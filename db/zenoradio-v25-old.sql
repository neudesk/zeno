SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0;
SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0;
SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='TRADITIONAL,ALLOW_INVALID_DATES';

DROP SCHEMA IF EXISTS `zenoradio-v25` ;
CREATE SCHEMA IF NOT EXISTS `zenoradio-v25` DEFAULT CHARACTER SET utf8 ;
SHOW WARNINGS;
USE `zenoradio-v25` ;

-- -----------------------------------------------------
-- Table `zenoradio-v25`.`data_group_advertise_agency`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `zenoradio-v25`.`data_group_advertise_agency` ;

SHOW WARNINGS;
CREATE  TABLE IF NOT EXISTS `zenoradio-v25`.`data_group_advertise_agency` (
  `id` BIGINT(19) UNSIGNED NOT NULL AUTO_INCREMENT ,
  `title` CHAR(200) NULL DEFAULT NULL ,
  `is_deleted` TINYINT(1) NULL DEFAULT '0' ,
  PRIMARY KEY (`id`) )
ENGINE = InnoDB;

SHOW WARNINGS;

-- -----------------------------------------------------
-- Table `zenoradio-v25`.`data_campaign`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `zenoradio-v25`.`data_campaign` ;

SHOW WARNINGS;
CREATE  TABLE IF NOT EXISTS `zenoradio-v25`.`data_campaign` (
  `id` BIGINT(19) UNSIGNED NOT NULL AUTO_INCREMENT ,
  `title` CHAR(200) NULL DEFAULT NULL ,
  `advertise_agency_id` BIGINT(19) UNSIGNED NULL DEFAULT NULL ,
  `active` TINYINT(1) NULL DEFAULT 0 ,
  `date_limit_start` DATE NULL ,
  `date_limit_stop` DATE NULL ,
  `date_limit_weekday_sun` TINYINT(1) NULL DEFAULT 1 ,
  `date_limit_weekday_mon` TINYINT(1) NULL DEFAULT 1 ,
  `date_limit_weekday_tue` TINYINT(1) NULL DEFAULT 1 ,
  `date_limit_weekday_wed` TINYINT(1) NULL DEFAULT 1 ,
  `date_limit_weekday_thu` TINYINT(1) NULL DEFAULT 1 ,
  `date_limit_weekday_fri` TINYINT(1) NULL DEFAULT 1 ,
  `date_limit_weekday_sat` TINYINT(1) NULL DEFAULT 1 ,
  `budget_cost_limit` DOUBLE NULL DEFAULT 99999 ,
  `budget_cost_balance` DOUBLE NULL DEFAULT 0 COMMENT 'Temporary hardcode balance. Future balance need look at log_conference\n' ,
  `media_interruption_enabled` TINYINT(1) NULL DEFAULT 0 ,
  `media_interruption_limit_play_per_unique_listener_count` INT UNSIGNED NULL DEFAULT 0 ,
  `media_interruption_limit_play_per_unique_listener_minutes_window` INT UNSIGNED NULL DEFAULT 0 ,
  `media_interruption_cost_per_play` FLOAT UNSIGNED NULL DEFAULT 0 ,
  `media_interruption_cost_per_unique_listener` FLOAT UNSIGNED NULL DEFAULT 0 ,
  `media_interruption_entryway_commission_per_play` FLOAT UNSIGNED NULL DEFAULT 0 ,
  `media_interruption_entryway_commission_per_unique_listener` FLOAT UNSIGNED NULL DEFAULT 0 ,
  `media_interruption_gateway_commission_per_play` FLOAT UNSIGNED NULL DEFAULT 0 ,
  `media_interruption_gateway_commission_per_unique_listener` FLOAT UNSIGNED NULL DEFAULT 0 ,
  `media_interruption_content_commission_per_play` FLOAT UNSIGNED NULL DEFAULT 0 ,
  `media_interruption_content_commission_per_unique_listener` FLOAT UNSIGNED NULL DEFAULT 0 ,
  `media_request_enabled` TINYINT(1) NULL DEFAULT 0 ,
  `media_request_cost_per_play` FLOAT UNSIGNED NULL DEFAULT 0 ,
  `media_request_cost_per_unique_listener` FLOAT UNSIGNED NULL DEFAULT 0 ,
  `media_request_entryway_commission_per_play` FLOAT UNSIGNED NULL DEFAULT 0 ,
  `media_request_entryway_commission_per_unique_listener` FLOAT UNSIGNED NULL DEFAULT 0 ,
  `media_request_gateway_commission_per_play` FLOAT UNSIGNED NULL DEFAULT 0 ,
  `media_request_gateway_commission_per_unique_listener` FLOAT UNSIGNED NULL DEFAULT 0 ,
  `media_request_content_commission_per_play` FLOAT UNSIGNED NULL DEFAULT 0 ,
  `media_request_content_commission_per_unique_listener` FLOAT UNSIGNED NULL DEFAULT 0 ,
  PRIMARY KEY (`id`) ,
  CONSTRAINT `fk_data_campaign_1`
    FOREIGN KEY (`advertise_agency_id` )
    REFERENCES `zenoradio-v25`.`data_group_advertise_agency` (`id` )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;

SHOW WARNINGS;
CREATE INDEX `fk_data_campaign_1` ON `zenoradio-v25`.`data_campaign` (`advertise_agency_id` ASC) ;

SHOW WARNINGS;

-- -----------------------------------------------------
-- Table `zenoradio-v25`.`data_campaign_media_binary`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `zenoradio-v25`.`data_campaign_media_binary` ;

SHOW WARNINGS;
CREATE  TABLE IF NOT EXISTS `zenoradio-v25`.`data_campaign_media_binary` (
  `id` BIGINT(19) UNSIGNED NOT NULL AUTO_INCREMENT ,
  `binary` LONGBLOB NULL DEFAULT NULL ,
  PRIMARY KEY (`id`) )
ENGINE = InnoDB;

SHOW WARNINGS;

-- -----------------------------------------------------
-- Table `zenoradio-v25`.`data_campaign_media`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `zenoradio-v25`.`data_campaign_media` ;

SHOW WARNINGS;
CREATE  TABLE IF NOT EXISTS `zenoradio-v25`.`data_campaign_media` (
  `id` BIGINT(19) UNSIGNED NOT NULL AUTO_INCREMENT ,
  `campaign_id` BIGINT UNSIGNED NULL DEFAULT NULL ,
  `type` ENUM('INTERRUPTION','REQUEST') NULL ,
  `type_order` INT NULL ,
  `title` CHAR(200) NULL DEFAULT NULL ,
  `date_last_change` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP ,
  `binary_id` BIGINT UNSIGNED NULL ,
  `binary_kb` INT UNSIGNED NULL DEFAULT 0 ,
  `binary_seconds` INT UNSIGNED NULL DEFAULT 0 ,
  PRIMARY KEY (`id`) ,
  CONSTRAINT `fk_data_campaign_prompt_1`
    FOREIGN KEY (`campaign_id` )
    REFERENCES `zenoradio-v25`.`data_campaign` (`id` )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_data_campaign_prompt_2`
    FOREIGN KEY (`binary_id` )
    REFERENCES `zenoradio-v25`.`data_campaign_media_binary` (`id` )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;

SHOW WARNINGS;
CREATE INDEX `fk_data_campaign_prompt_1` ON `zenoradio-v25`.`data_campaign_media` (`campaign_id` ASC) ;

SHOW WARNINGS;
CREATE INDEX `fk_data_campaign_prompt_2` ON `zenoradio-v25`.`data_campaign_media` (`binary_id` ASC) ;

SHOW WARNINGS;
CREATE INDEX `TYPE` ON `zenoradio-v25`.`data_campaign_media` (`type` ASC) ;

SHOW WARNINGS;
CREATE INDEX `PL_ORDER` ON `zenoradio-v25`.`data_campaign_media` (`type_order` ASC) ;

SHOW WARNINGS;

-- -----------------------------------------------------
-- Table `zenoradio-v25`.`data_group_broadcast`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `zenoradio-v25`.`data_group_broadcast` ;

SHOW WARNINGS;
CREATE  TABLE IF NOT EXISTS `zenoradio-v25`.`data_group_broadcast` (
  `id` BIGINT(19) UNSIGNED NOT NULL AUTO_INCREMENT ,
  `title` CHAR(200) NULL DEFAULT NULL ,
  `is_deleted` TINYINT(1) NULL DEFAULT '0' ,
  PRIMARY KEY (`id`) )
ENGINE = InnoDB;

SHOW WARNINGS;

-- -----------------------------------------------------
-- Table `zenoradio-v25`.`data_group_country`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `zenoradio-v25`.`data_group_country` ;

SHOW WARNINGS;
CREATE  TABLE IF NOT EXISTS `zenoradio-v25`.`data_group_country` (
  `id` CHAR(2) NOT NULL ,
  `title` CHAR(200) NULL DEFAULT NULL ,
  `is_deleted` TINYINT(1) NULL DEFAULT '0' ,
  PRIMARY KEY (`id`) )
ENGINE = InnoDB
COMMENT = 'populate with ISO country table at http://www.iso.org/iso/co';

SHOW WARNINGS;

-- -----------------------------------------------------
-- Table `zenoradio-v25`.`data_group_language`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `zenoradio-v25`.`data_group_language` ;

SHOW WARNINGS;
CREATE  TABLE IF NOT EXISTS `zenoradio-v25`.`data_group_language` (
  `id` BIGINT(19) UNSIGNED NOT NULL AUTO_INCREMENT ,
  `title` CHAR(200) NULL DEFAULT NULL ,
  `is_deleted` TINYINT(1) NULL DEFAULT '0' ,
  PRIMARY KEY (`id`) )
ENGINE = InnoDB;

SHOW WARNINGS;

-- -----------------------------------------------------
-- Table `zenoradio-v25`.`data_group_genre`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `zenoradio-v25`.`data_group_genre` ;

SHOW WARNINGS;
CREATE  TABLE IF NOT EXISTS `zenoradio-v25`.`data_group_genre` (
  `id` BIGINT(19) UNSIGNED NOT NULL AUTO_INCREMENT ,
  `title` CHAR(200) NULL DEFAULT NULL ,
  `is_deleted` TINYINT(1) NULL DEFAULT '0' ,
  PRIMARY KEY (`id`) )
ENGINE = InnoDB;

SHOW WARNINGS;

-- -----------------------------------------------------
-- Table `zenoradio-v25`.`data_content`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `zenoradio-v25`.`data_content` ;

SHOW WARNINGS;
CREATE  TABLE IF NOT EXISTS `zenoradio-v25`.`data_content` (
  `id` BIGINT(19) UNSIGNED NOT NULL AUTO_INCREMENT ,
  `title` CHAR(200) NULL DEFAULT NULL ,
  `broadcast_id` BIGINT(19) UNSIGNED NULL DEFAULT NULL ,
  `country_id` CHAR(2) NULL DEFAULT NULL ,
  `language_id` BIGINT(19) UNSIGNED NULL DEFAULT NULL ,
  `genre_id` BIGINT(19) UNSIGNED NULL DEFAULT NULL ,
  `media_type` CHAR(32) NULL ,
  `media_url` CHAR(255) NULL ,
  `is_deleted` TINYINT(1) NULL DEFAULT 0 ,
  `flag_disable_advertise_forward` TINYINT(1) NULL DEFAULT 0 ,
  `flag_disable_advertise` TINYINT(1) NULL DEFAULT 0 ,
  `advertise_timmer_interval_minutes` INT UNSIGNED NULL DEFAULT 15 ,
  PRIMARY KEY (`id`) ,
  CONSTRAINT `fk_data_content_1`
    FOREIGN KEY (`broadcast_id` )
    REFERENCES `zenoradio-v25`.`data_group_broadcast` (`id` )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_data_content_2`
    FOREIGN KEY (`country_id` )
    REFERENCES `zenoradio-v25`.`data_group_country` (`id` )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_data_content_3`
    FOREIGN KEY (`language_id` )
    REFERENCES `zenoradio-v25`.`data_group_language` (`id` )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_data_content_4`
    FOREIGN KEY (`genre_id` )
    REFERENCES `zenoradio-v25`.`data_group_genre` (`id` )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;

SHOW WARNINGS;
CREATE INDEX `fk_data_content_1_idx` ON `zenoradio-v25`.`data_content` (`broadcast_id` ASC) ;

SHOW WARNINGS;
CREATE INDEX `fk_data_content_1_idx1` ON `zenoradio-v25`.`data_content` (`country_id` ASC) ;

SHOW WARNINGS;
CREATE INDEX `fk_data_content_1_idx2` ON `zenoradio-v25`.`data_content` (`language_id` ASC) ;

SHOW WARNINGS;
CREATE INDEX `gener_idx` ON `zenoradio-v25`.`data_content` (`genre_id` ASC) ;

SHOW WARNINGS;

-- -----------------------------------------------------
-- Table `zenoradio-v25`.`data_group_3rdparty`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `zenoradio-v25`.`data_group_3rdparty` ;

SHOW WARNINGS;
CREATE  TABLE IF NOT EXISTS `zenoradio-v25`.`data_group_3rdparty` (
  `id` BIGINT(19) UNSIGNED NOT NULL AUTO_INCREMENT ,
  `title` CHAR(200) NULL DEFAULT NULL ,
  `is_deleted` TINYINT(1) NULL DEFAULT '0' ,
  PRIMARY KEY (`id`) )
ENGINE = InnoDB;

SHOW WARNINGS;

-- -----------------------------------------------------
-- Table `zenoradio-v25`.`data_entryway_provider`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `zenoradio-v25`.`data_entryway_provider` ;

SHOW WARNINGS;
CREATE  TABLE IF NOT EXISTS `zenoradio-v25`.`data_entryway_provider` (
  `id` BIGINT(19) UNSIGNED NOT NULL AUTO_INCREMENT ,
  `title` CHAR(200) NULL DEFAULT NULL ,
  `flag_enable_advertise` TINYINT(1) NULL DEFAULT '1' ,
  `flag_enable_advertise_forward` TINYINT(1) NULL DEFAULT '1' ,
  PRIMARY KEY (`id`) )
ENGINE = InnoDB;

SHOW WARNINGS;

-- -----------------------------------------------------
-- Table `zenoradio-v25`.`data_group_rca`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `zenoradio-v25`.`data_group_rca` ;

SHOW WARNINGS;
CREATE  TABLE IF NOT EXISTS `zenoradio-v25`.`data_group_rca` (
  `id` BIGINT(19) UNSIGNED NOT NULL AUTO_INCREMENT ,
  `title` CHAR(200) NULL DEFAULT NULL ,
  `is_deleted` TINYINT(1) NULL DEFAULT '0' ,
  PRIMARY KEY (`id`) )
ENGINE = InnoDB;

SHOW WARNINGS;

-- -----------------------------------------------------
-- Table `zenoradio-v25`.`data_gateway_prompt_blob`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `zenoradio-v25`.`data_gateway_prompt_blob` ;

SHOW WARNINGS;
CREATE  TABLE IF NOT EXISTS `zenoradio-v25`.`data_gateway_prompt_blob` (
  `id` BIGINT(19) UNSIGNED NOT NULL ,
  `binary` LONGBLOB NULL DEFAULT NULL ,
  PRIMARY KEY (`id`) )
ENGINE = InnoDB;

SHOW WARNINGS;

-- -----------------------------------------------------
-- Table `zenoradio-v25`.`data_gateway_prompt`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `zenoradio-v25`.`data_gateway_prompt` ;

SHOW WARNINGS;
CREATE  TABLE IF NOT EXISTS `zenoradio-v25`.`data_gateway_prompt` (
  `id` BIGINT(19) UNSIGNED NOT NULL AUTO_INCREMENT ,
  `title` CHAR(200) NULL DEFAULT NULL ,
  `gateway_id` BIGINT(19) UNSIGNED NULL DEFAULT NULL ,
  `media_kb` INT(10) UNSIGNED NULL DEFAULT '0' ,
  `media_seconds` INT(10) UNSIGNED NULL DEFAULT '0' ,
  `date_last_change` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP on update CURRENT_TIMESTAMP ,
  PRIMARY KEY (`id`) ,
  CONSTRAINT `fk_data_gateway_prompt_1`
    FOREIGN KEY (`gateway_id` )
    REFERENCES `zenoradio-v25`.`data_gateway` (`id` )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_data_gateway_prompt_2`
    FOREIGN KEY (`id` )
    REFERENCES `zenoradio-v25`.`data_gateway_prompt_blob` (`id` )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;

SHOW WARNINGS;
CREATE INDEX `fk_data_gateway_prompt_1_idx` ON `zenoradio-v25`.`data_gateway_prompt` (`gateway_id` ASC) ;

SHOW WARNINGS;

-- -----------------------------------------------------
-- Table `zenoradio-v25`.`data_gateway`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `zenoradio-v25`.`data_gateway` ;

SHOW WARNINGS;
CREATE  TABLE IF NOT EXISTS `zenoradio-v25`.`data_gateway` (
  `id` BIGINT(19) UNSIGNED NOT NULL AUTO_INCREMENT ,
  `title` CHAR(200) NULL DEFAULT NULL ,
  `country_id` CHAR(2) NULL DEFAULT NULL ,
  `language_id` BIGINT(19) UNSIGNED NULL DEFAULT NULL ,
  `broadcast_id` BIGINT(19) UNSIGNED NULL DEFAULT NULL ,
  `rca_id` BIGINT(19) UNSIGNED NULL DEFAULT NULL ,
  `is_deleted` TINYINT(1) NULL DEFAULT '0' ,
  `empty_extension_rule` ENUM('ASK_AGAIN','PLAY_FIRST') NULL DEFAULT 'PLAY_FIRST' ,
  `empty_extension_threshold_count` TINYINT UNSIGNED NULL DEFAULT 2 ,
  `invalid_extension_rule` ENUM('ASK_AGAIN','PLAY_FIRST') NULL DEFAULT 'PLAY_FIRST' ,
  `invalid_extension_threshold_count` TINYINT UNSIGNED NULL DEFAULT 3 ,
  `ivr_welcome_enabled` TINYINT(1) NULL DEFAULT 1 ,
  `ivr_welcome_prompt_id` BIGINT UNSIGNED NULL ,
  `ivr_extension_ask_prompt_id` BIGINT UNSIGNED NULL ,
  `ivr_extension_invalid_enabled` TINYINT(1) NULL DEFAULT 1 ,
  `ivr_extension_invalid_prompt_id` BIGINT UNSIGNED NULL ,
  `flag_disable_advertise` TINYINT(1) NULL DEFAULT 0 ,
  `flag_disable_advertise_forward` TINYINT(1) NULL DEFAULT 0 ,
  PRIMARY KEY (`id`) ,
  CONSTRAINT `fk_data_gateway_1`
    FOREIGN KEY (`country_id` )
    REFERENCES `zenoradio-v25`.`data_group_country` (`id` )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_data_gateway_2`
    FOREIGN KEY (`language_id` )
    REFERENCES `zenoradio-v25`.`data_group_language` (`id` )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_data_gateway_3`
    FOREIGN KEY (`broadcast_id` )
    REFERENCES `zenoradio-v25`.`data_group_broadcast` (`id` )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_data_gateway_4`
    FOREIGN KEY (`rca_id` )
    REFERENCES `zenoradio-v25`.`data_group_rca` (`id` )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_data_gateway_5`
    FOREIGN KEY (`ivr_welcome_prompt_id` )
    REFERENCES `zenoradio-v25`.`data_gateway_prompt` (`id` )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_data_gateway_6`
    FOREIGN KEY (`ivr_extension_ask_prompt_id` )
    REFERENCES `zenoradio-v25`.`data_gateway_prompt` (`id` )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_data_gateway_7`
    FOREIGN KEY (`ivr_extension_invalid_prompt_id` )
    REFERENCES `zenoradio-v25`.`data_gateway_prompt` (`id` )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;

SHOW WARNINGS;
CREATE INDEX `fk_data_gateway_1_idx` ON `zenoradio-v25`.`data_gateway` (`country_id` ASC) ;

SHOW WARNINGS;
CREATE INDEX `fk_data_gateway_2_idx` ON `zenoradio-v25`.`data_gateway` (`language_id` ASC) ;

SHOW WARNINGS;
CREATE INDEX `fk_data_gateway_3_idx` ON `zenoradio-v25`.`data_gateway` (`broadcast_id` ASC) ;

SHOW WARNINGS;
CREATE INDEX `fk_data_gateway_4_idx` ON `zenoradio-v25`.`data_gateway` (`rca_id` ASC) ;

SHOW WARNINGS;
CREATE INDEX `fk_data_gateway_5` ON `zenoradio-v25`.`data_gateway` (`ivr_welcome_prompt_id` ASC) ;

SHOW WARNINGS;
CREATE INDEX `fk_data_gateway_6` ON `zenoradio-v25`.`data_gateway` (`ivr_extension_ask_prompt_id` ASC) ;

SHOW WARNINGS;
CREATE INDEX `fk_data_gateway_7` ON `zenoradio-v25`.`data_gateway` (`ivr_extension_invalid_prompt_id` ASC) ;

SHOW WARNINGS;
-- -----------------------------------------------------
-- Table `zenoradio-v25`.`data_entryway_provider`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `zenoradio-v25`.`data_entryway_provider` ;

SHOW WARNINGS;
CREATE  TABLE IF NOT EXISTS `zenoradio-v25`.`data_entryway_provider` (
  `id` BIGINT(19) UNSIGNED NOT NULL AUTO_INCREMENT ,
  `title` CHAR(200) NULL DEFAULT NULL ,
  `flag_disable_advertise` TINYINT(1) NULL DEFAULT 0 ,
  `flag_disable_advertise_forward` TINYINT(1) NULL DEFAULT 0 ,
  PRIMARY KEY (`id`))
-- -----------------------------------------------------
-- Table `zenoradio-v25`.`data_entryway`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `zenoradio-v25`.`data_entryway` ;

SHOW WARNINGS;
CREATE  TABLE IF NOT EXISTS `zenoradio-v25`.`data_entryway` (
  `id` BIGINT(19) UNSIGNED NOT NULL AUTO_INCREMENT ,
  `title` CHAR(200) NULL DEFAULT NULL ,
  `did_e164` CHAR(32) NULL DEFAULT NULL ,
  `gateway_id` BIGINT(19) UNSIGNED NULL DEFAULT NULL ,
  `country_id` CHAR(2) NULL DEFAULT NULL ,
  `3rdparty_id` BIGINT(19) UNSIGNED NULL DEFAULT NULL ,
  `entryway_provider` BIGINT(19) UNSIGNED NULL DEFAULT NULL ,
  `is_deleted` TINYINT(1) NULL DEFAULT '0' ,
  `is_default` TINYINT(1) NULL DEFAULT 0 ,
  `flag_disable_advertise` TINYINT(1) NULL DEFAULT 0 ,
  `flag_disable_advertise_forward` TINYINT(1) NULL DEFAULT 0 ,
  PRIMARY KEY (`id`) ,
  CONSTRAINT `3rdparty`
    FOREIGN KEY (`3rdparty_id` )
    REFERENCES `zenoradio-v25`.`data_group_3rdparty` (`id` )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `country`
    FOREIGN KEY (`country_id` )
    REFERENCES `zenoradio-v25`.`data_group_country` (`id` )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `entreway_provider`
    FOREIGN KEY (`entryway_provider` )
    REFERENCES `zenoradio-v25`.`data_entryway_provider` (`id` )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `gateway`
    FOREIGN KEY (`gateway_id` )
    REFERENCES `zenoradio-v25`.`data_gateway` (`id` )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;

SHOW WARNINGS;
CREATE INDEX `DID` ON `zenoradio-v25`.`data_entryway` (`did_e164` ASC) ;

SHOW WARNINGS;
CREATE INDEX `title` ON `zenoradio-v25`.`data_entryway` (`title` ASC) ;

SHOW WARNINGS;
CREATE INDEX `gateway` ON `zenoradio-v25`.`data_entryway` (`gateway_id` ASC) ;

SHOW WARNINGS;
CREATE INDEX `fk_data_entryway_1_idx` ON `zenoradio-v25`.`data_entryway` (`entryway_provider` ASC) ;

SHOW WARNINGS;
CREATE INDEX `fk_data_entryway_1_idx1` ON `zenoradio-v25`.`data_entryway` (`gateway_id` ASC) ;

SHOW WARNINGS;
CREATE INDEX `fk_data_entryway_1_idx2` ON `zenoradio-v25`.`data_entryway` (`3rdparty_id` ASC) ;

SHOW WARNINGS;
CREATE INDEX `fk_data_entryway_1_idx3` ON `zenoradio-v25`.`data_entryway` (`country_id` ASC) ;

SHOW WARNINGS;

-- -----------------------------------------------------
-- Table `zenoradio-v25`.`data_gateway_content`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `zenoradio-v25`.`data_gateway_content` ;

SHOW WARNINGS;
CREATE  TABLE IF NOT EXISTS `zenoradio-v25`.`data_gateway_content` (
  `id` BIGINT(19) UNSIGNED NOT NULL AUTO_INCREMENT ,
  `gateway_id` BIGINT(19) UNSIGNED NULL DEFAULT NULL ,
  `content_id` BIGINT(19) UNSIGNED NULL DEFAULT NULL ,
  `extension` CHAR(16) NULL DEFAULT NULL ,
  PRIMARY KEY (`id`) ,
  CONSTRAINT `fk_data_gateway_content_1`
    FOREIGN KEY (`gateway_id` )
    REFERENCES `zenoradio-v25`.`data_gateway` (`id` )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_data_gateway_content_2`
    FOREIGN KEY (`content_id` )
    REFERENCES `zenoradio-v25`.`data_content` (`id` )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;

SHOW WARNINGS;
CREATE INDEX `fk_data_gateway_content_1_idx` ON `zenoradio-v25`.`data_gateway_content` (`gateway_id` ASC) ;

SHOW WARNINGS;
CREATE INDEX `fk_data_gateway_content_2_idx` ON `zenoradio-v25`.`data_gateway_content` (`content_id` ASC) ;

SHOW WARNINGS;

-- -----------------------------------------------------
-- Table `zenoradio-v25`.`data_listener`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `zenoradio-v25`.`data_listener` ;

SHOW WARNINGS;
CREATE  TABLE IF NOT EXISTS `zenoradio-v25`.`data_listener` (
  `id` BIGINT(19) UNSIGNED NOT NULL AUTO_INCREMENT ,
  `title` CHAR(200) NULL DEFAULT NULL ,
  `flag_push_marketing_opt_in` TINYINT(1) NULL DEFAULT '0' ,
  PRIMARY KEY (`id`) )
ENGINE = InnoDB;

SHOW WARNINGS;

-- -----------------------------------------------------
-- Table `zenoradio-v25`.`data_listener_ani_carrier`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `zenoradio-v25`.`data_listener_ani_carrier` ;

SHOW WARNINGS;
CREATE  TABLE IF NOT EXISTS `zenoradio-v25`.`data_listener_ani_carrier` (
  `id` BIGINT(19) UNSIGNED NOT NULL AUTO_INCREMENT ,
  `title` CHAR(200) NULL DEFAULT NULL ,
  `data247_id` CHAR(32) NULL DEFAULT NULL ,
  `is_premium` TINYINT(1) NULL DEFAULT '0' ,
  `is_mobile` TINYINT(1) NULL DEFAULT '0' ,
  PRIMARY KEY (`id`) )
ENGINE = InnoDB;

SHOW WARNINGS;

-- -----------------------------------------------------
-- Table `zenoradio-v25`.`data_listener_ani`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `zenoradio-v25`.`data_listener_ani` ;

SHOW WARNINGS;
CREATE  TABLE IF NOT EXISTS `zenoradio-v25`.`data_listener_ani` (
  `id` BIGINT(19) UNSIGNED NOT NULL AUTO_INCREMENT ,
  `listener_id` BIGINT(19) UNSIGNED NULL DEFAULT NULL ,
  `ani_e164` CHAR(64) NULL DEFAULT NULL ,
  `carrier_id` BIGINT(19) UNSIGNED NULL DEFAULT NULL ,
  `carrier_last_check` DATETIME NULL DEFAULT NULL ,
  PRIMARY KEY (`id`) ,
  CONSTRAINT `fk_data_listener_ani_1`
    FOREIGN KEY (`listener_id` )
    REFERENCES `zenoradio-v25`.`data_listener` (`id` )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_data_listener_ani_2`
    FOREIGN KEY (`carrier_id` )
    REFERENCES `zenoradio-v25`.`data_listener_ani_carrier` (`id` )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;

SHOW WARNINGS;
CREATE INDEX `fk_data_listener_ani_1_idx` ON `zenoradio-v25`.`data_listener_ani` (`listener_id` ASC) ;

SHOW WARNINGS;
CREATE INDEX `fk_data_listener_ani_2_idx` ON `zenoradio-v25`.`data_listener_ani` (`carrier_id` ASC) ;

SHOW WARNINGS;
CREATE INDEX `lastcheck` ON `zenoradio-v25`.`data_listener_ani` (`carrier_last_check` ASC) ;

SHOW WARNINGS;
CREATE INDEX `ani` ON `zenoradio-v25`.`data_listener_ani` (`ani_e164` ASC) ;

SHOW WARNINGS;

-- -----------------------------------------------------
-- Table `zenoradio-v25`.`data_listener_at_campaign`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `zenoradio-v25`.`data_listener_at_campaign` ;

SHOW WARNINGS;
CREATE  TABLE IF NOT EXISTS `zenoradio-v25`.`data_listener_at_campaign` (
  `id` BIGINT(19) UNSIGNED NOT NULL AUTO_INCREMENT ,
  `listener_id` BIGINT(19) UNSIGNED NULL DEFAULT NULL ,
  `campaign_id` BIGINT(19) UNSIGNED NULL DEFAULT NULL ,
  `assigned_date` TIMESTAMP NULL DEFAULT NULL on update CURRENT_TIMESTAMP ,
  `last_session_date` DATETIME NULL DEFAULT NULL ,
  `statistics_inclusion_play_count` INT NULL DEFAULT 0 ,
  `statistics_listenerrequest_play_count` INT NULL DEFAULT 0 ,
  `statistics_inclusion_last_plays_timestamp` CHAR(255) NULL ,
  `statistics_listenerrequest_last_plays_timestamp` CHAR(255) NULL ,
  PRIMARY KEY (`id`) ,
  CONSTRAINT `fk_data_listener_at_campaign_1`
    FOREIGN KEY (`listener_id` )
    REFERENCES `zenoradio-v25`.`data_listener` (`id` )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_data_listener_at_campaign_2`
    FOREIGN KEY (`campaign_id` )
    REFERENCES `zenoradio-v25`.`data_campaign` (`id` )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;

SHOW WARNINGS;
CREATE INDEX `index2` ON `zenoradio-v25`.`data_listener_at_campaign` (`assigned_date` ASC) ;

SHOW WARNINGS;
CREATE INDEX `index5` ON `zenoradio-v25`.`data_listener_at_campaign` (`last_session_date` ASC) ;

SHOW WARNINGS;
CREATE INDEX `fk_data_listener_at_campaign_1_idx` ON `zenoradio-v25`.`data_listener_at_campaign` (`listener_id` ASC) ;

SHOW WARNINGS;
CREATE INDEX `fk_data_listener_at_campaign_2_idx` ON `zenoradio-v25`.`data_listener_at_campaign` (`campaign_id` ASC) ;

SHOW WARNINGS;

-- -----------------------------------------------------
-- Table `zenoradio-v25`.`data_listener_at_content`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `zenoradio-v25`.`data_listener_at_content` ;

SHOW WARNINGS;
CREATE  TABLE IF NOT EXISTS `zenoradio-v25`.`data_listener_at_content` (
  `id` BIGINT(19) UNSIGNED NOT NULL AUTO_INCREMENT ,
  `listener_id` BIGINT(19) UNSIGNED NULL DEFAULT NULL ,
  `content_id` BIGINT(19) UNSIGNED NULL DEFAULT NULL ,
  `assigned_date` TIMESTAMP NULL DEFAULT NULL on update CURRENT_TIMESTAMP ,
  `status` ENUM('NOT_ACTIVE','ACTIVE','LOST') NULL DEFAULT NULL ,
  `status_last_change_date` DATETIME NULL DEFAULT NULL ,
  `is_new` TINYINT(1) NULL DEFAULT '0' ,
  `is_return` TINYINT(1) NULL DEFAULT '0' ,
  `is_frequency_listen_dialy` TINYINT(1) NULL DEFAULT '0' ,
  `is_frequency_listen_weekly` TINYINT(1) NULL DEFAULT '0' ,
  `average_minutes_per_day` INT(11) NULL DEFAULT NULL ,
  `last_session_date` DATETIME NULL DEFAULT NULL ,
  PRIMARY KEY (`id`) ,
  CONSTRAINT `fk_data_listener_at_content_1`
    FOREIGN KEY (`listener_id` )
    REFERENCES `zenoradio-v25`.`data_listener` (`id` )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_data_listener_at_content_2`
    FOREIGN KEY (`content_id` )
    REFERENCES `zenoradio-v25`.`data_content` (`id` )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;

SHOW WARNINGS;
CREATE INDEX `index2` ON `zenoradio-v25`.`data_listener_at_content` (`assigned_date` ASC) ;

SHOW WARNINGS;
CREATE INDEX `index3` ON `zenoradio-v25`.`data_listener_at_content` (`status` ASC) ;

SHOW WARNINGS;
CREATE INDEX `index4` ON `zenoradio-v25`.`data_listener_at_content` (`status_last_change_date` ASC) ;

SHOW WARNINGS;
CREATE INDEX `index5` ON `zenoradio-v25`.`data_listener_at_content` (`last_session_date` ASC) ;

SHOW WARNINGS;
CREATE INDEX `index7` ON `zenoradio-v25`.`data_listener_at_content` (`is_new` ASC, `is_return` ASC) ;

SHOW WARNINGS;
CREATE INDEX `index8` ON `zenoradio-v25`.`data_listener_at_content` (`is_frequency_listen_dialy` ASC, `is_frequency_listen_weekly` ASC) ;

SHOW WARNINGS;
CREATE INDEX `fk_data_listener_at_content_1_idx` ON `zenoradio-v25`.`data_listener_at_content` (`listener_id` ASC) ;

SHOW WARNINGS;
CREATE INDEX `fk_data_listener_at_content_2_idx` ON `zenoradio-v25`.`data_listener_at_content` (`content_id` ASC) ;

SHOW WARNINGS;

-- -----------------------------------------------------
-- Table `zenoradio-v25`.`data_listener_at_entryway`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `zenoradio-v25`.`data_listener_at_entryway` ;

SHOW WARNINGS;
CREATE  TABLE IF NOT EXISTS `zenoradio-v25`.`data_listener_at_entryway` (
  `id` BIGINT(19) UNSIGNED NOT NULL AUTO_INCREMENT ,
  `listener_id` BIGINT(19) UNSIGNED NULL DEFAULT NULL ,
  `entryway_id` BIGINT(19) UNSIGNED NULL DEFAULT NULL ,
  `assigned_date` TIMESTAMP NULL DEFAULT NULL on update CURRENT_TIMESTAMP ,
  `status` ENUM('NOT_ACTIVE','ACTIVE','LOST') NULL DEFAULT NULL ,
  `status_last_change_date` DATETIME NULL DEFAULT NULL ,
  `is_new` TINYINT(1) NULL DEFAULT '0' ,
  `is_return` TINYINT(1) NULL DEFAULT '0' ,
  `is_frequency_listen_dialy` TINYINT(1) NULL DEFAULT '0' ,
  `is_frequency_listen_weekly` TINYINT(1) NULL DEFAULT '0' ,
  `average_minutes_per_day` INT(11) NULL DEFAULT NULL ,
  `last_session_date` DATETIME NULL DEFAULT NULL ,
  PRIMARY KEY (`id`) ,
  CONSTRAINT `fk_data_listener_at_entryway_1`
    FOREIGN KEY (`listener_id` )
    REFERENCES `zenoradio-v25`.`data_listener` (`id` )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_data_listener_at_entryway_2`
    FOREIGN KEY (`entryway_id` )
    REFERENCES `zenoradio-v25`.`data_entryway` (`id` )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;

SHOW WARNINGS;
CREATE INDEX `index2` ON `zenoradio-v25`.`data_listener_at_entryway` (`assigned_date` ASC) ;

SHOW WARNINGS;
CREATE INDEX `index3` ON `zenoradio-v25`.`data_listener_at_entryway` (`status` ASC) ;

SHOW WARNINGS;
CREATE INDEX `index4` ON `zenoradio-v25`.`data_listener_at_entryway` (`status_last_change_date` ASC) ;

SHOW WARNINGS;
CREATE INDEX `index5` ON `zenoradio-v25`.`data_listener_at_entryway` (`last_session_date` ASC) ;

SHOW WARNINGS;
CREATE INDEX `index7` ON `zenoradio-v25`.`data_listener_at_entryway` (`is_new` ASC, `is_return` ASC) ;

SHOW WARNINGS;
CREATE INDEX `index8` ON `zenoradio-v25`.`data_listener_at_entryway` (`is_frequency_listen_dialy` ASC, `is_frequency_listen_weekly` ASC) ;

SHOW WARNINGS;
CREATE INDEX `fk_data_listener_at_entryway_1_idx` ON `zenoradio-v25`.`data_listener_at_entryway` (`listener_id` ASC) ;

SHOW WARNINGS;
CREATE INDEX `fk_data_listener_at_entryway_2_idx` ON `zenoradio-v25`.`data_listener_at_entryway` (`entryway_id` ASC) ;

SHOW WARNINGS;

-- -----------------------------------------------------
-- Table `zenoradio-v25`.`data_listener_at_gateway`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `zenoradio-v25`.`data_listener_at_gateway` ;

SHOW WARNINGS;
CREATE  TABLE IF NOT EXISTS `zenoradio-v25`.`data_listener_at_gateway` (
  `id` BIGINT(19) UNSIGNED NOT NULL AUTO_INCREMENT ,
  `listener_id` BIGINT(19) UNSIGNED NULL DEFAULT NULL ,
  `gateway_id` BIGINT(19) UNSIGNED NULL DEFAULT NULL ,
  `assigned_date` TIMESTAMP NULL DEFAULT NULL on update CURRENT_TIMESTAMP ,
  `status` ENUM('NOT_ACTIVE','ACTIVE','LOST') NULL DEFAULT NULL ,
  `status_last_change_date` DATETIME NULL DEFAULT NULL ,
  `is_new` TINYINT(1) NULL DEFAULT '0' ,
  `is_return` TINYINT(1) NULL DEFAULT '0' ,
  `is_frequency_listen_dialy` TINYINT(1) NULL DEFAULT '0' ,
  `is_frequency_listen_weekly` TINYINT(1) NULL DEFAULT '0' ,
  `average_minutes_per_day` INT(11) NULL DEFAULT NULL ,
  `last_session_date` DATETIME NULL DEFAULT NULL ,
  PRIMARY KEY (`id`) ,
  CONSTRAINT `fk_data_listener_at_gateway_1`
    FOREIGN KEY (`listener_id` )
    REFERENCES `zenoradio-v25`.`data_listener` (`id` )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_data_listener_at_gateway_2`
    FOREIGN KEY (`gateway_id` )
    REFERENCES `zenoradio-v25`.`data_gateway` (`id` )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;

SHOW WARNINGS;
CREATE INDEX `index2` ON `zenoradio-v25`.`data_listener_at_gateway` (`assigned_date` ASC) ;

SHOW WARNINGS;
CREATE INDEX `index3` ON `zenoradio-v25`.`data_listener_at_gateway` (`status` ASC) ;

SHOW WARNINGS;
CREATE INDEX `index4` ON `zenoradio-v25`.`data_listener_at_gateway` (`status_last_change_date` ASC) ;

SHOW WARNINGS;
CREATE INDEX `index5` ON `zenoradio-v25`.`data_listener_at_gateway` (`last_session_date` ASC) ;

SHOW WARNINGS;
CREATE INDEX `index7` ON `zenoradio-v25`.`data_listener_at_gateway` (`is_new` ASC, `is_return` ASC) ;

SHOW WARNINGS;
CREATE INDEX `index8` ON `zenoradio-v25`.`data_listener_at_gateway` (`is_frequency_listen_dialy` ASC, `is_frequency_listen_weekly` ASC) ;

SHOW WARNINGS;
CREATE INDEX `fk_data_listener_at_gateway_1_idx` ON `zenoradio-v25`.`data_listener_at_gateway` (`listener_id` ASC) ;

SHOW WARNINGS;
CREATE INDEX `fk_data_listener_at_gateway_2_idx` ON `zenoradio-v25`.`data_listener_at_gateway` (`gateway_id` ASC) ;

SHOW WARNINGS;

-- -----------------------------------------------------
-- Table `zenoradio-v25`.`log_call_listen`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `zenoradio-v25`.`log_call_listen` ;

SHOW WARNINGS;
CREATE  TABLE IF NOT EXISTS `zenoradio-v25`.`log_call_listen` (
  `id` BIGINT(19) UNSIGNED NOT NULL AUTO_INCREMENT ,
  `date_start` DATETIME NULL DEFAULT NULL ,
  `date_stop` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP ,
  `server_id` BIGINT UNSIGNED NULL ,
  `seconds` INT(10) UNSIGNED NULL DEFAULT '0' ,
  `log_call_id` BIGINT UNSIGNED NULL ,
  `extension` CHAR(16) NULL DEFAULT NULL ,
  `content_id` BIGINT(19) UNSIGNED NULL DEFAULT NULL ,
  `on_summary` TINYINT(1) NULL DEFAULT '0' ,
  PRIMARY KEY (`id`) )
ENGINE = InnoDB;

SHOW WARNINGS;
CREATE INDEX `date_start` ON `zenoradio-v25`.`log_call_listen` (`date_start` ASC) ;

SHOW WARNINGS;
CREATE INDEX `date_stop` ON `zenoradio-v25`.`log_call_listen` (`date_stop` ASC) ;

SHOW WARNINGS;
CREATE INDEX `call` ON `zenoradio-v25`.`log_call_listen` (`log_call_id` ASC) ;

SHOW WARNINGS;
CREATE INDEX `on_summary` ON `zenoradio-v25`.`log_call_listen` (`on_summary` ASC) ;

SHOW WARNINGS;

-- -----------------------------------------------------
-- Table `zenoradio-v25`.`sys_server_location`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `zenoradio-v25`.`sys_server_location` ;

SHOW WARNINGS;
CREATE  TABLE IF NOT EXISTS `zenoradio-v25`.`sys_server_location` (
  `id` BIGINT(19) UNSIGNED NOT NULL AUTO_INCREMENT ,
  `title` CHAR(200) NULL DEFAULT NULL ,
  PRIMARY KEY (`id`) )
ENGINE = InnoDB;

SHOW WARNINGS;

-- -----------------------------------------------------
-- Table `zenoradio-v25`.`sys_server`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `zenoradio-v25`.`sys_server` ;

SHOW WARNINGS;
CREATE  TABLE IF NOT EXISTS `zenoradio-v25`.`sys_server` (
  `id` BIGINT(19) UNSIGNED NOT NULL AUTO_INCREMENT ,
  `title` CHAR(200) NULL DEFAULT NULL ,
  `short_title` CHAR(16) NULL DEFAULT NULL ,
  `ip` CHAR(15) NULL DEFAULT NULL ,
  `location_id` BIGINT(19) UNSIGNED NULL DEFAULT NULL ,
  `engine_listen_remote_ip` CHAR(200) NULL DEFAULT NULL ,
  `engine_talk_remote_ip` CHAR(200) NULL DEFAULT NULL ,
  `engine_privatetalk_remote_ip` CHAR(200) NULL DEFAULT NULL ,
  `engine_media_remote_ip` CHAR(200) NULL DEFAULT NULL ,
  `engine_advertise_remote_ip` CHAR(200) NULL DEFAULT NULL ,
  `is_deleted` TINYINT(1) NULL DEFAULT '0' ,
  PRIMARY KEY (`id`) ,
  CONSTRAINT `location`
    FOREIGN KEY (`location_id` )
    REFERENCES `zenoradio-v25`.`sys_server_location` (`id` )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB
COMMENT = 'engine_*_remote_ip if blank, mens call server will use local';

SHOW WARNINGS;
CREATE INDEX `fk_sys_server_1_idx` ON `zenoradio-v25`.`sys_server` (`location_id` ASC) ;

SHOW WARNINGS;

-- -----------------------------------------------------
-- Table `zenoradio-v25`.`now_session`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `zenoradio-v25`.`now_session` ;

SHOW WARNINGS;
CREATE  TABLE IF NOT EXISTS `zenoradio-v25`.`now_session` (
  `id` BIGINT(19) UNSIGNED NOT NULL AUTO_INCREMENT ,
  `log_call_id` BIGINT NULL ,
  `log_call_listen_id` BIGINT NULL ,
  `call_date_start` DATETIME NULL DEFAULT NULL ,
  `call_server_id` BIGINT(19) UNSIGNED NULL DEFAULT NULL ,
  `call_server_asterisk_channel` CHAR(64) NULL DEFAULT NULL ,
  `call_server_asterisk_uniqueid` CHAR(64) NULL DEFAULT NULL ,
  `call_ani_e164` CHAR(32) NULL DEFAULT NULL ,
  `call_did_e164` CHAR(32) NULL DEFAULT NULL ,
  `call_listener_ani_id` BIGINT UNSIGNED NULL ,
  `call_listener_id` BIGINT(19) UNSIGNED NULL DEFAULT NULL ,
  `call_entryway_id` BIGINT(19) UNSIGNED NULL DEFAULT NULL ,
  `call_gateway_id` BIGINT(19) UNSIGNED NULL DEFAULT NULL ,
  `call_gateway_play_welcome` TINYINT(1) NULL DEFAULT '1' ,
  `listen_session_date_start` DATETIME NULL ,
  `listen_session_extension` CHAR(16) NULL DEFAULT NULL ,
  `listen_session_content_id` BIGINT(19) UNSIGNED NULL DEFAULT NULL ,
  `listen_session_server_id` BIGINT NULL ,
  `listen_session_server_asterisk_channel` CHAR(64) NULL ,
  `listen_session_server_asterisk_uniqueid` CHAR(64) NULL ,
  `engine_now` ENUM('LISTEN','TALK','PRIVATETALK','ADVERTISE','MEDIA','HANGUP') NULL DEFAULT NULL ,
  `engine_now_date_start` DATETIME NULL DEFAULT NULL ,
  `engine_now_server_id` BIGINT(19) UNSIGNED NULL DEFAULT NULL ,
  `engine_now_server_asterisk_channel` CHAR(64) NULL DEFAULT NULL ,
  `engine_now_server_asterisk_uniqueid` CHAR(64) NULL DEFAULT NULL ,
  `engine_now_server_app_konference_name` CHAR(64) NULL DEFAULT NULL ,
  `engine_now_server_app_konference_user` CHAR(16) NULL DEFAULT NULL ,
  `engine_now_advertise_trigger_type` ENUM('PREROLL','MANUAL','CONTENTTIMMER','CONTENTREPLACEAD','LISTENERTIMMER','LISTENERREQUEST') NULL DEFAULT NULL ,
  `engine_now_advertise_detail_digits` CHAR(16) NULL DEFAULT NULL ,
  `engine_now_advertise_campaign_item_id` BIGINT(19) UNSIGNED NULL DEFAULT NULL ,
  `engine_next_step_1` ENUM('LISTEN','TALK','PRIVATETALK','ADVERTISE','MEDIA','HANGUP') NULL DEFAULT NULL ,
  `engine_next_step_1_advertise_trigger_type` ENUM('PREROLL','MANUAL','CONTENTTIMMER','CONTENTREPLACEAD','LISTENERTIMMER','LISTENERREQUEST') NULL DEFAULT NULL ,
  `engine_next_step_2` ENUM('LISTEN','TALK','PRIVATETALK','ADVERTISE','MEDIA','HANGUP') NULL DEFAULT NULL ,
  `engine_next_step_2_advertise_trigger_type` ENUM('PREROLL','MANUAL','CONTENTTIMMER','CONTENTREPLACEAD','LISTENERTIMMER','LISTENERREQUEST') NULL DEFAULT NULL ,
  PRIMARY KEY (`id`) ,
  CONSTRAINT `fk_now_listen_session_1`
    FOREIGN KEY (`call_server_id` )
    REFERENCES `zenoradio-v25`.`sys_server` (`id` )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_now_listen_session_2`
    FOREIGN KEY (`call_listener_id` )
    REFERENCES `zenoradio-v25`.`data_listener` (`id` )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_now_listen_session_3`
    FOREIGN KEY (`call_entryway_id` )
    REFERENCES `zenoradio-v25`.`data_entryway` (`id` )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_now_listen_session_4`
    FOREIGN KEY (`call_gateway_id` )
    REFERENCES `zenoradio-v25`.`data_gateway` (`id` )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_now_listen_session_5`
    FOREIGN KEY (`listen_session_content_id` )
    REFERENCES `zenoradio-v25`.`data_content` (`id` )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_now_listen_session_6`
    FOREIGN KEY (`engine_now_server_id` )
    REFERENCES `zenoradio-v25`.`sys_server` (`id` )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_now_listen_session_7`
    FOREIGN KEY (`call_listener_ani_id` )
    REFERENCES `zenoradio-v25`.`data_listener_ani` (`id` )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB
COMMENT = 'This table hold many runtime information that will be discar';

SHOW WARNINGS;
CREATE INDEX `engine_now` ON `zenoradio-v25`.`now_session` (`engine_now` ASC) ;

SHOW WARNINGS;
CREATE INDEX `fk_now_listen_session_1_idx` ON `zenoradio-v25`.`now_session` (`call_server_id` ASC) ;

SHOW WARNINGS;
CREATE INDEX `fk_now_listen_session_2_idx` ON `zenoradio-v25`.`now_session` (`call_listener_id` ASC) ;

SHOW WARNINGS;
CREATE INDEX `fk_now_listen_session_3_idx` ON `zenoradio-v25`.`now_session` (`call_entryway_id` ASC) ;

SHOW WARNINGS;
CREATE INDEX `fk_now_listen_session_4_idx` ON `zenoradio-v25`.`now_session` (`call_gateway_id` ASC) ;

SHOW WARNINGS;
CREATE INDEX `fk_now_listen_session_5_idx` ON `zenoradio-v25`.`now_session` (`listen_session_content_id` ASC) ;

SHOW WARNINGS;
CREATE INDEX `fk_now_listen_session_6_idx` ON `zenoradio-v25`.`now_session` (`engine_now_server_id` ASC) ;

SHOW WARNINGS;
CREATE INDEX `fk_now_listen_session_7` ON `zenoradio-v25`.`now_session` (`call_listener_ani_id` ASC) ;

SHOW WARNINGS;

-- -----------------------------------------------------
-- Table `zenoradio-v25`.`summary_listeners_by_campaign`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `zenoradio-v25`.`summary_listeners_by_campaign` ;

SHOW WARNINGS;
CREATE  TABLE IF NOT EXISTS `zenoradio-v25`.`summary_listeners_by_campaign` (
  `id` BIGINT(19) UNSIGNED NOT NULL AUTO_INCREMENT ,
  `date` DATE NULL DEFAULT NULL ,
  `campaign_id` BIGINT(19) UNSIGNED NULL DEFAULT NULL ,
  `status_not_active` INT(11) NULL DEFAULT NULL ,
  `status_active` INT(11) NULL DEFAULT NULL ,
  `status_lost` INT(11) NULL DEFAULT NULL ,
  `active_by_new` INT(11) NULL DEFAULT NULL ,
  `active_by_return` INT(11) NULL DEFAULT NULL ,
  `frequency_listen_dialy` INT(11) NULL DEFAULT NULL ,
  `frequency_listen_weekly` INT(11) NULL DEFAULT NULL ,
  `frequency_unknown` INT(11) NULL DEFAULT NULL ,
  `frequency_0_to_5_minutes_per_day` INT(11) NULL DEFAULT NULL ,
  `frequency_5_to_20_minutes_per_day` INT(11) NULL DEFAULT NULL ,
  `frequency_20_to_60_minutes_per_day` INT(11) NULL DEFAULT NULL ,
  `frequency_more_60_minutes_per_day` INT(11) NULL DEFAULT NULL ,
  PRIMARY KEY (`id`) ,
  CONSTRAINT `fk_summary_listeners_by_campaign_1`
    FOREIGN KEY (`campaign_id` )
    REFERENCES `zenoradio-v25`.`data_campaign` (`id` )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;

SHOW WARNINGS;
CREATE INDEX `date` ON `zenoradio-v25`.`summary_listeners_by_campaign` (`date` ASC) ;

SHOW WARNINGS;
CREATE INDEX `fk_summary_listeners_by_campaign_1_idx` ON `zenoradio-v25`.`summary_listeners_by_campaign` (`campaign_id` ASC) ;

SHOW WARNINGS;

-- -----------------------------------------------------
-- Table `zenoradio-v25`.`summary_listeners_by_content`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `zenoradio-v25`.`summary_listeners_by_content` ;

SHOW WARNINGS;
CREATE  TABLE IF NOT EXISTS `zenoradio-v25`.`summary_listeners_by_content` (
  `id` BIGINT(19) UNSIGNED NOT NULL AUTO_INCREMENT ,
  `date` DATE NULL DEFAULT NULL ,
  `content_id` BIGINT(19) UNSIGNED NULL DEFAULT NULL ,
  `status_not_active` INT(11) NULL DEFAULT NULL ,
  `status_active` INT(11) NULL DEFAULT NULL ,
  `status_lost` INT(11) NULL DEFAULT NULL ,
  `active_by_new` INT(11) NULL DEFAULT NULL ,
  `active_by_return` INT(11) NULL DEFAULT NULL ,
  `frequency_listen_dialy` INT(11) NULL DEFAULT NULL ,
  `frequency_listen_weekly` INT(11) NULL DEFAULT NULL ,
  `frequency_unknown` INT(11) NULL DEFAULT NULL ,
  `frequency_0_to_5_minutes_per_day` INT(11) NULL DEFAULT NULL ,
  `frequency_5_to_20_minutes_per_day` INT(11) NULL DEFAULT NULL ,
  `frequency_20_to_60_minutes_per_day` INT(11) NULL DEFAULT NULL ,
  `frequency_more_60_minutes_per_day` INT(11) NULL DEFAULT NULL ,
  PRIMARY KEY (`id`) ,
  CONSTRAINT `fk_summary_listeners_by_content_1`
    FOREIGN KEY (`content_id` )
    REFERENCES `zenoradio-v25`.`data_content` (`id` )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;

SHOW WARNINGS;
CREATE INDEX `date` ON `zenoradio-v25`.`summary_listeners_by_content` (`date` ASC) ;

SHOW WARNINGS;
CREATE INDEX `fk_summary_listeners_by_content_1_idx` ON `zenoradio-v25`.`summary_listeners_by_content` (`content_id` ASC) ;

SHOW WARNINGS;

-- -----------------------------------------------------
-- Table `zenoradio-v25`.`summary_listeners_by_content_broadcast`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `zenoradio-v25`.`summary_listeners_by_content_broadcast` ;

SHOW WARNINGS;
CREATE  TABLE IF NOT EXISTS `zenoradio-v25`.`summary_listeners_by_content_broadcast` (
  `id` BIGINT(19) UNSIGNED NOT NULL AUTO_INCREMENT ,
  `date` DATE NULL DEFAULT NULL ,
  `status_not_active` INT(11) NULL DEFAULT NULL ,
  `status_active` INT(11) NULL DEFAULT NULL ,
  `status_lost` INT(11) NULL DEFAULT NULL ,
  `active_by_new` INT(11) NULL DEFAULT NULL ,
  `active_by_return` INT(11) NULL DEFAULT NULL ,
  `frequency_listen_dialy` INT(11) NULL DEFAULT NULL ,
  `frequency_listen_weekly` INT(11) NULL DEFAULT NULL ,
  `frequency_unknown` INT(11) NULL DEFAULT NULL ,
  `frequency_0_to_5_minutes_per_day` INT(11) NULL DEFAULT NULL ,
  `frequency_5_to_20_minutes_per_day` INT(11) NULL DEFAULT NULL ,
  `frequency_20_to_60_minutes_per_day` INT(11) NULL DEFAULT NULL ,
  `frequency_more_60_minutes_per_day` INT(11) NULL DEFAULT NULL ,
  `broadcast_id` BIGINT(19) UNSIGNED NULL DEFAULT NULL ,
  PRIMARY KEY (`id`) ,
  CONSTRAINT `fk_summary_listeners_by_content_broadcast_1`
    FOREIGN KEY (`broadcast_id` )
    REFERENCES `zenoradio-v25`.`data_group_broadcast` (`id` )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;

SHOW WARNINGS;
CREATE INDEX `date` ON `zenoradio-v25`.`summary_listeners_by_content_broadcast` (`date` ASC) ;

SHOW WARNINGS;
CREATE INDEX `fk_summary_listeners_by_content_broadcast_1_idx` ON `zenoradio-v25`.`summary_listeners_by_content_broadcast` (`broadcast_id` ASC) ;

SHOW WARNINGS;

-- -----------------------------------------------------
-- Table `zenoradio-v25`.`summary_listeners_by_content_country`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `zenoradio-v25`.`summary_listeners_by_content_country` ;

SHOW WARNINGS;
CREATE  TABLE IF NOT EXISTS `zenoradio-v25`.`summary_listeners_by_content_country` (
  `id` BIGINT(19) UNSIGNED NOT NULL AUTO_INCREMENT ,
  `date` DATE NULL DEFAULT NULL ,
  `status_not_active` INT(11) NULL DEFAULT NULL ,
  `status_active` INT(11) NULL DEFAULT NULL ,
  `status_lost` INT(11) NULL DEFAULT NULL ,
  `active_by_new` INT(11) NULL DEFAULT NULL ,
  `active_by_return` INT(11) NULL DEFAULT NULL ,
  `frequency_listen_dialy` INT(11) NULL DEFAULT NULL ,
  `frequency_listen_weekly` INT(11) NULL DEFAULT NULL ,
  `frequency_unknown` INT(11) NULL DEFAULT NULL ,
  `frequency_0_to_5_minutes_per_day` INT(11) NULL DEFAULT NULL ,
  `frequency_5_to_20_minutes_per_day` INT(11) NULL DEFAULT NULL ,
  `frequency_20_to_60_minutes_per_day` INT(11) NULL DEFAULT NULL ,
  `frequency_more_60_minutes_per_day` INT(11) NULL DEFAULT NULL ,
  `country_id` CHAR(2) NULL DEFAULT NULL ,
  PRIMARY KEY (`id`) ,
  CONSTRAINT `fk_summary_listeners_by_content_country_1`
    FOREIGN KEY (`country_id` )
    REFERENCES `zenoradio-v25`.`data_group_country` (`id` )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;

SHOW WARNINGS;
CREATE INDEX `date` ON `zenoradio-v25`.`summary_listeners_by_content_country` (`date` ASC) ;

SHOW WARNINGS;
CREATE INDEX `fk_summary_listeners_by_content_country_1_idx` ON `zenoradio-v25`.`summary_listeners_by_content_country` (`country_id` ASC) ;

SHOW WARNINGS;

-- -----------------------------------------------------
-- Table `zenoradio-v25`.`summary_listeners_by_content_language`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `zenoradio-v25`.`summary_listeners_by_content_language` ;

SHOW WARNINGS;
CREATE  TABLE IF NOT EXISTS `zenoradio-v25`.`summary_listeners_by_content_language` (
  `id` BIGINT(19) UNSIGNED NOT NULL AUTO_INCREMENT ,
  `date` DATE NULL DEFAULT NULL ,
  `status_not_active` INT(11) NULL DEFAULT NULL ,
  `status_active` INT(11) NULL DEFAULT NULL ,
  `status_lost` INT(11) NULL DEFAULT NULL ,
  `active_by_new` INT(11) NULL DEFAULT NULL ,
  `active_by_return` INT(11) NULL DEFAULT NULL ,
  `frequency_listen_dialy` INT(11) NULL DEFAULT NULL ,
  `frequency_listen_weekly` INT(11) NULL DEFAULT NULL ,
  `frequency_unknown` INT(11) NULL DEFAULT NULL ,
  `frequency_0_to_5_minutes_per_day` INT(11) NULL DEFAULT NULL ,
  `frequency_5_to_20_minutes_per_day` INT(11) NULL DEFAULT NULL ,
  `frequency_20_to_60_minutes_per_day` INT(11) NULL DEFAULT NULL ,
  `frequency_more_60_minutes_per_day` INT(11) NULL DEFAULT NULL ,
  `language_id` BIGINT(19) UNSIGNED NULL DEFAULT NULL ,
  PRIMARY KEY (`id`) ,
  CONSTRAINT `fk_summary_listeners_by_content_language_1`
    FOREIGN KEY (`language_id` )
    REFERENCES `zenoradio-v25`.`data_group_language` (`id` )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;

SHOW WARNINGS;
CREATE INDEX `date` ON `zenoradio-v25`.`summary_listeners_by_content_language` (`date` ASC) ;

SHOW WARNINGS;
CREATE INDEX `fk_summary_listeners_by_content_language_1_idx` ON `zenoradio-v25`.`summary_listeners_by_content_language` (`language_id` ASC) ;

SHOW WARNINGS;

-- -----------------------------------------------------
-- Table `zenoradio-v25`.`summary_listeners_by_entryway`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `zenoradio-v25`.`summary_listeners_by_entryway` ;

SHOW WARNINGS;
CREATE  TABLE IF NOT EXISTS `zenoradio-v25`.`summary_listeners_by_entryway` (
  `id` BIGINT(19) UNSIGNED NOT NULL AUTO_INCREMENT ,
  `date` DATE NULL DEFAULT NULL ,
  `entryway_id` BIGINT(19) UNSIGNED NULL DEFAULT NULL ,
  `status_not_active` INT(11) NULL DEFAULT NULL ,
  `status_active` INT(11) NULL DEFAULT NULL ,
  `status_lost` INT(11) NULL DEFAULT NULL ,
  `active_by_new` INT(11) NULL DEFAULT NULL ,
  `active_by_return` INT(11) NULL DEFAULT NULL ,
  `frequency_listen_dialy` INT(11) NULL DEFAULT NULL ,
  `frequency_listen_weekly` INT(11) NULL DEFAULT NULL ,
  `frequency_unknown` INT(11) NULL DEFAULT NULL ,
  `frequency_0_to_5_minutes_per_day` INT(11) NULL DEFAULT NULL ,
  `frequency_5_to_20_minutes_per_day` INT(11) NULL DEFAULT NULL ,
  `frequency_20_to_60_minutes_per_day` INT(11) NULL DEFAULT NULL ,
  `frequency_more_60_minutes_per_day` INT(11) NULL DEFAULT NULL ,
  PRIMARY KEY (`id`) ,
  CONSTRAINT `fk_summary_listeners_by_entryway_1`
    FOREIGN KEY (`entryway_id` )
    REFERENCES `zenoradio-v25`.`data_entryway` (`id` )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;

SHOW WARNINGS;
CREATE INDEX `date` ON `zenoradio-v25`.`summary_listeners_by_entryway` (`date` ASC) ;

SHOW WARNINGS;
CREATE INDEX `fk_summary_listeners_by_entryway_1_idx` ON `zenoradio-v25`.`summary_listeners_by_entryway` (`entryway_id` ASC) ;

SHOW WARNINGS;

-- -----------------------------------------------------
-- Table `zenoradio-v25`.`summary_listeners_by_entryway_3rdparty`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `zenoradio-v25`.`summary_listeners_by_entryway_3rdparty` ;

SHOW WARNINGS;
CREATE  TABLE IF NOT EXISTS `zenoradio-v25`.`summary_listeners_by_entryway_3rdparty` (
  `id` BIGINT(19) UNSIGNED NOT NULL AUTO_INCREMENT ,
  `date` DATE NULL DEFAULT NULL ,
  `3rdparty_id` BIGINT(19) UNSIGNED NULL DEFAULT NULL ,
  `status_not_active` INT(11) NULL DEFAULT NULL ,
  `status_active` INT(11) NULL DEFAULT NULL ,
  `status_lost` INT(11) NULL DEFAULT NULL ,
  `active_by_new` INT(11) NULL DEFAULT NULL ,
  `active_by_return` INT(11) NULL DEFAULT NULL ,
  `frequency_listen_dialy` INT(11) NULL DEFAULT NULL ,
  `frequency_listen_weekly` INT(11) NULL DEFAULT NULL ,
  `frequency_unknown` INT(11) NULL DEFAULT NULL ,
  `frequency_0_to_5_minutes_per_day` INT(11) NULL DEFAULT NULL ,
  `frequency_5_to_20_minutes_per_day` INT(11) NULL DEFAULT NULL ,
  `frequency_20_to_60_minutes_per_day` INT(11) NULL DEFAULT NULL ,
  `frequency_more_60_minutes_per_day` INT(11) NULL DEFAULT NULL ,
  PRIMARY KEY (`id`) ,
  CONSTRAINT `fk_summary_listeners_by_entryway_3rdparty_1`
    FOREIGN KEY (`3rdparty_id` )
    REFERENCES `zenoradio-v25`.`data_group_3rdparty` (`id` )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;

SHOW WARNINGS;
CREATE INDEX `date` ON `zenoradio-v25`.`summary_listeners_by_entryway_3rdparty` (`date` ASC) ;

SHOW WARNINGS;
CREATE INDEX `fk_summary_listeners_by_entryway_3rdparty_1_idx` ON `zenoradio-v25`.`summary_listeners_by_entryway_3rdparty` (`3rdparty_id` ASC) ;

SHOW WARNINGS;

-- -----------------------------------------------------
-- Table `zenoradio-v25`.`summary_listeners_by_gateway`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `zenoradio-v25`.`summary_listeners_by_gateway` ;

SHOW WARNINGS;
CREATE  TABLE IF NOT EXISTS `zenoradio-v25`.`summary_listeners_by_gateway` (
  `id` BIGINT(19) UNSIGNED NOT NULL AUTO_INCREMENT ,
  `date` DATE NULL DEFAULT NULL ,
  `gateway_id` BIGINT(19) UNSIGNED NULL DEFAULT NULL ,
  `status_not_active` INT(11) NULL DEFAULT NULL ,
  `status_active` INT(11) NULL DEFAULT NULL ,
  `status_lost` INT(11) NULL DEFAULT NULL ,
  `active_by_new` INT(11) NULL DEFAULT NULL ,
  `active_by_return` INT(11) NULL DEFAULT NULL ,
  `frequency_listen_dialy` INT(11) NULL DEFAULT NULL ,
  `frequency_listen_weekly` INT(11) NULL DEFAULT NULL ,
  `frequency_unknown` INT(11) NULL DEFAULT NULL ,
  `frequency_0_to_5_minutes_per_day` INT(11) NULL DEFAULT NULL ,
  `frequency_5_to_20_minutes_per_day` INT(11) NULL DEFAULT NULL ,
  `frequency_20_to_60_minutes_per_day` INT(11) NULL DEFAULT NULL ,
  `frequency_more_60_minutes_per_day` INT(11) NULL DEFAULT NULL ,
  PRIMARY KEY (`id`) ,
  CONSTRAINT `fk_summary_listeners_by_gateway_1`
    FOREIGN KEY (`gateway_id` )
    REFERENCES `zenoradio-v25`.`data_gateway` (`id` )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;

SHOW WARNINGS;
CREATE INDEX `date` ON `zenoradio-v25`.`summary_listeners_by_gateway` (`date` ASC) ;

SHOW WARNINGS;
CREATE INDEX `fk_summary_listeners_by_gateway_1_idx` ON `zenoradio-v25`.`summary_listeners_by_gateway` (`gateway_id` ASC) ;

SHOW WARNINGS;

-- -----------------------------------------------------
-- Table `zenoradio-v25`.`summary_listeners_by_gateway_broadcast`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `zenoradio-v25`.`summary_listeners_by_gateway_broadcast` ;

SHOW WARNINGS;
CREATE  TABLE IF NOT EXISTS `zenoradio-v25`.`summary_listeners_by_gateway_broadcast` (
  `id` BIGINT(19) UNSIGNED NOT NULL AUTO_INCREMENT ,
  `date` DATE NULL DEFAULT NULL ,
  `broadcast_id` BIGINT(19) UNSIGNED NULL DEFAULT NULL ,
  `status_not_active` INT(11) NULL DEFAULT NULL ,
  `status_active` INT(11) NULL DEFAULT NULL ,
  `status_lost` INT(11) NULL DEFAULT NULL ,
  `active_by_new` INT(11) NULL DEFAULT NULL ,
  `active_by_return` INT(11) NULL DEFAULT NULL ,
  `frequency_listen_dialy` INT(11) NULL DEFAULT NULL ,
  `frequency_listen_weekly` INT(11) NULL DEFAULT NULL ,
  `frequency_unknown` INT(11) NULL DEFAULT NULL ,
  `frequency_0_to_5_minutes_per_day` INT(11) NULL DEFAULT NULL ,
  `frequency_5_to_20_minutes_per_day` INT(11) NULL DEFAULT NULL ,
  `frequency_20_to_60_minutes_per_day` INT(11) NULL DEFAULT NULL ,
  `frequency_more_60_minutes_per_day` INT(11) NULL DEFAULT NULL ,
  PRIMARY KEY (`id`) ,
  CONSTRAINT `fk_summary_listeners_by_gateway_broadcast_1`
    FOREIGN KEY (`broadcast_id` )
    REFERENCES `zenoradio-v25`.`data_group_broadcast` (`id` )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;

SHOW WARNINGS;
CREATE INDEX `date` ON `zenoradio-v25`.`summary_listeners_by_gateway_broadcast` (`date` ASC) ;

SHOW WARNINGS;
CREATE INDEX `fk_summary_listeners_by_gateway_broadcast_1_idx` ON `zenoradio-v25`.`summary_listeners_by_gateway_broadcast` (`broadcast_id` ASC) ;

SHOW WARNINGS;

-- -----------------------------------------------------
-- Table `zenoradio-v25`.`summary_listeners_by_gateway_rca`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `zenoradio-v25`.`summary_listeners_by_gateway_rca` ;

SHOW WARNINGS;
CREATE  TABLE IF NOT EXISTS `zenoradio-v25`.`summary_listeners_by_gateway_rca` (
  `id` BIGINT(19) UNSIGNED NOT NULL AUTO_INCREMENT ,
  `date` DATE NULL DEFAULT NULL ,
  `rca_id` BIGINT(19) UNSIGNED NULL DEFAULT NULL ,
  `status_not_active` INT(11) NULL DEFAULT NULL ,
  `status_active` INT(11) NULL DEFAULT NULL ,
  `status_lost` INT(11) NULL DEFAULT NULL ,
  `active_by_new` INT(11) NULL DEFAULT NULL ,
  `active_by_return` INT(11) NULL DEFAULT NULL ,
  `frequency_listen_dialy` INT(11) NULL DEFAULT NULL ,
  `frequency_listen_weekly` INT(11) NULL DEFAULT NULL ,
  `frequency_unknown` INT(11) NULL DEFAULT NULL ,
  `frequency_0_to_5_minutes_per_day` INT(11) NULL DEFAULT NULL ,
  `frequency_5_to_20_minutes_per_day` INT(11) NULL DEFAULT NULL ,
  `frequency_20_to_60_minutes_per_day` INT(11) NULL DEFAULT NULL ,
  `frequency_more_60_minutes_per_day` INT(11) NULL DEFAULT NULL ,
  PRIMARY KEY (`id`) ,
  CONSTRAINT `fk_summary_listeners_by_gateway_rca_1`
    FOREIGN KEY (`rca_id` )
    REFERENCES `zenoradio-v25`.`data_group_rca` (`id` )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;

SHOW WARNINGS;
CREATE INDEX `date` ON `zenoradio-v25`.`summary_listeners_by_gateway_rca` (`date` ASC) ;

SHOW WARNINGS;
CREATE INDEX `fk_summary_listeners_by_gateway_rca_1_idx` ON `zenoradio-v25`.`summary_listeners_by_gateway_rca` (`rca_id` ASC) ;

SHOW WARNINGS;

-- -----------------------------------------------------
-- Table `zenoradio-v25`.`summary_sessions_by_campaign`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `zenoradio-v25`.`summary_sessions_by_campaign` ;

SHOW WARNINGS;
CREATE  TABLE IF NOT EXISTS `zenoradio-v25`.`summary_sessions_by_campaign` (
  `id` BIGINT(19) UNSIGNED NOT NULL AUTO_INCREMENT ,
  `date` DATE NULL DEFAULT NULL ,
  `hour` INT(10) UNSIGNED NULL DEFAULT NULL ,
  `campaign_id` BIGINT(19) UNSIGNED NULL DEFAULT NULL ,
  `campaign_media_id` BIGINT(19) UNSIGNED NULL DEFAULT NULL ,
  `sessions` BIGINT(19) UNSIGNED NULL DEFAULT NULL ,
  `seconds` MEDIUMINT(8) UNSIGNED NULL DEFAULT NULL ,
  `usage_points` FLOAT NULL DEFAULT NULL ,
  `price_entryway` FLOAT NULL DEFAULT NULL ,
  `price_gateway` FLOAT NULL DEFAULT NULL ,
  `price_content` FLOAT NULL DEFAULT NULL ,
  `price_campaign` FLOAT NULL DEFAULT NULL ,
  PRIMARY KEY (`id`) ,
  CONSTRAINT `fk_summary_sessions_by_campaign_1`
    FOREIGN KEY (`campaign_id` )
    REFERENCES `zenoradio-v25`.`data_campaign` (`id` )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;

SHOW WARNINGS;
CREATE INDEX `date` ON `zenoradio-v25`.`summary_sessions_by_campaign` (`date` ASC) ;

SHOW WARNINGS;
CREATE INDEX `date-hr` ON `zenoradio-v25`.`summary_sessions_by_campaign` (`date` ASC, `hour` ASC) ;

SHOW WARNINGS;
CREATE INDEX `fk_summary_sessions_by_campaign_1_idx` ON `zenoradio-v25`.`summary_sessions_by_campaign` (`campaign_id` ASC) ;

SHOW WARNINGS;

-- -----------------------------------------------------
-- Table `zenoradio-v25`.`summary_sessions_by_content`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `zenoradio-v25`.`summary_sessions_by_content` ;

SHOW WARNINGS;
CREATE  TABLE IF NOT EXISTS `zenoradio-v25`.`summary_sessions_by_content` (
  `id` BIGINT(19) UNSIGNED NOT NULL AUTO_INCREMENT ,
  `date` DATE NULL DEFAULT NULL ,
  `hour` INT(10) UNSIGNED NULL DEFAULT NULL ,
  `content_id` BIGINT(19) UNSIGNED NULL DEFAULT NULL ,
  `country_id` CHAR(2) NULL DEFAULT NULL ,
  `language_id` BIGINT(19) UNSIGNED NULL DEFAULT NULL ,
  `genre_id` BIGINT(19) UNSIGNED NULL DEFAULT NULL ,
  `broadcast_id` BIGINT(19) UNSIGNED NULL DEFAULT NULL ,
  `sessions` BIGINT(19) UNSIGNED NULL DEFAULT NULL ,
  `sessions_acd_10sec` MEDIUMINT(8) UNSIGNED NULL DEFAULT NULL ,
  `sessions_acd_1min` MEDIUMINT(8) UNSIGNED NULL DEFAULT NULL ,
  `sessions_acd_5min` MEDIUMINT(8) UNSIGNED NULL DEFAULT NULL ,
  `sessions_acd_20min` MEDIUMINT(8) UNSIGNED NULL DEFAULT NULL ,
  `sessions_acd_1hr` MEDIUMINT(8) UNSIGNED NULL DEFAULT NULL ,
  `sessions_acd_2hr` MEDIUMINT(8) UNSIGNED NULL DEFAULT NULL ,
  `sessions_acd_6hr` MEDIUMINT(8) UNSIGNED NULL DEFAULT NULL ,
  `sessions_acd_more6hr` MEDIUMINT(8) UNSIGNED NULL DEFAULT NULL ,
  `seconds` MEDIUMINT(8) UNSIGNED NULL DEFAULT NULL ,
  PRIMARY KEY (`id`) ,
  CONSTRAINT `fk_summary_sessions_by_content_1`
    FOREIGN KEY (`content_id` )
    REFERENCES `zenoradio-v25`.`data_content` (`id` )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_summary_sessions_by_content_2`
    FOREIGN KEY (`country_id` )
    REFERENCES `zenoradio-v25`.`data_group_country` (`id` )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_summary_sessions_by_content_3`
    FOREIGN KEY (`language_id` )
    REFERENCES `zenoradio-v25`.`data_group_language` (`id` )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_summary_sessions_by_content_4`
    FOREIGN KEY (`genre_id` )
    REFERENCES `zenoradio-v25`.`data_group_genre` (`id` )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_summary_sessions_by_content_5`
    FOREIGN KEY (`broadcast_id` )
    REFERENCES `zenoradio-v25`.`data_group_broadcast` (`id` )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;

SHOW WARNINGS;
CREATE INDEX `date` ON `zenoradio-v25`.`summary_sessions_by_content` (`date` ASC) ;

SHOW WARNINGS;
CREATE INDEX `date-hr` ON `zenoradio-v25`.`summary_sessions_by_content` (`date` ASC, `hour` ASC) ;

SHOW WARNINGS;
CREATE INDEX `fk_summary_minutes_listen_sessions_content_1_idx` ON `zenoradio-v25`.`summary_sessions_by_content` (`content_id` ASC) ;

SHOW WARNINGS;
CREATE INDEX `fk_summary_minutes_listen_sessions_content_2_idx` ON `zenoradio-v25`.`summary_sessions_by_content` (`country_id` ASC) ;

SHOW WARNINGS;
CREATE INDEX `fk_summary_minutes_listen_sessions_content_3_idx` ON `zenoradio-v25`.`summary_sessions_by_content` (`language_id` ASC) ;

SHOW WARNINGS;
CREATE INDEX `fk_summary_minutes_listen_sessions_content_4_idx` ON `zenoradio-v25`.`summary_sessions_by_content` (`genre_id` ASC) ;

SHOW WARNINGS;
CREATE INDEX `fk_summary_minutes_listen_sessions_content_5_idx` ON `zenoradio-v25`.`summary_sessions_by_content` (`broadcast_id` ASC) ;

SHOW WARNINGS;

-- -----------------------------------------------------
-- Table `zenoradio-v25`.`summary_sessions_by_entryway`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `zenoradio-v25`.`summary_sessions_by_entryway` ;

SHOW WARNINGS;
CREATE  TABLE IF NOT EXISTS `zenoradio-v25`.`summary_sessions_by_entryway` (
  `id` BIGINT(19) UNSIGNED NOT NULL AUTO_INCREMENT ,
  `date` DATE NULL DEFAULT NULL ,
  `hour` INT(10) UNSIGNED NULL DEFAULT NULL ,
  `entryway_id` BIGINT(19) UNSIGNED NULL DEFAULT NULL ,
  `entryway_provider_id` BIGINT(19) UNSIGNED NULL DEFAULT NULL ,
  `country_id` CHAR(2) NULL DEFAULT NULL ,
  `3rdparty_id` BIGINT(19) UNSIGNED NULL DEFAULT NULL ,
  `sessions` MEDIUMINT(8) UNSIGNED NULL DEFAULT NULL ,
  `sessions_acd_10sec` MEDIUMINT(8) UNSIGNED NULL DEFAULT NULL ,
  `sessions_acd_1min` MEDIUMINT(8) UNSIGNED NULL DEFAULT NULL ,
  `sessions_acd_5min` MEDIUMINT(8) UNSIGNED NULL DEFAULT NULL ,
  `sessions_acd_20min` MEDIUMINT(8) UNSIGNED NULL DEFAULT NULL ,
  `sessions_acd_1hr` MEDIUMINT(8) UNSIGNED NULL DEFAULT NULL ,
  `sessions_acd_2hr` MEDIUMINT(8) UNSIGNED NULL DEFAULT NULL ,
  `sessions_acd_6hr` MEDIUMINT(8) UNSIGNED NULL DEFAULT NULL ,
  `sessions_acd_more6hr` MEDIUMINT(8) UNSIGNED NULL DEFAULT NULL ,
  `seconds` MEDIUMINT(8) UNSIGNED NULL DEFAULT NULL ,
  PRIMARY KEY (`id`) ,
  CONSTRAINT `fk_summary_sessions_by_entryway_1`
    FOREIGN KEY (`entryway_id` )
    REFERENCES `zenoradio-v25`.`data_entryway` (`id` )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_summary_sessions_by_entryway_2`
    FOREIGN KEY (`entryway_provider_id` )
    REFERENCES `zenoradio-v25`.`data_entryway_provider` (`id` )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_summary_sessions_by_entryway_3`
    FOREIGN KEY (`country_id` )
    REFERENCES `zenoradio-v25`.`data_group_country` (`id` )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_summary_sessions_by_entryway_4`
    FOREIGN KEY (`3rdparty_id` )
    REFERENCES `zenoradio-v25`.`data_group_3rdparty` (`id` )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;

SHOW WARNINGS;
CREATE INDEX `date` ON `zenoradio-v25`.`summary_sessions_by_entryway` (`date` ASC) ;

SHOW WARNINGS;
CREATE INDEX `date-hr` ON `zenoradio-v25`.`summary_sessions_by_entryway` (`date` ASC, `hour` ASC) ;

SHOW WARNINGS;
CREATE INDEX `fk_summary_sessions_by_entryway_1_idx` ON `zenoradio-v25`.`summary_sessions_by_entryway` (`entryway_id` ASC) ;

SHOW WARNINGS;
CREATE INDEX `fk_summary_sessions_by_entryway_2_idx` ON `zenoradio-v25`.`summary_sessions_by_entryway` (`entryway_provider_id` ASC) ;

SHOW WARNINGS;
CREATE INDEX `fk_summary_sessions_by_entryway_3_idx` ON `zenoradio-v25`.`summary_sessions_by_entryway` (`country_id` ASC) ;

SHOW WARNINGS;
CREATE INDEX `fk_summary_sessions_by_entryway_4_idx` ON `zenoradio-v25`.`summary_sessions_by_entryway` (`3rdparty_id` ASC) ;

SHOW WARNINGS;

-- -----------------------------------------------------
-- Table `zenoradio-v25`.`summary_sessions_by_gateway`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `zenoradio-v25`.`summary_sessions_by_gateway` ;

SHOW WARNINGS;
CREATE  TABLE IF NOT EXISTS `zenoradio-v25`.`summary_sessions_by_gateway` (
  `id` BIGINT(19) UNSIGNED NOT NULL AUTO_INCREMENT ,
  `date` DATE NULL DEFAULT NULL ,
  `hour` INT(10) UNSIGNED NULL DEFAULT NULL ,
  `gateway_id` BIGINT(19) UNSIGNED NULL DEFAULT NULL ,
  `country_id` CHAR(2) NULL DEFAULT NULL ,
  `language_id` BIGINT(19) UNSIGNED NULL DEFAULT NULL ,
  `rca_id` BIGINT(19) UNSIGNED NULL DEFAULT NULL ,
  `broadcast_id` BIGINT(19) UNSIGNED NULL DEFAULT NULL ,
  `sessions` BIGINT(19) UNSIGNED NULL DEFAULT NULL ,
  `sessions_acd_10sec` MEDIUMINT(8) UNSIGNED NULL DEFAULT NULL ,
  `sessions_acd_1min` MEDIUMINT(8) UNSIGNED NULL DEFAULT NULL ,
  `sessions_acd_5min` MEDIUMINT(8) UNSIGNED NULL DEFAULT NULL ,
  `sessions_acd_20min` MEDIUMINT(8) UNSIGNED NULL DEFAULT NULL ,
  `sessions_acd_1hr` MEDIUMINT(8) UNSIGNED NULL DEFAULT NULL ,
  `sessions_acd_2hr` MEDIUMINT(8) UNSIGNED NULL DEFAULT NULL ,
  `sessions_acd_6hr` MEDIUMINT(8) UNSIGNED NULL DEFAULT NULL ,
  `sessions_acd_more6hr` MEDIUMINT(8) UNSIGNED NULL DEFAULT NULL ,
  `seconds` MEDIUMINT(8) UNSIGNED NULL DEFAULT NULL ,
  PRIMARY KEY (`id`) ,
  CONSTRAINT `fk_summary_minutes_listen_sessions_gateway_1`
    FOREIGN KEY (`gateway_id` )
    REFERENCES `zenoradio-v25`.`data_gateway` (`id` )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_summary_minutes_listen_sessions_gateway_2`
    FOREIGN KEY (`country_id` )
    REFERENCES `zenoradio-v25`.`data_group_country` (`id` )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_summary_minutes_listen_sessions_gateway_3`
    FOREIGN KEY (`language_id` )
    REFERENCES `zenoradio-v25`.`data_group_language` (`id` )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_summary_minutes_listen_sessions_gateway_4`
    FOREIGN KEY (`rca_id` )
    REFERENCES `zenoradio-v25`.`data_group_rca` (`id` )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_summary_minutes_listen_sessions_gateway_5`
    FOREIGN KEY (`broadcast_id` )
    REFERENCES `zenoradio-v25`.`data_group_broadcast` (`id` )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;

SHOW WARNINGS;
CREATE INDEX `date` ON `zenoradio-v25`.`summary_sessions_by_gateway` (`date` ASC) ;

SHOW WARNINGS;
CREATE INDEX `date-hr` ON `zenoradio-v25`.`summary_sessions_by_gateway` (`date` ASC, `hour` ASC) ;

SHOW WARNINGS;
CREATE INDEX `fk_summary_minutes_listen_sessions_gateway_1_idx` ON `zenoradio-v25`.`summary_sessions_by_gateway` (`gateway_id` ASC) ;

SHOW WARNINGS;
CREATE INDEX `fk_summary_minutes_listen_sessions_gateway_2_idx` ON `zenoradio-v25`.`summary_sessions_by_gateway` (`country_id` ASC) ;

SHOW WARNINGS;
CREATE INDEX `fk_summary_minutes_listen_sessions_gateway_3_idx` ON `zenoradio-v25`.`summary_sessions_by_gateway` (`language_id` ASC) ;

SHOW WARNINGS;
CREATE INDEX `fk_summary_minutes_listen_sessions_gateway_4_idx` ON `zenoradio-v25`.`summary_sessions_by_gateway` (`rca_id` ASC) ;

SHOW WARNINGS;
CREATE INDEX `fk_summary_minutes_listen_sessions_gateway_5_idx` ON `zenoradio-v25`.`summary_sessions_by_gateway` (`broadcast_id` ASC) ;

SHOW WARNINGS;

-- -----------------------------------------------------
-- Table `zenoradio-v25`.`sys_config`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `zenoradio-v25`.`sys_config` ;

SHOW WARNINGS;
CREATE  TABLE IF NOT EXISTS `zenoradio-v25`.`sys_config` (
  `group` CHAR(64) NOT NULL ,
  `name` CHAR(128) NOT NULL ,
  `value` CHAR(255) NULL DEFAULT NULL ,
  PRIMARY KEY (`group`, `name`) )
ENGINE = InnoDB;

SHOW WARNINGS;

-- -----------------------------------------------------
-- Table `zenoradio-v25`.`sys_user_permission`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `zenoradio-v25`.`sys_user_permission` ;

SHOW WARNINGS;
CREATE  TABLE IF NOT EXISTS `zenoradio-v25`.`sys_user_permission` (
  `id` BIGINT(19) UNSIGNED NOT NULL AUTO_INCREMENT ,
  `title` CHAR(200) NULL DEFAULT NULL ,
  `can_login_at_noc` TINYINT(1) NULL DEFAULT '0' ,
  `can_manage_all_entryways` TINYINT(1) NULL DEFAULT '0' ,
  `can_manage_all_gateways` TINYINT(1) NULL DEFAULT '0' ,
  `can_manage_all_contents` TINYINT(1) NULL DEFAULT '0' ,
  `can_manage_all_group_data` TINYINT(1) NULL DEFAULT '0' ,
  `can_manage_all_campaigns` TINYINT(1) NULL DEFAULT '0' ,
  `can_manage_all_sys_users` TINYINT(1) NULL DEFAULT '0' ,
  `can_manage_all_sys_servers` TINYINT(1) NULL DEFAULT '0' ,
  `can_write_3rdparty_resources` TINYINT(1) NULL DEFAULT '0' ,
  `can_write_advertise_agency_resources` TINYINT(1) NULL DEFAULT '0' ,
  `can_write_broadcast_resources` TINYINT(1) NULL DEFAULT '0' ,
  `can_write_rca_resources` TINYINT(1) NULL DEFAULT '0' ,
  `can_read_3rdparty_resources` TINYINT(1) NULL DEFAULT '0' ,
  `can_read_advertise_agency_resources` TINYINT(1) NULL DEFAULT '0' ,
  `can_read_broadcast_resources` TINYINT(1) NULL DEFAULT '0' ,
  `can_read_rca_resources` TINYINT(1) NULL DEFAULT '0' ,
  PRIMARY KEY (`id`) )
ENGINE = InnoDB;

SHOW WARNINGS;

-- -----------------------------------------------------
-- Table `zenoradio-v25`.`sys_user`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `zenoradio-v25`.`sys_user` ;

SHOW WARNINGS;
CREATE  TABLE IF NOT EXISTS `zenoradio-v25`.`sys_user` (
  `id` BIGINT(19) UNSIGNED NOT NULL AUTO_INCREMENT ,
  `title` CHAR(200) NULL DEFAULT NULL ,
  `permission_id` BIGINT(19) UNSIGNED NULL DEFAULT NULL ,
  `contact_email` CHAR(200) NOT NULL ,
  `password` CHAR(200) NULL DEFAULT NULL ,
  PRIMARY KEY (`id`) ,
  CONSTRAINT `permission`
    FOREIGN KEY (`permission_id` )
    REFERENCES `zenoradio-v25`.`sys_user_permission` (`id` )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;

SHOW WARNINGS;
CREATE INDEX `fk_sys_user_1_idx` ON `zenoradio-v25`.`sys_user` (`permission_id` ASC) ;

SHOW WARNINGS;

-- -----------------------------------------------------
-- Table `zenoradio-v25`.`sys_user_resource_3rdparty`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `zenoradio-v25`.`sys_user_resource_3rdparty` ;

SHOW WARNINGS;
CREATE  TABLE IF NOT EXISTS `zenoradio-v25`.`sys_user_resource_3rdparty` (
  `id` BIGINT(19) UNSIGNED NOT NULL AUTO_INCREMENT ,
  `user_id` BIGINT(19) UNSIGNED NULL DEFAULT NULL ,
  `3rdparty_id` BIGINT(19) UNSIGNED NULL DEFAULT NULL ,
  PRIMARY KEY (`id`) ,
  CONSTRAINT `fk_sys_user_resource_3rdparty_1`
    FOREIGN KEY (`user_id` )
    REFERENCES `zenoradio-v25`.`sys_user` (`id` )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_sys_user_resource_3rdparty_2`
    FOREIGN KEY (`3rdparty_id` )
    REFERENCES `zenoradio-v25`.`data_group_3rdparty` (`id` )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;

SHOW WARNINGS;
CREATE INDEX `fk_sys_user_resource_3rdparty_1_idx` ON `zenoradio-v25`.`sys_user_resource_3rdparty` (`user_id` ASC) ;

SHOW WARNINGS;
CREATE INDEX `fk_sys_user_resource_3rdparty_2_idx` ON `zenoradio-v25`.`sys_user_resource_3rdparty` (`3rdparty_id` ASC) ;

SHOW WARNINGS;

-- -----------------------------------------------------
-- Table `zenoradio-v25`.`sys_user_resource_advertise_agency`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `zenoradio-v25`.`sys_user_resource_advertise_agency` ;

SHOW WARNINGS;
CREATE  TABLE IF NOT EXISTS `zenoradio-v25`.`sys_user_resource_advertise_agency` (
  `id` BIGINT(19) UNSIGNED NOT NULL AUTO_INCREMENT ,
  `user_id` BIGINT(19) UNSIGNED NULL DEFAULT NULL ,
  `advertise_agency_id` BIGINT(19) UNSIGNED NULL DEFAULT NULL ,
  PRIMARY KEY (`id`) ,
  CONSTRAINT `fk_sys_user_resource_advertise_agency_1`
    FOREIGN KEY (`user_id` )
    REFERENCES `zenoradio-v25`.`sys_user` (`id` )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_sys_user_resource_advertise_agency_2`
    FOREIGN KEY (`advertise_agency_id` )
    REFERENCES `zenoradio-v25`.`data_group_advertise_agency` (`id` )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;

SHOW WARNINGS;
CREATE INDEX `fk_sys_user_resource_advertise_agency_1_idx` ON `zenoradio-v25`.`sys_user_resource_advertise_agency` (`user_id` ASC) ;

SHOW WARNINGS;
CREATE INDEX `fk_sys_user_resource_advertise_agency_2_idx` ON `zenoradio-v25`.`sys_user_resource_advertise_agency` (`advertise_agency_id` ASC) ;

SHOW WARNINGS;

-- -----------------------------------------------------
-- Table `zenoradio-v25`.`sys_user_resource_broadcast`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `zenoradio-v25`.`sys_user_resource_broadcast` ;

SHOW WARNINGS;
CREATE  TABLE IF NOT EXISTS `zenoradio-v25`.`sys_user_resource_broadcast` (
  `id` BIGINT(19) UNSIGNED NOT NULL AUTO_INCREMENT ,
  `user_id` BIGINT(19) UNSIGNED NULL DEFAULT NULL ,
  `broadcast_id` BIGINT(19) UNSIGNED NULL DEFAULT NULL ,
  PRIMARY KEY (`id`) ,
  CONSTRAINT `fk_sys_user_resource_broadcast_1`
    FOREIGN KEY (`user_id` )
    REFERENCES `zenoradio-v25`.`sys_user` (`id` )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_sys_user_resource_broadcast_2`
    FOREIGN KEY (`broadcast_id` )
    REFERENCES `zenoradio-v25`.`data_group_broadcast` (`id` )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;

SHOW WARNINGS;
CREATE INDEX `fk_sys_user_resource_broadcast_1_idx` ON `zenoradio-v25`.`sys_user_resource_broadcast` (`user_id` ASC) ;

SHOW WARNINGS;
CREATE INDEX `fk_sys_user_resource_broadcast_2_idx` ON `zenoradio-v25`.`sys_user_resource_broadcast` (`broadcast_id` ASC) ;

SHOW WARNINGS;

-- -----------------------------------------------------
-- Table `zenoradio-v25`.`sys_user_resource_rca`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `zenoradio-v25`.`sys_user_resource_rca` ;

SHOW WARNINGS;
CREATE  TABLE IF NOT EXISTS `zenoradio-v25`.`sys_user_resource_rca` (
  `id` BIGINT(19) UNSIGNED NOT NULL AUTO_INCREMENT ,
  `user_id` BIGINT(19) UNSIGNED NULL DEFAULT NULL ,
  `rca_id` BIGINT(19) UNSIGNED NULL DEFAULT NULL ,
  PRIMARY KEY (`id`) ,
  CONSTRAINT `rca`
    FOREIGN KEY (`rca_id` )
    REFERENCES `zenoradio-v25`.`data_group_rca` (`id` )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `user`
    FOREIGN KEY (`user_id` )
    REFERENCES `zenoradio-v25`.`sys_user` (`id` )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;

SHOW WARNINGS;
CREATE INDEX `fk_sys_user_resource_rca_1_idx` ON `zenoradio-v25`.`sys_user_resource_rca` (`user_id` ASC) ;

SHOW WARNINGS;
CREATE INDEX `fk_sys_user_resource_rca_1_idx1` ON `zenoradio-v25`.`sys_user_resource_rca` (`rca_id` ASC) ;

SHOW WARNINGS;

-- -----------------------------------------------------
-- Table `zenoradio-v25`.`log_call_listen_engine`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `zenoradio-v25`.`log_call_listen_engine` ;

SHOW WARNINGS;
CREATE  TABLE IF NOT EXISTS `zenoradio-v25`.`log_call_listen_engine` (
  `id` BIGINT(19) UNSIGNED NOT NULL AUTO_INCREMENT ,
  `date_start` DATETIME NULL DEFAULT NULL ,
  `date_stop` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP ,
  `seconds` INT(10) UNSIGNED NULL DEFAULT '0' ,
  `log_call_id` BIGINT UNSIGNED NULL ,
  `log_call_listen_id` BIGINT UNSIGNED NULL ,
  `call_server_id` BIGINT(19) UNSIGNED NULL DEFAULT NULL ,
  `call_ani_e164` CHAR(32) NULL DEFAULT NULL ,
  `call_did_e164` CHAR(32) NULL DEFAULT NULL ,
  `call_listener_ani_id` BIGINT UNSIGNED NULL ,
  `call_listener_id` BIGINT(19) UNSIGNED NULL DEFAULT NULL ,
  `call_entryway_id` BIGINT(19) UNSIGNED NULL DEFAULT NULL ,
  `call_gateway_id` BIGINT(19) UNSIGNED NULL DEFAULT NULL ,
  `listen_server_id` BIGINT UNSIGNED NULL ,
  `listen_extension` CHAR(16) NULL DEFAULT NULL ,
  `listen_content_id` BIGINT(19) UNSIGNED NULL DEFAULT NULL ,
  `engine_server_id` BIGINT UNSIGNED NULL ,
  `engine_type` ENUM('LISTEN','TALK','PRIVATETALK','ADVERTISE','MEDIA','HANGUP') NULL ,
  `engine_advertise_trigger_type` ENUM('PREROLL','MANUAL','CONTENTTIMMER','CONTENTREPLACEAD','LISTENERTIMMER','LISTENERREQUEST') NULL ,
  `engine_advertise_capaign_log_id` BIGINT UNSIGNED NULL ,
  `call_end_asterisk_disposition` CHAR(64) NULL ,
  `call_end_asterisk_amaflags` CHAR(64) NULL ,
  `checked` TINYINT(1) NULL DEFAULT 0 ,
  PRIMARY KEY (`id`) )
ENGINE = InnoDB;

SHOW WARNINGS;
CREATE INDEX `date_start` ON `zenoradio-v25`.`log_call_listen_engine` (`date_start` ASC) ;

SHOW WARNINGS;
CREATE INDEX `date_stop` ON `zenoradio-v25`.`log_call_listen_engine` (`date_stop` ASC) ;

SHOW WARNINGS;
CREATE INDEX `call_session_id` ON `zenoradio-v25`.`log_call_listen_engine` (`log_call_id` ASC) ;

SHOW WARNINGS;
CREATE INDEX `checked` ON `zenoradio-v25`.`log_call_listen_engine` (`checked` ASC) ;

SHOW WARNINGS;

-- -----------------------------------------------------
-- Table `zenoradio-v25`.`log_call`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `zenoradio-v25`.`log_call` ;

SHOW WARNINGS;
CREATE  TABLE IF NOT EXISTS `zenoradio-v25`.`log_call` (
  `id` BIGINT(19) UNSIGNED NOT NULL AUTO_INCREMENT ,
  `date_start` DATETIME NULL DEFAULT NULL ,
  `date_stop` DATETIME NULL ,
  `server_id` BIGINT(19) UNSIGNED NULL DEFAULT NULL ,
  `seconds` INT UNSIGNED NULL ,
  `ani_e164` CHAR(32) NULL DEFAULT NULL ,
  `did_e164` CHAR(32) NULL DEFAULT NULL ,
  `listener_ani_id` BIGINT UNSIGNED NULL ,
  `listener_id` BIGINT(19) UNSIGNED NULL DEFAULT NULL ,
  `entryway_id` BIGINT(19) UNSIGNED NULL DEFAULT NULL ,
  `gateway_id` BIGINT(19) UNSIGNED NULL DEFAULT NULL ,
  PRIMARY KEY (`id`) )
ENGINE = InnoDB;

SHOW WARNINGS;
CREATE INDEX `date_start` ON `zenoradio-v25`.`log_call` (`date_start` ASC) ;

SHOW WARNINGS;
CREATE INDEX `date_stop` ON `zenoradio-v25`.`log_call` (`date_stop` ASC) ;

SHOW WARNINGS;

-- -----------------------------------------------------
-- Table `zenoradio-v25`.`now_session_storage_errors`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `zenoradio-v25`.`now_session_storage_errors` ;

SHOW WARNINGS;
CREATE  TABLE IF NOT EXISTS `zenoradio-v25`.`now_session_storage_errors` (
  `id` BIGINT(19) UNSIGNED NULL ,
  `log_call_id` BIGINT NULL ,
  `log_call_listen_id` BIGINT NULL ,
  `call_date_start` DATETIME NULL DEFAULT NULL ,
  `call_server_id` BIGINT(19) UNSIGNED NULL DEFAULT NULL ,
  `call_server_asterisk_channel` CHAR(64) NULL DEFAULT NULL ,
  `call_server_asterisk_uniqueid` CHAR(64) NULL DEFAULT NULL ,
  `call_ani_e164` CHAR(32) NULL DEFAULT NULL ,
  `call_did_e164` CHAR(32) NULL DEFAULT NULL ,
  `call_listener_ani_id` BIGINT UNSIGNED NULL ,
  `call_listener_id` BIGINT(19) UNSIGNED NULL DEFAULT NULL ,
  `call_entryway_id` BIGINT(19) UNSIGNED NULL DEFAULT NULL ,
  `call_gateway_id` BIGINT(19) UNSIGNED NULL DEFAULT NULL ,
  `call_gateway_play_welcome` TINYINT(1) NULL DEFAULT '1' ,
  `listen_session_date_start` DATETIME NULL ,
  `listen_session_extension` CHAR(16) NULL DEFAULT NULL ,
  `listen_session_content_id` BIGINT(19) UNSIGNED NULL DEFAULT NULL ,
  `listen_session_server_id` BIGINT NULL ,
  `listen_session_server_asterisk_channel` CHAR(64) NULL ,
  `listen_session_server_asterisk_uniqueid` CHAR(64) NULL ,
  `listen_session_active_advertise_media` BIGINT UNSIGNED NULL ,
  `engine_now` ENUM('LISTEN','TALK','PRIVATETALK','ADVERTISE','MEDIA','HANGUP') NULL DEFAULT NULL ,
  `engine_now_date_start` DATETIME NULL DEFAULT NULL ,
  `engine_now_server_id` BIGINT(19) UNSIGNED NULL DEFAULT NULL ,
  `engine_now_server_asterisk_channel` CHAR(64) NULL DEFAULT NULL ,
  `engine_now_server_asterisk_uniqueid` CHAR(64) NULL DEFAULT NULL ,
  `engine_now_server_app_konference_name` CHAR(64) NULL DEFAULT NULL ,
  `engine_now_server_app_konference_user` CHAR(16) NULL DEFAULT NULL ,
  `engine_now_advertise_trigger_type` ENUM('PREROLL','MANUAL','CONTENTTIMMER','CONTENTREPLACEAD','LISTENERTIMMER','LISTENERREQUEST') NULL DEFAULT NULL ,
  `engine_now_advertise_detail_digits` CHAR(16) NULL DEFAULT NULL ,
  `engine_now_advertise_campaign_item_id` BIGINT(19) UNSIGNED NULL DEFAULT NULL ,
  `engine_next_step_1` ENUM('LISTEN','TALK','PRIVATETALK','ADVERTISE','MEDIA','HANGUP') NULL DEFAULT NULL ,
  `engine_next_step_1_advertise_trigger_type` ENUM('PREROLL','MANUAL','CONTENTTIMMER','CONTENTREPLACEAD','LISTENERTIMMER','LISTENERREQUEST') NULL DEFAULT NULL ,
  `engine_next_step_2` ENUM('LISTEN','TALK','PRIVATETALK','ADVERTISE','MEDIA','HANGUP') NULL DEFAULT NULL ,
  `engine_next_step_2_advertise_trigger_type` ENUM('PREROLL','MANUAL','CONTENTTIMMER','CONTENTREPLACEAD','LISTENERTIMMER','LISTENERREQUEST') NULL DEFAULT NULL ,
  `error_date` DATETIME NULL ,
  `error_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT ,
  PRIMARY KEY (`error_id`) )
ENGINE = InnoDB
COMMENT = 'This table hold many runtime information that will be discar';

SHOW WARNINGS;
CREATE INDEX `engine_now` ON `zenoradio-v25`.`now_session_storage_errors` (`engine_now` ASC) ;

SHOW WARNINGS;

-- -----------------------------------------------------
-- Table `zenoradio-v25`.`data_campaign_publish_at_entryway`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `zenoradio-v25`.`data_campaign_publish_at_entryway` ;

SHOW WARNINGS;
CREATE  TABLE IF NOT EXISTS `zenoradio-v25`.`data_campaign_publish_at_entryway` (
  `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT ,
  `campaign_id` BIGINT UNSIGNED NULL ,
  `entryway_id` BIGINT UNSIGNED NULL ,
  `date` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP ,
  PRIMARY KEY (`id`) ,
  CONSTRAINT `fk_data_campaign_publish_at_entryway_1`
    FOREIGN KEY (`campaign_id` )
    REFERENCES `zenoradio-v25`.`data_campaign` (`id` )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_data_campaign_publish_at_entryway_2`
    FOREIGN KEY (`entryway_id` )
    REFERENCES `zenoradio-v25`.`data_entryway` (`id` )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;

SHOW WARNINGS;
CREATE INDEX `fk_data_campaign_publish_at_entryway_1` ON `zenoradio-v25`.`data_campaign_publish_at_entryway` (`campaign_id` ASC) ;

SHOW WARNINGS;
CREATE INDEX `fk_data_campaign_publish_at_entryway_2` ON `zenoradio-v25`.`data_campaign_publish_at_entryway` (`entryway_id` ASC) ;

SHOW WARNINGS;

-- -----------------------------------------------------
-- Table `zenoradio-v25`.`data_campaign_publish_at_gateway`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `zenoradio-v25`.`data_campaign_publish_at_gateway` ;

SHOW WARNINGS;
CREATE  TABLE IF NOT EXISTS `zenoradio-v25`.`data_campaign_publish_at_gateway` (
  `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT ,
  `campaign_id` BIGINT UNSIGNED NULL ,
  `gateway_id` BIGINT UNSIGNED NULL ,
  `date` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP ,
  PRIMARY KEY (`id`) ,
  CONSTRAINT `fk_data_campaign_publish_at_gateway_1`
    FOREIGN KEY (`campaign_id` )
    REFERENCES `zenoradio-v25`.`data_campaign` (`id` )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_data_campaign_publish_at_gateway_2`
    FOREIGN KEY (`gateway_id` )
    REFERENCES `zenoradio-v25`.`data_gateway` (`id` )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;

SHOW WARNINGS;
CREATE INDEX `fk_data_campaign_publish_at_gateway_1` ON `zenoradio-v25`.`data_campaign_publish_at_gateway` (`campaign_id` ASC) ;

SHOW WARNINGS;
CREATE INDEX `fk_data_campaign_publish_at_gateway_2` ON `zenoradio-v25`.`data_campaign_publish_at_gateway` (`gateway_id` ASC) ;

SHOW WARNINGS;

-- -----------------------------------------------------
-- Table `zenoradio-v25`.`data_campaign_publish_at_content`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `zenoradio-v25`.`data_campaign_publish_at_content` ;

SHOW WARNINGS;
CREATE  TABLE IF NOT EXISTS `zenoradio-v25`.`data_campaign_publish_at_content` (
  `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT ,
  `campaign_id` BIGINT UNSIGNED NULL ,
  `content_id` BIGINT UNSIGNED NULL ,
  `date` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP ,
  PRIMARY KEY (`id`) ,
  CONSTRAINT `fk_data_campaign_publish_at_content_1`
    FOREIGN KEY (`campaign_id` )
    REFERENCES `zenoradio-v25`.`data_campaign` (`id` )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_data_campaign_publish_at_content_2`
    FOREIGN KEY (`content_id` )
    REFERENCES `zenoradio-v25`.`data_content` (`id` )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;

SHOW WARNINGS;
CREATE INDEX `fk_data_campaign_publish_at_content_1` ON `zenoradio-v25`.`data_campaign_publish_at_content` (`campaign_id` ASC) ;

SHOW WARNINGS;
CREATE INDEX `fk_data_campaign_publish_at_content_2` ON `zenoradio-v25`.`data_campaign_publish_at_content` (`content_id` ASC) ;

SHOW WARNINGS;

-- -----------------------------------------------------
-- Table `zenoradio-v25`.`data_campaign_publish_at_country`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `zenoradio-v25`.`data_campaign_publish_at_country` ;

SHOW WARNINGS;
CREATE  TABLE IF NOT EXISTS `zenoradio-v25`.`data_campaign_publish_at_country` (
  `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT ,
  `campaign_id` BIGINT UNSIGNED NULL ,
  `country_id` CHAR(2) NULL ,
  `date` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP ,
  PRIMARY KEY (`id`) ,
  CONSTRAINT `fk_data_campaign_publish_at_country_1`
    FOREIGN KEY (`campaign_id` )
    REFERENCES `zenoradio-v25`.`data_campaign` (`id` )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_data_campaign_publish_at_country_2`
    FOREIGN KEY (`country_id` )
    REFERENCES `zenoradio-v25`.`data_group_country` (`id` )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;

SHOW WARNINGS;
CREATE INDEX `fk_data_campaign_publish_at_country_1` ON `zenoradio-v25`.`data_campaign_publish_at_country` (`campaign_id` ASC) ;

SHOW WARNINGS;
CREATE INDEX `fk_data_campaign_publish_at_country_2` ON `zenoradio-v25`.`data_campaign_publish_at_country` (`country_id` ASC) ;

SHOW WARNINGS;

-- -----------------------------------------------------
-- Table `zenoradio-v25`.`log_campaign`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `zenoradio-v25`.`log_campaign` ;

SHOW WARNINGS;
CREATE  TABLE IF NOT EXISTS `zenoradio-v25`.`log_campaign` (
  `id` BIGINT(19) UNSIGNED NOT NULL AUTO_INCREMENT ,
  `date_start` DATETIME NULL DEFAULT NULL ,
  `date_stop` DATETIME NULL ,
  `server_id` BIGINT(19) UNSIGNED NULL DEFAULT NULL ,
  `ani_e164` CHAR(32) NULL DEFAULT NULL ,
  `did_e164` CHAR(32) NULL DEFAULT NULL ,
  `listener_ani_id` BIGINT UNSIGNED NULL ,
  `listener_id` BIGINT(19) UNSIGNED NULL DEFAULT NULL ,
  `entryway_id` BIGINT(19) UNSIGNED NULL DEFAULT NULL ,
  `gateway_id` BIGINT(19) UNSIGNED NULL DEFAULT NULL ,
  `country_id` CHAR(2) NULL ,
  `campaign_id` BIGINT UNSIGNED NULL ,
  `trigger_type` ENUM('PREROLL','MANUAL','CONTENTTIMMER','CONTENTREPLACEAD','LISTENERTIMMER','LISTENERREQUEST') NULL ,
  `media_type` ENUM('INTERRUPTION','REQUEST') NOT NULL ,
  `media_order` INT NULL ,
  `media_id` BIGINT UNSIGNED NULL ,
  `seconds` INT UNSIGNED NULL DEFAULT 0 ,
  `seconds_played` BIGINT UNSIGNED NULL ,
  `cost_per_play` FLOAT UNSIGNED NULL DEFAULT 0 ,
  `cost_per_unique_listener` FLOAT NULL ,
  `cost_status` ENUM('READY','INVOICED','INVOICEPAID') NULL DEFAULT 'READY' ,
  `cost_invoice_id` BIGINT UNSIGNED NULL ,
  `commission_entryway_per_play` FLOAT UNSIGNED NULL DEFAULT 0 ,
  `commission_entryway_per_unique_listener` FLOAT UNSIGNED NULL DEFAULT 0 ,
  `commission_entryway_status` ENUM('NOTREADY','READY','INVOICED','INVOICEPAID') NULL DEFAULT 'NOTREADY' ,
  `commission_entryway_invoice_id` BIGINT UNSIGNED NULL ,
  `commission_gateway_per_play` FLOAT UNSIGNED NULL DEFAULT 0 ,
  `commission_gateway_per_unique_listener` FLOAT UNSIGNED NULL DEFAULT 0 ,
  `commission_gateway_status` ENUM('NOTREADY','READY','INVOICED','INVOICEPAID') NULL DEFAULT 'NOTREADY' ,
  `commission_gateway_invoice_id` BIGINT UNSIGNED NULL ,
  `commission_content_per_play` FLOAT UNSIGNED NULL DEFAULT 0 ,
  `commission_content_per_unique_listener` FLOAT UNSIGNED NULL DEFAULT 0 ,
  `commission_content_status` ENUM('NOTREADY','READY','INVOICED','INVOICEPAID') NULL DEFAULT 'NOTREADY' ,
  `commission_content_invoice_id` BIGINT UNSIGNED NULL ,
  PRIMARY KEY (`id`) )
ENGINE = InnoDB;

SHOW WARNINGS;
CREATE INDEX `date_start` ON `zenoradio-v25`.`log_campaign` (`date_start` ASC) ;

SHOW WARNINGS;
CREATE INDEX `date_stop` ON `zenoradio-v25`.`log_campaign` (`date_stop` ASC) ;

SHOW WARNINGS;
USE `zenoradio-v25` ;


SET SQL_MODE=@OLD_SQL_MODE;
SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS;
SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS;

-- -----------------------------------------------------
-- Data for table `zenoradio-v25`.`data_group_advertise_agency`
-- -----------------------------------------------------
START TRANSACTION;
USE `zenoradio-v25`;
INSERT INTO `zenoradio-v25`.`data_group_advertise_agency` (`id`, `title`, `is_deleted`) VALUES (1, 'Zenoradio test agency', NULL);

COMMIT;

-- -----------------------------------------------------
-- Data for table `zenoradio-v25`.`data_campaign`
-- -----------------------------------------------------
START TRANSACTION;
USE `zenoradio-v25`;
INSERT INTO `zenoradio-v25`.`data_campaign` (`id`, `title`, `advertise_agency_id`, `active`, `date_limit_start`, `date_limit_stop`, `date_limit_weekday_sun`, `date_limit_weekday_mon`, `date_limit_weekday_tue`, `date_limit_weekday_wed`, `date_limit_weekday_thu`, `date_limit_weekday_fri`, `date_limit_weekday_sat`, `budget_cost_limit`, `budget_cost_balance`, `media_interruption_enabled`, `media_interruption_limit_play_per_unique_listener_count`, `media_interruption_limit_play_per_unique_listener_minutes_window`, `media_interruption_cost_per_play`, `media_interruption_cost_per_unique_listener`, `media_interruption_entryway_commission_per_play`, `media_interruption_entryway_commission_per_unique_listener`, `media_interruption_gateway_commission_per_play`, `media_interruption_gateway_commission_per_unique_listener`, `media_interruption_content_commission_per_play`, `media_interruption_content_commission_per_unique_listener`, `media_request_enabled`, `media_request_cost_per_play`, `media_request_cost_per_unique_listener`, `media_request_entryway_commission_per_play`, `media_request_entryway_commission_per_unique_listener`, `media_request_gateway_commission_per_play`, `media_request_gateway_commission_per_unique_listener`, `media_request_content_commission_per_play`, `media_request_content_commission_per_unique_listener`) VALUES (1, 'Campaign 1', 1, 1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 1000, 1, NULL, NULL, 0.1, 0.5, NULL, NULL, NULL, NULL, NULL, NULL, 1, 0.5, 5, NULL, NULL, NULL, NULL, NULL, NULL);

COMMIT;

-- -----------------------------------------------------
-- Data for table `zenoradio-v25`.`data_campaign_media_binary`
-- -----------------------------------------------------
START TRANSACTION;
USE `zenoradio-v25`;
INSERT INTO `zenoradio-v25`.`data_campaign_media_binary` (`id`, `binary`) VALUES (1, 0xD82993EB59504038E49648DB73E0C8D195829F51CFB6E72DB91C8348B6D392DB67D6A5AC6E89A7D2C6D0B9DB245570A8DBC249159CD044D0CE4924A15042C492C725D5A98B6183ECF0A623AB37249CCB1AD4E664E3EEA82A29BCEE72A34CC6D33D3AECD5E98399C2A7A86188D8C4EC5569B34A6FB964AD2DB65B51F52B588D5919A1BB56D5EB8BE142572BAB335483A4594D4B236E2338574B2CA66DA317AD489714CE9810D5AC94A50357EBA75C72BA30AB6A753C8FBA9257E866748794BAAB6B93DBD15912D56C8CA54AAB2B513AB5572B55CA60C46DF8ED55CC355D11D56B53CBC8D8E9B55BD52D8D6982554EB703EA4B1C5109D6605F2B1BA14C64D8F5B925512BC40AD23EE4D5289C6E439E8D5608F24CEDEAAE40C592D72C9B6990BA7A6762E52B90E472D723D461AC2A4196CD096C7256D4E0E761E8894BBFEE0401E7DD484AEC43B37FB636CAD49F4AE6E3E662977FB66491ECC18C703A3E69E2C2311B926CDB92C1859BCED832D6627A9D05CEC1B6AEDA561198A1156DD63E53B322CE2E71C5125A00E53D8EAA1AD7AC935DEBC440CAB692549ADEA113247148A3B3C9C91B9D26DC5801BB1A33EAE6D2A88C29AAA662B09CB5B492E024B9249634435109C8E49226675747972D7152C7D4274D9EB05747D75CB2544155C4259E35B7285549772392471355C50ED4AE291BD4E73D9E785527A3DA924ADCA907263B52B95C5545943B964B9455C52C85794AEBD56624722A5768344F71B96B57C542EDA68CE1ACA6489509D923AEA5E4E2C206EBD6A36855DE6343EE176A9D22A242FD2CACA91AA621D0E59DA6DCCE40BADC9358D3D7DB5A1A2DEC00129D73C91CE80046A34E5B31E04028A3524AB49220355B91C723D95AD45E64BA6034D24526EDE8A0C91B725D77C3C2DDAD92344877CE369EACF6D2DAE8AC95FA56AA6F9B2A66D35AA570EE5B67D1E64734C61C1CEFAEC7350A84E2BAD6E671974882C8BF0DA5D6F282C466A7393C2DE768589C4A292FE6EB58DC29057CD524BB9B0050CABBE4B144086169F32279DB2266AA321EAED4FBD16C48DB467523D4EAB36AC96D6A591C96B80A6D29F3636E68F371299803E6C6ECE14AD922718584D4ABB32688D8A7F926D5DD2471683FD56DB715E3E8435ADE8D0DE327A76A91AA28D52ABB2A9173863B6616293573CA47011DB95C756A496C6D12F89A082DD49FDFABD5AA9AEB09E74A20CD6EB53473EB371C7563D5E7E6679B89B310E78677F5491FA2D5E97B728173C734D78EBAD773693915923613E5C83B16A1631CE74946C35C2D53D56864F5C0E72BDAE38DB69FE68A095C964924E527A496F9AB5471E8B8DA7535D1D4E584B60073C5B8E54D43D3E3C759456938A471C7B92AA85CE471084924CAA683D46274E6026F28F51B6EB71BDCE714EF4AC8F4DB67AA94563ECCDD647B968A068BD49B8B2A90DAA83F1B93472BDCA516157EC8F5DAC4349C252837BEC45735EE4681DA61A8C13AEF0535EA8AEF54D4A41D4BA0465C8A208CC4B7E714E4424914522B45DA69A44EA8EE425C2BEA66A268417593AE3C5ECAC295A6B0369C6EE29EED8A38C9D66252AB437B026896EEC6996AE19EA496889EC8A13F15828AED57A9C7246D2477D42284AA0252EC5B1B207D5A56A939627103EDACAC38E46E20FC5BCCC8DB9236DFD4A284AE81B70C052552CB505B29AEAC89BCF3B7C8051BD0CA9A5D49341676C6A3D31FA4AE89B9262B50914928B8A8D7256C9C97BAA853A291B405BB45EBAB49C6D0D1EBCCAD92B8A51FFFD24712628717EC895B24BEA482779195A3B8A3544091ED2FD133DCD4D95C8228D204E7DBB4C274DB91A915BAA1195AB0C8D8C0A0CB56ABD63BD220C471DCCAC1191FC9DB6B69210B0E8AA4DD60C12B56523AA2A4C0BE73C7A4F2DB629BE9E2D4A0DB1E9B6FA56BA2220E12F00F59EF2CE28E36FC56098276F296E8DAAEDD4922888926FD45BCEDDA673074CDB953B044D69B839794D0E8CB1B49D5FBD5E32BDE2CE7265D2C8510939328A965ADA01F54C9C52D9132D7A8A5B0AFDD0340D32A3D223154A7F4A492391B56C21D639A7692ACC3B3E392CB1A57A1BA7ACD9AD3D26E3DEA3156A2405372D925B2C1B622C5D536AF4136AF3D863C5321F8A34F46DDD2EF3D567AA7015CDA61D9DC53015D52844924A5A159635066DD53425AD369F51BD3B14425735B63789C206B5EA5A6392D488B8E99C9CB646C68A59908395D5074D6D4AD558EB199A6AAAA631E6D9909C9590BC92599284AD05E0F1B99CAC72488F69CD4ED7466D9998BD4DAEA572599AD528775CAE49B8860075DC39B9B4C263995CCB2D52DA39ED2E9CCC663914CB9E98C243C56B72A9DCD35DB91B8DD9DA8714561F8F1D52EC3DF4BEDCD3E1C4DE8A39D0C116AB95D539D2B899DD54A8AEB6A4EE7EDD652D52DBB5B04EB2AF8A6ADB491E90B72ED91C9229B6819C4CE98D7E948B94CEEB817D42CC396429D663B2590E170EA85FAB578325EEE24CDB49430D5E8027B7CB64A83D5A89B5993EA2126D45DFCE3CE40C624663B93F040526C769CC3EA405533751AD4D4E6F45D20B40056EC9198DBE82048E471471CB4A0491B6D472CEAC0496491B4DBD9EC935CE58740B6DA6DC93675C1DDAEB1B20C7DAC3464E9532376AC40E48DB723DC35FCE49B84C80D65ADCDACEEC934D95F229B6E828BAC6D9B7FBCA522C4BDF30CDD2DE639C56885372BA56AC4B486D66D4D7B486D28A7B34D5D08A929EE45B2384EDC71D2B0D566A5F3FAE42599AC86E94C95443DD68856AA4D93EFD4A8C85A2D5F65D41B9BE3507AA39AC205AAF6BA8464C432A96EBCE9C91A645EDC50CC58E265F4E5D2E69BAA4150A85593604D25A4E72AD3607AF65944A7CCA80EEDAF0476B452B45BD1E9D42D8AB0E3E8ED6EB817B082A0EC7E2BCCB48224FCCDF8E5B8C2926FB94D1CD1E8D3EE12BBC2A71AD1B15C5F21E75B00ED2ABF23BEE489B68D56C55764B2C681D1E7E4665257826B606BC51457A139538E18F95722036D91CD23AF21803E5DBD2CD1AAE46AC257E1C7898D636057016489B63B1EAD2136CA1E494F576248C25ABAE6D262BB7349AB41E91A24FFBDADC2AADB85513555A2F5A896192255C208D68741E2D56299A34855ECC8DC723497A9EE49246DA6FB574C8B23B1C65E68AC176B562481D52B8AB68AADCBD16A762ADC574A8925924B23AD6C115D92496459CA42E891C8EBD52E81BD8A5928B821CAC714B1469D06334B10B308E6A369F524B3484AEB6CBE6CD4EDA22AD15BC4C3706E014E5BC6579C72351F5B0787AB9648D95BC5F31AD0871AD3AC826690B30396F8AE4455B0A7429F6EB764B285531B0FCB1C5D05BB2A410BBFD22A732A335882E689840A73B2C3B96C4D37DD5B01A42DAE4696B541F6C459D8C8D22B7B3272B6C257E456E8D9B761229E59F9545D41420D92CAF5BAC1485029CB63D16BCCE9DBBAC15B61650AB4BEC1279F513864C2C0CD0DCED913BEA0A8F48E3955D5A393211BCAE1B49B9F6B9A65E8B8DB6DBE23548858D378A12EA52A3ED48D13EDD3B054563152A72FAAA8A19BA0A5C5BBADB162A2C8472C6DA5DB51A3387BADB4DDD4304CCAE951E346B28DD1E35164C7328D23E351A4291D8EA82C5124B92671A47CD3F0450B29A365B72B6DB5D35363E8F26DA1E2A5254AE572267A53C1C39A355747D3F24BD57C53C3391E8DC8865363B5DDCA4606550388EB9E26C9A702FA73934512D333535D745561EB2A9F2A56A9418932367511A902F4AB915B1CAB42B4B35DAF0CD2764BCEF95681C044CDD963ACC0CA9F3629CBAC81516359D8E4AEC1550C29D8E4D232BAD92B594158E3484F545B00CB70C5A2B45940AB2C753644B4E0DB26AAA440D231CA9922B740D8EE32B8DA5D00B4B5B54B1DBB00A8D99AC6F560812A9A65EB23D234C2991A6160D6E28CAB1CC0E0C5AB58A41562A0E924B9B51AC2C0A3F2B2EC92D2AADB259A61E14614D6457F63C1C9182660F55FA2B8DC90B5D15DE4D52B75451FD374C1619B5B24B3E396A8C85A848F6CD9E8E95B2591D2B23B235983F3261A46F1D3F0D1E5DB59C43488C764E55BC7BE595C5AEB5946592C0471E4B529BB1D7028D7D472B1ADE35B08B8EC9244465B291F249649095DE596EA90C5E4B9868663B62A2AD4B0B8B1935FC9271F38B4DC5F463E91931D1BBF07B91728DB1D61E3D95091F4D0D4EFB836536167AF1C7A58E063C4AE1E52A6AB63E4E4DADC4971C7269E9B0249ADD3AE81B5836565C8F55025BA65445283A9F514CD063DD6493755D1673347524725D36F6AB48BD36449C530CD1ED4C525265998106BA2F86B8AC5346D03D28B9CD8E4D3EC5BB5026D04E8EB89253B6D82F4EC71334ED92527DBAE391C6FC2F582CEB761D2EB5C34836F62D31A6A47A0DCC24B0CEA5852DCA251A68DB775E6C36691454B3DD1E7B43253E541CB4DCD44C16161DAA257C9EEDCC1C00BEEB135D9225924713467D16ACC31D371011756D5B6E06F41479C8E48E6D6A15751257EA37140CD2584C02AD1A9BC760BE120BCDD8FD719E140B01A96BB66736138DB264562D8C14AE78F4550D168D42A12708084EFB2CBA4D6A14710697AEB7B00AD8A6D12A582C0FD5D9B3712D0E78DFA99D0A1244B6EC6DCE8A0DAEC29B99DEAA0C4A299BAD3E4A0C91CB6B2A4D1638C36A1B6E0E66151B7357AC0B95B913A55BEC0A7AD91B91C72A0C8D48DC573D2A17AEE99CEA0CA5C7244D97480D6DDB3451BA0C036E36E5BBAC6806B1B8DC81AD562725E5CEA802AE5AAC75DE6A04798AC4C9E5E20178BCDD69C8A403B1C8A3713D6AAA111E4D04056EC7634E4EE404B1C6E471C92003B2471C91CD000371C92B91B);
INSERT INTO `zenoradio-v25`.`data_campaign_media_binary` (`id`, `binary`) VALUES (2, 0xDB20CAA05A5020271C91C924642048D26DC6E486C039236E3723B960B6DC2EB6E1D7669C2F18EDF13E5552391B82CB391D76BF7AA711B22D92C923575124B8B6C99AD664B42249A34DA19BEE49489E8D612C964918E0AF8129B23B55508C907B7A5961D62B5BA10253090933BA2E49A2EC1AFB7956DAA4CB24E752C95AA729E0DCEB492ED5AC9B5D82554B0C42F1DCEC592B358192AD145729562A29F6B4AD6C56D56176A5D62B84250B5769ED2B608CE7572B396E66043A550BDAEB94E25F57CC589486C797D5AC8CA959554B87DBB5B6C0AB2D651E8EC698552BACEC92B6E8A90B09A4B2CA9DD4ED9CA9D0A98A09DD6A491B530C04A4AA47A2A78BA728EE432A530D62B98DC91BD4EC94F1C2A16C31DA91E760518CF71AAE491AED8D76AC5239299B0A21B9969D60D4E5A3EE43E6AB0F5DB1D6C8E30B0EE669C893E60A5B25B9B006548409E4CE20DAD41A636B24E8244D6F8E3892EC4276649836D6EEA33294AA491FEC21EA5DB68823D5215A59DCAA81DA3B92110DE682EB6CB2088C56C1BAE38C48A5E8E3C92391B6B8D8E48A5589E7029C9D7DE45C5E417D737434ADB640C9658D2685DC40FADBCA62A4D5245B266ABDE8C8F855C71B5820FACE1D26AC9261D76348B2DFF048CB246905ADD3E664E5B250AB4B24489EDB56894B249521A3AB492AEC7531E355C4D8F18AB17CD4A74CA9F155C58B1BAA270655C3391BB58B4F55683923B5C88055C43BCD71C515D52734EDF155081F0D91D8E2AB492ED58ED519AB44D1DE89FCD8AB64B64FAEC530D62451669C57462A05EEC1EB56E4970898E773E8A53E826124EEB6217DF545B25BD61C4966769C21C97D91B8DBCC4030ECF192D5E840289DB1C8EBCEA04AA3D26554DA597190DCF02048DC8E4B13AE403963AE4712EC20451A8E491BCDC03913B9697CDA20B41E32E5C748DC6DB48871D02F219D45657408121D9106E884040D7BF736B1D7EBA2E7AAE206450B4F3BEAEEA8475A71BAD7B2C73333B1D498728822DED36D5FD5A2935AC06949A4836DC96B51494AEC053EDE5F2B452B6D1C366D2829055E08C3D4EAAB6AC8772D3BE26DCAEB6B2BC6D87CD91B6DC5EC2B18C783E4A83AA6B168C4D4EAC366D0DB8808A3AAD8F271A796E8A1651B71493B2391E4C6714773644F67ACD52BAB2EC8E3C6D6A519A85B73C525668C75EAF0C76916F8DA6173E72A6B793970D5A9A36B10754A6AB380CE5DE326B575D7D3DBE7C82354CF36FA75CB44E2768CDCD5E7936709E0AB3D2C91B64073E76159311F1C732936533E2CCEE569A99C91AA36D5A9643D808CAABE85B277227348042F19CB25E76834E16C5E3CE688A6BEAEB4D0D52684FA80734A8D64923B2473871B4512D15474C8CEADAD90057108FA9A8ED95BD4E4752E41E12964A0B4E75CE125A362903B82710644E4D2B898DD0608B44DD7E5D39E94A6C2DD24B684765533DB02E0BC254DE7692528DAE5E95CDC86C8A475AF15D819901368E52330C0076D636EA3DF2A50E69CCA83611EEEBD5D72E147913D92E8DB28D34CF0AF02FAA5493B628AC1D2DB56947B9E82C778B2169CF0A1B719759542D9ADCB4B58CF43F4FB4A290C5662D98CA8A7D996C329DC5ED6C5D6A26D67CD308FD3A18CAF0271A2EAA104C6F75507D4E34D2F6550CC46D15E39645728453307B52CD4A27C32C157C8492345F56B5BC88764692E345BA9232BAEB7075D48BF525E368AD4E173F341B7A954AE424714B9EABE248DD6A55D47E20DDE4523BCA9CB1110DF5BD229BD7212C0AAD92D6410AE54C56D5AB2A3A0B0C4DD3E4E4A97B884F9139E2911D1ACD465995D21B95B86E998B8A200EDD63F1DB8C32443AF592A5C81E8C900DB74D12BDCA992BAC15B6A2C93DFBCC114ECD4E6D164C0D5247D4927CCA11D2349BC93D9DCB3215AC881230E91B7299EA09938CD98A6E6C0CBB6D9E293A5EE38E46E36DFDB68AB19B8718D88DB71BD4C72A8CF5452A51CC4A3EB251EFB64C023B1348D487BD82A3A11EEE2E342D65EAAD6EEA4B36450EA268D0453C3E4231F80E94B2260AF5AD3A44CA5F250E67FA34028D6A0872B6C6A427BAEE6DB6A6DB67DACA5A72595B850D2EB3C2DEBB08674D5B2370B572377157254E2ACC2AE9D89DE9BB082349F744BE2D26F5C2DB4AEA2A6CF91BDA2A542D6C48EB96CA52228D0AA39735521B6D1EA4776D2F04519BB53C144A1EACCCB5341D490C7B766A34448D22F992C5366C6DA7CC7A4D4F14503A9A12846D25D395D9946C688EDD8F49786C718F1491D9729368F6744ECD46D655E9A99E7B3649AAFA999CAA15672CD229B8B13CBB13A9B9B4C3E9E6A46DBD52D93A6219BABBE6772AC82E98D9F15924E899D8AE7936ADA299D8D732A8E28F0D52DBB265A9DC8A18F79E883EB8D26E5AE4AC89F6E4B2495A43A9D6C58E292163BD52CD39AD2ED2FC8DBB1A6799DA9B954B069CBEB2A2CD6B831D4E949FD238541A2D4EDA2E302E9487CFACD2A15E8CA5B554D1E9DE8A8BB1D710E9DEAC84AE3289EE4D46492D659EE44EDA140AEECE82361DB75191BEA017326B9C2B9B640C66252CB22D4ACE3A6DAEA2066AD7314EADA20492B4D3525C6604B2271B923EA4049226DB96CD7649A5113D8A058DB519B4C60A062B2352CCB856137238E46FE52E1B5628A1A02DB2FAA991B51CB5990D24B405EAC59BA2958DB80C6E462B7B414B0868D9C425D14DD2EDCA88DAFC642256D6695C96517AB3D60E57D2544A1F627CAAEE44CA3791E5FDC2CD52455A149C8DD8E18FA56A8992B11BB1A76C75B41AE335DAF682B398A7358DBA7599436A925F362A6C96C94C6D321D13E35B2868B1B66592584A948D2613DF6D322A3AE4050CEC8910FE8ED88E9C2C1EE592E9AEAB713E958DD554797187D4ADCD268AB75C256C7C51B13292CAEA44C66446525B2E43B0E8886AD5B24CAE47636C3D172BC2949B6A37DACAA569B5C81DD9453C4EAB8E225E28A4E9661623255914B38D1AACBAE835F41B924808EED6142A9AA9423ED5762D4BC8D20A75761C915B2348FD1AADC2A825701196D75C6C357818B176E459B57C11E6B586E5D570190EC72AAE3D1E9CC6F42AD4200EC922BDB578139208DAB6B57213241CA5B57AD22D6A25D2CDDD4E089DF92B1C6B4D9293FF45504BB2B046D3C51A8A754D0B3D2A9AF491B724E4DD528A22F00574AC36B8C156DADAB5A959202A757E8556D1558D857697ADCB24682D52E8A79CAAF0AF1AA6F46E0572A8ADEB1DCE4AFEC318CB2B8DC5967942A7B48F8D4ED8271CAB327E44BE2E895B3069D931B2B21B2CAD91B25732D5BC5C91494CA67D42D9266D05B2654EB722678C2C9DCE4AA260BB3E6749670C6ED5AA58EEDD6492BD22C63AEB9B2C5B01C76C76BB282ECB09214EDB2E1B609D7B625B2C2CAD2063D63D1ADAB26B3B34249E46A26F4B6823567B1145A5F00E51DBB2819BCA135A4774929D169D4DE5CBF6128BC51B913C080D820AB66D5C4C0E8A250E5A5CCA0AB9535A45CD766835912B721BB7FF9B72163C3901DDAC92468A2C91A20BBAB5DEA46DB92C6B8D4EA5B62725B293F4795C4D15449392DD24608AACA76A4972951590891E44ED924D46B461EE85925203CB2352BB143B6637B40A6B123455915D8CE5BA3295B57978CD4EA3E66E85BA363555067245BA4AADB6D29455BE3D8AB9637505B637B53CF3750D5AA25A6305BA48EE2AE52E45B6495E471DD21B72430D5B2652C5B63B8E311D959D6AA486666B4E644DC50396BD602DD3A4636947620A95FCE4923D6205F7210B4EBD65A81E5EAF00036D5B54AE3DA604923924723EA2039248E48E3BC4046DC724923D969ACA0E4A86036DB92491B5EA0369220A96D84A0DB6EDE3B1D73CBB6DC4A53F3DD2BC39D14692C86EDB224E45CC9611759D955B065D921E9A836CEA6456D654E52DC2DE39CB6614864D4956C2BA0E737167DB66BBEA750EC99A53D66E738D0CCBB72DAADD390F9D8A46959EDA98CC2A30CED871B2490C4C9233735176AA4C0AAB1C4DDD96343CB126EA2997A55B51EB220AE32EA368EEE61AEDC954A615B64375CD758C0D39F75730957A920ADFA36D952A9B7DB7258D352A825D492C8D353C4C5DAA5672AD5604CAF59554724BC8EAF23578398408E72F559A69CA1E6C2ED5928A8E86738DDD5205473515B065ADC652EE45B46BB1C6E25DBB76939245236D75D850CDC5148D4D5215C6B905D8331CCC63BA9BB84391C932327BD8322DFC2D892BF055563683F24D4246CB3C16143B8DEC986B26363C96B922821C3223A6BEF3A6A63826ADD15B94CD36684EF886523570307C75DC9C22178B2BC636522C92756C2C2CB8378716DC524D2A8A46F506723348655E8DDCD627AC44324EECF224E168916EED0E34B25E2D4DAD2AC933A99D12336BA75D7DC6B21D70906B963D5424D2550B0D6E4E33B2DCEE448D26EA2AE9AD521B27AAE4B22D521DAA287A873D4825AD590B2976D216524D4E4DAD2718A32D8D6A186B2B1CB64D6C1450946D594D8C0CA7A898297D2A1A9549CD8A2D23089AEA2D8C116E5565BD36AC13ADA35E4A4D2A0FD0BB212DECCE09AF6B0B8A1D22B8959F56AC0C732B6C71368A0A6D49354E3BCC0C70C6DA76B76E0B9246CC8EBD22D78266CD08017DDEEB72252A0352172C96CD680369C52489BEA4058EB51B91CD42DC9D092DE80479B92B755E40024DC72B8DC844036E496A71BCC00372C8D3AE4D5A5F5A49B864046DAB248E4D2A0392592596454A046E492391C88204923724924DAA5BBA51BB440391B6E371CC28039238E47238000471C6DB924A4003924923723DA67BBED5A8C0046DB724924AE2048E472389B5C4046E391C9248000391C8E3723DAEACB69D9E82049249246E464E0491C6E491C682038E492492450004924924924);
INSERT INTO `zenoradio-v25`.`data_campaign_media_binary` (`id`, `binary`) VALUES (3, 0xD8699BEBAB504038E48E396D6BC0C72C8EC8D955B136DB6DF6DB6A27BD2CC83374D666B46E91A7524935680B2554F14922692EA59ECEDB2B509E64534FC9227046E4D5A78B5E02ECCE6B59A258B4ECCBC6D9A62EEDF0AC371281DEE6E8CCB961A02D56D5EA735981532C4B2C4D875CA749FB2414A8BAABABE71A86C75F57098F1AADAE12D5AC942583570AF8A3AF5711AD298B5693E8B3AF4A0A2DB2769AAFCAB3CBAA46DCD5AD755D0BAF6C94BA95D922572BD0C74F38ECAD4E485AE6C725554A35107DAB16D56C7CA593AB6AC8A0785D2655A7BCE361095455860519ABC554A7E92521ECE6B5D52D8CED8255ABB72289DEF0532C57334D1EA49F4EB92C548EDC50AF476C4CAF1BD52994B2039F0C7365883E9D9B2CC72608D6F2E74DB96849C7269909D9D00EC63FD4A0AC2AC9E329CD0892452CE085B430A3F0E3E844A08837FCE5EE44104A37FBA3D41F42E6ECEC23B85072492CEE23C699EEB6E4F02253465A389554C112E99DBEAED5DB721E0DDCC294C492CB2C58410253BE591AC0E335171AC922CD024613725B63D7ECA35DEB92209A1C4E6B74E860B49376C8DAE1AAC71B71B7DA524331E59256DDD2E86CE6628861B45C53DB1DE462A714D23E71F0A49272CE7CD852A997DB72C8E4D3E84D9EB05528243B71CAEB5547A63C723924558348C1B0AEAC5584B8E4A974ECD4E735DE70558528DA7E475C558545148336EA55E3E89DC236ADABC7BB13938962D5672B7A2B5785634D4D0F185508F96C32236356A83B6D3140A3AEA67AED6B26A8D722609663E2043BDFD6BC0AC042B5AEB72880CE21E8E695CBD9B401165CB224DDD79F71562BB440E91B6E48E3B84025147236EDB2E052D36DD6EB64604B236DC8E3D99FCADE55BC2048DA4922495820396ED624EE5D815D6EDAF9546BACC6DB69E6CFDA66AB91F9594D0924ADB753980859D11BD4F5C0A8512B74538C5EA83939745A96D72879DAD0BEA8A983ECE8A6BCA537076565A2C088D8E3A8B81C60CB4B2E71B488D561AC1A885D2B99EBBA4B1B616C2AA611A95C66CA355225F4FA6B4C3CAC91B42FD4EA9BAA88E32B0CA379C7236D29C4977938E56FC7B89B89A832DF66F92B94440AD4EBB36EC871C65AAA871EAF71C88D286E291D73C734F0BE1663E364F3DFF4B3B1D52BB2EE58E529A2575938ECE52C296C6935DBDEE7A4FE775D48752987C4D2A92CD569A32EC8E7E8415D55B1E66AACB96395B910732B1EA4524925E74BB4CB7CC8D3D566942A51752A69228DB09782AB0B5ADE4B23E5AA5520CDC7257368D94C4C8791D5277479C0E4C8F8AF92C8CCE68C36F9B1C71CE48A476230FEE3E5E5350A354411D52584F280E528FADCAB66EDE3C9A7041A595B71273CE9AD0465E30578E473E692D4238CAA82DEC902BB75B9A46EA7E8DB06D6A5D8E5BB5CADB088DCA578A4B64B19D35E8332C86CE6129F71C932DAC64A8B6BB5D470E43F4C6E22D8B8C3A9DA9BD993DA62B8803DD2E546484DDB2E94C2D5220AB29C90A16BB76984ABE2226568E69E21DA29B456F05082D0EAC9CCE468A1C5058E3B6BCCA264625FE7D25EA2A0BB6ECA65D82B50D30C5B42D6F03263956281E49C1DB7F2A2A2B67A95AAA4D8A7396D71B481D42284730251EBABEEB1B20F54891D63763950572978ADAE3B20ADCBDE55894D1ED46284AEC15BC9A1CBB227245B0A4682EE591BB74B3AC95DBB1C5DE8B59AB20F8AD31F94B311B9E7CAC5A3F854B92958E669D7686EE8B5E996C8C9C2081164F9BB64D22AC57152C0A8241B7F49A2C6C7C481DAD8E45D62CB50053936B8E567234416EDD1E9D3E59A5CA459EC911265B4E2E8A592A488BAA1EFFB6E4B13BC810247DB476CD25E94B5DCC2E1191274CCE6C0813772DCD4A254A1531B91F31A92C0C95AE69A3BDB64B3622A8AA136DD965DBFC5E4BA936A2D305FCCB71BEE26E374CFB7DA52D91CDB2EDD8CF1882632028DB951AE277D5C42D763C0A706DE6DB6B4C4E4646C90849FD6651C1E2BBF0689BCD6629C62E5B764723A58A2C601E5575D03550816BC31DB5CD32A44A62B56C5403B4AC92BACC3CA84AD5924AF61B669F2B96657A2379AE78B23D26C6471AB56E247600317A9B0A1FBA525278E554237AB49B3DC53E10CBC5AA8EAD2EB7AE9AC5522B76E4DA43453A1C8A3CE288453A2DADC92451F53E116F38C9AB6D36F4C61B353634B2492C200A3256AF2B2D448F1C751DC7A34969B6B29238E36B9D4AF54D63299E8275555214F9949BAECC903AB99C865278D2D03990AE8E4A58ED4D4EC84DAA299C855252078E59BEA3D5A0BAD229BE9E95B831D0A9BAC58EC8697DCD52D9BE30AE9EA389B1CAF229DCBC80ABAC3A49DE9B4ABEEBB229DE8A5B0ADB71DD52DC39B4A9DEA57589198749DC87B8858366B9D09F848F267559D48C28793B8F3D52DC35B44EB28304E77BB6BEB29142973B964E94AB4227ACAE1E92830637F4EE2D4ACC396C29D08215C8E4B1CEB49BEE471C8ABEAC3872ADE08BBF00410E6B24B13D5A99BA641F0018AC471D6E5EE60C139423AE2E000DAA2A65AEBE60058DE89C8EAD4E7F46999CE00489FAEB71AD86036E49648A3B040392C9646A4EE20372496D91CD9EC931D267C2022990894D597A1CB6ED6FCE457AAB69246CE1460ACCAFB31CADADC34EB5CAA62A8269BF3D35CD205EEDA90BB59EC052784990AE3DEA33650CE8E4CDCECEDB0C5B546CCAB5A36FC6F4636F85352E97EC5B4D3DDB83E7749317646D943DC30DCF4965865994CB5E41AAAA5CE3AB1C1C4CD49BF246E48D07286B12DF2CB9BD5969B62A09AE403E69599A2D48449657ADAD0A149B9258E2404512CF8E5ADA69FD2E49BAE0052A925B471A817A4E8B95B8DB857E8EA391C95D64256C677AC72B713D22ACBADC3AEC50CF691D8ECB0C430E276CB24B4C2C6081E6AF35D22372306D7DBD16ED3EE43B9425C64951ED45F82076A92B535D0A2E8D6CE46C8CA81AF237E7715D1A9DCE702BF82B905B7A63C57A1B31B584C3A59623643F5C4EE57E1C8A4713768D1E8D466C2AD818AEC75356EAD219D1C8089BEAD8260D46E36AC57E147628E3958D225BBEECA570266DCB5B40E57225DA2F4B606558288E54EB91B55A378A28E469DD560A21F4955A7932FD5A91B57AB96BD6DE68B68AF25DBB1B91B57C90571FD1B44D52C92764257C83551E978E5AD48B24299AD17AF2B4ACA1D4AE4594A48DA4B9B5DD52E7235C9B1484AA36570F859C6191B4D49E359A8D92372CB46B0E9DD1CCAB608D4EE8A6E8AB384F58D2EBB235B268A26CEDB22B3278032B64B2C5B44B01747792BD3EC89EA10B345470C9CBAE3B363049ABFDAA25B45371C7113EBBCE5A963AC80CCD22B5C2ABAB325DFED71C91AB4A21AC8DB46CBAC6275DA17FAD9B541B5EF7239ACD1EC8B72725D21A0565933755B41B8DB0DE913B9416912928EFBB8E13DE42CA31ED169C42D9ABEC136BCA9981BC1214B5394B55364E09B2E69E915CAC098DBB238ADD5A57299ACD1CA36DB9236F858CAAD3A75349262E9396DB22009AEAD76DC9A3711D4AA4D1A79554C78DC8EC95BA94809248CE96CACC911CC925AA45747127B71C95BD52A451EB05726460792C76CAD8336856FF8645549B91A1E491CAB28771C43575BD4A7552E2057E5B6E36E8C9B55273D1C651EECA924C95B49B19755642F2B488CE7D4215C66D0A8A5B7B365A1B354E5576412056BA6E43AA64A34C7BAC3F71DC840D1D8A2338A61D2A4C76DF6451164C2AAB1B2614B62820D54964714AAA168EB593473DA25AB14E9D4C1489359D6E5D400D71A28B6DEB640D7A369A8E358A0475B914314D9A9C359D9AAC0296471369950C04965B642E262E03ADACCB55268A0C79372A52DDAA6AC1DEB6D21335D4E26746681C565716B035A8153613078309DC5C6E353CA74DA2BAAD6395EA5353039329875493EA2BDA4EC76E4A306905D95A6249B4B82BADBDAF3925E1EE0C63969B2F06BB8866E2292932D942330AE792CBCDAA43C227072E5D5603BEA2CF0A48B8369BB1D63433E044EBDBA64854B4301EEDE50AAC8D32BB4DCD3A93CE1F2554766A3ABA764A543E6EAE6C9ABA3444D1B48792153A3771A4E651BD3EB2D9EB15163CF1528F726A363BAE54866E6A366471B6C76E553E1BE7458546FD4E935936253840CDB91272A53A22879C325735344C99C6D91ABA7A43ABA8AB695D5A7259B5255C4D5258EA4B957A53C2D6E369C5CCA38DD91B6505725792ACFB7D4D6A425E70AAFE4C0ED82E9775BE50185B15CA85B85F713ADF31C5D0698DC034B16D59F4E2ED25DC6CEBD92068DBD86EEE45DB0A15F4758B2D8F8DA61288D258AB91ED5DD4E36CBC565803D98D92465862D4F3144AD6706AD0FA9A42BCF073922D57C62D59C4F7593CFC4EC62C23717690618D05AC4A3D345556C80A16A6DC6BAE41E1524D55B5F758DD70486AD95C6AED94338C9A2599DD963CAF588132BD74458B4ED4CA1D3DB977202DB2323F589E78D6F05C2DAAFA71CDD63C8AC491B39DCA2D8B3B6AF62D4D967F5C3DD2310CF6A4AF2DDA2AB258FBE0C6F223F61B2340C6EC2F71CBAD76BD31CA7E844DCA3D052B25525DAA228D381B7E4D68224E74E46C9D8811DDDB6E573D21FAEE844D8E210A2CA4B646AC1BB142BC95BCAC149C4AE52ACDA812ADCD83B0CD49933AED47321175432AD46EAE0DA843C4D4CE2A0E4EB76976CC820C6654DC8DAD7DD74E903D820783C75B6DBF04047246DC8EDA220469376DADCEA6036E3923B32D7DC9BE489924036DC71B8DC702049246DB724B220391C9246DB9E8047236DC923D75F929C9AEE2047248DC71B7080371C9256E3606036E4923723924046E48DC923D6E1BBE590C02047246DC8DB608038E38DB91CE40046DB7248DB7000491B8E26E4D7609364D26E204B2392491C940036EC6DC6E3C62046DC9248DCF12048DB6E36E3);
INSERT INTO `zenoradio-v25`.`data_campaign_media_binary` (`id`, `binary`) VALUES (4, 0xD96489DD915000372372471B620046DB71C724A00046E371C7238200391B8E46E3D99F9A1959A42046E371C91CD40037248DB71BDC4036E47248DBD40036DC6DC6E4D4A35A5EFC600048E38E48E3E02048DC71C4DA58C1379B8DB8DC664047234D4924D0EDC5ADA3BE4046DA724B63CAE0489A73FAC55880565A5EB6E79B00B52171B6EED49B83AD9257A1B8D9495FBD510248D1257BEB5962271409C798EDAA47708D2763D4E06C6F8B5EA84EAB6DA92CAEABB963AD21E35129ABA52E93E19F494DDB4D1ED3D3E284F2CB9B29C7D485BCE4E4CA5EA32876E59706CEDC04E5259724E7503A9BA7D36284F24AE105D2D99E372BE168A71F6DCAA2976836FB7255119705E439BAC712D3DC846B03E165A16CAABA65E4A40B6CB17464E8828B6CF0DAA8EEE546D75156F9D9626A8783E8A506A397595358A334DC8BC399C8E214D4ABE368E6C35908A5CB24D92FA35B94C2A1D46F553B0DB2C2D77B31B526E0A2351F713894A2E1516CE19D87D8EC72DACAD4A1C1175DA4657321CB1B89E6BACEA1E52C41E655D703C7348E200DD49F5B6B8B54E6DDED2007F46A27D993233B258687D89C1DD6E68F46234775B5BCD51D63EBC3910606A3B13BE8D925051D71FB0BDB48C724762918DF442AADB828C4D41C6C3EC19527D8E591A6A7E4E7C4FC68B6795E84AE7F8C0896A2834F7D559A2BD5594B1F93A0A3B924D306995EE24D49CDAD50AEA25E6CAAA6CEAAA2C39AEEBAE0D4DA4AE7D86881769F7F9D1A9E820A13CF62F256A2A6627D66EC5123C70D1A3CDBD3A05CB9D9654317042EF723ABA6491C82A91B5542F78401BBD2A5456B1C405D2CD2E35D3A055145AED548F49C5124579D28F13B9CC52F2B613BDB9AA64B636069DCD2657DB5C3EB25BB5484759C5144C71B2BC95C5163E8DB27AB5DA323DAD36255DCD2279D718AA3224913614D1EA3423CE24CCE2DA5423ED2A5686B5502B76A901AA5D52483F18255C958DC8DA0AE55A8FAD391B496575048E48DC6FC594C9513B54657D5688CFA1356AC956B925948AF0D0C767A49655B8DA385A9C72459E9B83286AAE1D62984321AB52D5881E2C94DB52E5523279B24B5AD2B15710CBA5B4F2924A985CDD6AC8BF252B54FCAE57644475F50C9629955015B4DF32D72C91AB52F11CC95BB2BD5EC8CB28A5B0C941793259AB34C36B1F8C17AB32EE75267C51C5B6EB8E34978EDD52D95320A5B6CB6E58DA19CB72AB895927147B52AA715B2AD01B7CB715CF5B6C2D4ED852E035B4B93D3ADD9A35B6C26BAB5A72DB32BB858EAC8D4596AC6A03E99EBD4AA7CAA42B129D9218674ADAF49BB1431AEDBAF0AA91B6CA5DEAD2919D993264DD5A25BDA20AECA352BAE4558B2064BEB6FA713C643036FD75912BE02A440AFDFF4D21F842A5BBEA234CB0EC71CBC415A6C85AEEBC2A122CB72B72EC0E0638A664256D6675A15626D21B726B6E8D054A3029CB6D92354C11093723726B1A948FA5626DBD2E67CEDE270213AA36AA7A18AC27C954D36ECE465C963682D3352CACB234976DBD3E664A5B25748DAA3890D5D5548B9646C87E255C6BEAC56531455E4DA72752E3DD4E644A9FA55A588E49226D755A6072D51CB585505F8DCBEA702A98B0D5471D6A4D5681D2A2955458ED56ECD19AB671EE3A5F71AAB67B51F4DBC9CAAA5AA029E471CD7265099A5A72B49589248DD620367024D2966A421DD98463493E4224D7B4936A3D9187A91DECE400EE59624E3A00048DCB64493DC0028E3BA64DBF060389C92C6EDDAA4B31D93AA60491C9246D1BF20A252725DB66CE0FB2EB2445F5BA6F2E4ADB489DA21AC5E725FB237644FA8E45C2AE2C56D368C862856B7EF3A9CD42946C3ADBBB2D72B822310DC66D123553C9ECAC490BB362D5BDAE529272748B6E76AB7128A4B3ED5E0AC130050ABC91B4807EA5FEA2324713EA678C9BB53B244D0688D353A95B95CD4EBAB3288D18C3B230F2B246D6869666E1278E8C9E561FA4AD4DB0890CF3938E6D4EBBB66C9718557543D0C2571E82AE271E5587126CEEE71D91C73C6C8CCF0D50DD52CAAF25073E85AE46DB728A0A90FA4F6D75D73E9DB0F4E39217349B91C8C15A3D56B82B2498429E6EF926719E709893A954B5DE7AB390C6FA6E96F0661B3A7C951D56993AE41E7C86121CDB964E76C368D5D36DC736BD9238988E78C09875B7EBAE3D5286CF9C17327B844EAD2DCE569576458194E84C8A6AFB24289750805389AC96BD4E68D3280E546156B0174EBEDC84D93E9520573C6651ABA21537168B61B96BADCD4A27CAE81DEA857336D0372DF05AD42BD384C6F27473B9249656D28C8D94976A4D31F8C2B02DB63556AC2175D80A394A59C5E4ADA8313E2E949E1EAC3B6C94E6D43D99B9041F9D0A44D66ADA4806725389FA6B3635AC3C1692E352394A1DA152EB726DAAAEC0D79D2E2B6A4774F1158A2D5151AB4FB8CA331DDACA7235CE1D98AED2C0ED9ADE2D268EAA2EB2A063D4770A44B0B91A3A85C8317DC35B9627AC3251286ABBFD42274B703532348C052CBE699E54ACC01FB7F576C4681F249245726A56807A7ACD4A17436C25785B8A3A9F6AB5948A8E6648F245B46C3D4E502ACB528791536B848D3E16C3EC15D2688F3524B0A5D484EDC8E46ABBAA500DF375762C0C574992CCF34D16E8E6983C0A37963708563BC4249E38D2475BC41C6D7CDC4525F210CA38F48DDD12ECCDD8BC081248EB2A96BC521C69B3E2E966120DB47491F5F5EC12D1E5522CCD225AA9A9DC7C3C78631C71B64818336E9AAF3A821E44A6EDB2ABAE1593C542536D8219ADD44C9416D274A43A192C1570C9B359A7F2235309DCCA35420C92AAE1CDBD82CC499A2C6C0AACC7F338AED4838E37274DC5E229E218A1CDCA2C5495B72E643D4E84365EACEA36E0591975E60A27C9A8EC9A3BCC3A319BEDF59C52B34BB72C91BD3EC3DAD2950CB25DB91C8E39B032032CE2BE4EB64135D714F27F12506DB96A765D3AC4D692955C398DCADCAE855844945914ADC5763505752C762AD23D74A15E924D26C5BB9EBAEC448E142292CB0A1FE9766069CB4E1BFABA90436B4A35AECD23212D1B19479D054E1CF5E924A08B08275657645535AE10D2F735724B4A19033B2BBA4D1AEB46DA85B413208BA65A65BC1771C3148A85B41692A207B6A5BE0DE5A9872A3D22A94AE61B5A174FC91D0CE5B225BA595C8805143357A53BBB25105A116524CCCD51F75A6C25BEB27D9BA39245CEB308E72C8E45AC849015DDF1BB3483B2508F52BD55B85A58C5B67BB2C65AE5E5BE7755331B7955BA4134ECEC6585B03F6CF794CE0D4DC8E2D0D5BE3C26535EBF85BC5A945EDC6DC5BE30F05C658D5594937923D9765D51A8E3154B327B72604F4675947B6B58A0CE4B348D52690A19C59453CDD72C079D5187DB112AF4A392B89B6A75547D52495374357A3BFA017550B55A4B66B6E38D8D49A8635135303B5DE91DCD4A50314A19F48C25184F4E491B8DA9FE409EB8D5895D51875BA4B9D438B64B766429D23985DBF44CCEB24C6DAB6B8D7ECC2E12DF9AA5BDAA7604E62A1C417BF91347452A60D74D0C238B5270FB55A2082E9663E227E9EB9DBB0FD1CB38947265EB7C5965B47D4DE411F9280CB44DCED58DA5729351C4F30FADCB1FDB0D5CAA8692B12D8CEA4AA87336A7A9454A54D250E91E0B0C767219FA0E8DD2FFCE8D4E30929D20EEC537E8B38D74E492274E77C0B98BD167929B4E43EB75BDC6CD39D347828DA1B91C2D67327CD285E382BE8C878AA89977582C748D16E460FD699539BD0ECC3CD24368E5CF024C31C8E9EA9E8E43AEB6AE9DC93EA44907F4AF3D42263F6C250CCC6923E3B1C57047A77614357B0E856DD4466EBB545379AFA0224D22A95B20C5EA67B255648D1B8C220B3B666E7BEA2C7232DCF5DC0C2A509D9D8BDD175CC9915612129242DD4CBC0C1F6E48D259BBE813726564908C0A1672B5DC954D1B3BBE199C101132AB63ADCC160A04C4F799D61022AAB6D76E460C1D9164915CDD1AFD3219ABF21CADC6FA4D960C149347A395AC2A1B133923B1CC4A136D079D724D136D1DDDBC4C0C91B65471CC6A03D26713672BC8018D4987B9CCCA00F9C764924D227C369A2CCA0B6C999DB5D63E13963615B2963C1D92371987C5F4246ED6E4690D2AB6BF1A35FC2719572B6EA5D4291647667565B82AA4F31C6F35942B6C2DCE56CD4A245EA5859A3271914CEDA5785DAE46DF51C57A1AB1415056755A3C17296215DD4DF45BA98ABA3A8754DA7DA55C36B6BA24A2355E3C6DE2B194FA7254B1AE9A4CDD4DE4672A0A5253923B9A546A344A732F926CDA363CB72F1961DA3048B72B95513D2A564A9F0AAC32BEAF82313A40155F392B952B020D2657EAB0CC44054DD9159DBD2DF84FA1AB0203886B1CAA2E000471B71C8DCD00046DB6E3723E240471A91B8DCD85C922D99784037239248DBCA0038E491B71BDA6048DB91B6DBB20037247238E3DB9DACA14A9E6036DB6DC8DB7AC0276C6DC6DB6AC02D2371C6E38E0038DB71B91BD46DD3EA2AD22046E36E36E4E820392371B724CBA348DB6DC7D256E4C6DF69B6D3D3B6A4A26266C6721D99A8E57A20BB14B1BCD3D02146D44FA7BCE4212AE082A4EBD4EC929D5378A19AB876C692C0A1FAA37AB31DA4E121EB4E4F116741B51A9AEFF5D2F4919B515544D4482F7B6450E53682D644EC5546492443292459E757238A74DCD3F19AA3435D48491D8D01E25DE73EB3ED96555CA7B93293A8D95D06839498AE7AD4ED937303BDE8C73959C5DD5FE8D8C03A2CEB61C5AA2B46616361E83E9E724E67D5AA9B2FC2618886E15A462261AA4AF493BE13614BB07B95D75D616BB848F15ADDD4E7BBE743BF49AF6B4846B6BF08991CF850A8BF68EAE5520603BF2A752C96B8C5D467AC2A425F2595E3ED4152BA882A4AEEBB1CBAA8458161DB6DC286E8D94146CDD71D7292CABEA87B6C8DA76052E3F7269D49517C8349749723E0D8C44369DA60EADA26B3DEA389A6371CC3386366C71D20CEC4EC84E61BA056506EC0A40DEC8BB2A5D9E9CB9AAB6AA428E54B8578ECA4C12CAD97D386C368CE3DB7249F4648E0934516DA67C3D6F162C33A53928F655CC41B5B13B69EEA02069D5D26FBAEC29B159A509DDB6A9D9E6ACC81B8DFC0EA8F7441598E92889CC22176CDB2371DA880A71391B51DDDABB3E09AECE0C7996FC89AF0205AE471BD1BEC60475B6E38E3EE8044DD713923DB66D3A5635200471B8E471CA80046DC8E3924DA40392391B6E39200391C91C923DC6BE298A269A048A472372AD7E0C6E46EB5675121B8E50DC8E376E2AA9B2A7F5ED3DF9BFB1067C35C8B3FC849528346BAD22962D1C9B4E4B646D8508B9EE46E5AE3D3A26D371159468BD472D4E4B0A8303B955B1C5D045AD03E351EBAC6671B03AAECD3DF7ABB585F65CADA692EE4BEA7272D4CD6165F425BEAEB3BC4C8C50F1E76C69BD2DB946B6862E324A1B1C738D822691324CF65CE61E7674990AEC041476CB64911D0F1EBA559D02092EC964924D60026D276D56DD44046E46D2764DA8049228E36DBD7A094925ADDE1369CDFEAC9688100A4B1B7247020D8D2723480C5EAB71F49BB5AD36BE313106C2303DC5F692BBC642214DF7BE3EF4C341F7644ED6145DA830E8F1DD3AFD22290C166CCB2482C3D63673B248E322F70A9292AB2C720634897C68E4724D46E9A6E40654934CAEAB6E4C729E8E061CCE4632A471B9234D7C8E8DB24755890D4EA9AAB0165C83C2C6A4AEBC928461BC254F4C72B491C11CA73650689B56E004ED4A59C1EC265069EBD95C85263A4BA29CC66AD6506C624D1DAE3C946BAD227C86DD3A08DE203C76429DBAD87CEC4A41F55B9B542C6E5F31CB24992C7428847705F1BD39A8FA9C265E21F6E6A37A1C922746B95B738CB41E1AD2A1A58CA82BEF452DAA5D29BAEF14BCAC39415924965CCA1548884E731D6E27FA248A2FECD614893F6B2DED29AA6299CDC8214F671CDF3608194D206D8D3D54176D970A8DC67615896F6AB5ED919036AE47502345B72FFAC5321B18230D7116302548710CD9DB722B71AC622FCD6D814EF9AD3E4571C6A10AA5F04752C99B8585D243AEB29FB61BD05013C9129ADD3DA4EF6915CE4261392C926BB42355562B58D5F02DBAB44A3DC6123273D69A68FD35C67B2825D43C913AFAD5361C3A82D91C8DB61C33A1C52C6AA6122D4D247B8DDD29F86B658C36378A3650CDC63E3B79C89B9276303072292D55B63A22B5E4ACC70D2DE7EEB1065444498F2452DC70288ED0C995DC722CB25ADA80FACE54A5FF2BAD2D31E76270865028314B14B3BCB02BA183ED75265C2B59C720AAC67021B35752850D2DE95AE20CD43AB86BB291C67E18609513DE16722D7024B4526CDC21ADD4CEAB8D4959CB5E1C7247696F248D167C3BBD96ECA4A676438C493292E65A8C6E5920924DA5949563669E5B955D1344069667512BE371E6E8510A5D5A13EAE84E51A9480A6DCEE98C14CBF26CAF6B5C61A55252B3E9B68E058C3A01256BB6AB483D99569311BDB6CCCA466D2428960B234DAE802311CB63517D041933546896560A1D59AA1E59ADB66A2D03CD8A18AF9D2B71C7EA1B62E5635A3D8A2C4F176BE6E52C3B5186939ECD5A46B2EF05D4448A0242BFF50895B1B68AF245D4AA7958DA19C5EC836EA77CB62D5E853E6B06FA6B3D37148E36D28D71A63591DDD68392591C23AAAC7369D97F955D56B4CEAE8DFC656A88DA9247106632C2D852DDCE4AD9E77D150E0A78EED5247DDD46A5D6D70DF43E180F9B6EADCA54964ADA0BBEE042ADCB3CD59DB03C27976B932D42C556D316D42CA70473915D9633B2B9292B9EE22EB5C9BCD9369A3C6338E48DCD3EC4DE8EAD16254E116BB2ACF2271A489295BC9217D557CEA51CB21E4E69576D2D36D4DE4E9C32130B43968ABBB61B6D7523B5B59212C911A3B23AF01576084CAE3D36944B0E3AD4165124FB62D5741D89371F2E652C15EDB421CE6A4E1595282279DD5290BE0ECEE015B6B34A56A54A0E72A38A8EBA8A0AB5C333AA574A0BB4CA5E2F2D62D7A24EAB08062A552EC517EC0C764ACB8DCDC40391C76AB0C9C20355BCDD6E4D925B3A521D460391C91B91B9E0038E48DC6E4E02048E38DC923AC4037238E48DBDA24B2E2237E40492491B923B80048E491B6E39E40491B9238E3706046DB9238DCDAA7BB695B5440391C92491B7A8046E48DC8E49E2048DC71B6E3D02049248DC71CDA699B655AA400491B92491BB2404724923723B000471C6DC9247A4048DC924924D9E5E3555C846037249248DBDE2048DC91B924E680571C91C91BC4C048E38E38E4DAA4DBA59ADC00392491B71B9E2048E48E3923EC0038E39248E39E2046E48E48E4DA67CBE9E39AC038E48DB9239C0037246E4924B640391C8E48E4AC00471C923924DA27D46DE2E600371C8E4924C4C038DC8E37245A4049237248DC8A00391B71C924DA69C32D63E820372471C91C8C6048DC92491BBC2049246E48E3562049238DC91CDA67BBE9626A204724923724CE00372491C924C62039249238E4EE60391C923923DAA5C3A9A98A6047249236E3E2A0471C9249246A40491C9248DCB00048E48E491CDAA7BBE5A39EA0391C8DC6E45E20491B9237239200492391C924BC20391C923724D9A5D4A1E15A20492371C92366C0391B91C6E3ECC0491C71B8DBB20049246DB714D9A3A2E11AEE0038DC9248E4EC0036E491B6E3B40049246E4924AC20391B8DC724D8A28AA19A6220491B8E47236E20491C724724A20048DB6E48DC6800371C71B724D5AABA5599700048DC72372460A0491C7248DCE4E048DB713B74614048DC6E1AAFD2317C2B495B00BB2369066E53A1E523A615B75365C8E20BCADA5CC4CD536D1EA4D2E395A3A159E847256923D5572AB9274DC45CABA8AB2CEDC892A92B45247E36E2D4DA66EED25708F6EF8EB91957071CF54EB888A50A052C6EC8CA51078B2559C919D4D96F6DD4A365593AD5D6C2A4858E9F9AEB18A324089CB24B63A6C382A5B66EE3D6572E7A4A5741CC55902A6AB28298FC8DA6E2BE61072C3D18E39CC158BC953894DAEDA21D62EC201CFD89A91A9240B4E4D236E3DE2039666D490BAEC0296482945CD868829D23E1403A5194E2EC67A15B5C6A45C352E1C5248B28E77BC6B75B8E36BED86C629AB56FA911F351C89B6643CAA0CB394B92C613A7AD26E1EAA5D2B58A75F2D3DD752E09AD6A249CD6EA8085C81FD6B2A6058D4CF6A46DB88EDF6EB9234DC6BBD49E74EA419BCAAD2395A6FD51C5E685826354A3092B61912A1F5327DCB48DA446D29EA522C2A6A77971CDAA49BC68D8E4B1B841B247EDAD723690AB46B9BC6A3713D16CA668C156A5216DB156DCAC828476123D93AEA33497A9E5AA5961B292F2C73BD0F5B51107B101AA934B2CC358E14F93472961B0C163B570B8EB5B60AAE3A5A391D0F094324AB3016B1BAE541054C1FD5996C8DB5B6235CE51D6E4BAC0B0F4D9C8DBD0EAD4ADDBBA8148DA316B5AC0C0D59C61A8F4CCE09B2395D116CAE0C8ECADB929D2DC7C6E6C6EA0C6D476E8DC70A0AB2365BB6DE0A034EC8E0684C1812765B14731D2E26C6B596700AA9292CD625F0138DC0D5B745DC3C722117AD357A8D962713EDBD31F7E6B52592847E349B55B57C4B93A95265B5763F97789A2A8AF85C7E389A954D51957B28B5786F7648A58E159089E256F555BAF83F0C556B4BB594500AC76599CD5593F7E03B1042048F5B4BE5943A4457DD91EB3242A1A13B755B36477236164B1D39B7EF21A59A4C6F19532335BE559AC6A36F05B03FAECFCD650B34478DF5729A8D16CDCA159B486B0C5BA58E358C4B6BCAA2923B2A434D3F6A4E5B54248437E6515D1AFD429A15B624918453CFAB542DB646490EA5B01F92FD294555D21AAB4C9A281D1ADD421625B622F646F485AB3C348BB913B2359022031D8792B59023A071EA91DD1B0A312F25741A40253539B57A1DB34B3A90555C1DD1435394555C28924A9C723D22DB2DD6355E2C2EA7237EA53E2F2A3CC32FE532838DC6DB7DC9367BB640D7627D271A9961C52A73CDC8D0B64A3245AD5710773F0A658DC850D5BEF03F55C853B61D26FC9D59C516438E32978E7EF42BCA324EB5F9F6358DA65667CED43C8E42C782DD2B1CA195B51E3475A8349329FE3BAD340DEEC5123C95B05772DA123D92328F8A5D2F7999D63F144C9A36876F4F147D72468672553C2AA4ED42AAB5523AE72C09CD6D3358A95B257430E55C083E957C4FC9E32B6AA59A3BB0BB328E054A531AE8BD7C2D3B47A1DB25BC32E6FF1610F5DE605D491AE655D26D450CE9AEC6127C95A43EA8BD3726B65B3BF284B256D89DA5F27C92D9224875947A8EAB73EA15D24BC9BD23CFAD36D6561A9BB28512B8EC762BB047141D97874B945A9194BA9165DE5C3536DC5CED3AA5629B0B7C3A94751D26D5B65D76692944F5B2413A591DA985BA545E266DB0DD3A55D3D5AB54605A491DCD45B07285736292CB2A3235023F99BC243492240956FD1A7C461A2B8C2699AAA31246420A5AC69B20BAC40ED1BB64911C420A52EB1CB24D0AAF56951BEC028CA2EC8E2C2204D6C495B24E040451D96B725A4203B268DC924D81D82A031F0E0B7246DCBB462401014B2444A94404B6C6E5B6BD761C8E5A244A2D79E431E1C5B8E36E5C2C72478469CCBB7564298475B6D4E568057EC392D91B443D559563F0B56C8EFEB9B56085C89F8E37744099CE8B6D4BA304FEAC8B714DE304ED619467E8B9C88CB1DBAB444E9265B63DA5042E888E924B6321B9B062AE3B59632D7183E3F05E926D925B0B15B99A4D72EDC045B97083736AC88E4E3C5B7F609291AD81835FF04E3E30AE9D6FDA7970728D855CD6C95838B2465478BDF82B91C26AEA5D6955E765995C637528E48D893A5DB1C8CB497DB4559DC92125D9105EB2592402BD4D686AE49D8C5ED6D6C0AF690A5B72B64C7EAD8E3EAD9557C99D8A1EA86503D35D51495AD99E44196B06DC6DDE840D8AB393723E820452295269DDA40476569B963D498BD36596A2039646DC71CAE20492369B724DC6046DB6DC924E20046DB71C8E3DB2B9215A29C2036E46E4B64922036A351B4929FA0B6DB92DB7451A248E46D24FADAE9DB2D5950A2B71B91E1146041C9238DB5E2AE00DC9CB6564DF0C346EA8A208CDA257B5AE2B7ED78CA96C49A52AC5E5A95B72CAA877486B5B4A4AC02D9005E595ADA6EDBC752B0A21C15E58CBEC082A8633E646678C3332F691DD4B2C3B6AE5AB813D5195C2EDAA281EFDC999812DCA21556CEC148B164B4EEABD4986D489B6B9EB854D4E0852A43530C34BB5648E352898274765B2CA529A43A95C76655AA072552372CD5A46C6A8B57E7C8DD6DD8D7574A18491DBB24AF0BCAA148F6EC59A93763AE0EC5D5297C32C25B4BB92C718565B56CC6E48E968FBA8B876396C70A5D2AAE64AE2924D4EB8373045FCBC12275495B5F694A4A8E5717BF69395D0DB7ABC1683CE4A595D9D42F92B30AC108775596B6D2C1E74C14864A666305905D5D4B65C566C89094F196D2EF99F6CB6143BCBC322894C2C5C3D49594F2CCC516EBD2D808B5273D5C89D8F7D2EE69FA516566209E52D8DC62E7C89A6BB72B632437DE7423D3C744665695B611D2AD6B76136324F51F6EB92363A261287228FB6324448A5DAD2361223D33448D5DD22BABB304C2C35765ED1233C4A337EDADF64BC4A33E14B2E924C2A39643BAC974D22AC472925F02B8E102576DBFC2269D608AD761A247DAC8D92A5F623B9FEA58C9D1ECC3F61261821F4C062762612216BC792D25BF21C2A09757246142391B093924D1ABECA652C1415D65880716BF41C526F642D2BF8125686D7A5B61E14B6A54D46BD1ADCC720961C13D53AA591B614115A2446AEEC3011F03CD4454C340FDA672B511D262A42E4AC4A19977AD4934C9E2A2A3FEC4546722C8DB6C6E046385DADBC3447DD4617C774363E8C6D789F40157087735CB657C5D2AA3D396371D5DE922FB2DD6A5D3A58D36C45DC4E745C1CC495D887B54B1ADACB92737B28E01ACBB6668E4512460D3E38C36C3BB4548EAB5F499BB431F1C8F5313BCA700A572CD64BCC7C80B51CB34D69D629751BAC648F205999464C6791C50B928CFA553316D3A1D54C4B9850E38E6DB2AAC8DF8A6C3CB638E101CB8C4A56C4228F5F0C5456427A721E2E2570E93A3DDDA279D5B54A0A3F2D4F238DCE422C6AC53C26BC8A2339332666F9D01A9636B2A41DA6A9BA2D49AC2DD289F351D70A2C117D81A875C81D3A46A15E4A6C1CE87C632F4DA6DA4DE92D882DA999649036341BAA9AF36C56CC119CE7CBA4DCAE0A775B43355DB75D5D20B614176AE6E52D4CEA11BA471C8E2C02034D6D376D4CA00249396D92CDB6DAA8C89E84034D46E4764F02039236E4724E2003724724924EE2048DC6E34DBD514AB59D2C48038E47237239C4038DC71B6DBE2203723924924C9E148E48D971BD6E0A4A2D46F9036DB73095C5A04F4CC46371A9C22D8EEA7B52EE40266A214CAD3D9297A279C6DE2A8D58D15EEADE3BA856BB9685CC5169AD637E4CEA598D3399FE5D6DA6BDA835EE8C4E312999B57275E2D2CC8E366C8D72415155D5DE937B19528C5D523846A096E8A2F56B648DB670B0B3B72A923BF49C41BE252BC614B389C49732AD52584EA02630968E674B0E56489D91DB25718C6AA0EDDAD5AE56D4AA693E656E4D4E684A2426B48DAA3493E9D6745D6DD923AC4D1091E9C8E38ECD305E42BD2B96CD4E074DE4ACF64BAE310F526CD24472B5850DB66E2BDE49EE810D0C3A5A47759DCD41D4D5F03D0C2984587A76CCA40E159B54706C60028F05B1BF2CA2043633168E2D7A468D9E0D40037258ED922C44038DA8DB8E5C44057238DB8A4CC003723ADC6ABD9E8CB1D61E820471C71C6E39A40392492471BDE4047249248E4B80036E4524724D737ACA9E3D660371C8E48DBB3A046E489F8DC6BC2372472462B57CBB6DBE9B924D7309AA1AB5A2334E39EB6A1A0A6C71B95A6E7E842832271E84ACAE236BEA6E55AD82EEC1D12D0224508B995E4ECC25B9E0537DCB2E1ED0DEE139252A162F2AD7923D9AAFC999B612156F64E935559612F298D591E5EE1B8E9AEA5BC87018855F4AADDDA26F425B29CC1448BD6AA48AE816B60AB4ACC9080BCD559ABDAB2E13C6652B4E4DAE5D421AAE88166EB4FD6557281651A6EACDC9880D62574C36BEAC0D86B903962DC69D42D9B56A0B95B8CCCF4ECC0B8D559492450A0B7958AA91388A0359DAA9B4CDCE9CCA59BB62049238D38E3E640471B8D491BE040392DB24924700036DB6DB724DA639B25519A4048E56DB9245C4038DC6E47238C00372391B924DC4048E391C8DBDA5E8199E2742048E49238E4A80047238E471B75C0372396B93679A1B6A38E36C3D8248B22DA61EB4E1B9326E46C222A94E5B8EC9E61139ECC4522DC613A92B1C89FD873C38F1ADEE1652C8D0B0ED880EB0D934525E2C0B96A4626B7EAC0989D6F3524D7F06AA6D972E095636F58EB76A04622724563CE20B95C99B29BE00057248AD75CD7A0A36E22682037256E34DCE04046DB95C8DCD02048DC8DC723CC20391C71C724D4268D6C0DE28046D391C9247420492391D72469A136DB92368F6540AD114E5D1BD62094F24976C1B4E6BAC290AF82ADE36EC8DB702124A6BEDF54B3EBB4BA8DC72CD8237B6E9855ACA8D44DF6E36B2BF970086D29BF91476C8D25DC634E44A73E2056D6227CB24054AD27B23EC8D05B0CFD2435B660572B3AE799D698A6CE356596B6D0D3DE93A59498CB05DCD64918F08BC8DAD638D89F09F71BB938E151293B629638E0D39E8C2E03A52BB5DA8E3914568AAAF999AB1BA68910D78EBB5CAAA8B60AF6CAEBD1EABCF54BBCC8C8426F595DACC4D95865BB13ACA47ADD24F8EB5702B7AD6C455DD2E28CB683B1C4CAE48A15045B84ECE709D2E35B03D5DD9DBE49B5A7CE9291C8D5D55E73B3835BC6016CAAEEA55D68305DB146F4B5E9B921ED2AD257A4596A43E09DD5A073B30A598577534672FA5986E92BB11A32AFAC48E492362C598765C876A6A5D55F7B734A59068D74AD3AC159C688B96DC715B1248CD7CE6773B127B45BEEBD25D2E274F7125945A8986E4D23B0A346139544BEAEC334C03FC91559A1CE3B4EB512D2269D720B57225D2388892BAF61AAA46B37AFB142312C51A6EE594247A4925040D16EBCA95255022B2C36C5E3B0A1AD2E4FC91AB16129954ED8E35B0116647AC964D168C3EE54B36436E37238A7B1248D5B6A48DB54224F24492724BA40A9AF8D2064D21E84A9A4F040E8DEF4C313BF40DACD72344D86C1376B71BCDCE8A0B32379C71CD9688B10DA66C0475D65053CBCA0DA8A56595C8A80B89B94C8E47B0043194C6932D92ABB662BEEA0C72B919653EA80CBEAB1A3927EA138E47DC8D3CEA0D72D4EC2EBD9EAECA99BC941571C8EC82354A0E0E46AB95A5740DB43ADC8D3DD21B9238A68C2DA72E4D1E256C2EC4DB04B24530314BC6ABB129143FAC39D5F0254E27A09D646DDDAF19B099AA2A2DC5D0DC6A5BC81E3A169DDE96CA128A55B8845C0E258F6F19252D45A477AC865C3B4ACDF46DC54A20564DA186AB6C503D7A5DD1B5CC3A2D7763935D45B573AD0B524464C1D579B5D2448EB68652B5D42DB942901D65FC23AF17A572FD35E6EB718CA840B6BBB47085F4306F452C8DBBD63B42AF13B5C5F44B8A319BB1DD2A096B320C102E8EA4C88D4C102AD774CC29DBCC3CAE4F9C693C162B8DE6BBB1BD29E9DFEA0C362365A7637F563A1C7139EC861C3024F5D4234DB6341C76EB22D28D76521AF31CAC3972CF5152ED0A250A1B62764CA6094AE6E3762EA404A994EC68CD6185A6AA3C6203B236DC8DCEA40391C8E391CF02038DB72471CE00038DB6E3724DB34D359A396404925B1B52667AB46DB71BE5A66255F3165B96488A438EC19D69ADAF5E3D894BE84631FAA19EB5FA7D763E4C112670C15998DFEDA5447DFD16227A4DA32F52094BEE69B2F6E58A8CC86C406AC3922570649256FC5CCB3681DA482C925D7A54999AAED07CA83D9A4A450C3496A5DC6E3C0A20F6851D60153CAC9648E3448D4A63DEA3050ACFD5A7756E254883C1772C56CB0E583C2B2571DB927784BB61AE5D4A83D66715D07491B43B71C5D465B1B84579BB94759238D13D45DA3487C555A8ED56733F1FB5B4556DBF63B50B9A5471395BF14BD24F24492BB2360C4C9C980DB5CD3642CAEF1C40478D4A9B4E3C641656377B111C820BB93BA19FCD440A21376C925D0E9CD7950CE003D6D8C82ACE00028E3924713E020471B924924EA403B247648ECDBA59B1DD9D9C14B646493246EE1229CDBEB1BB34238E44EA7D159A7752BACA762DCA6D3122959AA4E2A4E5E9B68A7A37D55C31AB8CAB4A692F01BB8A8AFAA6934DED5DF49732086487B017648E3CE232AE6EA9490B8C647346EC440534759E392C440D2A4A52AD851465FB592D7089F24F6AB9B64685107F72B92B6A15184751A7238D4D22CA4729951C42ACF51A96B5163329CD222A7A124889BB634D4F0E628E4B940CFD232936F20F0E2AEF3B9A087A0A21BA6B2B240F0A237E59A3488F142B5CF59B6D8D27062B2B35122F55ACFA25A53234665BE36A450C26635DBB150A6E436E59744F0D3AF49952554A340EACE694352E42C7C92BAC4A8A3A8B1F256EBAC828A4B8EBB3CD5AAC8D1C96BC4129B56FCF45D265E844A56EB50C5458E51AE5263E614F1D87A91D62CFA1A417327D5246F387AAB462C957025A7CB47BE6090C657A6A8BF3F068063D52FA8DD8B54C7DEF58E0884B2A8D925ADB828A96974EAB2B91366CCAEDD92B6DAD533B9EAD25729A1D4926B5B55AA9024D1C96355C9C8BB72A49C55A83E7548C71ED570D2674C57E9D90611BB26572CC91815C8E457E8F7E30D3566578896AD770B32D573BA6B0BAFAA450652ECA5B14CB6EB6935D3B16A795C45A633596A5B2C92C481D5749B2EC3B12A796B724B625B4B3EDB72491BB34823D56A4723AF2936C5AAC95CD5745CF18B5908475319C923B2C4C523062D2DB244D85B0547F4A70559294CFB35D4AB7BF143E682A6C4A7B91594E6B895E2C71ACE42173DB6204382035F2D68A57CD42A9BB703F004DB1A647AE45421382C56B86A860159D36D48EBC040191B8EB75CD61FDC6DA3CC0036DCADD71CAE20352571B91B9440492C8DB91BE840491B71C8E4DD2C7B29ECD2A046DCB1C6A55E6048E576B91C96A0391B91B764AF40451A6A5A9BD9DE82A5915EE048EB8DC6E26880555BB1B8DC8460491C72C8D3E5A1B8ED71B703DC2BBD616365AACE5B91B8DC8EA8A8DC6E483499A5D8E5EC87D576A502BA975616D9EAFDE524CCAAB6CD2FB114F1AC531DE9BADA608612E7330BA29CA86693E62793DB35BB6D1C6790491B963E5B54494DD32EC52388CE34A781DAE3CC6948CAF8B75CDAF0D364DBAEC909F28978AAEA290F1C6EB8B57AC9153C6E23BBD8E88B9B73B325D931DCF48480C8A6BC0E396BC2E7346D6E26DFBF0854E56DD20F52A7A8EE734624D8ADCCE15B6EC827DD53545C6CC868A36EC7D4D6A595D40376DCC0E3C36784B5D5D4283D59D9A0E3D9F48DC8CDB562B8679835105D67D5E5B1B441508C3F1C924511D5A84521E89FAD769C8E42D2E98FF8E49256D1514C13EB75B50C512CA5343E36D0D6684D26505190F8E4AA48DB530CF75C8E38D1A54975DE3D444051898CE2D1C797D6A764E6C853A986DD563D1253E95594C54A98538A6D2A9216C5A3ED1EDB95C89CD6E85CE681A3E91CA16E78AF51886C38E8E499A18B6AE8E94899EF0BA1DDB64751D6A85BB2029F2A8EAFAE4A82ED0B9CE6AA56C39D893AE08F38B9E9CCE294794397D5268BB1839B6B27AA9196B8E50889E355A6D8E3285F60B60A9C970BAB9C74276CD2E383E9CEE0CB672411471494C53531D4BE5DDE64EC80373B64934446C199E522D168D52E0DDAA44604AE996592C333E442B95ADC2289A355CB0BDE215CA472EA2BD65474A5DDE643251FD6D2A15C01B7D5A948D5C8A0A62CAAE508E48114C269E96CDC30ACAA8B53E14B2852795176E1B32BCA2D6F50A2081BBAE10886C22EEDA47A63DBE9A49DA392E2337D2EAAE56541A7F9F6368850C3C7A1E62B677D68B75B9204D3DBE4A4A8F58DD039D35236DC5A088C95B9391CC8E8C8E5950AEDE86736D615B998DC2CACB5267F4815ED9457216AE76E6836B4D380E4CB5E854AE7AE6312E312AD5ADA26BCA5DBD02249DD91A6E4C840C86BA828B5C821D89D90C998E12137A38BCD20DAE6AC25637EA1B96391B903BC810D63EF543186A1AB6BD125DDBCE1261DCB32F1DA2BAB71E492A1C2E3A34BD26E81B76375AF25ACC1A23C96566C6681B4897A69D5D71F8A990A9E81BB0298CAE48081A8C46D473BE8E248E281B8D6CA825B2668B404D3305530E35DC45BED9636085E818FE4D5EB3A6126B4FA6E28E579C3D6D4715E6ED3ED45253390C7592592B69873C39D88EE26EB7543B5582CF6A7E6C4D6ED8DC809D42C4DDCF2E764772D8E26E578C4C2C31B499CDD228AF409A43F7CE1F7919E6212D2EC5564A276C394FB92C6ECE0C4A6D373A6EBD8E19AE3E5E08AE36272E459C721D32B45E1296D622A0794D915E142495C51216570E19F6B924861E92253173258A4D2EA3E64A178A2471B6C2B318E81C96392B6A0ECA1876D3648E5796156D98CE8DED3A80D9D22E4E15AA695A74B7AC155FD47D8EBEE8238A411B8F374E0CD1BC9545ED5ED035CAA84A125A2DDDF1B64C1B70B74355282E24EE391B6D5876248D4C2C4ABD6F44B9C2C9CC1B94AB448A29A8162AC46D5ED96E1595372319A9EA0E87A965762D6F36B68EA9AC0C2E849A965D2C0D92D99268E9C20B9256E1AE58A20576B6DC554D62D933EAAEC2048DA74EF1CCA2024EC7626E4B8A036A492372CEE40491A4DBB64D825C2E5A3EE2034D4B2C51A6820492491C71CA020395B8DC6E3CC40391B8DB91BDA26CB299B980048E39238DBB040491C9246DCC00036E48DC9245E00491B91B71CDA25C3EA22EE4048DC9248DCCA2048DCAE48DC700049238E47248EA0472491C964D69872A1AA648038E38DB6E35A40471C724924EC4046DB7237237AC0472472349BD498A36A2264004B5C6E48E4742038DC8E391CD2A049228D48DD622037239248DB);
INSERT INTO `zenoradio-v25`.`data_campaign_media_binary` (`id`, `binary`) VALUES (5, 0xD8A18211AA500036DC8E37245E2036E472489B7C4049236E3924A82046D38E471CD7256911ACE200371B71C924D0C036DA92B95CEAA028DD7628A3622046E38E4B23D168C52619ACA026D38AC96C5A8066E392495D9FE055527159635BC1369A55ED12D2A6AD6E8A53A356E06B5B2653A4594D01276455284B2264F71B53A859127276E4D2E3B572CB51E6BD1A48769E51A757278C24A551E6D922130CB59FC6689A516ABBD2E395B643ED87F8D37678739BC7ACA5EF26CC9D4736625C4B24E925D82A85F763D35994730AEAC7411172B926A0A7B1139328DDE8A3F0D524C6EFDAE56894094933D8A591E258C4C3D5428556EBC4A2CF6E2D895DB0A336E9930CEC5723D2DECA9B0FDAA3ABDE2A5282B88C76B15C7EC2365C904BBABAA2BA1599B72478C252C4F6A2F5DAA9A492A26523276709592162C25D534B1F60C6C1D6FA4E46D6E6E189A376B3E0D9A299D220E5429AEB961B056D43AB52F144FC74A20696B5C225B483A754937DADD2E19CB38353CAB4497BFB1B6447A03C91BB9BAC28B7585DC69DBEC624A580F52AD3219CAF42C124B97355B22ABE845E9ADE47586303039D6F48DDC6E5069A926961D99E5AC298CD4548E24D8ADD64A5FBA380D363D943DD08E6CA9BACC3B104532B2AD8ECCC131B78A249456E4ED598E4592035DA11E28369DC95C76064C32AEBC127BCD9E7BB1AA9EA8312FB834CDD69432E427A451D6C838A5DCCC6DDC0A2A416B8BA6BDB2BB4DDAA5482273135C7869EC230BDC4C5E6C4C202FD754A9ADA817B831268A7DAE59AE61A6F410ADB6F1AF5B0C338A38D3BF950A3A33D8D0C6B62E4AB1AD20B2BD3A49432827881F247D4EC92D3223AF9A93C76CEC5392AA5A55F91CC492340F8E5D4E7852E02512DC91A88F71B5189EB9D488D9C55EBA6ED4E746E575047636D2E5DD5289D6A8AABCC34AB95411357EBCAE4B1B8B957ED36E4914ADFB751A75B764690D56A7DA64A574E771C9258D3570A810DD5FCD0AB4C0263B25A99536CA3DD763923D5A4961B01A50AF66F4E56D55329D0F1EABAABA2CAA434CA5CE9A2896084B23D5BD5E46D5A8AE027C2448E5724AC419C772A34D3D620AB1B29C56EE2005ECC8A5F1CD6618BB208E60018DBADBB1BA42036DB72CADBDE0038E38E4B1BA820472392471CD8ECA3261BD200491B8DB6E4ECA0372371D6DD6DE9B6DB6FB69C6F2D36F94EC89BD6A04BA1DA5C4A74958DB8DBB221FB4D4B3832D443D76592230853E61775FBAA48D4A075A6425EAFA3EA91B9246087060CE378DDC0C83D11171DE3C16846E76C171ED31F8DA64960C6E83493164AC34581D9554A95632308FF92ACD3C685C4D106FBEDD172B5E48BC245372A643924C0424D1BADA27DC0019925EE4A5163208AE4CBCAB2D16CCCED12C541144DB645ADC561D6D9275ADBC920EB2D2980EECB20E8B68AB250D1E8DC659ACCE1593D96C9A2CF00A44A26EDA266E0CB1341169ED480BBEC8CB8E4D2DB93EA9BCEA0A0A49756A3E280AAF576475AAAE0D52232A3A2CE80BACCADD724D7184A61DB68005B5B91C89BCE60396389C6E3EC6039246D36DBC2E049649247E5D963C39E595DA2491D51104861D1570B9D36DD5248D41CF103BEC42816BA2FA8ECD966935B1CE246E422723CEBD643BF129D44A3EEA844DAD1BF9954478723F512A5D7228956D89A24C7257A3A32DE84C72A98593AE6A8A68D53D7A95349C42B8B4D26D5DF99C692568921038ED99C95693804106D3E5929367131BF5F6ECCB6D309CEBDD4EAB21E43AF0C56F26D13D3548C6B2C6DA0F353EAC8A64E41C455AC56DC7246F9D4F1A16992532C5763CE3687534CB96491B887554A49DB78C6C255A5C2B8953C78D532A9AD9255C6B74FAE6BC655CC8B1CAE38E3552A01D4B63B24ABC8878B89B8ABD530BA29CA550BB64772E6F3ABC83E24B2C43457EB44A715C731ABA8710E6E24F3D5AD9AEE09ABAB48E463BAA3552D3AE38073ADABC9CADC0CF8FC55A6F63B3250D5D5AB83EA0AA94D652B9191CCAB0DD56572327A55EB3A2BAD64D5552B39EC8D42C5D5A86CA281A96A39E46D349FA8EC1D6392348155C83EA375485555CBF55C71C6E2D5E85C1AC2A7C747C9B1436BA7460DC499671BA706103E975921A6C9129F96D925D1AB76A650B2C8A00C5FD913A882F5B76901299C42C44F95A7B2F022C889F242BDD16DB4AD585521BA5156BD175521B6D1123B9DA92256E3424972AB41DADB504B5CD16BCC6962AD012F1D8090F6ADC1B8EFADB4B4590114378A301C596164B5B6268ED16AE3B192B0E16D9CFA4449B100A93ED2C6E15BC0B8EC6EA4F0B36084A39A629AD2DBBBA69AB9614490B6C8E55A834E339246DC500077555238E2E2C24B636DC6B0D2A88DA5CCEE822E9C92392378C134E3556B73C8A256982D5FBD5926C6D15EB6A6D42184F6425B8668638159A359685B5B44F72359A2B541AF474E5967472C8DA2BCD3619D76435B42E30FAA6808B385D454D0A7E2B3C5C845B92969B346875392BB63D31EA56A8AB324A8A28AAF32590426943E2A6E5B23272A2BB8DC59227AA348AD64D4179D26C9B34257930D9CEDB2C2AB3B414695B342EA9E398F8DD8E3D773F162EADB2761CD79C5A596E46D5DE3672406D4114D5582841B1B10CABCE0C6546C6C758FDCF1DB1D6BBDE69C6B9284917844FAE2516B13BCC2B2E4E606C1D6A47A1CB6B91DDE30DC599CCB4516E376618CBB451E70D1996F5084A4B99A2B6293638D746657D3DDF6F3E5E6B346A1345229D5E3270BA412555E7E88E68D8CBFE366C7A933465EA0DD32FCB05CD885FBC0937694CEA7F8D5195794C8C40A90F1CB8DE4C83CA468CBDCDCB4F4E82D9344B6EAC057236F25281B753C7ADCC574DC6A36ACE483E8E4F1B04DDBA818293DCAC37D2AB0BB1BA162B94C67D8F0BAC37B2474B01052E55FAA65A05FD6973B7EB05AC4FF9BDA1245A6C5CB13B2B60FA0C6DB1B96348F5124BA9B96C047D4DB3DF3099E854B5A9652449EE2ED54AE2234ED222EE471BCC4ED43491CB0B63CD49D55B308EDE2E72B9034459FC36DE275C3049FE25ED36B19D7EDC36A947245D6D3616DB7109DC1ACAC75B1039DE26FA328C6C99DC2ABAD8A39089DC2957CB5B715D3E3557B48EBC223AC7D54BC9D22F7120CF77D9B62D6E9423BAAE9A1F29C6F2EE1D2E575F7839BA23E9BC291259B227EC15237279B02DAC07A46E6E742C609D1C96FD32385AFC39BA24519164F279BE2C90395E6C69BC26AC391D4E59D812C7B666361D36084EFC8EB220669D943D2ED2636BBAE3714510308AA963B2A53020A5BEAC963D4A2523F70A3A2388F7151FA54A406974DB9E5A8A29193A547ACEEC449191546EDD8566A1DBC5EC3BB1C22B96A9EA2DB7C40D31C56E1D971D3085AB2A1B6FAAEC98CDBEA83D962D2E253D596DA52B54186D5A8A65C88E1FB6AA634AD57222B160B5953DDABCB245664C2654C6CF4E2F142BAF075C745758417639E149D50C426ECA7D542DC6DD430469763D6249D595255A3F82D12295D6B45569C1E0D21A1A69F6167412CD61F79AA7B89685E5B294662A9466A5AE21514A8CBB96CAD903D50ADC8EDB0A47BD3AA4CE9F258C9CB6CA1F64EAEC8991C94AED9B0E3AB935F7361B32551646B4B94D2ED55E1F15D661231AE3754B904DED134D74CBAC3AB73406E24C0E568E5AD96F9D2F054F16CBE84293C8E6A91C2843E24D647A35F42823B8B4B1CBF42B850CAC765D2F054716CBF219B6844756ABF023B54CD927B612253ED8E468A61408BA6D9578DD2718BAD5AC0A386E4AE48E3C081D303B2F36BC08145132479395F41C95CAB82A5D2AC6B2DEBC341BAAC91E4C1C362E71BBDC6E55F03242C9549D46142D4C9EB1AB6D4293525F95F4546E3423CDB5D24DB237121DC5DE2A8FA9236B0B7234CA1DDC8E8D4272E65F85D427CA4972932B76431D3ADB922B941D4D413B765B8A3372341CB24D2A755AD69BE81DA5DA89C2CBCC0E75AAEAF42C240BB2671CB23CA0029137246E4D7A29A8C94D600691B493BACE240B923723863C94036F4A798EC642046DB8EBB23D56EFB94D9B40046DB71B725DA4036DB6D36E4F0A0C924722924B4E037246DB4DBD6B6BC221B8EC026EB95D9BB7AE0529A68AF8A8300B6E383471C7CC0471C8D26E3D5B3E4AE22C2204B1A52469BC6A038EDB1B6E58101492335B91C64605D6FBAEADAD475C329E3BFA5B6DB6DCE9B6041F91B7648E4AFE437236DC97AD2A407736A36A3D62AA4666A5C40C6E3AE3474D4225B03761B5BCF224B12B2B4B75DE4291B968753D6A9BC66945F45F7156E856A80C273952F19299A8354AC6FE624E6A33B0C38B77BD66DB3ADE354A2AED1B2711FB8A3410DE147ADD421BA9B7E26D46CA229E18D9549D3348A5F93ECC25BF3AD02DF75C3EF0A02CDBE75A9242C76591078C9655E9513CDD42F9AE7C4812B3AE50B45647F4B5A0ACB3AB4834C25CD915899830C772456B66BD52AA3E7C387AA3AA718BE658BAD2D4512A91D8B2C4700CDD92B8D0BC6876EB7A3D52AA46B4291A8C9466A2BF493888934660F9F974F74E38E48DAE2D0D724924898D52AA4EEC49D50392491C6D8512D592C724960A32BE6B39257DB55AE891D6E3924D56BA52EC457AAAAE51CC965598A572BA3352B596D3485AE4B2BB52CA6D21AB925D5299DA9C4B50926D530F52CB54A34DB52DE25B72797263056795AEACB25B24480D42BA51D045B04F834AE46E2B6A78D9475D91BB2C7363B6EC765B6C8B50491CB25D4638B66025B4324C96743DC5AA36AD1605E2EB0C3CD65188866AD44BB26A6E031D6E1819E805AE4BCF792088AB0A352D6F5FF05F085342273473CD8822613CBACECD927C21B589EC2DFDC523812BCC3295B1A393E66A226EA3F447168823D20594761D964B3DACB6CE1A72D4E3839C0E2D9D10BE74A54A339DB59B3647AA1D61BD12C6AD9A6BB622AF0A1E54F72B51B6CA2ACD3E95E13C501723F49E48586C1C5DA39D71DDCABC42A6AC48218A455E1625CC1AEE44E46ADE2C1227B2EDAD9D660CDA371B76ADC6CBC5612CC0062DD91C75CEC0039238DB724AA20471C6E3724D40046E38DB4E4DB72B1596EEE405765B6C91B71C146E271287B5345BA95ACF9347706C8CC758892D9676B5E3381AE373B8DB9236402004289D92D8C018ADC8DA8A4DE2296D389BB7FD1E6BBEA2AEE2348C24E59649400270B77C9D8D4E1031DF2F48C51441B9CC93A60D26BAA58DA58C4FABF2E26C850A4557F9125089EC4D77D91A710F0C4E775B4B550D2B49258E3A2848D358EB91A54A40B2C77372AA6E60D54B248E2574483EB71D915D2B67A98F3572312354EBB24AB424607332DD557E262DE624B5157A34A9C7D3C2BD33573D53B57E366A21955AD5765CAEA22B76457A3C1D485BAB35764E56BA11ED6D4345AE17457A838E475323D57A70CE771AA975548875C8FC4895708195D925698D4725BA0F4ABC64D86AE54D9554B0F1C8EC91AAB2AA19BB1D723570B367A8EB92BD4B23D55B9574AA43B9248E4AB2746C69246DCAB03AAE06F3C34AB03F1D00A4757D4AE361D705784750C938B8C556364DB27D35EA924AE62A91F1CAD24D7936C86F4D4EA45A2A859A9C6E49244B95BA60E6EAE361759438E367D56505BE7ACAB75575FD4E864E5A85D288474733AF3BB89469256AF855DA82939E315D95DC6B5C7512AA8D4E774A5985DA973239146ED5D665969762400B90B7B239148DB5DC332718FC134D42574A1E0B928348F734724B9284A937DBD135D04972404A79EB8C8B8DD898164D26693AD31BB24D5E756AC9FC6A835629238C2B8E3F1557658E4BA841472F24AEBD16DAB7571BAC3B4C3CE3AA5BAC1BACB2B44E0BE81E9E58593A56161B53370B55FD226939E6EBEC1CCE0973AD26500E05F8DC91DC8C08892A6D3A8E0A0DCEA40CBB6D928B3A1A3BC80DAF365474AF021665E72E2D378C1372E7946DCA1E836DB6FA6E3D82DCCDD6950017D528DAB23BC60C71B91CB08D2414EA34B4C9C7DC838DB92749DD7ECA354DB66A32E5A8EAA60A0A33B0D6F4613CE24DA25912AE562A4466562EF7CD3AB44F15BC348B0527BEB22506691E3964912922721E2763CDA514537D4B1CB1BD42C45AD2951A321DC71B59F5305022CB5C92355E397D39238ED55053A45925724D32C4C7522A96548866DD913AD62B825E8A96AB0C2A9604ABEE3B2826AE58500BED1EDA37A29B4E34B2B88A42B58E2656F91903159625B149646505B61BEEAB73AD1D1729CB598590133A56E48D4B2E2052C924CE2B50162CDED59665B20DB000E57C4D22AB3F2215BC235155057A35D0359A44E20D55BA27B949B22955B42C996B23819D45F7522D15BE5993DC9A8EA5B8922E7522ADB628CB2BC5645245A8AC812EDD91CD4DB95AD4B5B674483587BDAB5A5D6E334C3DE5B25BAF2848B05B5266564AD163BD51D7E2D035BC443CE38D48D5B26359D75D7585B8415DBAAAA3A5B85C9EB89B8DCD4DB966D04B5A4357B1CA6EBB5E6B6EB82B6EDB3A308DF58F22EB3C3616C0B4746D51896A91259E3E38B7CCB5F594748E451B47CAF67455E8A484F66CA592491B881D5596635525546DAA492C710A9C40B03D1E65353442F1C6EC898A5434CCC82781AD45A86B98AA3421D8FC5E24A9EC38F1FD7D4C0ECC48B65D2664BEB25051C9258D3D5D873FE1A9D43D522B75A03A0A3EAEBD64614EF24555B95A87D5385A8A4B164F8DB70D30CE153A650A6BFB445B78855BC8AF22B5088181A79B53A59078D2DD09919DBB0F52424948499246EC16BAE850B5B57336BE68899AC8A74D553089C17625AE3DC72ECA45D62E839338DEC0AAAA968C3B1B71FF0E8498D341920B487ABDE1EB517DD2EF4A4CDF08598D442CAE95F88C5D3BCCAA976E898FA3676D8ACE8CAD2944B9DDC32DCE82B914697726433E252C8B4DD92E90298A641D1D0DD38D4C63DABBB06D0D4D97C7268DAE65FA365251D80E4C76B18B95D8789C95B67C4B5832B4651ED4B6DD41D852E908E8932274B592A92C98793D9BAD892E84CAE8A548693080E96AA5540D49C7BE709E147C36B562847E6A7B76294C4879AE9491CAE342AE8C87B1C8E321CD261C562C29AA5FDDC6D225E9CA3591E6D216CEAA2DAA76991BBED0746A57237D4D45F9BE6C05366C59A6C0AEE5126DA9C8D81FA5348C72B71A5DB53C53AD44D0DDAD4E76B39C953C5C91C95071953E4BB2D89AB8653E4D8D3D54C2353E3CA64867356D4AA5435C95366C95C91B64755642963AEB420A90676E3763950AB64796495D750D3A77B6E11570427D75648DCAE8422ACF1C914BC62A2037F7D22C44222D2493BFED1AADBEDA1C020D6406A345DC640D4E5764712C60057AC5A67A5C6E036638EDAEBD1E2A52E1CCCC048E26CCB6B648027949994666CC038E46D54DCD2A0292571D6D4D4E75BAED0C680B71B724BAD61E1349A71BA7075E238EB5194BD59CC4B2368AF1DD4E88BE709538ACAA37435CC54CC47258D25DBAAAA78ADB2143BAD6AF86D55B0D5D52D6CAE82594A1CE48EB6A057C86C5D6AB6F859488EE46E4B1A59669968F2491FD52D9B2A91B3C83B3187BB4B5BE6BA58AE66D35BA5F51E38749C5D69CB2369AE6AD56FA2DB19B7C6D8EBAE5706B7282925725888B7285A7C72491A5D47A90796671AD4EFA22751B52850C655C95C5B86DCEDE2B91AB36638EA1EBCA2B3C28E8B90BD83D3B0A26A8359444B24703C24B14371A32A4D9AB142A86551B507B2C3ACEB92C880D3AEA25E4B5B62DEE675C554B4A1833C95C89AA620C6514DBBA5E440B2DC65A964D75F93AA24E2A0888AB1CB1B9A20195B6E391CA400471C8DB724EE40371B6E4924D8E18B6E1A860038DC92471BC200392491C6E46640491C8DB9245C204724923923D3DD826A2AC040471C71C71C7440491C8DC71D89C1B8DB524B385541E8D8434D21D5214BB6DB53A349234C635553A2F92A2C782551E7CADA83C89D9DA94B4A83D857D4616D3B4A97CA78533DAB1E952BA6D0E5ECAA9147F08D1EEAD48F6843A1FB0810D52344BA8A8B4B78A58DB47A8708E47AED916B876777932DCD23CAE7E40633D563D49D742B43CA85B063D98BD38AC49F1C7318E9D0A52A7470DCD8CA84292AD950E1D9A8BB56119422D765AE3C22EEA5395C62471C56A2DBD4718A8DB883D93C31A723DB2ABD19E2ECA29F8AF14D8A7AC2D86BA2711DE4C245E12F3A94B282CB0CAE4904DAABC5CEDDE282DF1B8E36DD9742496B62456B74E246DA6A3F995122BAE89DA732D5DD6A9A53788227D436C8ACBA8215257236F0E0C2F4EC3926D55F65BAF4909610D467BC2E43E7AE3D54B1B41754ABE6AD92C44356C9A7AC9E3448AB2A70B552C75CD4E9ACB2835788B19491D96D598B422CB1C6E45BA8B6AC5D1AA25BC8B78BE8D532D52A9CAA425D4C38DB6BB6DBB96C495B69BE94B8AA292EA9803CB70A4AB4F1CA50D56C93A644BB69F5EB9655B2652A32CF47BB6C6547C6D907A795C9283F7555107AD56D7B7204C9A6AC0C996D71CB06AE5FA9E95DCD49C4172EC724CDC6F67A64F8A4D52B7C364369EC48E48DC93067081F0775C5AB69C82B3091B75C69882871E1F4F9D4E993F68369C8473A72C46D92EBFBA4B5D6886B0B97DB76376CD54948D0573125D3E2932F02D6E74F6C4D23667E42B9C5D8DA94EE221005D3FF2BEE62C6DB24253ED1E7BB6E1AE441F8E3B6D692E0408AFD694D2CE200D69A48C92CE0403F6DD13601D129DC29A2F0002336935BADEE8038D2924924ECE0392C91A722E08036EC91B924D0E5DC7223E6A036D251B7ABECA044DCAEB5226B20476B91B733C740045F99552BD22774626369A0C8CB50F92369E1C91C71A6BAB960A6EBCDCEA07BA2372EB22F51D3EA4D2670C1AB36976DC92471E64B6B68276D676647B29A22C0678776EB7546E3D4283DEA28694842B98DD923D14858942FA6E4D164CC2E64C2FF92A5ADEF926AC8D6673AE2FB6B258515AECF54D109DB138047247283FE3641575D8C223B64BE4ADBD8A399DCE4E6213CB6ACB4ABEE00B4D38E5AF2CA4026E572389DEA405ADC8D3923D9135A21D3DE6036E492491DB2802B8C6A38E36CE037247259B3B0E0D8DC51164ADA21A461FA61F1B753730AE46247C026C9C6ACA4634B1E94CE56E227A4A19256FCD72D71EED0EEA48EA50BA7CB6144D0EE8AC74DF085A56C59BF1CE968B2A12DCD7DD562B3D2C05DCA4B2B4C09EB6147D85C89A3CC5A8D76E491D8E3676A073A752B25D4EBA32EC8D1CC495412A95A6D4B4B2371448F7C898AA37739236F48B2D71A4966D4ECB36AC8DF0B2762AD17CD7169352C92B8D87107C9D2D2CB5DE38543C4B10AADD4EAB32650736AC6E48DB6AF73A90D5AB2C6DB73493453E266EBE709675B7100F9D4AB9BAA008C257C6FF6CC587526B1EE70D516E4AC2B1B69BEE471A52D23665152D4E984AA00E14A3EE575C913E32755439648D9E2A95B2451946762C62EC9DEDD2CD52575668173C569026ECBA0736748E32C579B6AC4E2BC8FAA8BE6C609E3B1DB23D4256DA981E6C5CA93267374E8A63923ADB6C277245E6C524AE5E9238892B658DDD32294E5C27363C91C6E271F88C3B7CC7328D27302181FE2D7237123751C6DA8FAD2A4AD24CAE0C25ADBF24352E4E357DC922765E521B45D2EF7537162C8DB9226C5D2E28CF203E3616C85D9BB35E541E61151196EE501AB2D6D3114D2C1297E96EF11D2249CF2C2E2A231258EBD23E0812D21156752D4C13D2296E641C0A135A4737D2DD719328F3AEEC224418CDF2D70C1E31B99077AD342A9AB8DD93C5B4256D095C6E5DAA8CAD07260C1B7A231A068C0824726BEC78DD8A1154644F66C6102C6B3A25914DC2AB3E8BD7362B7A0CAB919C2C1FD4BB3302F98A1C3949E22ADC28258256DD716DB2C94DA2C9B218385D8A4A2A722D633C5B91D60C2B85AD308EC608147441A684DDAEB9D91A3E421CE64525523D241A7D9B14753750128E6556121BD61595D8C499FDAACADD4AA8742A944B23924DB410873AAB7528CA1D7625D891E6342B6DF4D27ABD9A9EC192B5CA2279B37315564E1177C46D921AAA1C71D2392B3E6A2FB5A91A71CD7ACBAD99874A188A39AD6CCAC20D922431AC690A12B14B7309AC620D921953AE6D724A266B3AE0035744AD71CE820269A925924D000371B8E371BB24058E371C91CDA69A3E598D20036DC92B91BD24038DC6DC9239A0048DB9246E3D240471B91C724D9A4ABE8E3A640471C7246E4AA2039249246DCD840392391B723824049238DB923DA25A3DDB3CE20391B723923828039239247245240392391B724BE20391C924723DA27C3611AD84039248DC8E36A4038DB9248DB6440491C91C724660048DB724924D928C2E1619640491B8DC924DE20491B8DC924C00049246DC6E4CE2046DC91B924D868DAD9A2680039244DC923764046DC8E48DCCA0049248E49239E00471C8E38DCDAE5C3E9E2800046E48E4924D200472492491CE0003924923923F0A049236E3964DAA6BBEA2B542039246E4724B020472491B91CEE0048E48E3924824049246E4924DAA7E3E9E2A8A036E492471CDEA048E46E491B8E0048DB7247245C4037246E48E3DAA8B369EB6C2049246E491CC64049248DC9237E00492492492492203724724924DA68D3E9EBB2A036E391C723BE4049246E49249A2047248E391CD220492391C8DCD9A6B3A9A3EA8047248E48DCE2C04724723924E040371B924724506036E39246E3D9A3C365A3DA0038E48E46DC644039247248E4804039246E371C880046E46E48E4DA24BADDEBCE2037247248DB820039247249245C0046E47246DC540048E3924923DA26A364E25E80371C8DC6E462604924723723AA0039249249247A6048DC724924D8E8CB6162CA00392371C91D9CA03ADB7237247600372471B8E4D20049246DC724DA27C4E5A2D84038E471C924AE40491C91B8DCE42049248DC924AC4039248DC8DBDAA5DBAA1B84803923724724D6A038E491B723500048E49239246A00392491C924DA67C425EAA0A036E491B92350004924924924DC4046E392491BE84049248DC724DAE8CB6D63B840492492391B9E0048E48E491CEE2038E491B724544048E471C91CDB26BB71ABB22038DC7249247A00472391C6E4A4C048E471C9247C4048DB924924D7DC6221E162C037248E36DCAC8046E472371BF0E0392392472370404ADB4DC924DA2BBA16197220492492371C9E403ADC6DB8DCCEA0372492371C542036E491B71AD5A06DB2449EA037236D26E66DE346DA7AD842640476ED6DB7246000162987B2A4D8A25B2F90CC60172CD75775AE0036DA44945379C8B924B6DCC8500EA3DC91B6E4D75F63F74196A92B8BBA3688994CD8E4BAE400E7ECA6EC6FE9585F8D052DAE3ADBD4DD6C7DC254CD227A963B22AAC9356F16B793A888129EEAE72BA6C8B04F96C963D223C4F1CBA6A8C6013ADB6C56C7B9137DB4DDACC4BAD96BA91255656924285D64D1ABD4315B5883B7AD6C0175B0A3C736AD0065B323549FB5B2D4B2E24B1DFA4689D1ABDBE522B4C18D22CFB6B3BAA1D44F95D75CBEC0D2C816DFA4C4A136E9689CA5D49F4C28DCCB41EBDA293694AAC16FEEB5D6DA9684B584963B245640C5198EC919D8DF7A55DDAA40B51ECD38CEE02073197751E0BCA036F473AAF2EC807E5B8AA76BDAA9DC9D6B57C0C7237249825CE0BB6BC8BB5572C1481752D46A5CC14D1C4ABB1DDAADD4999BACA119A5D44526EAE1306D1DCB3AA322CD234C371762A25398966E51DB71CC95A498C257CA57A33591A5545CED976D64A30C5C9551DD7CE3372C4C6727DC6E9B596BEA842E529244E47E224732714C1CE4C2F6E38DC69C7CC1F2D471C724DB9D4A9A1ADE008B1C75456BDEE12AB37A9722F0C0D4B45CB31E6EE1E7222F5DFED45855BE9855653249535F6350A3B886BB136C5122929791B9A451E22273F05924D65C1577A09FA3324F79C7AD51C29621C945A551C2B2FA65CF32518259D54F364AD5DE34F3A8518252D4B6EEF39FA7B50476D7245145A43B91CB6451E222D44D6C26D45D652B3851C1E3B353192851022023CC2BF9A12292F0EECEE3F1E3CEC66E3323D3DE7BB2795181F4AB8D24BA51033207763B2BF103460E962AF4A3422668B63F96D55F3AEAB3530324DAADC634EA22AAD03156E560A08838ADA6DCB220B7AC8AB91BD6E05226E3EE40C8E675C6DBE800372C9636E49A4038DC9248E4E04036E492471BDAF29C6A2C682046DA72DDBF7DC446DB6D1684516CC6DBEE669C52027A99EDB714DC31FD75C490C53686AFEA9467242CA07CC69C75062D065E3B5A73AC44DC8DB93ADB2EFCF14BDF878FD7A1250486A6406751E813D4E752AC65DF10D88463A160F9FDDA71FCF10A8708572A75312CC928313C12D2DF7CC5B9DB9158D874A4A7D15259DED5653BB26AE04454A1015DB598C3BED9214DBB974956D21E389E5B26FA23857192D5293DE4EBB3677ECC912923BCCA396471B267C6C82564B1CB005FA68E248EBAA3D4AA4E8DF95F05361751A7A4BA8758D11DBAA5BB45D95C4866E45F23AF2571036AD32D6DD1B2BD4398F2AA2A1BBCA217CEBE5B09BD031595B2BE73BF02D24FABA796D2727C1D72BF626341AEBA75BEC272F280DB15C0C1BFA2729095C2E13EF656B849D1EDC3A0E3C0C11966AB52D0BAC137E4A9E8DAB4A0B215D637ECB4A136C8334716D1F4A25D625AC1C8DB61E92BB5009BD4ACA3EB59A1D66F2B16BC57615AA784D297D22F9A5DEBAB01D3737B010855236AAB7EA6D253020DA48F5A8455441CEC75DA28D22C73AE995542A3EC957A5555A2B6B9A69B225563A67C74E7635544B6A4E6D5A2D26096624BA7A418D2F4C87D5504A112D1553653E4332AED3CD7532534E15E391DD4595F7184A385ECA242CB2AA3A296111D2F79A3E28A625D4AA8A325789227571DD2DC87611B536538220EDB12A50676E58947ABA548592B5049A45544372344576ED16CCC255AA6E4BD23602D75A8A3339C7013EFA703A85C923634A9A12E5EB19A65D16CDC615A558206E3ADB8DC55E1B325723B5755A1892B8A4A6C55E229134A6918D5176DF5CCA9A8252DF6A89057299EF487D892530885E2566B4BA74783AC367942D5D64E798CA728986BCAAEA25529267D71C95B5547967C72BF61A784A3D510E5D6D5D556BDC355A53AE66AAAB055A79D13E646E3A7A6BB9D3D389A55A4872274E4E2D5955FB60455247C0363A796A9477AC36A1924A9274F19894724A94446F42CAF9DD5575E3DCBA9A5A825E6A56A55C4483B92352655E4C7148DAC22574748D75112EBD55764FDC9AA87FB9A9634C3AB2759DB49AB75BC849AED51F51D5A83C21569CD2BD35684F9A2DA40D85C44BAF4C420C8DBB358E3DE0068A465B724B220471C91C71CD8229B505AE06038DB924AE3EA4036DB92B91CE22038E46E471CC04036E472371CD7A9F4A99AAA003AE46DCADB5EA03524B636E35A20471C9258E3A84048DC91B71CD5B3A359AAD8A036E37259245BE1B8E391BE9455A8B8E38A39D25EA4B76745B7A6D632C5251BA4A6891DB192E456C4D0E78DBD1BDF26216C862ABB77A3978F1FC365D671D5659B6547279D2D7654CF2A4C8A96A37A58A7C16546D4558EC9D51DA9BB03D66ED4E5D4D1495894960AF586C690FF69C687A0C65A6AA7B757E4A84AF06A4424D4EB5A116CE4E7D52450E6C698A42E2DB454E8B4884CB475B501F0A97AEBD5840ED3AB3C2DAB9D4728A6F1888D536818ED89C697534518ADCDD2C853A47A29B39B23D56A1DDAF055A773636E478C55281E738E5AE35529876491D91CAB07A0AE563B23D5E715DBA0AB0824C78A2B255568C6C7523B23AB07AADB19D72557E2F553E4BC8FD5213E2712AD26C92323371C57A3CC8B7657855723ABAC490B67AB44C735493155D49C57669AAB0557A38D34BAA9C33516A07D6D530526ECEE42CDA72524ECEDA6CED49A6FED9B53C2C7C572641D518407655746E25166B8E3D1B48FA1C3411C1AA2ADD4D97EB5D351A42B63B146C69F871B639535059DC5D32BCD987D9BC736E5B1B8B9D55976B653E789A724B2367A99A857167991D299A7CC626E9F0C970A6962908E55D5597DF29397E74B3A4E1126E3C846DD34953997C742F9551BC1E1C92B62E5C8D3D69C64F605E1EB44BB95BB2AE1ECA7D5C96AD1954B85A176374895AACF0BD09EF2D65E65B58495AAF7248E5753952C4B1CB62432DF4AB6EDAC91DCE12C58E4698E63D65E6DBA0397C7A72DCC94B8E38BA92E88C77999C8B4E1A6EE659BABB88C75D823D5DB7DF2829D0C4AD31748ECEB0C2B1A6FA72351AC46DCA2B913532CC8EB0EC91DD5DB76AE1155CAD51C7446E3AB495B5B81675BAD0AC6F28DA1DE5B68C9AB9411C6D51A86B553B34954E575C850B4A908DCF649605D068D1E51E91EB90686876F271DD51976F593BD264A681E48ABC148276465F36161665B63B2106D6363C5CCAB4A88D59A5EED9461C58ADD4DAA9B63E34F849A2A76C703BAE365A9DBCCC5D75DB1A02CD4DA7EB24A92C3F9BE95E753AEC480ADF6491BB523BE2C96A45B5C6176E32ECAEBD8DF4BEA6B9E20D4DB45C924E8000AD36DCAD3F00048E29AC924EE00491B6CB71CD8AA696DCA72C03724B76B72C3E0B51244A00F57AD39CD49CB6C6A4924D0BBB265D6DB5BEA1A8A23E616D0196CEC293723724C25EE43511A444BBD92C75B2260933DD365AAEA9256C74B6CA9B04F59230E4BD9FB985EA799D55667236129A78CCC6C6BD46F8CF643592CD9125C4A9B6A8BBB3AB1A07C7148D8EB8F2AC5D90C21247248DAD4AFA3B65A73882F1E4C6CA370ABB6EB73CAE279CA8D22D2431B83484B29902E6ED4EAE3A6E0C869451B95D9E68AA9B8881DC75C7E8737144F6AFC94C811EB923766D4F0A336C96F8FCB246974DC6265B6858E5D3D9F480A8B87A961EA46B915FA7C9AD4B0B32F08854723D492B91E7108752C613CE3E308C8E2EE46C2E0A94793ADDF2BD52AA2F302E1AC3454E6689D654A67534571A165494D32AD10EB5CCB4EDCB6C918D56983EEC8C88CB5DBB64B2467E6A42F13A4AA656AD8D42978A3C94BC36C6DC497D4E5955EC9C6E88B6ABAC899C888832AB63D25C9268AC28A5B5565A6596A79B9E0D4A264E2D165663CEA9199395B470961725ADAC72465D0B31AEAC92534CBEEA8B5D326557210CAE54B0C22732366E1AEDBE19277DE01AB5E579D49D20231167E4924D2DC736AACD441C8692D5ADBECC1DB5B6C34ABEC4158AB7DBACCDCA0A56A275B61D5195A2A63E6809C0E6E27236AA0F7236E2915DAA0C72350CA75DAE134DC92BCA3D25B9CB2E29F40720C35BD2FA74146DC19691DF101B8A85DCA6550C165105A649FD39A6DA69B536358DC11C91D58C2DAE242BB1BAD22D95C48692A55223F5C458D2DD35C866A5253E22B248D849E53820CE5960B2B5523377D8823645163A5EC80A7A5D2A0CF69139FA3726D5450DE5144CD2CC19AE49D244AF5A41EACE70556F6612B24D31CBFF88B9943DB7006AB9599E3D6DA9C4F2CE5A4C69A784AEA9902EC51093AF5D399A7B8C299C2476D19D390E523B31F76C7599942967ABADAD3E5228235FEC74BD41997E51AE584845DB647AD57462B664EDAC0996498A4925907F167696272C411D35AC72562E943C76492C6109AE539A4B6C407F0E54B5DB630069F634D259244C8D2DCCFAC99ECC3CD64924085EF23BB23B1B68FF1E3561489A33E5143D6E4B626C5D3D8AFACDA5545C92C92268653A3B9E4AD36225745BB5CB644589F64A5A49AECE0D397D76563B0C47AF39B5881A7431A9457EF21A905A0E4765B635524242391CF64D3D6BFED14AB2434C475C9A5AF04A6D9EA46E3AFA3C7247EB8935941CAC36310E5D396CFE563B3E2D8C28E62D15B22C9ECA8D11CB52334EF8DD94BB7025791BE371BD5166735D55DC2E891AABE885D45B72B91DDEC5F67368895D8A6670936D26D0F1CD59846F60B654639E2AAA6C6C3476EE09DCAE267C50B9A54CCDC6946C8D91EB8D5D51D4EEE4B698463655291446526EC87B267126927AF6372D46669E8A71749CB1ED4E25D66CA69A699E185CDA36B673916E9228A692C73247249226BABC6DF4AD69DD5685D66D869EAB95D4C6B0D6BEA3924B1A4577C8B2B5F32E9A16BCC372A9288EAD52B6566606B2C5ADB497763D74A378EAEA24F9A8B07F67D3D64D9E9AAD8A65B1AD4ED6C71A26D2AD95C289EEF6F689D65B1A608DB08756F5347336D6A34058F48EDD4AD64E8E1DB0A0D2285A99C6B26F46591D35BDB094EA389D594D90636EA3A0B39D4ED4624E06D27D7548A23DBC4E7BAA4B6DE40D7452F197AA9146D66B6CAEA3B5DD4AD3E6119D4E46B21480F29CEC33F2CB5B649D0A31FA3B5D93369E336C74EC4EBD4AB3DDD606963D6D28EF86DCD63391ACC452F6722C5558FD693C903B49D8D66FBD42B3CE160C70354905DC8EB652547197174E4C164D8A2A2C39E5F444523B53497D42B3DA0625E8272AEAE47F2C6C5433A6EC7236922D5418B4A6BCEC449248C34BCD3AA355D6868A229738E4903D0C2A9D3D1C91BD2C23113B5BAE5CCC1BADA6215E4D4A90361325EE14D8E8E0C53BEE13D9AF8CCCED4A1316CAA635CCEA0DA5D319ADAD62F1310717680CAB579A51474A0857355E8EDE2204A16059B1D9E80D6EAD156A2D6B18225208AE0190A791F669CA0599289485E8CA02D1D95A362C020291B762D1BD6AE7B2DEAC2A0472A95A91CDA2049529148E3D2E059656DC6DB74A044DB91D91DD6E4D325E9B680451B6DC89BBA0049238DC964CC0036DB7238DCD000492371C8E4DA24B365A3E84039246DC9236E0038E46E3923AC2038E39237239A40471C92371CDA27A3659B74604723924723D8003923723924BC20391C924724E620391C6DC8DCD9E7B3696270404724723924BE20371C724923D00038DC92491C682048DB6E4924D8E8D29D22AA2036DB923924504046DC9249245C8036E46DB724A4A04A9B8E46DBD52BDB5E2B704049248DB6DBC8A0471C6EC8DD5EC03AEC4D4CDB64A046B36DC90CD4EDFBE11AAEC04CE36DC89DB800571A6DC924D06036E48DB723E42039248E3924D599ABDD198CC0491C6D36DBE40047246E3924A200492391B6E45AC0491C91B914D232BA1D6CAB40572DB126915F20B71D9234D151C3392C92364558A367217E4863D2AE7AA7925D0323D4C5E7BA5B6630B3B1D7A25B245310F5B5275BE5558B7CD1D5D3E673AB5159C5CE6A60FB5259C849D288AEAC5768C7DC6D33F1576717A5AD1667D3DF753292AD2989258DC85A550886A49DB4E15749F36BD5451AAB66F33DD9D702D49A7BB249A8C6878F8FD858A4240C36BA694BAE05512191B923CEC3C093B7A742DAABDB6222AF22E73CDD3705B2A44D23A2BAE258E2A97470A0E56882E4FEC9C54AD8A7A31E6AD2A1DA2382284D92A3D72B6A3A1BC76546EBBEB2BA50C291143DE862D7E78AD5935CC247BBAEA4E5CE21A2DC5ED904DA21192B6AB92BB3A3B8E46D2717D2248BA99CD703D53C4DA9138C60A91C8DB6E0B42068E5C3BC58D221A6E4B7DCE1D1706BF69955222402DBC6AD5921F95A30C4D5BCC25D2A658EA96361372C91A29FD1B283AAE863818D2DADCADD7121B34B72F4EDC9E2694A326425592258DB07BAE4D1F0ABA9B259E2393A4535D559433D2B8A00A45BC3C76391B6FA59C5DADBC9BA97D3B3C99EDB5BE5837F8DEB905D0A0126B9491C5B49B47891B7645D29D70AE5D75ED432E19E9C5D88B91B27976B5BC8BD24501EDD5BC646DC72C1D25BE5A95E0DD578D435D12AAC5B88C99BCE46D05908092596BD9BB18BA0B272472C594A011AB5D8EDD3F5E0EB9AAF47141E7238DEAD45D5D6B50917AB440A609A372C55C2E5C942FD30D3B3E8A34B5345C9125D48E2A3252A39EE98E9A165D34475D75CEF43F30299C397D36FC827829D455659F548DDE9444125B146E0E6844492EDCB32E4C39A85B15963D619DBC163E9228CCD75C924E4211810D6586CEEA2576D819A64F00053B07CF054D85A8329E3E00054DC962335D620552386CB5D7E0038DC72B923A66038DC92391BDA9A7AA4E1DC4046DCB1B762C64046EC8E491A9420471D6DD9246CC04924764B2DDAE2AC1A6A51A936E36DB4B850B149D352C6E46A25876303C2D4B4057CAB4AD723D4D9AB9EA8F023086C89AB44A4A306E2B0D4DBD2A3B52C777AA25FE9B29F8E6922D2A7A4DF105149461472992C5A86DA915E975CBAA85533499E6B74A4BB3B761614D3DE851A616A22499CB65CFBCC41228D21DD14C6217914A556A5C020B866AE48E3D45A9C2E21BE003B256DD89BE860391C924923EE0036E48EC9646400491B6E371CD85E6A21F2C64046DB91B924C44047236DC6DBCA4039248E38DCA8003924AE4964D769BB6113E8A049236DB49B89C03925BB7B6351C4B6DA49769C54C94BCB7256DCD329A2DD23642172A47A0C3BB2C2CAD2171A8DF0031C7491B0C18CE8DB2490A07ED2ADC1A26454E5347FCCC24552C6291DB63500A6A5F4EBB7475057647A6C7A4749D2F298AEA3AD648F1592471A5563A1EC9248EBAB22222675CFABAB045680EDC76DD2B4982ED35723485AEDC36357A242ECF4678CAD2208A30F99395742E723645CE3D27390E623AFA1C762AB1E6457633D238E4126B0E157F57D3200B0E1F99D5A56E2D16ECB29DBBC81AC67971922B6811423FD4A745D21368536BB5DB741C8D22DF75BD16DBB2E925B61C961633CE459808AA96D4AA759C1475572272757C08A73AF2663D22E6BB3215761E8DE96440557C161AFB1C6D2578230DC91D51457C145DD71591DD1B0842B4A574186F3A63AEBABA1E9AD6C32DC5761209E96399FAB41C294AEB6FCD2298CEDD95582971B4EBEE255C258988B5B2453A445225CE41F52A844E25E876BD5E364AE4155A8C598073BAC55AC575247AB24536BC9124BA763514B3AA267C762D7225B730351C9599B1797AC518ABED3AA852C9B6A765A143FAD9768E410EEDB2AD69E74324397A8D8DC9E24A297E5F23E50549797A824977173599909D0BD9A3D52D61A8466439908A1DB95F32BE529BEDB8EA71CE546F75CB0B6EAE6CB49657234D0D22185F586E8C78BB4B6CCD0E843C8C9B63657EA2558D1B9B697EA63D4C6B130BED1A8B6589E9CA2C70CD64247EEA2658F9232155161DAA592263353C1E62495B2D5D136C448E254E2F71D923694A6C12AF2ECCAD9AA81BCDD6FA71AAEA109DDC6D91CD1ACF4D999B101A49BBE3BAC59024680AE5AEC5B4158510DE9555B81F4A491AB1CD2DBBEB19361842D0B6583E45EC5D93D95948660C3C6EBDA391863E2C5DD6E46A5D29DA7ADCC6543B4CCEDB8F5656228D4697A52CB634F4AAD42BA6CA3B2E5F89D19D39D66AEC9C72410E6CE39236BA4B6DB7D58D369434CE45111DC6B02F52D6DD51AD32085EE8A6B230B2491C91BD5A356AA8339526B03575E91115D6742391F54ED47D321856F09D7C2C9587727226D444650EE58DDD7C18EAB528D93D2C2A6EF4B5AC1D3A26D33826D428F5F7AC66BD923D89A51AF2CDB6299629201C46D81889CAF5928D2E184EF816D629323AE7713D922C7829346D56EA3595BC9309CCD426875C6457DD7DB690E7B79A414F776DCF464E333E9461C5DE1632C636E8D1ADC8370A40CA921DDEBCAE50FD9435EEA14171BA2835F25AFE964CF0210113027DD80C44A9C704515DC71C3702576E2F5EEEE18D9B6A320EC66B9EAA543BA45A63B5AB5C4DD6C8FB464D51A8D57829564346D482B62B722D91929A9079B08DB234C0F5D51E9CAD44A72A5D3E774B242596A3B1D8C0CE2B56A5AEC79B0795968CD1B94FB085F09AEDE8DCB24D3A58C3243BD89269B8EA4A761872AD3BD3ED461665562054957C12595AAB88267D26694BA8AC105BBCDD0E82E6126AA13CE2723C2E423EA8A7667BE86451912CB1ED1AF9DF5896082D52B611B29C282ABE48D329DD2E3391F86448263C1BBE3C5BAABD22AC4F1A163622015B54B5E65A2D9B120977E636366EC518162C7A27F762EB56CD4208CB24AD129B72ED2273A58EA243276B96364ACC71A2FC4E56B2C472389B739D56194EACA82EC58DBD9BA48D1E8AEB565DDAF69EA3693C1F65C692BD6F36995C6D526A4AA0A67690CB67A4441694A7C9E52DCA569ADBAE512B76269CA63551544A3D56B94AE82694C292AD2281F7EEBCEE1BBDB83698A02A9AD2E9767AB577563E36DD5AB94AAC9692DA91D8D14B968AC3CD75A5CD16BEAB12F39AEA3D5ED28A3A2F164D62E7C668A694CD72B6CA3D3D32A26BDAAE500D12D2E9E4A5924D16BD2C7533374D62C8BE2CA67CAB51C8DD81D672A47A57512D7C96C8D52D238E2650880AB77C72CD6228D0E49C8A9C608955B5CC8C762996D7926C8A6D91B0CA8A3CEE4CD76A8A419D7A43B55E8D2A2DBF2DBA908CA02607AA6C6AAD640B4EB9B2B22DC2027014D48F4D7ABA9DD13EE002B5D98CAD4E64036959256E4B400391B6DB723CC20391B6DB72DD871C26A1CD3C13928D2269B57CD36DF0DB8E4502EB73B4A58D488C7AC9CBE3093DB6AFC5D54AAA658072B5758E8A9586EAC49998E886C1B164A95C16A191D521727DD6DE5994CC967871AF0E89E8F64D928E90DD0AB48A9EC15B8DC8486F8C6B0D8CBDDEEEBD94E81057ACBE72AE2E6A74A39C96754DAA388B54B27D7A4840B2B8E15EBDCEBFCAC0FEA2536D7AED188C6C44AECBC5ACA9AC2489BF5048ECAC2D74BD249FCD4E17AB2D089435A8B0614F762C23561691457A3ECC92C91B4BB628539688E7F19D46473F282690820FB95B524D5685892123B22DD46CB7451270F80C6E368535D29D4E4836AC47327C858F158D3E94467AD110096AEA51FCDBF7B1AE926A6468AD35AD3266BF20B7705392C4A97D3768266E39FC68BEEA4B4FB8D4925F0C2E502681D35D2288CB659F0C1C36ABF58D0EEE1917AB06EDFECA1C6E24C8DD477614925D1C4D9D1ABBCF251ED00959D6D4D5FED21455B6A64A4ED009BE9E9C49AED40ED1D3BAD84D12AC4B2C2EAE1AAC252D69B7500FBA28DAB1CE8E16E5C57592BECA0C3488AF69BD12ACC72C2F100895D8DB4A4F0C0FAEA77E963F080B8C26AE6A37520CD156AB521D21ECBEE197B00BEDE8FD5597D61209A76CD5378E0C96444A69675C224ED91A6A7D45781A65BE5213E6441BB749420E25A2F22A4E4A0C6EC56D4C2EEC156BC8D4729DD225BDE227EE15A9C7365D9B6C2361DB2C71A6A40752C99B719C2E09AD673D2E3DAE9CD61ECE8C0EAA172355F90813928AE595AD6E16AE4515A5C92C14F5230DB33DBE5C3696C872116A3CDBB03730165039BA89CBBE2A8EB55F85577022F54331AECD9A7745A6B9A81576E6165E2EAC1B8DD5A1CB4A1215C43D00A718B46B7E96A569BD868C41A23644254A3EE55239040B1B561495AE82146AE6CCB31EC40BCE294CB14D7E5D2E2EB68A019576CDC9CD02066D68DC91BAC00492292471CE24038E36E3724DAA0A329EBDE4047246DC71CBA4037237246E4BC20472471C8DCA24037246E371CD9E5ABE621D840471C7249246E2046DC6E48E4C20046E471C8E4524046E391C8E4DA2AB3A562AE2048E3924724D60037247248DB984038DB8E4923B00039248DC924DA23BC295BAA2048E372371C8C0037248E4924704048DB72491C66204924924724D82AD32121CC20471C8DC92390C047246DB91CCE00491C92491C78003924924924);

COMMIT;

-- -----------------------------------------------------
-- Data for table `zenoradio-v25`.`data_campaign_media`
-- -----------------------------------------------------
START TRANSACTION;
USE `zenoradio-v25`;
INSERT INTO `zenoradio-v25`.`data_campaign_media` (`id`, `campaign_id`, `type`, `type_order`, `title`, `date_last_change`, `binary_id`, `binary_kb`, `binary_seconds`) VALUES (1, 1, 'INTERRUPTION', 1, 'Interruption 1', NULL, 1, 10, 10);
INSERT INTO `zenoradio-v25`.`data_campaign_media` (`id`, `campaign_id`, `type`, `type_order`, `title`, `date_last_change`, `binary_id`, `binary_kb`, `binary_seconds`) VALUES (2, 1, 'INTERRUPTION', 2, 'Interruption 2', NULL, 2, 10, 10);
INSERT INTO `zenoradio-v25`.`data_campaign_media` (`id`, `campaign_id`, `type`, `type_order`, `title`, `date_last_change`, `binary_id`, `binary_kb`, `binary_seconds`) VALUES (3, 1, 'INTERRUPTION', 3, 'Interruption 3', NULL, 3, 10, 10);
INSERT INTO `zenoradio-v25`.`data_campaign_media` (`id`, `campaign_id`, `type`, `type_order`, `title`, `date_last_change`, `binary_id`, `binary_kb`, `binary_seconds`) VALUES (4, 1, 'REQUEST', 1, 'Request 1', NULL, 4, 10, 10);
INSERT INTO `zenoradio-v25`.`data_campaign_media` (`id`, `campaign_id`, `type`, `type_order`, `title`, `date_last_change`, `binary_id`, `binary_kb`, `binary_seconds`) VALUES (5, 1, 'REQUEST', 2, 'Request 2', NULL, 5, 10, 10);

COMMIT;

-- -----------------------------------------------------
-- Data for table `zenoradio-v25`.`data_content`
-- -----------------------------------------------------
START TRANSACTION;
USE `zenoradio-v25`;
INSERT INTO `zenoradio-v25`.`data_content` (`id`, `title`, `broadcast_id`, `country_id`, `language_id`, `genre_id`, `media_type`, `media_url`, `is_deleted`, `flag_disable_advertise_forward`, `flag_disable_advertise`, `advertise_timmer_interval_minutes`) VALUES (10, 'DEFAULT CONTENT', NULL, NULL, NULL, NULL, 'SHOUTCAST', 'http://sfstream1.somafm.com:8090', 0, 0, 0, 2);
INSERT INTO `zenoradio-v25`.`data_content` (`id`, `title`, `broadcast_id`, `country_id`, `language_id`, `genre_id`, `media_type`, `media_url`, `is_deleted`, `flag_disable_advertise_forward`, `flag_disable_advertise`, `advertise_timmer_interval_minutes`) VALUES (11, 'Chinese', NULL, NULL, NULL, NULL, 'SHOUTCAST', 'http://sfstream1.somafm.com:8090', 0, 0, 0, 2);
INSERT INTO `zenoradio-v25`.`data_content` (`id`, `title`, `broadcast_id`, `country_id`, `language_id`, `genre_id`, `media_type`, `media_url`, `is_deleted`, `flag_disable_advertise_forward`, `flag_disable_advertise`, `advertise_timmer_interval_minutes`) VALUES (12, 'Indie', NULL, NULL, NULL, NULL, 'SHOUTCAST', 'http://sfstream1.somafm.com:8090', 0, 0, 0, 2);

COMMIT;

-- -----------------------------------------------------
-- Data for table `zenoradio-v25`.`data_entryway_provider`
-- -----------------------------------------------------
START TRANSACTION;
USE `zenoradio-v25`;
INSERT INTO `zenoradio-v25`.`data_entryway_provider` (`id`, `title`, `flag_enable_advertise`, `flag_enable_advertise_forward`) VALUES (1, 'DEFAULT', NULL, NULL);
INSERT INTO `zenoradio-v25`.`data_entryway_provider` (`id`, `title`, `flag_enable_advertise`, `flag_enable_advertise_forward`) VALUES (2, 'Internal tests', NULL, NULL);

COMMIT;

-- -----------------------------------------------------
-- Data for table `zenoradio-v25`.`data_gateway`
-- -----------------------------------------------------
START TRANSACTION;
USE `zenoradio-v25`;
INSERT INTO `zenoradio-v25`.`data_gateway` (`id`, `title`, `country_id`, `language_id`, `broadcast_id`, `rca_id`, `is_deleted`, `empty_extension_rule`, `empty_extension_threshold_count`, `invalid_extension_rule`, `invalid_extension_threshold_count`, `ivr_welcome_enabled`, `ivr_welcome_prompt_id`, `ivr_extension_ask_prompt_id`, `ivr_extension_invalid_enabled`, `ivr_extension_invalid_prompt_id`, `flag_disable_advertise`, `flag_disable_advertise_forward`) VALUES (1, 'DEFAULT', NULL, NULL, NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO `zenoradio-v25`.`data_gateway` (`id`, `title`, `country_id`, `language_id`, `broadcast_id`, `rca_id`, `is_deleted`, `empty_extension_rule`, `empty_extension_threshold_count`, `invalid_extension_rule`, `invalid_extension_threshold_count`, `ivr_welcome_enabled`, `ivr_welcome_prompt_id`, `ivr_extension_ask_prompt_id`, `ivr_extension_invalid_enabled`, `ivr_extension_invalid_prompt_id`, `flag_disable_advertise`, `flag_disable_advertise_forward`) VALUES (2, 'Test', NULL, NULL, NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);

COMMIT;

-- -----------------------------------------------------
-- Data for table `zenoradio-v25`.`data_entryway`
-- -----------------------------------------------------
START TRANSACTION;
USE `zenoradio-v25`;
INSERT INTO `zenoradio-v25`.`data_entryway` (`id`, `title`, `did_e164`, `gateway_id`, `country_id`, `3rdparty_id`, `entryway_provider`, `is_deleted`, `is_default`, `flag_disable_advertise`, `flag_disable_advertise_forward`) VALUES (1, 'DEFAULT', '000', 1, NULL, NULL, 1, 0, 1, 0, 0);
INSERT INTO `zenoradio-v25`.`data_entryway` (`id`, `title`, `did_e164`, `gateway_id`, `country_id`, `3rdparty_id`, `entryway_provider`, `is_deleted`, `is_default`, `flag_disable_advertise`, `flag_disable_advertise_forward`) VALUES (2, 'Sip:12345', '12345', 2, NULL, NULL, 2, 0, 0, 0, 0);

COMMIT;

-- -----------------------------------------------------
-- Data for table `zenoradio-v25`.`data_gateway_content`
-- -----------------------------------------------------
START TRANSACTION;
USE `zenoradio-v25`;
INSERT INTO `zenoradio-v25`.`data_gateway_content` (`id`, `gateway_id`, `content_id`, `extension`) VALUES (NULL, 1, 10, NULL);
INSERT INTO `zenoradio-v25`.`data_gateway_content` (`id`, `gateway_id`, `content_id`, `extension`) VALUES (NULL, 2, 11, '1');
INSERT INTO `zenoradio-v25`.`data_gateway_content` (`id`, `gateway_id`, `content_id`, `extension`) VALUES (NULL, 2, 12, '2');

COMMIT;

-- -----------------------------------------------------
-- Data for table `zenoradio-v25`.`sys_server_location`
-- -----------------------------------------------------
START TRANSACTION;
USE `zenoradio-v25`;
INSERT INTO `zenoradio-v25`.`sys_server_location` (`id`, `title`) VALUES (1, 'Test servers');

COMMIT;

-- -----------------------------------------------------
-- Data for table `zenoradio-v25`.`sys_server`
-- -----------------------------------------------------
START TRANSACTION;
USE `zenoradio-v25`;
INSERT INTO `zenoradio-v25`.`sys_server` (`id`, `title`, `short_title`, `ip`, `location_id`, `engine_listen_remote_ip`, `engine_talk_remote_ip`, `engine_privatetalk_remote_ip`, `engine_media_remote_ip`, `engine_advertise_remote_ip`, `is_deleted`) VALUES (1, 'Test server', NULL, NULL, 1, NULL, NULL, NULL, NULL, NULL, 0);

COMMIT;

-- -----------------------------------------------------
-- Data for table `zenoradio-v25`.`data_campaign_publish_at_entryway`
-- -----------------------------------------------------
START TRANSACTION;
USE `zenoradio-v25`;
INSERT INTO `zenoradio-v25`.`data_campaign_publish_at_entryway` (`id`, `campaign_id`, `entryway_id`, `date`) VALUES (1, 1, 1, NULL);
INSERT INTO `zenoradio-v25`.`data_campaign_publish_at_entryway` (`id`, `campaign_id`, `entryway_id`, `date`) VALUES (2, 1, 2, NULL);

COMMIT;

-- -----------------------------------------------------
-- Data for table `zenoradio-v25`.`data_campaign_publish_at_gateway`
-- -----------------------------------------------------
START TRANSACTION;
USE `zenoradio-v25`;
INSERT INTO `zenoradio-v25`.`data_campaign_publish_at_gateway` (`id`, `campaign_id`, `gateway_id`, `date`) VALUES (1, 1, 1, NULL);
INSERT INTO `zenoradio-v25`.`data_campaign_publish_at_gateway` (`id`, `campaign_id`, `gateway_id`, `date`) VALUES (2, 1, 2, NULL);

COMMIT;

-- -----------------------------------------------------
-- Data for table `zenoradio-v25`.`data_campaign_publish_at_content`
-- -----------------------------------------------------
START TRANSACTION;
USE `zenoradio-v25`;
INSERT INTO `zenoradio-v25`.`data_campaign_publish_at_content` (`id`, `campaign_id`, `content_id`, `date`) VALUES (1, 1, 10, NULL);
INSERT INTO `zenoradio-v25`.`data_campaign_publish_at_content` (`id`, `campaign_id`, `content_id`, `date`) VALUES (2, 1, 11, NULL);
INSERT INTO `zenoradio-v25`.`data_campaign_publish_at_content` (`id`, `campaign_id`, `content_id`, `date`) VALUES (3, 1, 12, NULL);

COMMIT;
