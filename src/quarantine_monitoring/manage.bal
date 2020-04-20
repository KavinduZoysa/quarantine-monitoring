import ballerina/log;

public function checkDb() returns boolean {
    return checkDbConnectivity();
}

public function addDeviceInfo(json info) returns boolean {
    return addDeviceInfoToTable(info.device_id.toString(), info.mac_address.toString());
}

public function manageNotification(string receiverId, string deviceId) returns boolean {
    if (deviceId == "-1") { 
        return true;
    }
    log:printInfo("Quarantine rules violation is detected.");

    json[] person = <json[]>getPersonInfo(deviceId);
    boolean isPersonPresent = false;
    if (person[0].is_person_present is boolean) {
        isPersonPresent = <boolean> person[0].is_person_present;
    } 

    if (!isPersonPresent) {
        log:printError("Person is not available for device id : " + deviceId);
        return false;
    }
    log:printInfo("Quarantine rules are violated by " + person[0].name.toString());

    json[] responsiblePerson = <json[]>getResponsiblePersonInfo(receiverId);
    if (responsiblePerson[0] is ()) {
        log:printError("Responsible person is not assigned for receiver id : " + receiverId);
        return false;
    }

    if (!sendNotification(responsiblePerson[0].phone_number.toString(), person[0].name.toString(), person[0].address.toString())) {
        log:printError("Error in sending notification.");
        return false;
    }
    return true;
}

public function addResponsiblePerson(json info) returns boolean {
    return addResponsiblePersonInfo(info.receiver_id.toString(),
                                    info.name.toString(),
                                    info.address.toString(),
                                    info.phone_number.toString());
}

public function addPersonInfo(json info) returns boolean {
    int age = 0;
    if (info.age is int) {
        age = <int> info.age;
    }
    boolean isPersonPresent = false;
    if (info.is_person_present is boolean) {
        isPersonPresent = <boolean> info.is_person_present;
    }

    return updateDeviceInfo(isPersonPresent,
                            info.name.toString(),
                            info.address.toString(),
                            age,
                            info.receiver_id.toString(),
                            info.device_id.toString());
}

public function getDeviceIds(string receiverId) returns json {
    return getDeviceIdsFromDb(receiverId);
}

public function populateTables() returns boolean {
    return createTables();
}