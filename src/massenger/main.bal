import ballerina/io;
import ballerinax/twilio;

const ACCOUNT_SID = "AC59481c60745b7e78d2f746b7dba366c1";
const AUTH_TOKEN = "72ddfe7c8bb76749ba796cec3847d5f6";
const AUTHY_API_KEY = "";

const fromNumber = "+12064880329";
const toNumber = "+94710630867";

twilio:TwilioConfiguration twilioConfig = {
    accountSId: ACCOUNT_SID,
    authToken: AUTH_TOKEN,
    xAuthyKey: AUTHY_API_KEY
};

twilio:Client twilioClient = new(twilioConfig);

public function main() {
    var details = twilioClient->sendSms(fromNumber, toNumber, "test message");
    if (details is  twilio:SmsResponse) {
    // If successful, print SMS Details.
        io:println("SMS Details: ", details);
    } else {
    // If unsuccessful, print the error returned.
    io:println("Error: ", details);
    }
}
