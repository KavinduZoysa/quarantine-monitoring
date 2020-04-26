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

    map<json> mapOfDeviceInfo = createMap(receiverBindedInfo);
    map<int> missingCount = {};
    foreach var missingDeviceId in missingDeviceIds {
        string missingId = <string>missingDeviceId;
        if (mapOfDeviceInfo.hasKey(missingId)) {
            json deviceInfo = mapOfDeviceInfo[missingId];
            int i = <int>deviceInfo.missing_count;
            i = i + 1;
            if (i >= 20) {
                notify(missingId, receiverId, responsiblePersonInfo);
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

public function notify(string deviceId, string receiverId, json[] responsiblePersonInfo) {
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

    foreach var responsiblePerson in responsiblePersonInfo {
        if (!sendNotification(responsiblePerson.phone_number.toString(), 
                              personInfo.name.toString(), 
                              personInfo.address.toString())) {
            log:printError("Error in sending notification to : " + personInfo.name.toString());
        }
    }
    return;
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
        boolean isUpdated = updateDeviceInfo(person, 
                                             true, 
                                             person.name.toString(), 
                                             address, 
                                             age, 
                                             person.gender.toString(), 
                                             person.receiver_id.toString(), 
                                             person.becon_id.toString());
        if (!isUpdated) {
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
    return addResponsiblePerson(info,
                                info.username.toString(),
                                info.password.toString(),
                                info.fullname.toString(),
                                info.phone_number.toString());
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
    return deletePersonEntry(personInfo.device_id.toString());
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