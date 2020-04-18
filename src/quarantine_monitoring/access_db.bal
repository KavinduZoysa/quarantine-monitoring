import ballerinax/java.jdbc;
import ballerina/log;
import ballerina/time;

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
        return true;
    } else {
        log:printInfo("failed: " + <string>returned.detail()?.message);
        // return false;
    }

    log:printInfo("Cannot create the table `device_info`");
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
