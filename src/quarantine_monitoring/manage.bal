import ballerina/log;

public function addDeviceInfo(json info) returns boolean {
    return addDeviceInfoToTable(info.device_id.toString(), info.mac_address.toString());
}

public function manageNotification(string receiverId, string deviceId) returns boolean {
    if (deviceId == "-1") { 
        return true;
    }
    log:printInfo("Quarantine rules violation is detected.");

    json person = getPersonInfo(deviceId);
    boolean isPersonPresent = false;
    if (person.is_person_present is boolean) {
        isPersonPresent = <boolean> person.is_person_present;
    } else if (person.is_person_present is string) {
        log:printInfo("YYYYYYYYYYYYYYYYYYYYY");
    } else {
        log:printInfo((person.is_person_present).toString());
    }

    if (!isPersonPresent) {
        log:printError("Person is not available for device id : " + deviceId);
        return false;
    }
    log:printInfo("Quarantine rules are violated by " + person.name.toString());

    json responsiblePerson = getResponsiblePersonInfo(receiverId);
    if (responsiblePerson is ()) {
        log:printError("Responsible person is not assigned for receiver id : " + receiverId);
        return false;
    }

    if (!sendNotification(responsiblePerson.phone_number.toString(), person.name.toString(), person.address.toString())) {
        log:printError("Error in sending notification.");
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