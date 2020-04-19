import ballerinax/java.jdbc;
import ballerina/log;
import ballerina/time;
import ballerina/jsonutils;

jdbc:Client qurantineMonitorDb = new ({
    url: "jdbc:mysql://localhost:3306/quarantine_monitor",
    username: "root",
    password: "root",
    dbOptions: {useSSL: false}
});

public function createTables() returns boolean {
    var returned = qurantineMonitorDb->update("CREATE TABLE device_info(device_id VARCHAR(255), mac_address VARCHAR(255), is_person_present boolean, " + 
    " name VARCHAR(255), address VARCHAR(255), age INT, inserted_time TIMESTAMP , receiver_id VARCHAR(255), PRIMARY KEY (device_id))");

    if (returned is jdbc:UpdateResult) {
        log:printInfo("Created the table `device_info` with status: " + returned.updatedRowCount.toString());
    } else {
        log:printError("failed: " + <string>returned.detail()?.message);
    }

    returned = qurantineMonitorDb->update("CREATE TABLE responsible_person(receiver_id VARCHAR(255), name VARCHAR(255), address VARCHAR(255), " + 
    " phone_number VARCHAR(255), PRIMARY KEY (receiver_id))"); 
    
    if (returned is jdbc:UpdateResult) {
        log:printInfo("Created the table `device_info` with status: " + returned.updatedRowCount.toString());
        return true;
    } else {
        log:printError("failed: " + <string>returned.detail()?.message);
    }

    log:printError("Cannot create the tables");
    return false;
}

public function addResponsiblePersonInfo(string receiverId, string name, string address, string phoneNumber) returns boolean {

    var returned = qurantineMonitorDb->update("INSERT INTO responsible_person(receiver_id, name, address, phone_number) " + 
    " values (?, ?, ?, ?)", receiverId, name, address, phoneNumber);

    if (returned is jdbc:UpdateResult) {
        log:printInfo("Inseted the receiver id :" + receiverId + 
                    " and name : " + name + 
                    " and address : " + address + 
                    " and phone number : " + phoneNumber + " with status: " + returned.updatedRowCount.toString());
        return true;
    } else {
        log:printInfo("failed: " + <string>returned.detail()?.message);
    }

    string message = "Error in inserting values to the table `responsible_person`";
    log:printInfo(message);
    return false;
}
public function addDeviceInfoToTable(string deviceId, string macAddress) returns boolean {

    var returned = qurantineMonitorDb->update("INSERT INTO device_info(device_id, mac_address) values (?, ?)", deviceId, macAddress);

    if (returned is jdbc:UpdateResult) {
        log:printInfo("Inseted the device id :" + deviceId + " and mac address : " + macAddress + " with status: " + returned.updatedRowCount.toString());
        return true;
    } else {
        log:printInfo("failed: " + <string>returned.detail()?.message);
    }

    string message = "Error in inserting values to the table `device_info`";
    log:printInfo(message);
    return false;
}

public function updateDeviceInfo(boolean isPersonPresent, string name, string address, int age, string receiverId, 
                                    string deviceId) returns boolean {

    jdbc:Parameter insertedTime = {
        sqlType: jdbc:TYPE_TIMESTAMP,
        value: time:currentTime()
    };   

    var returned = qurantineMonitorDb->update("UPDATE device_info SET is_person_present = ?, name = ?, address = ?, age = ?, " +
        " inserted_time = ?, receiver_id = ?  WHERE device_id = ?", isPersonPresent, name, address, age, insertedTime, receiverId, deviceId);

    if (returned is jdbc:UpdateResult) {
        log:printInfo("Updated the isPersonPresent :" + isPersonPresent.toString() + 
                        " and name :" + name + 
                        " and address :" + address +
                        " and age :" + age.toString() +
                        " and receiver id :" + receiverId +
                        " where device id :" + deviceId + " with status :" + returned.updatedRowCount.toString());
        return true;
    } else {
        log:printInfo("failed: " + <string>returned.detail()?.message);
    }
    return false;
}

type DeviceId record {|
    string device_id;        
|};

public function getDeviceIdsFromDb(string receiverId) returns json {

    var selectRet = qurantineMonitorDb->select("SELECT device_id FROM device_info where receiver_id = ?", DeviceId, receiverId);

    json jsonConversionRet = ();
    if (selectRet is table<record{}>) {
        jsonConversionRet = jsonutils:fromTable(selectRet);
        log:printInfo("JSON: " + jsonConversionRet.toJsonString());
    } else {
        log:printInfo("Select device ids from device_info table failed: " + <string>selectRet.detail()?.message);
    }
    
    return jsonConversionRet;
}

type Person record {|
    boolean is_person_present;
    string name;
    string address;
|};

public function getPersonInfo(string deviceId) returns json {
    
    var selectRet = qurantineMonitorDb->select("SELECT is_person_present, name, address FROM device_info where device_id = ?", Person, deviceId);

    json jsonConversionRet = ();
    if (selectRet is table<record{}>) {
        jsonConversionRet = jsonutils:fromTable(selectRet);
        log:printInfo("JSON: " + jsonConversionRet.toJsonString());
    } else {
        log:printInfo("Select person info from device_info table failed: " + <string>selectRet.detail()?.message);
    }
    
    return jsonConversionRet;
}

type ResponsiblePerson record {|
    string name;
    string phone_number;
|};

public function getResponsiblePersonInfo(string receiverId) returns json {

    var selectRet = qurantineMonitorDb->select("SELECT name, phone_number FROM responsible_person where receiver_id = ?", ResponsiblePerson, receiverId);

    json jsonConversionRet = ();
    if (selectRet is table<record{}>) {
        jsonConversionRet = jsonutils:fromTable(selectRet);
        log:printInfo("JSON: " + jsonConversionRet.toJsonString());
    } else {
        log:printInfo("Select person info from device_info table failed: " + <string>selectRet.detail()?.message);
    }
    
    return jsonConversionRet;
}
