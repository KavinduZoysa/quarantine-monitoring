import ballerina/time;
import ballerinax/java.jdbc;
import ballerina/http;
import ballerina/log;

jdbc:Client testDB = new ({
    url: "jdbc:mysql://localhost:3306/testdb",
    username: "root",
    password: "root",
    dbOptions: {useSSL: false}
});

type Student record {
    int id;
    int age;
    string name;
    time:Time insertedTime;
};

@http:ServiceConfig {
    basePath: "/quarantine-monitor"
}
service quarantineMonitor on new http:Listener(9090) {

    @http:ResourceConfig {
        methods: ["POST"],
        path: "/add-person-info"
    }
    resource function addPersonInfo(http:Caller caller, http:Request req) {

        var payload = req.getJsonPayload();
        http:Response res = new;

        if (payload is json) {
            if (!addPersonInfo(payload)) {
                res.statusCode = 500;
                res.setPayload("Cannot add person information");                
            } 
        } else {
            res.statusCode = 500;
            res.setPayload(<@untainted string>payload.detail()?.message);
            log:printError("Invalid format in request body");
        }

        var result = caller->respond(res);
        if (result is error) {
           log:printError("Error in responding", result);
        }
    }

    @http:ResourceConfig {
        methods: ["POST"],
        path: "/add-device-info"
    }
    resource function addDeviceInfo(http:Caller caller, http:Request req) {

        var payload = req.getJsonPayload();
        http:Response res = new;

        if (payload is json) {
            if (!addDeviceInfo(payload)) {
                res.statusCode = 500;
                res.setPayload("Cannot update tables");                
            } 
        } else {
            res.statusCode = 500;
            res.setPayload(<@untainted string>payload.detail()?.message);
            log:printError("Invalid format in request body");
        }

        var result = caller->respond(res);
        if (result is error) {
           log:printError("Error in responding", result);
        }
    }

    @http:ResourceConfig {
        methods: ["GET"],
        path: "populate-tables"
    }
    resource function populateTables(http:Caller caller, http:Request req) {
        
        http:Response res = new;
        if (!populateTables()) {
            res.statusCode = 500;
            res.setPayload("Cannot create tables");
        }

        var result = caller->respond(res);
        if (result is error) {
           log:printError("Error in responding", result);
        }
    }
}
