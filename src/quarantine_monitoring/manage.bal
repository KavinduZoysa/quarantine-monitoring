import ballerina/log;

public function checkDb() returns boolean {
    return checkDbConnectivity();
}

public function addDeviceInfo(json info) returns boolean {
    return addDeviceInfoToTable(info, 
                                info.device_id.toString(), 
                                info.mac_address.toString());
}

public function manageNotification(json receiverInfo) returns boolean {
    string receiverId = "";
    if (receiverInfo.receiver_id is string) {
        receiverId = <string> receiverInfo.receiver_id;
    }
    json[] responsiblePersonInfo = getResponsiblePersonInfoFor(receiverId);
    if (responsiblePersonInfo.length() == 0) {
        log:printError("Responsible person is not assigned for receiver id : " + receiverId);
        return false;
    }

    json[] missingDeviceIds = [];
    if (receiverInfo.missing_ids is json[]) {
        missingDeviceIds = <json[]> receiverInfo.missing_ids;
    }

    json[] receiverBindedInfo = getReceiverBindedInfo(receiverId);
    string receiverAddr = receiverBindedInfo[0].address.toString();
    notifyPowerLevel(receiverId, receiverInfo.battery_level, receiverAddr, responsiblePersonInfo);
    notifyMotion(receiverId, receiverInfo.physical_motion, receiverAddr, responsiblePersonInfo);

    map<json> mapOfDeviceInfo = createMap(receiverBindedInfo);
    map<int> missingCount = {};
    foreach var missingDeviceId in missingDeviceIds {
        string missingId = <string>missingDeviceId;
        if (mapOfDeviceInfo.hasKey(missingId)) {
            json deviceInfo = mapOfDeviceInfo[missingId];
            int i = <int>deviceInfo.missing_count;
            i = i + 1;
            if (i >= MAX_MISSING_COUNT) {
                notifyMissingPerson(missingId, receiverId, responsiblePersonInfo);
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

public function getResponsiblePersonInfoFor(string receiverId) returns json[] {
    return <json[]> getResponsiblePersonInfo(receiverId);
}

public function notifyMissingPerson(string deviceId, string receiverId, json[] responsiblePersonInfo) {
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

    string name = personInfo.name.toString();
    string message = name + " has violated the quarantine rules, Punish " + name + " ASAP!";
    foreach var responsiblePerson in responsiblePersonInfo {
        if (!sendNotification(responsiblePerson.phone_number.toString(), message)) {
            log:printError("Error in sending notification to : " + name);
        }
    }
    return;
}

public function notifyPowerLevel(string receiverId, json|error powerLevel, string address, json[] responsiblePersonInfo) {
    int power = 0;
    if (powerLevel is int) {
        power = <int> powerLevel;
    }
    if (power == 0) {
        return;
    }
    string message = "Power is decreasing in receiver " + receiverId + " at " + address + ". Check " + receiverId + " ASAP!";
    foreach var responsiblePerson in responsiblePersonInfo {
        if (!sendNotification(responsiblePerson.phone_number.toString(), message)) {
            log:printError("Error in sending power decreasing notification to : " + receiverId);
        }
    }
}

public function notifyMotion(string receiverId, json|error motionInfo, string address, json[] responsiblePersonInfo) {
    int motion = 0;
    if (motionInfo is int) {
        motion = <int> motionInfo;
    }
    if (motionInfo == 0) {
        return;
    }
    string message = "Motion is detected in receiver " + receiverId + " at " + address + ". Check " + receiverId + " ASAP!";
    foreach var responsiblePerson in responsiblePersonInfo {
        if (!sendNotification(responsiblePerson.phone_number.toString(), message)) {
            log:printError("Error in sending power decreasing notification to : " + receiverId);
        }
    }
}

public function createMap(json[] receiverBindedInfo) returns map<json> {
    map<json> m = {};
    foreach var deviceInfo in receiverBindedInfo {
        m[<string> deviceInfo.device_id] = deviceInfo;
    }
    return m;
}

public function addPersonInfo(json info) returns boolean {

    json[] persons = <json[]> info;

    string address = getAddress(persons[0].receiver_id.toString());
    foreach json person in persons {
        int age = 0;
        if (person.age is int) {
            age = <int> person.age;
        }
        if (!updateDeviceInfo(person,
                              person.name.toString(), 
                              address, 
                              age, 
                              person.gender.toString(), 
                              person.receiver_id.toString(), 
                              person.becon_id.toString())) {
            return false;
        }
    }

    foreach json person in persons {
        if (!updatePersonPresence(person.becon_id.toString(), true)) {
            return false;
        }
    }

    return true;
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

public function signUp(json info) returns boolean {
    return updateResponsiblePerson(info,
                                info.username.toString(),
                                info.password.toString());
}

public function addResponsiblePerson(json info) returns boolean {
    return addResponsiblePersonInfo(info,
                                info.username.toString(),
                                info.name.toString(),
                                info.phone_number.toString());
}

public function removeResponsiblePerson(json info) returns boolean {
    return removeResponsiblePersonInfo(info, 
                                       info.username.toString());
}

public function getLoginInfo(json responsiblePersonInfo) returns json {
    json[] responsiblePersons = getResponsiblePersonInfoForLogin(responsiblePersonInfo.username.toString(), 
                                                                 responsiblePersonInfo.password.toString());

    json responseJson = {};
    if (responsiblePersons.length() == 0) {
        responseJson = {
            "success" : false
        };
    } else {
        responseJson = {
            "success" : true,
            "result" : responsiblePersons[0]
        };
    }
    return responseJson;
}

public function removePerson(json personInfo) returns boolean {
    return updatePersonPresence(personInfo.becon_id.toString(), false);
}

public function removeReceiver(json personInfo) returns boolean {
    return deletePersonsEntry(personInfo.receiver_id.toString());
}

public function addReceiverInfo(json receiverInfo) returns boolean {
    return updateReceiverInfo(receiverInfo.receiver_id.toString(), 
                              receiverInfo.address.toString(), 
                              receiverInfo.user_id.toString());
}

public function getPersonsStatus(string phiId) returns json[] {
    json[] returned = [];

    json[] receiversInfo = getReceiversInfo(phiId);

    int i = 0;
    foreach json receiverInfo in receiversInfo {
        string receiverId = receiverInfo.receiver_id.toString(); 
        returned[i] = {
            "receiver_id": receiverId,
            "address": receiverInfo.address.toString(),
            "persons": getPersonsStatusFor(receiverId)
        };
        i = i + 1;
    }
    return returned;
}