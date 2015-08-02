SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0;
SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0;
SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='TRADITIONAL,ALLOW_INVALID_DATES';

CREATE SCHEMA IF NOT EXISTS `zenoradio-v25` DEFAULT CHARACTER SET utf8 ;
USE `zenoradio-v25` ;

-- -----------------------------------------------------
-- Table `zenoradio-v25`.`data_group_broadcast`
-- -----------------------------------------------------
CREATE  TABLE IF NOT EXISTS `zenoradio-v25`.`data_group_broadcast` (
  `id` BIGINT(19) UNSIGNED NOT NULL AUTO_INCREMENT ,
  `title` CHAR(200) NULL DEFAULT NULL ,
  `is_deleted` TINYINT(1) NULL DEFAULT '0' ,
  PRIMARY KEY (`id`) )
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `zenoradio-v25`.`data_group_country`
-- -----------------------------------------------------
CREATE  TABLE IF NOT EXISTS `zenoradio-v25`.`data_group_country` (
  `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT ,
  `title` CHAR(200) NULL DEFAULT NULL COMMENT 'get data from here http://en.wikipedia.org/wiki/ISO_3166-1' ,
  `iso_alpha_2` CHAR(2) NULL ,
  `iso_alpha_3` CHAR(3) NULL ,
  `iso_numeric` CHAR(3) NULL ,
  `is_deleted` TINYINT(1) NULL DEFAULT '0' ,
  PRIMARY KEY (`id`) )
ENGINE = InnoDB
COMMENT = 'populate with ISO country table at http://www.iso.org/iso/co';


-- -----------------------------------------------------
-- Table `zenoradio-v25`.`data_group_language`
-- -----------------------------------------------------
CREATE  TABLE IF NOT EXISTS `zenoradio-v25`.`data_group_language` (
  `id` BIGINT(19) UNSIGNED NOT NULL AUTO_INCREMENT ,
  `title` CHAR(200) NULL DEFAULT NULL ,
  `is_deleted` TINYINT(1) NULL DEFAULT '0' ,
  PRIMARY KEY (`id`) )
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `zenoradio-v25`.`data_group_genre`
-- -----------------------------------------------------
CREATE  TABLE IF NOT EXISTS `zenoradio-v25`.`data_group_genre` (
  `id` BIGINT(19) UNSIGNED NOT NULL AUTO_INCREMENT ,
  `title` CHAR(200) NULL DEFAULT NULL ,
  `is_deleted` TINYINT(1) NULL DEFAULT '0' ,
  PRIMARY KEY (`id`) )
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `zenoradio-v25`.`data_content`
-- -----------------------------------------------------
CREATE  TABLE IF NOT EXISTS `zenoradio-v25`.`data_content` (
  `id` BIGINT(19) UNSIGNED NOT NULL AUTO_INCREMENT ,
  `title` CHAR(200) NULL DEFAULT NULL ,
  `broadcast_id` BIGINT(19) UNSIGNED NULL DEFAULT NULL ,
  `country_id` BIGINT UNSIGNED NULL DEFAULT NULL ,
  `language_id` BIGINT(19) UNSIGNED NULL DEFAULT NULL ,
  `genre_id` BIGINT(19) UNSIGNED NULL DEFAULT NULL ,
  `media_type` CHAR(32) NULL ,
  `media_url` CHAR(255) NULL ,
  `advertise_trigger_enable_listenerpreroll` TINYINT(1) NULL DEFAULT 1 ,
  `advertise_trigger_enable_listenertimeout` TINYINT(1) NULL DEFAULT 1 ,
  `advertise_trigger_enable_conferencetiemout` TINYINT(1) NULL DEFAULT 0 ,
  `advertise_trigger_enable_conferenceadreplace` TINYINT(1) NULL DEFAULT 0 ,
  `is_deleted` TINYINT(1) NULL DEFAULT 0 ,
  PRIMARY KEY (`id`) ,
  INDEX `fk_data_content_1_idx` (`broadcast_id` ASC) ,
  INDEX `fk_data_content_1_idx1` (`country_id` ASC) ,
  INDEX `fk_data_content_1_idx2` (`language_id` ASC) ,
  INDEX `gener_idx` (`genre_id` ASC) ,
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


-- -----------------------------------------------------
-- Table `zenoradio-v25`.`data_group_3rdparty`
-- -----------------------------------------------------
CREATE  TABLE IF NOT EXISTS `zenoradio-v25`.`data_group_3rdparty` (
  `id` BIGINT(19) UNSIGNED NOT NULL AUTO_INCREMENT ,
  `title` CHAR(200) NULL DEFAULT NULL ,
  `is_deleted` TINYINT(1) NULL DEFAULT '0' ,
  PRIMARY KEY (`id`) )
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `zenoradio-v25`.`data_entryway_provider`
-- -----------------------------------------------------
CREATE  TABLE IF NOT EXISTS `zenoradio-v25`.`data_entryway_provider` (
  `id` BIGINT(19) UNSIGNED NOT NULL AUTO_INCREMENT ,
  `title` CHAR(200) NULL DEFAULT NULL ,
  PRIMARY KEY (`id`) )
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `zenoradio-v25`.`data_group_rca`
-- -----------------------------------------------------
CREATE  TABLE IF NOT EXISTS `zenoradio-v25`.`data_group_rca` (
  `id` BIGINT(19) UNSIGNED NOT NULL AUTO_INCREMENT ,
  `title` CHAR(200) NULL DEFAULT NULL ,
  `is_deleted` TINYINT(1) NULL DEFAULT '0' ,
  PRIMARY KEY (`id`) )
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `zenoradio-v25`.`data_gateway_prompt_blob`
-- -----------------------------------------------------
CREATE  TABLE IF NOT EXISTS `zenoradio-v25`.`data_gateway_prompt_blob` (
  `id` BIGINT(19) UNSIGNED NOT NULL ,
  `binary` LONGBLOB NULL DEFAULT NULL ,
  `last_change` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP ,
  PRIMARY KEY (`id`) )
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `zenoradio-v25`.`data_gateway_prompt`
-- -----------------------------------------------------
CREATE  TABLE IF NOT EXISTS `zenoradio-v25`.`data_gateway_prompt` (
  `id` BIGINT(19) UNSIGNED NOT NULL AUTO_INCREMENT ,
  `title` CHAR(200) NULL DEFAULT NULL ,
  `gateway_id` BIGINT(19) UNSIGNED NULL DEFAULT NULL ,
  `media_kb` INT(10) UNSIGNED NULL DEFAULT '0' ,
  `media_seconds` INT(10) UNSIGNED NULL DEFAULT '0' ,
  `date_last_change` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP on update CURRENT_TIMESTAMP ,
  PRIMARY KEY (`id`) ,
  INDEX `fk_data_gateway_prompt_1_idx` (`gateway_id` ASC) ,
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


-- -----------------------------------------------------
-- Table `zenoradio-v25`.`data_gateway`
-- -----------------------------------------------------
CREATE  TABLE IF NOT EXISTS `zenoradio-v25`.`data_gateway` (
  `id` BIGINT(19) UNSIGNED NOT NULL AUTO_INCREMENT ,
  `title` CHAR(200) NULL DEFAULT NULL ,
  `country_id` BIGINT UNSIGNED NULL DEFAULT NULL ,
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
  PRIMARY KEY (`id`) ,
  INDEX `fk_data_gateway_1_idx` (`country_id` ASC) ,
  INDEX `fk_data_gateway_2_idx` (`language_id` ASC) ,
  INDEX `fk_data_gateway_3_idx` (`broadcast_id` ASC) ,
  INDEX `fk_data_gateway_4_idx` (`rca_id` ASC) ,
  INDEX `fk_data_gateway_5` (`ivr_welcome_prompt_id` ASC) ,
  INDEX `fk_data_gateway_6` (`ivr_extension_ask_prompt_id` ASC) ,
  INDEX `fk_data_gateway_7` (`ivr_extension_invalid_prompt_id` ASC) ,
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


-- -----------------------------------------------------
-- Table `zenoradio-v25`.`data_entryway`
-- -----------------------------------------------------
CREATE  TABLE IF NOT EXISTS `zenoradio-v25`.`data_entryway` (
  `id` BIGINT(19) UNSIGNED NOT NULL AUTO_INCREMENT ,
  `title` CHAR(200) NULL DEFAULT NULL ,
  `did_e164` CHAR(32) NULL DEFAULT NULL ,
  `gateway_id` BIGINT(19) UNSIGNED NULL DEFAULT NULL ,
  `country_id` BIGINT UNSIGNED NULL DEFAULT NULL ,
  `3rdparty_id` BIGINT(19) UNSIGNED NULL DEFAULT NULL ,
  `entryway_provider` BIGINT(19) UNSIGNED NULL DEFAULT NULL ,
  `is_deleted` TINYINT(1) NULL DEFAULT '0' ,
  `is_default` TINYINT(1) NULL DEFAULT 0 ,
  PRIMARY KEY (`id`) ,
  INDEX `DID` (`did_e164` ASC) ,
  INDEX `title` (`title` ASC) ,
  INDEX `gateway` (`gateway_id` ASC) ,
  INDEX `fk_data_entryway_1_idx` (`entryway_provider` ASC) ,
  INDEX `fk_data_entryway_1_idx1` (`gateway_id` ASC) ,
  INDEX `fk_data_entryway_1_idx2` (`3rdparty_id` ASC) ,
  INDEX `fk_data_entryway_1_idx3` (`country_id` ASC) ,
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


-- -----------------------------------------------------
-- Table `zenoradio-v25`.`data_gateway_conference`
-- -----------------------------------------------------
CREATE  TABLE IF NOT EXISTS `zenoradio-v25`.`data_gateway_conference` (
  `id` BIGINT(19) UNSIGNED NOT NULL AUTO_INCREMENT ,
  `gateway_id` BIGINT(19) UNSIGNED NULL DEFAULT NULL ,
  `content_id` BIGINT(19) UNSIGNED NULL DEFAULT NULL ,
  `extension` CHAR(16) NULL DEFAULT NULL ,
  PRIMARY KEY (`id`) ,
  INDEX `fk_data_gateway_content_1_idx` (`gateway_id` ASC) ,
  INDEX `fk_data_gateway_content_2_idx` (`content_id` ASC) ,
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


-- -----------------------------------------------------
-- Table `zenoradio-v25`.`data_group_advertise_agency`
-- -----------------------------------------------------
CREATE  TABLE IF NOT EXISTS `zenoradio-v25`.`data_group_advertise_agency` (
  `id` BIGINT(19) UNSIGNED NOT NULL AUTO_INCREMENT ,
  `title` CHAR(200) NULL DEFAULT NULL ,
  `is_deleted` TINYINT(1) NULL DEFAULT '0' ,
  PRIMARY KEY (`id`) )
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `zenoradio-v25`.`data_listener`
-- -----------------------------------------------------
CREATE  TABLE IF NOT EXISTS `zenoradio-v25`.`data_listener` (
  `id` BIGINT(19) UNSIGNED NOT NULL AUTO_INCREMENT ,
  `title` CHAR(200) NULL DEFAULT NULL ,
  `flag_push_marketing_opt_in` TINYINT(1) NULL DEFAULT '0' ,
  `area_code` CHAR(255) NULL ,
  PRIMARY KEY (`id`) )
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `zenoradio-v25`.`data_listener_ani_carrier`
-- -----------------------------------------------------
CREATE  TABLE IF NOT EXISTS `zenoradio-v25`.`data_listener_ani_carrier` (
  `id` BIGINT(19) UNSIGNED NOT NULL AUTO_INCREMENT ,
  `title` CHAR(200) NULL DEFAULT NULL ,
  `data247_id` CHAR(32) NULL DEFAULT NULL ,
  `is_premium` TINYINT(1) NULL DEFAULT '0' ,
  `is_mobile` TINYINT(1) NULL DEFAULT '0' ,
  PRIMARY KEY (`id`) )
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `zenoradio-v25`.`data_listener_ani`
-- -----------------------------------------------------
CREATE  TABLE IF NOT EXISTS `zenoradio-v25`.`data_listener_ani` (
  `id` BIGINT(19) UNSIGNED NOT NULL AUTO_INCREMENT ,
  `listener_id` BIGINT(19) UNSIGNED NULL DEFAULT NULL ,
  `ani_e164` CHAR(64) NULL DEFAULT NULL ,
  `carrier_id` BIGINT(19) UNSIGNED NULL DEFAULT NULL ,
  `carrier_last_check` DATETIME NULL DEFAULT NULL ,
  PRIMARY KEY (`id`) ,
  INDEX `fk_data_listener_ani_1_idx` (`listener_id` ASC) ,
  INDEX `fk_data_listener_ani_2_idx` (`carrier_id` ASC) ,
  INDEX `lastcheck` (`carrier_last_check` ASC) ,
  INDEX `ani` (`ani_e164` ASC) ,
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


-- -----------------------------------------------------
-- Table `zenoradio-v25`.`data_listener_at_campaign`
-- -----------------------------------------------------
CREATE  TABLE IF NOT EXISTS `zenoradio-v25`.`data_listener_at_campaign` (
  `id` BIGINT(19) UNSIGNED NOT NULL AUTO_INCREMENT ,
  `listener_id` BIGINT(19) UNSIGNED NULL DEFAULT NULL ,
  `context_at_id` BIGINT(19) UNSIGNED NULL DEFAULT NULL ,
  `statistics_first_session_date` TIMESTAMP NULL DEFAULT NULL ,
  `statistics_last_session_date` DATETIME NULL DEFAULT NULL ,
  `statistics_interruption_first_session_date` DATETIME NULL ,
  `statistics_interruption_last_session_date` DATETIME NULL ,
  `statistics_interruption_last_sessions_timestamp` VARCHAR(1024) NULL ,
  `statistics_interruption_last_sessions_log_campaign_id` VARCHAR(1024) NULL ,
  `statistics_interruption_sessions_count` BIGINT UNSIGNED NULL ,
  `statistics_interruption_sessions_seconds` BIGINT UNSIGNED NULL ,
  `statistics_request_first_session_date` DATETIME NULL ,
  `statistics_request_last_session_date` DATETIME NULL ,
  `statistics_request_last_sessions_timestamp` VARCHAR(1024) NULL ,
  `statistics_request_last_sessions_log_campaign_id` VARCHAR(1024) NULL ,
  `statistics_request_sessions_count` BIGINT UNSIGNED NULL ,
  `statistics_request_sessions_seconds` BIGINT UNSIGNED NULL ,
  PRIMARY KEY (`id`) ,
  INDEX `index2` (`statistics_first_session_date` ASC) ,
  INDEX `fk_data_listener_at_campaign_1_idx` (`listener_id` ASC) ,
  CONSTRAINT `fk_data_listener_at_campaign_1`
    FOREIGN KEY (`listener_id` )
    REFERENCES `zenoradio-v25`.`data_listener` (`id` )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `zenoradio-v25`.`data_listener_at_content`
-- -----------------------------------------------------
CREATE  TABLE IF NOT EXISTS `zenoradio-v25`.`data_listener_at_content` (
  `id` BIGINT(19) UNSIGNED NOT NULL AUTO_INCREMENT ,
  `listener_id` BIGINT(19) UNSIGNED NULL DEFAULT NULL ,
  `context_at_id` BIGINT(19) UNSIGNED NULL DEFAULT NULL ,
  `statistics_first_session_date` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP ,
  `statistics_last_session_date` DATETIME NULL DEFAULT NULL ,
  `statistics_last_sessions_timestamp` VARCHAR(1024) NULL ,
  `statistics_last_sessions_log_listen_id` VARCHAR(1024) NULL ,
  `statistics_sessions_count` BIGINT UNSIGNED NULL ,
  `statistics_sessions_seconds` BIGINT UNSIGNED NULL ,
  PRIMARY KEY (`id`) ,
  INDEX `index5` (`statistics_last_session_date` ASC) ,
  INDEX `fk_data_listener_at_content_1_idx` (`listener_id` ASC) ,
  INDEX `fk_data_listener_at_content_2_idx` (`context_at_id` ASC) ,
  CONSTRAINT `fk_data_listener_at_content_1`
    FOREIGN KEY (`listener_id` )
    REFERENCES `zenoradio-v25`.`data_listener` (`id` )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_data_listener_at_content_2`
    FOREIGN KEY (`context_at_id` )
    REFERENCES `zenoradio-v25`.`data_content` (`id` )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `zenoradio-v25`.`log_listen`
-- -----------------------------------------------------
CREATE  TABLE IF NOT EXISTS `zenoradio-v25`.`log_listen` (
  `id` BIGINT(19) UNSIGNED NOT NULL AUTO_INCREMENT ,
  `server_id` BIGINT UNSIGNED NULL ,
  `log_call_id` BIGINT UNSIGNED NULL ,
  `date_start` DATETIME NULL DEFAULT NULL ,
  `date_stop` DATETIME NULL DEFAULT NULL ,
  `seconds` INT(10) UNSIGNED NULL DEFAULT '0' ,
  `extension` CHAR(16) NULL DEFAULT NULL ,
  `content_id` BIGINT(19) UNSIGNED NULL DEFAULT NULL ,
  `gateway_conference_id` BIGINT UNSIGNED NULL ,
  PRIMARY KEY (`id`) ,
  INDEX `date_start` (`date_start` ASC) ,
  INDEX `date_stop` (`date_stop` ASC) ,
  INDEX `call` (`log_call_id` ASC) )
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `zenoradio-v25`.`now_session`
-- -----------------------------------------------------
CREATE  TABLE IF NOT EXISTS `zenoradio-v25`.`now_session` (
  `id` BIGINT(19) UNSIGNED NOT NULL AUTO_INCREMENT ,
  `log_call_id` BIGINT UNSIGNED NULL ,
  `log_listen_id` BIGINT NULL ,
  `log_campaign_id` BIGINT UNSIGNED NULL ,
  `log_campaign_siptransfer_id` BIGINT UNSIGNED NULL ,
  `call_server_id` BIGINT(19) UNSIGNED NULL DEFAULT NULL ,
  `call_date_start` DATETIME NULL DEFAULT NULL ,
  `call_asterisk_sip_ip` VARCHAR(15) NULL ,
  `call_asterisk_channel` CHAR(64) NULL DEFAULT NULL ,
  `call_asterisk_uniqueid` CHAR(64) NULL DEFAULT NULL ,
  `call_ani_e164` CHAR(32) NULL DEFAULT NULL ,
  `call_did_e164` CHAR(32) NULL DEFAULT NULL ,
  `call_listener_play_welcome` TINYINT(1) NULL DEFAULT '1' ,
  `call_listener_ani_id` BIGINT UNSIGNED NULL DEFAULT NULL ,
  `call_listener_id` BIGINT(19) UNSIGNED NULL DEFAULT NULL ,
  `call_listener_is_anonymous` TINYINT(1) NULL ,
  `call_entryway_id` BIGINT(19) UNSIGNED NULL DEFAULT NULL ,
  `call_gateway_id` BIGINT(19) UNSIGNED NULL DEFAULT NULL ,
  `listen_active` TINYINT(1) NULL DEFAULT 0 ,
  `listen_date_start` DATETIME NULL ,
  `listen_extension` CHAR(16) NULL DEFAULT NULL ,
  `listen_content_id` BIGINT(19) UNSIGNED NULL DEFAULT NULL ,
  `listen_gateway_conference_id` BIGINT UNSIGNED NULL ,
  `listen_server_id` BIGINT NULL ,
  `listen_last_played_campaign_id` BIGINT UNSIGNED NULL ,
  `listen_last_played_campaign_timestamp` DATETIME NULL ,
  `listen_last_played_campaign_log_id` BIGINT UNSIGNED NULL ,
  `listen_asterisk_channel` CHAR(64) NULL ,
  `listen_asterisk_uniqueid` CHAR(64) NULL ,
  `engine_type` ENUM('LISTEN','TALK','PRIVATETALK','ADVERTISESIPTRANSFER','HANGUP') NULL DEFAULT NULL ,
  `engine_date_start` DATETIME NULL DEFAULT NULL ,
  `engine_server_id` BIGINT(19) UNSIGNED NULL DEFAULT NULL ,
  `engine_asterisk_channel` CHAR(64) NULL DEFAULT NULL ,
  `engine_asterisk_uniqueid` CHAR(64) NULL DEFAULT NULL ,
  `engine_advertise_trigger_type` ENUM('LISTENERMANUAL','LISTENERTIMEOUT','LISTENERPREROLL','LISTENERREQUEST','CONFERENCEMANUAL','CONFERENCETIMEOUT','CONFERENCEADREPLACE') NULL DEFAULT NULL ,
  `engine_campaign_id` BIGINT UNSIGNED NULL DEFAULT NULL ,
  `next_step_1_engine_type` ENUM('LISTEN','TALK','PRIVATETALK','ADVERTISESIPTRANSFER','HANGUP') NULL DEFAULT NULL ,
  `next_step_1_engine_advertise_trigger_type` ENUM('LISTENERMANUAL','LISTENERTIMEOUT','LISTENERPREROLL','LISTENERREQUEST','CONFERENCEMANUAL','CONFERENCETIMEOUT','CONFERENCEADREPLACE') NULL DEFAULT NULL ,
  `next_step_1_engine_campaign_id` BIGINT UNSIGNED NULL ,
  `next_step_2_engine_type` ENUM('LISTEN','TALK','PRIVATETALK','ADVERTISESIPTRANSFER','HANGUP') NULL DEFAULT NULL ,
  `next_step_2_engine_advertise_trigger_type` ENUM('LISTENERMANUAL','LISTENERTIMEOUT','LISTENERPREROLL','LISTENERREQUEST','CONFERENCEMANUAL','CONFERENCETIMEOUT','CONFERENCEADREPLACE') NULL DEFAULT NULL ,
  `next_step_2_engine_campaign_id` BIGINT UNSIGNED NULL ,
  `last_engine_type` ENUM('LISTEN','TALK','PRIVATETALK','ADVERTISESIPTRANSFER','HANGUP') NULL ,
  `last_engine_advertise_trigger_type` ENUM('LISTENERMANUAL','LISTENERTIMEOUT','LISTENERPREROLL','LISTENERREQUEST','CONFERENCEMANUAL','CONFERENCETIMEOUT','CONFERENCEADREPLACE') NULL ,
  `last_engine_campaign_id` BIGINT UNSIGNED NULL ,
  PRIMARY KEY (`id`) ,
  INDEX `engine_now` (`engine_type` ASC) )
ENGINE = InnoDB
COMMENT = 'This table hold many runtime information that will be discar';


-- -----------------------------------------------------
-- Table `zenoradio-v25`.`sys_config`
-- -----------------------------------------------------
CREATE  TABLE IF NOT EXISTS `zenoradio-v25`.`sys_config` (
  `group` CHAR(64) NOT NULL ,
  `name` CHAR(128) NOT NULL ,
  `value` CHAR(255) NULL DEFAULT NULL ,
  PRIMARY KEY (`group`, `name`) )
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `zenoradio-v25`.`sys_server_location`
-- -----------------------------------------------------
CREATE  TABLE IF NOT EXISTS `zenoradio-v25`.`sys_server_location` (
  `id` BIGINT(19) UNSIGNED NOT NULL AUTO_INCREMENT ,
  `title` CHAR(200) NULL DEFAULT NULL ,
  PRIMARY KEY (`id`) )
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `zenoradio-v25`.`sys_server`
-- -----------------------------------------------------
CREATE  TABLE IF NOT EXISTS `zenoradio-v25`.`sys_server` (
  `id` BIGINT(19) UNSIGNED NOT NULL AUTO_INCREMENT ,
  `title` CHAR(200) NULL DEFAULT NULL ,
  `short_title` CHAR(16) NULL DEFAULT NULL ,
  `ip` CHAR(15) NULL DEFAULT NULL ,
  `location_id` BIGINT(19) UNSIGNED NULL DEFAULT NULL ,
  `engine_media_remote_ip` CHAR(200) NULL DEFAULT NULL ,
  `is_deleted` TINYINT(1) NULL DEFAULT '0' ,
  `advertise_disable_siptransfer` TINYINT(1) NULL ,
  PRIMARY KEY (`id`) ,
  INDEX `fk_sys_server_1_idx` (`location_id` ASC) ,
  CONSTRAINT `location`
    FOREIGN KEY (`location_id` )
    REFERENCES `zenoradio-v25`.`sys_server_location` (`id` )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB
COMMENT = 'engine_*_remote_ip if blank, mens call server will use local';


-- -----------------------------------------------------
-- Table `zenoradio-v25`.`sys_user_permission`
-- -----------------------------------------------------
CREATE  TABLE IF NOT EXISTS `zenoradio-v25`.`sys_user_permission` (
  `id` BIGINT(19) UNSIGNED NOT NULL AUTO_INCREMENT ,
  `title` CHAR(200) NULL DEFAULT NULL ,
  `is_super_user` TINYINT(1) NULL DEFAULT '0' ,
  `can_manage_specific_3rdparty_resources` TINYINT(1) NULL DEFAULT '0' ,
  `can_manage_specific_broadcast_resources` TINYINT(1) NULL DEFAULT '0' ,
  `can_manage_specific_rca_resources` TINYINT(1) NULL DEFAULT '0' ,
  `can_manage_all_zenoradio_data` TINYINT(1) NULL DEFAULT 0 ,
  `can_manage_all_zenoradio_metadata` TINYINT(1) NULL DEFAULT 0 ,
  `can_manage_all_zenoradio_users` TINYINT(1) NULL DEFAULT 0 ,
  PRIMARY KEY (`id`) )
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `zenoradio-v25`.`sys_user`
-- -----------------------------------------------------
CREATE  TABLE IF NOT EXISTS `zenoradio-v25`.`sys_user` (
  `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT ,
  `permission_id` BIGINT(20) UNSIGNED NULL DEFAULT NULL ,
  `title` CHAR(255) NULL ,
  `email` VARCHAR(255) CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NOT NULL DEFAULT '' ,
  `encrypted_password` VARCHAR(255) CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NOT NULL DEFAULT '' ,
  `reset_password_token` VARCHAR(255) CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `reset_password_sent_at` DATETIME NULL DEFAULT NULL ,
  `remember_created_at` DATETIME NULL DEFAULT NULL ,
  `sign_in_count` INT(11) NULL DEFAULT '0' ,
  `current_sign_in_at` DATETIME NULL DEFAULT NULL ,
  `last_sign_in_at` DATETIME NULL DEFAULT NULL ,
  `current_sign_in_ip` VARCHAR(255) CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `last_sign_in_ip` VARCHAR(255) CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `failed_attempts` INT(11) NULL DEFAULT '0' ,
  `unlock_token` VARCHAR(255) CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `locked_at` DATETIME NULL DEFAULT NULL ,
  `created_at` DATETIME NULL DEFAULT NULL ,
  `updated_at` DATETIME NULL DEFAULT NULL ,
  `name` VARCHAR(255) CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `landline` VARCHAR(255) CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `cellphone` VARCHAR(255) CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `enabled` TINYINT(1) NULL DEFAULT NULL ,
  PRIMARY KEY (`id`) ,
  INDEX `fk_sys_user_1_idx` (`permission_id` ASC) ,
  INDEX `fk_sys_user_1` (`permission_id` ASC) ,
  CONSTRAINT `fk_sys_user_1`
    FOREIGN KEY (`permission_id` )
    REFERENCES `zenoradio-v25`.`sys_user_permission` (`id` )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB
AUTO_INCREMENT = 15;


-- -----------------------------------------------------
-- Table `zenoradio-v25`.`sys_user_resource_3rdparty`
-- -----------------------------------------------------
CREATE  TABLE IF NOT EXISTS `zenoradio-v25`.`sys_user_resource_3rdparty` (
  `id` BIGINT(19) UNSIGNED NOT NULL AUTO_INCREMENT ,
  `user_id` BIGINT(19) UNSIGNED NULL DEFAULT NULL ,
  `3rdparty_id` BIGINT(19) UNSIGNED NULL DEFAULT NULL ,
  PRIMARY KEY (`id`) ,
  INDEX `fk_sys_user_resource_3rdparty_2_idx` (`3rdparty_id` ASC) ,
  INDEX `fk_sys_user_resource_3rdparty_1` (`user_id` ASC) ,
  CONSTRAINT `fk_sys_user_resource_3rdparty_2`
    FOREIGN KEY (`3rdparty_id` )
    REFERENCES `zenoradio-v25`.`data_group_3rdparty` (`id` )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_sys_user_resource_3rdparty_1`
    FOREIGN KEY (`user_id` )
    REFERENCES `zenoradio-v25`.`sys_user` (`id` )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `zenoradio-v25`.`sys_user_resource_advertise_agency`
-- -----------------------------------------------------
CREATE  TABLE IF NOT EXISTS `zenoradio-v25`.`sys_user_resource_advertise_agency` (
  `id` BIGINT(19) UNSIGNED NOT NULL AUTO_INCREMENT ,
  `user_id` BIGINT(19) UNSIGNED NULL DEFAULT NULL ,
  `advertise_agency_id` BIGINT(19) UNSIGNED NULL DEFAULT NULL ,
  PRIMARY KEY (`id`) ,
  INDEX `fk_sys_user_resource_advertise_agency_2_idx` (`advertise_agency_id` ASC) ,
  INDEX `fk_sys_user_resource_advertise_agency_1` (`user_id` ASC) ,
  CONSTRAINT `fk_sys_user_resource_advertise_agency_2`
    FOREIGN KEY (`advertise_agency_id` )
    REFERENCES `zenoradio-v25`.`data_group_advertise_agency` (`id` )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_sys_user_resource_advertise_agency_1`
    FOREIGN KEY (`user_id` )
    REFERENCES `zenoradio-v25`.`sys_user` (`id` )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `zenoradio-v25`.`sys_user_resource_broadcast`
-- -----------------------------------------------------
CREATE  TABLE IF NOT EXISTS `zenoradio-v25`.`sys_user_resource_broadcast` (
  `id` BIGINT(19) UNSIGNED NOT NULL AUTO_INCREMENT ,
  `user_id` BIGINT(19) UNSIGNED NULL DEFAULT NULL ,
  `broadcast_id` BIGINT(19) UNSIGNED NULL DEFAULT NULL ,
  PRIMARY KEY (`id`) ,
  INDEX `fk_sys_user_resource_broadcast_2_idx` (`broadcast_id` ASC) ,
  INDEX `fk_sys_user_resource_broadcast_1` (`user_id` ASC) ,
  CONSTRAINT `fk_sys_user_resource_broadcast_2`
    FOREIGN KEY (`broadcast_id` )
    REFERENCES `zenoradio-v25`.`data_group_broadcast` (`id` )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_sys_user_resource_broadcast_1`
    FOREIGN KEY (`user_id` )
    REFERENCES `zenoradio-v25`.`sys_user` (`id` )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `zenoradio-v25`.`sys_user_resource_rca`
-- -----------------------------------------------------
CREATE  TABLE IF NOT EXISTS `zenoradio-v25`.`sys_user_resource_rca` (
  `id` BIGINT(19) UNSIGNED NOT NULL AUTO_INCREMENT ,
  `user_id` BIGINT(19) UNSIGNED NULL DEFAULT NULL ,
  `rca_id` BIGINT(19) UNSIGNED NULL DEFAULT NULL ,
  PRIMARY KEY (`id`) ,
  INDEX `fk_sys_user_resource_rca_1_idx1` (`rca_id` ASC) ,
  INDEX `fk_sys_user_resource_rca_1` (`user_id` ASC) ,
  CONSTRAINT `rca`
    FOREIGN KEY (`rca_id` )
    REFERENCES `zenoradio-v25`.`data_group_rca` (`id` )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_sys_user_resource_rca_1`
    FOREIGN KEY (`user_id` )
    REFERENCES `zenoradio-v25`.`sys_user` (`id` )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `zenoradio-v25`.`log_call`
-- -----------------------------------------------------
CREATE  TABLE IF NOT EXISTS `zenoradio-v25`.`log_call` (
  `id` BIGINT(19) UNSIGNED NOT NULL AUTO_INCREMENT ,
  `server_id` BIGINT(19) UNSIGNED NULL DEFAULT NULL ,
  `asterisk_remote_ip` CHAR(15) NULL ,
  `date_start` DATETIME NULL DEFAULT NULL ,
  `date_stop` DATETIME NULL ,
  `seconds` INT UNSIGNED NULL ,
  `ani_e164` CHAR(64) NULL DEFAULT NULL ,
  `did_e164` CHAR(64) NULL DEFAULT NULL ,
  `listener_id` BIGINT(19) UNSIGNED NULL DEFAULT NULL ,
  `listener_ani_id` BIGINT UNSIGNED NULL ,
  `listener_is_anonymous` TINYINT(1) NULL DEFAULT 0 ,
  `entryway_id` BIGINT(19) UNSIGNED NULL DEFAULT NULL ,
  `gateway_id` BIGINT(19) UNSIGNED NULL DEFAULT NULL ,
  `on_summary` TINYINT(1) NULL DEFAULT 0 ,
  PRIMARY KEY (`id`) ,
  INDEX `date_start` (`date_start` ASC) ,
  INDEX `date_stop` (`date_stop` ASC) )
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `zenoradio-v25`.`log_campaign`
-- -----------------------------------------------------
CREATE  TABLE IF NOT EXISTS `zenoradio-v25`.`log_campaign` (
  `id` BIGINT(19) UNSIGNED NOT NULL AUTO_INCREMENT ,
  `log_call_id` BIGINT UNSIGNED NULL ,
  `log_listen_id` BIGINT UNSIGNED NULL ,
  `date_start` DATETIME NULL DEFAULT NULL ,
  `date_stop` DATETIME NULL ,
  `campaign_id` BIGINT UNSIGNED NULL ,
  `trigger_type` ENUM('LISTENERMANUAL','LISTENERTIMEOUT','LISTENERPREROLL','LISTENERREQUEST','CONFERENCEMANUAL','CONFERENCETIMEOUT','CONFERENCEADREPLACE') NULL ,
  `advertise_type` ENUM('INTERRUPTION','REQUEST') NOT NULL ,
  `advertise_play_at` ENUM('LISTENER','CONFERENCE') NULL ,
  `advertise_prompt_id` BIGINT UNSIGNED NULL ,
  `advertise_request_type` ENUM('PROMPT','SIPTRANSFER') NULL ,
  `listener_interruption_play_count` BIGINT UNSIGNED NULL DEFAULT 0 ,
  `listener_request_play_count` BIGINT UNSIGNED NULL ,
  `seconds` INT UNSIGNED NULL DEFAULT 0 ,
  `seconds_played` BIGINT UNSIGNED NULL ,
  `cost_per_play` FLOAT UNSIGNED NULL DEFAULT 0 ,
  `cost_per_unique_listener` FLOAT NULL ,
  `cost` FLOAT NULL ,
  PRIMARY KEY (`id`) ,
  INDEX `date_start` (`date_start` ASC) ,
  INDEX `date_stop` (`date_stop` ASC) )
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `zenoradio-v25`.`data_campaign`
-- -----------------------------------------------------
CREATE  TABLE IF NOT EXISTS `zenoradio-v25`.`data_campaign` (
  `id` BIGINT(19) UNSIGNED NOT NULL AUTO_INCREMENT ,
  `title` CHAR(200) NULL DEFAULT NULL ,
  `advertise_agency_id` BIGINT(19) UNSIGNED NULL DEFAULT NULL ,
  `limit_is_active` TINYINT(1) NULL DEFAULT '0' ,
  `limit_date_start` DATE NULL DEFAULT NULL ,
  `limit_date_stop` DATE NULL DEFAULT NULL ,
  `limit_budget_limit` DOUBLE NULL DEFAULT 0 ,
  `limit_budget_balance` DOUBLE NULL DEFAULT 100 ,
  `limit_play_interruption_per_unique_listener_count_limit` INT(10) UNSIGNED NULL DEFAULT '0' ,
  `limit_play_interruption_per_unique_listener_minutes_window` INT(10) UNSIGNED NULL DEFAULT '0' ,
  `playslot_A_play_interruption_cost_per_play` FLOAT UNSIGNED NULL DEFAULT '0' ,
  `playslot_A_play_request_cost_per_play` FLOAT UNSIGNED NULL DEFAULT '0' ,
  `playslot_A_play_request_cost_per_unique_listener` FLOAT UNSIGNED NULL DEFAULT '0' ,
  `playslot_B_play_interruption_cost_per_play` FLOAT UNSIGNED NULL DEFAULT '0' ,
  `playslot_B_play_request_cost_per_play` FLOAT UNSIGNED NULL DEFAULT '0' ,
  `playslot_B_play_request_cost_per_unique_listener` FLOAT UNSIGNED NULL DEFAULT '0' ,
  `playslot_C_play_interruption_cost_per_play` FLOAT UNSIGNED NULL DEFAULT '0' ,
  `playslot_C_play_request_cost_per_play` FLOAT UNSIGNED NULL DEFAULT '0' ,
  `playslot_C_play_request_cost_per_unique_listener` FLOAT UNSIGNED NULL DEFAULT '0' ,
  `playslot_D_play_interruption_cost_per_play` FLOAT UNSIGNED NULL DEFAULT '0' ,
  `playslot_D_play_request_cost_per_play` FLOAT UNSIGNED NULL DEFAULT '0' ,
  `playslot_D_play_request_cost_per_unique_listener` FLOAT UNSIGNED NULL DEFAULT '0' ,
  `playmatrix_sunday_00` ENUM('A','B','C','D') NULL DEFAULT 'A' ,
  `playmatrix_sunday_01` ENUM('A','B','C','D') NULL DEFAULT 'A' ,
  `playmatrix_sunday_02` ENUM('A','B','C','D') NULL DEFAULT 'A' ,
  `playmatrix_sunday_03` ENUM('A','B','C','D') NULL DEFAULT 'A' ,
  `playmatrix_sunday_04` ENUM('A','B','C','D') NULL DEFAULT 'A' ,
  `playmatrix_sunday_05` ENUM('A','B','C','D') NULL DEFAULT 'A' ,
  `playmatrix_sunday_06` ENUM('A','B','C','D') NULL DEFAULT 'A' ,
  `playmatrix_sunday_07` ENUM('A','B','C','D') NULL DEFAULT 'A' ,
  `playmatrix_sunday_08` ENUM('A','B','C','D') NULL DEFAULT 'A' ,
  `playmatrix_sunday_09` ENUM('A','B','C','D') NULL DEFAULT 'A' ,
  `playmatrix_sunday_10` ENUM('A','B','C','D') NULL DEFAULT 'A' ,
  `playmatrix_sunday_11` ENUM('A','B','C','D') NULL DEFAULT 'A' ,
  `playmatrix_sunday_12` ENUM('A','B','C','D') NULL DEFAULT 'A' ,
  `playmatrix_sunday_13` ENUM('A','B','C','D') NULL DEFAULT 'A' ,
  `playmatrix_sunday_14` ENUM('A','B','C','D') NULL DEFAULT 'A' ,
  `playmatrix_sunday_15` ENUM('A','B','C','D') NULL DEFAULT 'A' ,
  `playmatrix_sunday_16` ENUM('A','B','C','D') NULL DEFAULT 'A' ,
  `playmatrix_sunday_17` ENUM('A','B','C','D') NULL DEFAULT 'A' ,
  `playmatrix_sunday_18` ENUM('A','B','C','D') NULL DEFAULT 'A' ,
  `playmatrix_sunday_19` ENUM('A','B','C','D') NULL DEFAULT 'A' ,
  `playmatrix_sunday_20` ENUM('A','B','C','D') NULL DEFAULT 'A' ,
  `playmatrix_sunday_21` ENUM('A','B','C','D') NULL DEFAULT 'A' ,
  `playmatrix_sunday_22` ENUM('A','B','C','D') NULL DEFAULT 'A' ,
  `playmatrix_sunday_23` ENUM('A','B','C','D') NULL DEFAULT 'A' ,
  `playmatrix_monday_00` ENUM('A','B','C','D') NULL DEFAULT 'A' ,
  `playmatrix_monday_01` ENUM('A','B','C','D') NULL DEFAULT 'A' ,
  `playmatrix_monday_02` ENUM('A','B','C','D') NULL DEFAULT 'A' ,
  `playmatrix_monday_03` ENUM('A','B','C','D') NULL DEFAULT 'A' ,
  `playmatrix_monday_04` ENUM('A','B','C','D') NULL DEFAULT 'A' ,
  `playmatrix_monday_05` ENUM('A','B','C','D') NULL DEFAULT 'A' ,
  `playmatrix_monday_06` ENUM('A','B','C','D') NULL DEFAULT 'A' ,
  `playmatrix_monday_07` ENUM('A','B','C','D') NULL DEFAULT 'A' ,
  `playmatrix_monday_08` ENUM('A','B','C','D') NULL DEFAULT 'A' ,
  `playmatrix_monday_09` ENUM('A','B','C','D') NULL DEFAULT 'A' ,
  `playmatrix_monday_10` ENUM('A','B','C','D') NULL DEFAULT 'A' ,
  `playmatrix_monday_11` ENUM('A','B','C','D') NULL DEFAULT 'A' ,
  `playmatrix_monday_12` ENUM('A','B','C','D') NULL DEFAULT 'A' ,
  `playmatrix_monday_13` ENUM('A','B','C','D') NULL DEFAULT 'A' ,
  `playmatrix_monday_14` ENUM('A','B','C','D') NULL DEFAULT 'A' ,
  `playmatrix_monday_15` ENUM('A','B','C','D') NULL DEFAULT 'A' ,
  `playmatrix_monday_16` ENUM('A','B','C','D') NULL DEFAULT 'A' ,
  `playmatrix_monday_17` ENUM('A','B','C','D') NULL DEFAULT 'A' ,
  `playmatrix_monday_18` ENUM('A','B','C','D') NULL DEFAULT 'A' ,
  `playmatrix_monday_19` ENUM('A','B','C','D') NULL DEFAULT 'A' ,
  `playmatrix_monday_20` ENUM('A','B','C','D') NULL DEFAULT 'A' ,
  `playmatrix_monday_21` ENUM('A','B','C','D') NULL DEFAULT 'A' ,
  `playmatrix_monday_22` ENUM('A','B','C','D') NULL DEFAULT 'A' ,
  `playmatrix_monday_23` ENUM('A','B','C','D') NULL DEFAULT 'A' ,
  `playmatrix_tuesday_00` ENUM('A','B','C','D') NULL DEFAULT 'A' ,
  `playmatrix_tuesday_01` ENUM('A','B','C','D') NULL DEFAULT 'A' ,
  `playmatrix_tuesday_02` ENUM('A','B','C','D') NULL DEFAULT 'A' ,
  `playmatrix_tuesday_03` ENUM('A','B','C','D') NULL DEFAULT 'A' ,
  `playmatrix_tuesday_04` ENUM('A','B','C','D') NULL DEFAULT 'A' ,
  `playmatrix_tuesday_05` ENUM('A','B','C','D') NULL DEFAULT 'A' ,
  `playmatrix_tuesday_06` ENUM('A','B','C','D') NULL DEFAULT 'A' ,
  `playmatrix_tuesday_07` ENUM('A','B','C','D') NULL DEFAULT 'A' ,
  `playmatrix_tuesday_08` ENUM('A','B','C','D') NULL DEFAULT 'A' ,
  `playmatrix_tuesday_09` ENUM('A','B','C','D') NULL DEFAULT 'A' ,
  `playmatrix_tuesday_10` ENUM('A','B','C','D') NULL DEFAULT 'A' ,
  `playmatrix_tuesday_11` ENUM('A','B','C','D') NULL DEFAULT 'A' ,
  `playmatrix_tuesday_12` ENUM('A','B','C','D') NULL DEFAULT 'A' ,
  `playmatrix_tuesday_13` ENUM('A','B','C','D') NULL DEFAULT 'A' ,
  `playmatrix_tuesday_14` ENUM('A','B','C','D') NULL DEFAULT 'A' ,
  `playmatrix_tuesday_15` ENUM('A','B','C','D') NULL DEFAULT 'A' ,
  `playmatrix_tuesday_16` ENUM('A','B','C','D') NULL DEFAULT 'A' ,
  `playmatrix_tuesday_17` ENUM('A','B','C','D') NULL DEFAULT 'A' ,
  `playmatrix_tuesday_18` ENUM('A','B','C','D') NULL DEFAULT 'A' ,
  `playmatrix_tuesday_19` ENUM('A','B','C','D') NULL DEFAULT 'A' ,
  `playmatrix_tuesday_20` ENUM('A','B','C','D') NULL DEFAULT 'A' ,
  `playmatrix_tuesday_21` ENUM('A','B','C','D') NULL DEFAULT 'A' ,
  `playmatrix_tuesday_22` ENUM('A','B','C','D') NULL DEFAULT 'A' ,
  `playmatrix_tuesday_23` ENUM('A','B','C','D') NULL DEFAULT 'A' ,
  `playmatrix_wednesday_00` ENUM('A','B','C','D') NULL DEFAULT 'A' ,
  `playmatrix_wednesday_01` ENUM('A','B','C','D') NULL DEFAULT 'A' ,
  `playmatrix_wednesday_02` ENUM('A','B','C','D') NULL DEFAULT 'A' ,
  `playmatrix_wednesday_03` ENUM('A','B','C','D') NULL DEFAULT 'A' ,
  `playmatrix_wednesday_04` ENUM('A','B','C','D') NULL DEFAULT 'A' ,
  `playmatrix_wednesday_05` ENUM('A','B','C','D') NULL DEFAULT 'A' ,
  `playmatrix_wednesday_06` ENUM('A','B','C','D') NULL DEFAULT 'A' ,
  `playmatrix_wednesday_07` ENUM('A','B','C','D') NULL DEFAULT 'A' ,
  `playmatrix_wednesday_08` ENUM('A','B','C','D') NULL DEFAULT 'A' ,
  `playmatrix_wednesday_09` ENUM('A','B','C','D') NULL DEFAULT 'A' ,
  `playmatrix_wednesday_10` ENUM('A','B','C','D') NULL DEFAULT 'A' ,
  `playmatrix_wednesday_11` ENUM('A','B','C','D') NULL DEFAULT 'A' ,
  `playmatrix_wednesday_12` ENUM('A','B','C','D') NULL DEFAULT 'A' ,
  `playmatrix_wednesday_13` ENUM('A','B','C','D') NULL DEFAULT 'A' ,
  `playmatrix_wednesday_14` ENUM('A','B','C','D') NULL DEFAULT 'A' ,
  `playmatrix_wednesday_15` ENUM('A','B','C','D') NULL DEFAULT 'A' ,
  `playmatrix_wednesday_16` ENUM('A','B','C','D') NULL DEFAULT 'A' ,
  `playmatrix_wednesday_17` ENUM('A','B','C','D') NULL DEFAULT 'A' ,
  `playmatrix_wednesday_18` ENUM('A','B','C','D') NULL DEFAULT 'A' ,
  `playmatrix_wednesday_19` ENUM('A','B','C','D') NULL DEFAULT 'A' ,
  `playmatrix_wednesday_20` ENUM('A','B','C','D') NULL DEFAULT 'A' ,
  `playmatrix_wednesday_21` ENUM('A','B','C','D') NULL DEFAULT 'A' ,
  `playmatrix_wednesday_22` ENUM('A','B','C','D') NULL DEFAULT 'A' ,
  `playmatrix_wednesday_23` ENUM('A','B','C','D') NULL DEFAULT 'A' ,
  `playmatrix_thursday_00` ENUM('A','B','C','D') NULL DEFAULT 'A' ,
  `playmatrix_thursday_01` ENUM('A','B','C','D') NULL DEFAULT 'A' ,
  `playmatrix_thursday_02` ENUM('A','B','C','D') NULL DEFAULT 'A' ,
  `playmatrix_thursday_03` ENUM('A','B','C','D') NULL DEFAULT 'A' ,
  `playmatrix_thursday_04` ENUM('A','B','C','D') NULL DEFAULT 'A' ,
  `playmatrix_thursday_05` ENUM('A','B','C','D') NULL DEFAULT 'A' ,
  `playmatrix_thursday_06` ENUM('A','B','C','D') NULL DEFAULT 'A' ,
  `playmatrix_thursday_07` ENUM('A','B','C','D') NULL DEFAULT 'A' ,
  `playmatrix_thursday_08` ENUM('A','B','C','D') NULL DEFAULT 'A' ,
  `playmatrix_thursday_09` ENUM('A','B','C','D') NULL DEFAULT 'A' ,
  `playmatrix_thursday_10` ENUM('A','B','C','D') NULL DEFAULT 'A' ,
  `playmatrix_thursday_11` ENUM('A','B','C','D') NULL DEFAULT 'A' ,
  `playmatrix_thursday_12` ENUM('A','B','C','D') NULL DEFAULT 'A' ,
  `playmatrix_thursday_13` ENUM('A','B','C','D') NULL DEFAULT 'A' ,
  `playmatrix_thursday_14` ENUM('A','B','C','D') NULL DEFAULT 'A' ,
  `playmatrix_thursday_15` ENUM('A','B','C','D') NULL DEFAULT 'A' ,
  `playmatrix_thursday_16` ENUM('A','B','C','D') NULL DEFAULT 'A' ,
  `playmatrix_thursday_17` ENUM('A','B','C','D') NULL DEFAULT 'A' ,
  `playmatrix_thursday_18` ENUM('A','B','C','D') NULL DEFAULT 'A' ,
  `playmatrix_thursday_19` ENUM('A','B','C','D') NULL DEFAULT 'A' ,
  `playmatrix_thursday_20` ENUM('A','B','C','D') NULL DEFAULT 'A' ,
  `playmatrix_thursday_21` ENUM('A','B','C','D') NULL DEFAULT 'A' ,
  `playmatrix_thursday_22` ENUM('A','B','C','D') NULL DEFAULT 'A' ,
  `playmatrix_thursday_23` ENUM('A','B','C','D') NULL DEFAULT 'A' ,
  `playmatrix_friday_00` ENUM('A','B','C','D') NULL DEFAULT 'A' ,
  `playmatrix_friday_01` ENUM('A','B','C','D') NULL DEFAULT 'A' ,
  `playmatrix_friday_02` ENUM('A','B','C','D') NULL DEFAULT 'A' ,
  `playmatrix_friday_03` ENUM('A','B','C','D') NULL DEFAULT 'A' ,
  `playmatrix_friday_04` ENUM('A','B','C','D') NULL DEFAULT 'A' ,
  `playmatrix_friday_05` ENUM('A','B','C','D') NULL DEFAULT 'A' ,
  `playmatrix_friday_06` ENUM('A','B','C','D') NULL DEFAULT 'A' ,
  `playmatrix_friday_07` ENUM('A','B','C','D') NULL DEFAULT 'A' ,
  `playmatrix_friday_08` ENUM('A','B','C','D') NULL DEFAULT 'A' ,
  `playmatrix_friday_09` ENUM('A','B','C','D') NULL DEFAULT 'A' ,
  `playmatrix_friday_10` ENUM('A','B','C','D') NULL DEFAULT 'A' ,
  `playmatrix_friday_11` ENUM('A','B','C','D') NULL DEFAULT 'A' ,
  `playmatrix_friday_12` ENUM('A','B','C','D') NULL DEFAULT 'A' ,
  `playmatrix_friday_13` ENUM('A','B','C','D') NULL DEFAULT 'A' ,
  `playmatrix_friday_14` ENUM('A','B','C','D') NULL DEFAULT 'A' ,
  `playmatrix_friday_15` ENUM('A','B','C','D') NULL DEFAULT 'A' ,
  `playmatrix_friday_16` ENUM('A','B','C','D') NULL DEFAULT 'A' ,
  `playmatrix_friday_17` ENUM('A','B','C','D') NULL DEFAULT 'A' ,
  `playmatrix_friday_18` ENUM('A','B','C','D') NULL DEFAULT 'A' ,
  `playmatrix_friday_19` ENUM('A','B','C','D') NULL DEFAULT 'A' ,
  `playmatrix_friday_20` ENUM('A','B','C','D') NULL DEFAULT 'A' ,
  `playmatrix_friday_21` ENUM('A','B','C','D') NULL DEFAULT 'A' ,
  `playmatrix_friday_22` ENUM('A','B','C','D') NULL DEFAULT 'A' ,
  `playmatrix_friday_23` ENUM('A','B','C','D') NULL DEFAULT 'A' ,
  `playmatrix_saturday_00` ENUM('A','B','C','D') NULL DEFAULT 'A' ,
  `playmatrix_saturday_01` ENUM('A','B','C','D') NULL DEFAULT 'A' ,
  `playmatrix_saturday_02` ENUM('A','B','C','D') NULL DEFAULT 'A' ,
  `playmatrix_saturday_03` ENUM('A','B','C','D') NULL DEFAULT 'A' ,
  `playmatrix_saturday_04` ENUM('A','B','C','D') NULL DEFAULT 'A' ,
  `playmatrix_saturday_05` ENUM('A','B','C','D') NULL DEFAULT 'A' ,
  `playmatrix_saturday_06` ENUM('A','B','C','D') NULL DEFAULT 'A' ,
  `playmatrix_saturday_07` ENUM('A','B','C','D') NULL DEFAULT 'A' ,
  `playmatrix_saturday_08` ENUM('A','B','C','D') NULL DEFAULT 'A' ,
  `playmatrix_saturday_09` ENUM('A','B','C','D') NULL DEFAULT 'A' ,
  `playmatrix_saturday_10` ENUM('A','B','C','D') NULL DEFAULT 'A' ,
  `playmatrix_saturday_11` ENUM('A','B','C','D') NULL DEFAULT 'A' ,
  `playmatrix_saturday_12` ENUM('A','B','C','D') NULL DEFAULT 'A' ,
  `playmatrix_saturday_13` ENUM('A','B','C','D') NULL DEFAULT 'A' ,
  `playmatrix_saturday_14` ENUM('A','B','C','D') NULL DEFAULT 'A' ,
  `playmatrix_saturday_15` ENUM('A','B','C','D') NULL DEFAULT 'A' ,
  `playmatrix_saturday_16` ENUM('A','B','C','D') NULL DEFAULT 'A' ,
  `playmatrix_saturday_17` ENUM('A','B','C','D') NULL DEFAULT 'A' ,
  `playmatrix_saturday_18` ENUM('A','B','C','D') NULL DEFAULT 'A' ,
  `playmatrix_saturday_19` ENUM('A','B','C','D') NULL DEFAULT 'A' ,
  `playmatrix_saturday_20` ENUM('A','B','C','D') NULL DEFAULT 'A' ,
  `playmatrix_saturday_21` ENUM('A','B','C','D') NULL DEFAULT 'A' ,
  `playmatrix_saturday_22` ENUM('A','B','C','D') NULL DEFAULT 'A' ,
  `playmatrix_saturday_23` ENUM('A','B','C','D') NULL DEFAULT 'A' ,
  `advertise_interruption_prompt_id` BIGINT UNSIGNED NULL ,
  `advertise_request_type` ENUM('PROMPT','SIPTRANSFER') NULL DEFAULT 'PROMPT' ,
  `advertise_request_prompt_id` BIGINT UNSIGNED NULL ,
  `advertise_request_siptransfer_sip_string` CHAR(255) NULL ,
  `advertise_request_siptransfer_callid_mode` ENUM('CLEAN','LISTENERANI','LISTENERID') NULL DEFAULT 'LISTENERID' ,
  `advertise_request_siptransfer_preconnect_prompt_id` BIGINT UNSIGNED NULL ,
  `advertise_request_siptransfer_failconnect_prompt_id` BIGINT UNSIGNED NULL ,
  PRIMARY KEY (`id`) ,
  INDEX `dispatcher_1` (`limit_is_active` ASC) ,
  INDEX `dispatcher_2` (`limit_date_start` ASC, `limit_date_stop` ASC) ,
  INDEX `dispatcher_3` (`limit_budget_limit` ASC, `limit_budget_balance` ASC) ,
  INDEX `fk_data_campaign_1` (`advertise_agency_id` ASC) ,
  CONSTRAINT `fk_data_campaign_1`
    FOREIGN KEY (`advertise_agency_id` )
    REFERENCES `zenoradio-v25`.`data_group_advertise_agency` (`id` )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB
DEFAULT CHARACTER SET = latin1;


-- -----------------------------------------------------
-- Table `zenoradio-v25`.`data_campaign_publishmap`
-- -----------------------------------------------------
CREATE  TABLE IF NOT EXISTS `zenoradio-v25`.`data_campaign_publishmap` (
  `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT ,
  `campaign_id` BIGINT UNSIGNED NULL ,
  PRIMARY KEY (`id`) ,
  INDEX `fk_data_campaign_publishmap_1` (`campaign_id` ASC) ,
  CONSTRAINT `fk_data_campaign_publishmap_1`
    FOREIGN KEY (`campaign_id` )
    REFERENCES `zenoradio-v25`.`data_campaign` (`id` )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `zenoradio-v25`.`data_campaign_publishmap_expression`
-- -----------------------------------------------------
CREATE  TABLE IF NOT EXISTS `zenoradio-v25`.`data_campaign_publishmap_expression` (
  `id` BIGINT NOT NULL ,
  `publishmap_id` BIGINT UNSIGNED NULL ,
  `field` ENUM('ENTRYWAY_ID','GATEWAY_ID','CONTENT_ID','ENTRYWAY_PROVIDER_ID','3RDPARTY_ID','BROADCAST_ID','COUNTRY_ID','GENRE_ID','LANGUAGE_ID','RCA_ID','LISTENER_ANI_CARRIER_ID','CAMPAIGN_PLAYSLOT','LISTENER_IS_ANONYMOUS') NULL ,
  `operator` ENUM('EQUAL','NOT_EQUAL','IN_CSV_LIST','NOT_IN_CSV_LIST','IS_EMPTY','IS_NOT_EMPTY','IS_TRUE','IS_FALSE') NULL ,
  `value` VARCHAR(8192) NULL ,
  PRIMARY KEY (`id`) ,
  INDEX `fk_data_campaign_publishmap_querie_1` (`publishmap_id` ASC) ,
  CONSTRAINT `fk_data_campaign_publishmap_querie_1`
    FOREIGN KEY (`publishmap_id` )
    REFERENCES `zenoradio-v25`.`data_campaign_publishmap` (`id` )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `zenoradio-v25`.`data_listener_at_entryway`
-- -----------------------------------------------------
CREATE  TABLE IF NOT EXISTS `zenoradio-v25`.`data_listener_at_entryway` (
  `id` BIGINT(19) UNSIGNED NOT NULL AUTO_INCREMENT ,
  `listener_id` BIGINT(19) UNSIGNED NULL DEFAULT NULL ,
  `context_at_id` BIGINT(19) UNSIGNED NULL DEFAULT NULL ,
  `statistics_first_session_date` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP ,
  `statistics_last_session_date` DATETIME NULL DEFAULT NULL ,
  `statistics_last_sessions_timestamp` VARCHAR(1024) NULL ,
  `statistics_last_sessions_log_listen_id` VARCHAR(1024) NULL ,
  `statistics_sessions_count` BIGINT UNSIGNED NULL ,
  `statistics_sessions_seconds` BIGINT UNSIGNED NULL ,
  PRIMARY KEY (`id`) ,
  INDEX `index4` (`statistics_last_session_date` ASC) ,
  INDEX `fk_data_listener_at_entryway_1_idx` (`listener_id` ASC) ,
  INDEX `fk_data_listener_at_entryway_2_idx` (`context_at_id` ASC) ,
  CONSTRAINT `fk_data_listener_at_entryway_1`
    FOREIGN KEY (`listener_id` )
    REFERENCES `zenoradio-v25`.`data_listener` (`id` )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_data_listener_at_entryway_2`
    FOREIGN KEY (`context_at_id` )
    REFERENCES `zenoradio-v25`.`data_entryway` (`id` )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `zenoradio-v25`.`data_listener_at_gateway`
-- -----------------------------------------------------
CREATE  TABLE IF NOT EXISTS `zenoradio-v25`.`data_listener_at_gateway` (
  `id` BIGINT(19) UNSIGNED NOT NULL AUTO_INCREMENT ,
  `listener_id` BIGINT(19) UNSIGNED NULL DEFAULT NULL ,
  `context_at_id` BIGINT(19) UNSIGNED NULL DEFAULT NULL ,
  `statistics_first_session_date` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP ,
  `statistics_last_session_date` DATETIME NULL DEFAULT NULL ,
  `statistics_last_sessions_timestamp` VARCHAR(1024) NULL ,
  `statistics_last_sessions_log_listen_id` VARCHAR(1024) NULL ,
  `statistics_sessions_count` BIGINT UNSIGNED NULL ,
  `statistics_sessions_seconds` BIGINT UNSIGNED NULL ,
  PRIMARY KEY (`id`) ,
  INDEX `index4` (`statistics_last_session_date` ASC) ,
  INDEX `fk_data_listener_at_gateway_1` (`listener_id` ASC) ,
  INDEX `fk_data_listener_at_gateway_2` (`context_at_id` ASC) ,
  CONSTRAINT `fk_data_listener_at_gateway_1`
    FOREIGN KEY (`listener_id` )
    REFERENCES `zenoradio-v25`.`data_listener` (`id` )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_data_listener_at_gateway_2`
    FOREIGN KEY (`context_at_id` )
    REFERENCES `zenoradio-v25`.`data_gateway` (`id` )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `zenoradio-v25`.`data_campaign_prompt_blob`
-- -----------------------------------------------------
CREATE  TABLE IF NOT EXISTS `zenoradio-v25`.`data_campaign_prompt_blob` (
  `id` BIGINT(19) UNSIGNED NOT NULL ,
  `binary` LONGBLOB NULL DEFAULT NULL ,
  `last_change` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP ,
  PRIMARY KEY (`id`) )
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `zenoradio-v25`.`data_campaign_prompt`
-- -----------------------------------------------------
CREATE  TABLE IF NOT EXISTS `zenoradio-v25`.`data_campaign_prompt` (
  `id` BIGINT(19) UNSIGNED NOT NULL AUTO_INCREMENT ,
  `title` CHAR(200) NULL DEFAULT NULL ,
  `campaign_id` BIGINT(19) UNSIGNED NULL DEFAULT NULL ,
  `media_kb` INT(10) UNSIGNED NULL DEFAULT '0' ,
  `media_seconds` INT(10) UNSIGNED NULL DEFAULT '0' ,
  `date_last_change` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP on update CURRENT_TIMESTAMP ,
  PRIMARY KEY (`id`) ,
  INDEX `fk_data_campaign_prompt_1` (`campaign_id` ASC) ,
  INDEX `fk_data_campaign_prompt_2` (`id` ASC) ,
  CONSTRAINT `fk_data_campaign_prompt_1`
    FOREIGN KEY (`campaign_id` )
    REFERENCES `zenoradio-v25`.`data_campaign` (`id` )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_data_campaign_prompt_2`
    FOREIGN KEY (`id` )
    REFERENCES `zenoradio-v25`.`data_campaign_prompt_blob` (`id` )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `zenoradio-v25`.`log_campaign_siptransfer`
-- -----------------------------------------------------
CREATE  TABLE IF NOT EXISTS `zenoradio-v25`.`log_campaign_siptransfer` (
  `id` BIGINT(19) UNSIGNED NOT NULL AUTO_INCREMENT ,
  `log_call_id` BIGINT UNSIGNED NULL ,
  `log_listen_id` BIGINT UNSIGNED NULL ,
  `log_campaign_id` BIGINT UNSIGNED NULL ,
  `date_start` DATETIME NULL DEFAULT NULL ,
  `date_stop` DATETIME NULL DEFAULT NULL ,
  `sip_string` CHAR(255) NULL ,
  `callid_mode` ENUM('CLEAN','LISTENERANI','LISTENERID') NULL ,
  `callid_sent` CHAR(255) NULL ,
  `seconds` INT UNSIGNED NULL DEFAULT 0 ,
  `asterisk_dialstatus` CHAR(32) NULL ,
  `asterisk_hangupcause` CHAR(16) NULL ,
  PRIMARY KEY (`id`) ,
  INDEX `date_start` (`date_start` ASC) ,
  INDEX `date_stop` (`date_stop` ASC) )
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `zenoradio-v25`.`aggregate_custom`
-- -----------------------------------------------------
CREATE  TABLE IF NOT EXISTS `zenoradio-v25`.`aggregate_custom` (
  `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT ,
  `user_id` BIGINT UNSIGNED NULL DEFAULT NULL ,
  `removable_id` INT(11) NULL DEFAULT NULL ,
  `removable_type` VARCHAR(255) CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `remove_children` TINYINT(1) NULL DEFAULT '0' ,
  `created_at` DATETIME NOT NULL ,
  `updated_at` DATETIME NOT NULL ,
  PRIMARY KEY (`id`) ,
  INDEX `index_aggregate_custom_on_removable_id_and_removable_type` (`removable_id` ASC, `removable_type` ASC) ,
  INDEX `index_aggregate_custom_on_removable_id` (`removable_id` ASC) ,
  INDEX `index_aggregate_custom_on_removable_type` (`removable_type` ASC) ,
  INDEX `index_aggregate_custom_on_user_id` (`user_id` ASC) )
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8
COLLATE = utf8_unicode_ci;

USE `zenoradio-v25` ;


SET SQL_MODE=@OLD_SQL_MODE;
SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS;
SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS;
