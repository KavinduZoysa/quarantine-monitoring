import ballerina/log;

public function checkDb() returns boolean {
    return checkDbConnectivity();
}

public function addDeviceInfo(json info) returns boolean {
    return addDeviceInfoToTable(info.device_id.toString(), info.mac_address.toString());
}

public function manageNotification(json receiverInfo) returns boolean {
    string receiverId = "";
    if (receiverInfo.receiver_id is string) {
        receiverId = <string> receiverInfo.receiver_id;
    }
    log:printInfo("RECEIVER ID : " + receiverId);

    json[] missingDeviceIds = [];
    if (receiverInfo.missing_ids is json[]) {
        missingDeviceIds = <json[]> receiverInfo.missing_ids;
    }

    json[] receiverBindedInfo = getReceiverBindedInfo(receiverId);

    map<json> mapOfDeviceInfo = createMap(receiverBindedInfo);
    map<int> missingCount = {};
    foreach var missingDeviceId in missingDeviceIds {
        string missingId = <string>missingDeviceId;
        if (mapOfDeviceInfo.hasKey(missingId)) {
            json deviceInfo = mapOfDeviceInfo[missingId];
            int i = <int>deviceInfo.missing_count;
            i = i + 1;
            if (i >= 20) {
                notify(missingId, receiverId);
            }
            missingCount[missingId] = i;
            json remove = mapOfDeviceInfo.remove(missingId);
        }
    }

    foreach var [k, v] in mapOfDeviceInfo.entries() {
        missingCount[<string>k] = 0;
    }

    return updateMissingCount(missingCount);
}

public function notify(string deviceId, string receiverId) {
    json[] person = <json[]>getPersonInfo(deviceId);
    json personInfo = person[0];
    boolean isPersonPresent = false;
    if (personInfo.is_person_present is boolean) {
        isPersonPresent = <boolean> personInfo.is_person_present;
    } 

    if (!isPersonPresent) {
        log:printError("Person is not available for device id : " + deviceId);
        return;
    }
    log:printInfo("Quarantine rules are violated by " + personInfo.name.toString());

    json[] responsiblePerson = <json[]>getResponsiblePersonInfo(receiverId);
    if (responsiblePerson[0] is ()) {
        log:printError("Responsible person is not assigned for receiver id : " + receiverId);
        return;
    }

    if (sendNotification(responsiblePerson[0].phone_number.toString(), personInfo.name.toString(), personInfo.address.toString())) {
        return;
    }
    log:printError("Error in sending notification.");
    return;
}

public function createMap(json[] receiverBindedInfo) returns map<json> {
    map<json> m = {};
    foreach var deviceInfo in receiverBindedInfo {
        m[<string> deviceInfo.device_id] = deviceInfo;
    }
    return m;
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

public function getMissingCount() returns json {
    return getMissingCountPerPerson();
}

public function populateTables() returns boolean {
    return createTables();
}