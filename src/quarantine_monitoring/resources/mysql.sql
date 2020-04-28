USE quarantine_monitor;

CREATE TABLE device_info(device_id VARCHAR(255), mac_address VARCHAR(255), is_person_present boolean, name VARCHAR(255), 
address VARCHAR(255), age INT, inserted_time TIMESTAMP, receiver_id VARCHAR(255), PRIMARY KEY (device_id));

INSERT INTO quarantine_monitor.device_info(device_id, mac_address) values ("0001", "00-14-22-04-25-37");

UPDATE quarantine_monitor.device_info SET is_person_present = true, name = 'Frankfurt', address = 'Rathgama, Galle'
, age = 45, inserted_time = '2008-01-01 00:00:01', receiver_id = '0001'  WHERE device_id = "0001";

UPDATE quarantine_monitor.device_info 
	SET missing_count = CASE device_id
			   WHEN "0001" THEN 1
               WHEN "0002" THEN 2
               END
               WHERE device_id IN("0001", "0002");

SELECT device_id FROM device_info where receiver_id = "0001"; 
SELECT is_person_present, name, address FROM device_info where device_id = "0005";
 
SELECT * FROM quarantine_monitor.device_info;
  
-- DROP TABLE `quarantine_monitor`.`device_info`;

CREATE TABLE responsible_person(receiver_id VARCHAR(255), name VARCHAR(255), address VARCHAR(255), phone_number VARCHAR(255), username VARCHAR(255), password VARCHAR(255), PRIMARY KEY (receiver_id));

SELECT * FROM quarantine_monitor.responsible_person;
INSERT INTO quarantine_monitor.responsible_person(receiver_id, name, address, phone_number) values ("0001", "PHI-1", "Address1", "+94710630867");
SELECT name, phone_number FROM responsible_person where receiver_id = "0005";

-- DROP TABLE `quarantine_monitor`.`responsible_person`;

SELECT device_id, IF(missing_count> 10, TRUE, FALSE) AS is_missing FROM quarantine_monitor.device_info;

CREATE TABLE responsible_person_info(ID int NOT NULL AUTO_INCREMENT, username VARCHAR(255), password VARCHAR(255), name VARCHAR(255), phone_number VARCHAR(255), PRIMARY KEY (id, username));

USE quarantine_monitor;

CREATE TABLE responsible_person_info(id int NOT NULL AUTO_INCREMENT PRIMARY KEY, username VARCHAR(255) unique, password VARCHAR(255), name VARCHAR(255), phone_number VARCHAR(255));

CREATE TABLE receiver_id_mapping(receiver_id VARCHAR(255), phi_id INT);
SELECT * FROM responsible_person_info;
SELECT * FROM receiver_id_mapping;

INSERT INTO receiver_id_mapping(receiver_id, phi_id) values('0001', 1);
INSERT INTO receiver_id_mapping(receiver_id, phi_id) values('0001', 2);
INSERT INTO receiver_id_mapping(receiver_id, phi_id) values('0002', 3);

INSERT INTO responsible_person_info(username, password, name, phone_number) values('user1', 'user123', 'PHI Saman', '+94710630867');
INSERT INTO responsible_person_info(username, password, name, phone_number) values('user2', 'use', 'PHI Kamal', '+94710630867');
INSERT INTO responsible_person_info(username, password, name, phone_number) values('user3', 'use2345', 'PHI Kamal', '+94710630867');

SELECT phi_id FROM receiver_id_mapping where receiver_id = '0001';

SELECT name, phone_number from responsible_person_info WHERE id IN (SELECT phi_id FROM receiver_id_mapping where receiver_id = '0001');

SELECT device_id, name, address, IF(missing_count>= 20, TRUE, FALSE) AS is_missing FROM device_info WHERE is_person_present;

INSERT INTO receiver_id_mapping(receiver_id, phi_id) values('0003', (SELECT id FROM responsible_person_info WHERE username = "user1"));

SELECT name, phone_number from responsible_person_info WHERE id IN (SELECT phi_id FROM receiver_id_mapping where receiver_id = '0001');

CREATE TABLE device_info_dump(device_id VARCHAR(255), mac_address VARCHAR(255), is_person_present boolean, name VARCHAR(255), address VARCHAR(255), age INT, inserted_time TIMESTAMP , receiver_id VARCHAR(255));

INSERT INTO device_info_dump(device_id, mac_address, is_person_present, name, address, age, inserted_time, receiver_id) 
SELECT device_id, mac_address, is_person_present, name, address, age, inserted_time, receiver_id FROM device_info WHERE device_id = "0001";

USE quarantine_monitor;
UPDATE device_info SET is_person_present = false WHERE device_id IN (SELECT device_id FROM device_info WHERE receiver_id = "001");

SET SQL_SAFE_UPDATES = 1;UPDATE device_info SET is_person_present = true WHERE receiver_id = "001";
UPDATE device_info SET is_person_present = false WHERE receiver_id = '001';
SELECT * FROM quarantine_monitor.device_info;
SET @ModelID = (SELECT device_id FROM device_info WHERE receiver_id = "001");
