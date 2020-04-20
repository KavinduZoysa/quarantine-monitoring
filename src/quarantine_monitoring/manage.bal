import ballerina/log;

public function checkDb() returns boolean {
    return checkDbConnectivity();
}

public function addDeviceInfo(json info) returns boolean {
    return addDeviceInfoToTable(info.device_id.toString(), info.mac_address.toString());
}

@deprecated
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

public function manageNotification_v1(json receiverInfo) returns boolean {

    string receiverId = "";
    if (receiverInfo.receiver_id is string) {
        receiverId = <string> receiverInfo.receiver_id;
    }
    if (receiverId == "") {
        return false;
    }

    map<int> deviceInfoFromReceiver = {};
    if (receiverInfo.devices is json) {
        deviceInfoFromReceiver = exatractMacAddresses1(<json[]> receiverInfo.devices);
    }

    json deviceIds = getDeviceIds(receiverId);
    map<string> deviceInfoFromDb = exatractMacAddresses2(<json[]>deviceIds);
    string[] missingIds = compareMacAddressses(deviceInfoFromDb, deviceInfoFromReceiver);

    if (missingIds.length() == 0) {
        return true;
    }

    foreach var deviceId in missingIds {
        json[] person = <json[]>getPersonInfo(deviceId);
        json personInfo = person[0];
        boolean isPersonPresent = false;
        if (personInfo.is_person_present is boolean) {
            isPersonPresent = <boolean> personInfo.is_person_present;
        } 

        if (!isPersonPresent) {
            log:printError("Person is not available for device id : " + deviceId);
            return false;
        }
        log:printInfo("Quarantine rules are violated by " + personInfo.name.toString());

        json[] responsiblePerson = <json[]>getResponsiblePersonInfo(receiverId);
        if (responsiblePerson[0] is ()) {
            log:printError("Responsible person is not assigned for receiver id : " + receiverId);
            return false;
        }

        if (!sendNotification(responsiblePerson[0].phone_number.toString(), personInfo.name.toString(), personInfo.address.toString())) {
            log:printError("Error in sending notification.");
            return false;
        }
    }
    return true;
}

public function exatractMacAddresses1(json[] macAddresses) returns map<int> {
    map<int> m = {};
    foreach var macAddress in macAddresses {
        m[<string>macAddress.mac_address] = <int>macAddress.rssi;
    }
    return m;
}

public function exatractMacAddresses2(json[] devices) returns map<string> {
    map<string> m = {};
    foreach var device in devices {
        m[<string>device.mac_address] = <string>device.device_id;
    }
    return m;
}

public function compareMacAddressses(map<string> deviceInfoFromDb, map<int> deviceInfoFromReceiver) returns string[] {
    string[] missingDeviceIds = [];
    int i = 0;
    foreach var [k, v] in deviceInfoFromDb.entries() {
        if (!deviceInfoFromReceiver.hasKey(k)) {
            missingDeviceIds[i] = v;
            i = i+1;
        }
    }
    return missingDeviceIds;
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