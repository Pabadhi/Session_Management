import ballerinax/googleapis.gcalendar;
import ballerina/io;
import ballerina/uuid;

configurable string clientId = ?;
configurable string clientSecret = ?;
configurable string refreshToken = ?;
configurable string email = ?;



gcalendar:ConnectionConfig config = {
   auth: {
       clientId,
       clientSecret,
       refreshToken
   }
};

gcalendar:Client calendar ;

string calendarId = "";

function createCalendar(gcalendar:Client calendar)returns gcalendar:Calendar|error? {
    gcalendar:Calendar calendarResult = check calendar->/calendars.post({
       summary: "Session Schedule"
   });
    return calendarResult;
}

function createEvent(gcalendar:Client calendar, string calendarId, SessionBook session,gcalendar:EventAttendee[] eventAttendees) returns gcalendar:Event|error {
    string uuid1String = uuid:createType1AsString();
    gcalendar:Event event = check calendar->/calendars/[calendarId]/events.post(
   payload =
       {
       'start: {
           dateTime: session.start_time,//'2024-02-22T11:00:00+00:00'
           timeZone: session.timezone
       },
       end: {
           dateTime: session.end_time,
           timeZone: session.timezone
       },
       summary: session.subject+" - "+session.grade,
       attendees: eventAttendees,
       conferenceData: {
           createRequest: {
               requestId: uuid1String,
               conferenceSolutionKey: {
                   'type: "hangoutsMeet"
               }
           }
       }
   },
   conferenceDataVersion = 1
);
    return event;
}

function addStudent(SessionNew session, string student_email,string teacher_email) returns error? {
    gcalendar:EventAttendee[] eventAttendees = [{email:student_email},{email:teacher_email}];
    gcalendar:Event updatedEvent = check calendar->/calendars/[calendarId]/events/[session.event_id].put({
        "start": {
            "dateTime": session.start_time,
            "timeZone": session.timezone
        },
        "end": {
            "dateTime": session.end_time,
            "timeZone": session.timezone
        },
        "summary":session.subject+" - "+session.grade,
        "attendees": eventAttendees
    });
    io:println("Updated Event: ", updatedEvent);
  
}

function init() returns error? {
    calendar = check new (config);
//     gcalendar:Calendar calendarResult = check calendar->/calendars.post({
//        summary: "Session Schedule"
//    });
//     calendarId = <string>calendarResult.id;
    calendarId="e169cd2bbd48507bb167642ef7a657ea84c8e816a9edce011a6e5bce2f2dd361@group.calendar.google.com";
    return ();
}
function createEventByPost(SessionBook session, string teacher_email) returns string|error {
    gcalendar:EventAttendee[] eventAttendees = [{email:teacher_email}];
    gcalendar:Event event = check createEvent(calendar,calendarId,session,eventAttendees);
    
    return <string>event.id;
}
public function main() returns error? {
    //gcalendar:EventAttendee[] eventAttendees = [{email:"pabadhihsli@gmail.com"},{email:"vidulaliyanage2005@gmail.com"}];
    // gcalendar:Event updatedEvent = check calendar->/calendars/[calendarId]/events/["hbsfdk2rqbshjdkmu77574tau4"].put({
    //     "start": {
    //         "dateTime": "2024-10-22T15:30:00.0",
    //         "timeZone": "UTC"
    //     },
    //     "end": {
    //         "dateTime": "2024-10-22T16:30:00.0",
    //         "timeZone": "UTC"
    //     },
    //     "summary": "Project Progress Meeting - Test",
    //     "attendees": eventAttendees
    // });

    //io:println("Updated Event: ", updatedEvent);

}