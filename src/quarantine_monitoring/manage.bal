// import ballerina/log;

public function addDeviceInfo(json info) returns boolean {
    return addDeviceInfoToTable(info.device_id.toString(), info.mac_address.toString());
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