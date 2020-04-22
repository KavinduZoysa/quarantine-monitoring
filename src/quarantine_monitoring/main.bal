import ballerina/http;
import ballerina/log;

@http:ServiceConfig {
    basePath: "/quarantine-monitor"
}
service quarantineMonitor on new http:Listener(9090) {

    @http:ResourceConfig {
        methods: ["GET"],
        path: "/health-check"
    }
    resource function healthCheck(http:Caller caller, http:Request req) {
        http:Response res = new;

        json responseJson = {
            "server": true,
            "database": checkDb()
        };
        res.setJsonPayload(<@untainted>responseJson);

        var result = caller->respond(res);
        if (result is error) {
           log:printError("Error in responding", result);
        }
    }

    @http:ResourceConfig {
        methods: ["POST"],
        path: "/add-responsible-person-info"
    }
    resource function addResponsiblePersonInfo(http:Caller caller, http:Request req) {

        var payload = req.getJsonPayload();
        http:Response res = new;

        if (payload is json) {
            if (!addResponsiblePerson(payload)) {
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
        path: "/notify"
    }
    resource function notifyDeviceInfo(http:Caller caller, http:Request req) {

        http:Response res = new;

        var payload = req.getJsonPayload();
        if (payload is json) {
            if (!manageNotification_v2(payload)) {
                res.statusCode = 500;
                res.setPayload("Error in sending notification");                
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
        path: "/get-device-ids/{reveicerId}"
    }
    resource function getDeviceInfo(http:Caller caller, http:Request req, string reveicerId) {

        http:Response res = new;

        json deviceIds = getDeviceIds(reveicerId);
        if (deviceIds is ()) {
            res.statusCode = 500;
            res.setPayload("Cannot get device ids"); 
        } else {
            res.setJsonPayload(<@untainted>deviceIds);
        }

        var result = caller->respond(res);
        if (result is error) {
           log:printError("Error in responding", result);
        }
    }

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
