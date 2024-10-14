import ballerina/http;
import ballerina/sql;
import ballerinax/mysql;
import ballerinax/mysql.driver as _;
import ballerinax/googleapis.gcalendar;
import ballerina/io;
//import ballerina/io;
// import ballerina/uuid;


type BookingNew record {|
int session_id;
int student_id;
string booking_status;
|};

type Book record {|
int booking_id;
int session_id;
int student_id;
string booking_status;
|};

type SessionNew record {|
int session_id;
int teacher_id;
string subject;
string grade;
string start_time;
string end_time;
string timezone;
string event_id;
|};

type SessionBook record {|
int teacher_id;
string subject;
string grade;
string start_time;
string end_time;
string timezone;
|};


service /session on new http:Listener(8080) {


    private final mysql:Client db;
    private final gcalendar:Client calendar;
    private string calendarId = "";

    // Constructor to initialize db and calendar
    function init() returns error? {
        // Initialize MySQL client
        self.db = check new (host = "localhost", user = "root", password = "Asdf1234@", database = "tutoring", port = 3306);
    }


    resource function get sessions() returns SessionNew[]|error {
        stream<SessionNew, sql:Error?> Stream = self.db->query(`SELECT * FROM tutoring.lectures; `);
        return from SessionNew s in Stream
            select s;
    }

    resource function get session/[int session_id]() returns SessionNew|http:NotFound {
        SessionNew|error session = self.db->queryRow(`SELECT * FROM tutoring.lectures WHERE session_id = ${session_id}`);
        
        return session is SessionNew ? session : http:NOT_FOUND;
    }

     resource function get teacher/[int tutor_id]() returns SessionNew|http:NotFound {
        SessionNew|error session = self.db->queryRow(`SELECT * FROM tutoring.lectures WHERE teacher_id = ${tutor_id}`);
        
        return session is SessionNew ? session : http:NOT_FOUND;
    }

    resource function post create(SessionBook booking) returns SessionNew|error {
        string event_id = "";
        event_id = check createEventByPost(booking, "pabadhihsli@gmail.com");//need to get teachers email 
        _=check self.db->execute(`INSERT INTO tutoring.lectures (teacher_id, subject,grade, start_time, end_time, timezone, event_id)
VALUES (${booking.teacher_id}, ${booking.subject}, ${booking.grade}, ${booking.start_time}, ${booking.end_time}, ${booking.timezone},${event_id});`);
        SessionNew|error session = self.db->queryRow(`SELECT * FROM tutoring.lectures WHERE session_id = (SELECT MAX(session_id) FROM tutoring.lectures);`);
        return check session;    
    }

    resource function post book(BookingNew booking) returns Book|error {
        _=check self.db->execute(`INSERT INTO tutoring.bookings (session_id, student_id, booking_status)
VALUES (${booking.session_id}, ${booking.student_id}, ${booking.booking_status});`);
        return check self.db->queryRow(`SELECT * FROM tutoring.bookings WHERE booking_id = (SELECT MAX(booking_id) FROM tutoring.bookings);`);
        
    }

    resource function delete cancel/[int session_id]() returns http:NoContent|error {
         _ = check self.db->execute(`DELETE FROM tutoring.bookings WHERE session_id = ${session_id};`);
        return http:NO_CONTENT;
    }

    resource function put session/confirm/[int session_id]() returns Book|error {
        _=check self.db->execute(`UPDATE tutoring.bookings SET booking_status = 'confirmed' WHERE session_id = ${session_id};`);
        SessionNew session = check self.db->queryRow(`SELECT * FROM tutoring.lectures WHERE session_id = ${session_id}`);  
       if (session is SessionNew) {
            
            io:println("yes");
            _= check addStudent(session,"vidulaliyanage2005@gmail.com","pabadhihsli@gmail.com");//need to get students email
        }
        
       // _= check addStudent(session,"vidulaliyanage2005@gmail.com","pabadhihsli@gmail.com");//need to get students email
        return check self.db->queryRow(`SELECT * FROM tutoring.bookings WHERE session_id = ${session_id};`);
    }

}
