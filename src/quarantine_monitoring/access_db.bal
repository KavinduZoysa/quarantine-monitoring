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

// jdbc:Client qurantineMonitorDb = new ({
//     url: "jdbc:mysql://kavindu-rds-amazon.cmwczs08iavr.us-east-2.rds.amazonaws.com:3306/quarantine_monitor",
//     username: "admin",
//     password: "adminadmin",
//     dbOptions: {useSSL: false}
// });

public function checkDbConnectivity() returns boolean {
    var returned = qurantineMonitorDb->update(USE_DB);
    if (returned is jdbc:UpdateResult) {
        log:printInfo("Use database `quarantine_monitor` with status: " + returned.updatedRowCount.toString());
        return true;
    } else {
        log:printError(FAILED + <string>returned.detail()?.message);
    }
    return false;
}

public function createTables() returns boolean {
    var returned = qurantineMonitorDb->update(CREATE_DEVICE_INFO_TABLE);

    if (returned is jdbc:UpdateResult) {
        log:printInfo("Created the table `device_info` with status: " + returned.updatedRowCount.toString());
    } else {
        log:printError(FAILED + <string>returned.detail()?.message);
    }

    returned = qurantineMonitorDb->update(CREATE_RESPONSIBLE_PERSON_INFO_TABLE); 
    
    if (returned is jdbc:UpdateResult) {
        log:printInfo("Created the table `responsible_person_info` with status: " + returned.updatedRowCount.toString());
        return true;
    } else {
        log:printError(FAILED + <string>returned.detail()?.message);
    }

    returned = qurantineMonitorDb->update(CREATE_RECEIVER_ID_MAPPING); 
    
    if (returned is jdbc:UpdateResult) {
        log:printInfo("Created the table `receiver_id_mapping` with status: " + returned.updatedRowCount.toString());
        return true;
    } else {
        log:printError(FAILED + <string>returned.detail()?.message);
    }

    log:printError("Cannot create the tables");
    return false;
}

public function addResponsiblePerson(string username, string password, string name, string phoneNumber) returns boolean {

    var returned = qurantineMonitorDb->update(ADD_RESPONSIBLE_PERSON, username, password, name, phoneNumber);

    if (returned is jdbc:UpdateResult) {
        log:printInfo("Inseted the receiver id :" + username + 
                    " and name : " + password + 
                    " and address : " + name + 
                    " and phone number : " + phoneNumber + " with status: " + returned.updatedRowCount.toString());
        return true;
    } else {
        log:printInfo(FAILED + <string>returned.detail()?.message);
    }

    string message = "Error in inserting values to the table `responsible_person`";
    log:printInfo(message);
    return false;
}
public function addDeviceInfoToTable(string deviceId, string macAddress) returns boolean {

    var returned = qurantineMonitorDb->update(ADD_DEVICE_INFO, deviceId, macAddress);

    if (returned is jdbc:UpdateResult) {
        log:printInfo("Inserted the device id :" + deviceId + " and mac address : " + macAddress + " with status: " + returned.updatedRowCount.toString());
        return true;
    } else {
        log:printInfo(FAILED + <string>returned.detail()?.message);
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
    var returned = qurantineMonitorDb->update(UPDATE_DEVICE_INFO, isPersonPresent, name, address, age, insertedTime, receiverId, deviceId);

    if (returned is jdbc:UpdateResult) {
        log:printInfo("Updated the isPersonPresent :" + isPersonPresent.toString() + 
                        " and name :" + name + 
                        " and address :" + address +
                        " and age :" + age.toString() +
                        " and receiver id :" + receiverId +
                        " where device id :" + deviceId + " with status :" + returned.updatedRowCount.toString());
        return true;
    } else {
        log:printInfo(FAILED + <string>returned.detail()?.message);
    }
    return false;
}

type DeviceId record {|
    string device_id;  
    string mac_address;      
|};

public function getDeviceIdsFromDb(string receiverId) returns json {

    var selectRet = qurantineMonitorDb->select(SELECT_DEVICE_INFO, DeviceId, receiverId);

    json jsonConversionRet = ();
    if (selectRet is table<record{}>) {
        jsonConversionRet = jsonutils:fromTable(selectRet);
        log:printInfo("Device ids JSON: " + jsonConversionRet.toJsonString());
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
    
    var selectRet = qurantineMonitorDb->select(SELECT_PERSON_INFO, Person, deviceId);

    json jsonConversionRet = ();
    if (selectRet is table<record{}>) {
        jsonConversionRet = jsonutils:fromTable(selectRet);
        log:printInfo("Person info JSON: " + jsonConversionRet.toJsonString());
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

    var selectRet = qurantineMonitorDb->select(SELECT_RESPONSIBLE_PERSON_INFO, ResponsiblePerson, receiverId);

    json jsonConversionRet = ();
    if (selectRet is table<record{}>) {
        jsonConversionRet = jsonutils:fromTable(selectRet);
        log:printInfo("Responsible person info JSON: " + jsonConversionRet.toJsonString());
    } else {
        log:printInfo("Select person info from device_info table failed: " + <string>selectRet.detail()?.message);
    }
    
    return jsonConversionRet;
}

type DeviceInfo record {|
    string device_id;
    boolean is_person_present;
    string name;
    string address;
    int missing_count;
|};

public function getReceiverBindedInfo(string receiverId) returns json[] {

    var selectRet = qurantineMonitorDb->select(SELECT_RECEIVER_BINDED_INFO, DeviceInfo, receiverId);

    json jsonConversionRet = ();
    if (selectRet is table<record{}>) {
        jsonConversionRet = jsonutils:fromTable(selectRet);
        log:printInfo("Reveiver binded info JSON: " + jsonConversionRet.toJsonString());
    } else {
        log:printInfo("Select receiver binded info from device_info table failed: " + <string>selectRet.detail()?.message);
    }
    
    return <json[]> jsonConversionRet;
}

public function updateMissingCount(map<int> missingCount) returns boolean {
    var returned = qurantineMonitorDb->update(createMissingCountString(missingCount));

    if (returned is jdbc:UpdateResult) {
        log:printInfo("Missing counts are updated successfully.");
        return true;
    } else {
        log:printInfo(FAILED + <string>returned.detail()?.message);
    }
    return false;

}

public function createMissingCountString(map<int> missingCount) returns string {
    string updateQuery = "UPDATE quarantine_monitor.device_info SET missing_count = CASE device_id ";
    string ids = "";

    int l = missingCount.length();
    int i = 0;
    foreach var [k,v] in missingCount.entries() {
        updateQuery = updateQuery.concat(" WHEN '" + k + "' THEN '" + v.toString() + "' ");
        ids = ids.concat("'" + k + "'");
        if (i != l - 1) {
            ids = ids.concat(",");
        }
        i = i + 1;
    }

    updateQuery = updateQuery.concat(" END WHERE device_id IN( ");
    updateQuery = updateQuery.concat(ids);
    updateQuery = updateQuery.concat(");");
    log:printInfo("Missing counts update query : " + updateQuery);
    return updateQuery;
}

type MissingStatus record {
    string device_id;
    string name;
    string address;
    boolean is_missing;
};

public function getMissingCountPerPerson() returns json {

    var selectRet = qurantineMonitorDb->select(SELECT_MISSING_COUNT, MissingStatus);

    json jsonConversionRet = ();
    if (selectRet is table<record{}>) {
        jsonConversionRet = jsonutils:fromTable(selectRet);
        log:printInfo("Device ids JSON: " + jsonConversionRet.toJsonString());
    } else {
        log:printInfo("Select device ids from device_info table failed: " + <string>selectRet.detail()?.message);
    }
    
    return jsonConversionRet; 
}

type LoginResult record {
    int user_id;
    string username;
    string fullname;
};

public function getResponsiblePersonInfoForLogin(string username, string password) returns json {

    var selectRet = qurantineMonitorDb->select(SELECT_RESPONSIBLE_PERSON_INFO_FOR_LOGIN, LoginResult, username, password);

    json jsonConversionRet = ();
    if (selectRet is table<record{}>) {
        jsonConversionRet = jsonutils:fromTable(selectRet);
        log:printInfo("Login results JSON: " + jsonConversionRet.toJsonString());
    } else {
        log:printInfo("Select login results from responsible_person_info table failed: " + <string>selectRet.detail()?.message);
    }
    
    return jsonConversionRet; 
}
