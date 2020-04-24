const ERROR_IN_RESPONDING = "Error in responding";
const ERROR_INVALID_FORMAT = "Invalid format in request body";
const FAILED = "failed: ";

const string USE_DB = "USE quarantine_monitor";
const string CREATE_DEVICE_INFO_TABLE = "CREATE TABLE device_info(device_id VARCHAR(255), mac_address VARCHAR(255), " + 
    " is_person_present boolean DEFAULT false, name VARCHAR(255), address VARCHAR(255), age INT, inserted_time TIMESTAMP , " + 
    " receiver_id VARCHAR(255), PRIMARY KEY (device_id))";
const string CREATE_DEVICE_INFO_DUMP_TABLE = "CREATE TABLE device_info_dump(device_id VARCHAR(255), mac_address VARCHAR(255), " + 
    " is_person_present boolean DEFAULT false, name VARCHAR(255), address VARCHAR(255), age INT, inserted_time TIMESTAMP , " + 
    " receiver_id VARCHAR(255), PRIMARY KEY (device_id))";
const string CREATE_RESPONSIBLE_PERSON_INFO_TABLE = "CREATE TABLE responsible_person_info(id int NOT NULL AUTO_INCREMENT PRIMARY KEY, " + 
    " username VARCHAR(255) UNIQUE, password VARCHAR(255), name VARCHAR(255), phone_number VARCHAR(255));";
const string CREATE_RECEIVER_ID_MAPPING = "CREATE TABLE receiver_id_mapping(receiver_id VARCHAR(255), phi_id INT);";
const string ADD_RESPONSIBLE_PERSON = "INSERT INTO responsible_person_info(username, password, name, phone_number) values (?, ?, ?, ?)";
const string ADD_DEVICE_INFO = "INSERT INTO device_info(device_id, mac_address) values (?, ?)";
const string UPDATE_DEVICE_INFO = "UPDATE device_info SET is_person_present = ?, name = ?, address = ?, age = ?, " +
        " inserted_time = ?, receiver_id = ?  WHERE device_id = ?";
const string SELECT_DEVICE_INFO = "SELECT device_id, mac_address FROM device_info where receiver_id = ?";
const string SELECT_PERSON_INFO = "SELECT is_person_present, name, address FROM device_info where device_id = ?";
const string SELECT_RESPONSIBLE_PERSON_INFO = "SELECT name, phone_number from responsible_person_info WHERE id IN " + 
                    "(SELECT phi_id FROM receiver_id_mapping where receiver_id = ?);";
const string SELECT_RECEIVER_BINDED_INFO = "SELECT device_id, is_person_present, name, address, missing_count FROM device_info where receiver_id = ?";
const string SELECT_MISSING_COUNT = "SELECT device_id, name, address, IF(missing_count>= 20, TRUE, FALSE) AS is_missing " + 
    " FROM device_info WHERE is_person_present";
const string SELECT_RESPONSIBLE_PERSON_INFO_FOR_LOGIN = "SELECT id AS user_id, name AS fullname, username from responsible_person_info " + 
    " WHERE username = ? AND password = ?;";
const string ADD_RAW_DATA = "INSERT INTO raw_data(raw_data) values (?)";
const string CREATE_RAW_DATA_TABLE = "CREATE TABLE raw_data(raw_data VARCHAR(255));";
const string UPDATE_PERSON_PRESENCE = "UPDATE device_info SET is_person_present = ? WHERE device_id = ?";
const string DUMP_DEVICE_INFO_ENTRY = "INSERT INTO device_info_dump(device_id, mac_address, is_person_present, name, address, age, inserted_time, " + 
    " receiver_id) SELECT device_id, mac_address, is_person_present, name, address, age, inserted_time, receiver_id FROM device_info WHERE device_id = ?";
