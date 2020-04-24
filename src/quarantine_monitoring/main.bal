import ballerina/http;
import ballerina/log;

@http:ServiceConfig {
    basePath: "/quarantine-monitor"
}
service quarantineMonitor on new http:Listener(9090) {

    @http:ResourceConfig {
        methods: ["POST"],
        path: "/login"
    }
    resource function logIn(http:Caller caller, http:Request req) {
        http:Response res = new;

        var payload = req.getJsonPayload();

        if (payload is json) {            
            res.setJsonPayload(<@untainted>getLoginInfo(payload));
        } else {
            res.statusCode = 500;
            res.setPayload(<@untainted string>payload.detail()?.message);
            log:printError(ERROR_INVALID_FORMAT);
        }

        respondClient(caller, res);
    }

    @http:ResourceConfig {
        methods: ["POST"],
        path: "/signup"
    }
    resource function signUp(http:Caller caller, http:Request req) {
        http:Response res = new;

        var payload = req.getJsonPayload();

        if (payload is json) {
            json responseJson = {
                "success" : signUp(payload)
            };
            res.setJsonPayload(<@untainted>responseJson);
        } else {
            res.statusCode = 500;
            res.setPayload(<@untainted string>payload.detail()?.message);
            log:printError(ERROR_INVALID_FORMAT);
        }

        respondClient(caller, res);
    }

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

        respondClient(caller, res);
    }

    @http:ResourceConfig {
        methods: ["POST"],
        path: "/remove-person"
    }
    resource function removePerson(http:Caller caller, http:Request req) {
        http:Response res = new;

        var payload = req.getJsonPayload();

        if (payload is json) {
            if (!removePerson(payload)) {
                res.statusCode = 500;
                res.setPayload("Error in deleting person");                
            } 
        } else {
            res.statusCode = 500;
            res.setPayload(<@untainted string>payload.detail()?.message);
            log:printError(ERROR_INVALID_FORMAT);
        }

        respondClient(caller, res);
    }

    @http:ResourceConfig {
        methods: ["GET"],
        path: "/get-missing-count"
    }
    resource function getMissingCount(http:Caller caller, http:Request req) {

        http:Response res = new;

        json missingCount = getMissingCount();
        if (missingCount is ()) {
            res.statusCode = 500;
            res.setPayload("Cannot get device ids"); 
        } else {
            res.setJsonPayload(<@untainted>missingCount);
        }

        respondClient(caller, res);
    }

    @http:ResourceConfig {
        methods: ["POST"],
        path: "/notify"
    }
    resource function notifyDeviceInfo(http:Caller caller, http:Request req) {

        http:Response res = new;

        var payload = req.getJsonPayload();
        if (payload is json) {
            if (!manageNotification(payload)) {
                res.statusCode = 500;
                res.setPayload("Error in sending notification");                
            } 
        } else {
            res.statusCode = 500;
            res.setPayload(<@untainted string>payload.detail()?.message);
            log:printError(ERROR_INVALID_FORMAT);
        }

        respondClient(caller, res);
    }

    @http:ResourceConfig {
        methods: ["POST"],
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

        respondClient(caller, res);
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
            log:printError(ERROR_INVALID_FORMAT);
        }

        respondClient(caller, res);
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
            log:printError(ERROR_INVALID_FORMAT);
        }

        respondClient(caller, res);
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

        respondClient(caller, res);
    }

}

public function respondClient(http:Caller caller, http:Response res) {
    var result = caller->respond(res);
    if (result is error) {
        log:printError(ERROR_IN_RESPONDING, result);
    }       
}
