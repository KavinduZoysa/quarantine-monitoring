import ballerina/http;
import ballerina/log;

@http:ServiceConfig {
    basePath: "/quarantine-monitor",
    cors: {
        allowOrigins: ["*"]
    }
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
        methods: ["POST"],
        path: "/add-receiver-info"
    }
    resource function addReceiverInfo(http:Caller caller, http:Request req) {
        http:Response res = new;

        var payload = req.getJsonPayload();

        if (payload is json) {
            json responseJson = {
                "success" : addReceiverInfo(payload)
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
            json response = {
                success: removePerson(payload)
            };
            res.setJsonPayload(response);
        } else {
            res.statusCode = 500;
            res.setPayload(<@untainted string>payload.detail()?.message);
            log:printError(ERROR_INVALID_FORMAT);
        }

        respondClient(caller, res);
    }

    @http:ResourceConfig {
        methods: ["POST"],
        path: "/remove-receiver"
    }
    resource function removeReceiver(http:Caller caller, http:Request req) {
        http:Response res = new;

        var payload = req.getJsonPayload();

        if (payload is json) { 
            json response = {
                success: removeReceiver(payload)
            };
            res.setJsonPayload(response);
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
        log:printInfo("Notify request : " + payload.toString());
        if (payload is json) {
            json response = {
                success: manageNotification(payload)
            };
            res.setJsonPayload(response); 
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
        methods: ["GET"],
        path: "/get-persons-status/{phiId}"
    }
    resource function getPersonsStatus(http:Caller caller, http:Request req, string phiId) {

        http:Response res = new;

        json personsInfo = getPersonsStatus(phiId);
        json payLoad = {};
        if !(personsInfo is ()) {
            payLoad = {
                "success": true,
                "result": personsInfo
            };
            res.setJsonPayload(payLoad);
        } else {
            payLoad = {
                "success": false
            };
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
            json responseJson = {
                "success" : addPersonInfo(payload)
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

    @http:ResourceConfig {
        methods: ["POST"],
        path: "/add-responsible-person"
    }
    resource function addResponsiblePerson(http:Caller caller, http:Request req) {

        var payload = req.getJsonPayload();
        http:Response res = new;

        if (payload is json) {
            if (!addResponsiblePerson(payload)) {
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
        methods: ["POST"],
        path: "/remove-responsible-person"
    }
    resource function removeResponsiblePerson(http:Caller caller, http:Request req) {

        var payload = req.getJsonPayload();
        http:Response res = new;

        if (payload is json) {
            if (!removeResponsiblePerson(payload)) {
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

}

public function respondClient(http:Caller caller, http:Response res) {
    var result = caller->respond(res);
    if (result is error) {
        log:printError(ERROR_IN_RESPONDING, result);
    }       
}
