import ballerina/io;

type User record {|
    int id;
    string name;
|};

type Login record {|
    int userId;
    string time;
|};

public function main() {
    User[] users = [
        {id: 1234, name: "Keith"},
        {id: 6789, name: "Anne"}
    ];

    Login[] logins = [
        {userId: 6789, time: "20:10:23"},
        {userId: 1234, time: "10:30:02"},
        {userId: 3987, time: "12:05:00"}
    ];

    // Inner equijoin.
    string[] joinResult = from var login in logins
        join var user in users
                        on login.userId equals user.id
        select string `${user.name} : ${login.time}`;

    io:println(joinResult);

}

// Login[] $streamElement $_0 = <Login[]>logins;
// handle $streamElement $_1 = createPipeline();
// handle $streamElement $_2 = createInputFunction();
//  addStreamFunction() ;

// User[] $streamElement $_3 = <User[]>users;
// handle $streamElement $_4 = createPipeline();
// handle $streamElement $_5 = createInputFunction();
//  addStreamFunction() ;

// handle $streamElement $_6 = createInnerJoinFunction();
//  addStreamFunction() ;

// handle $streamElement $_7 = createSelectFunction();
//  addStreamFunction() ;

// handle $streamElement $_8 = getStreamFromPipeline();
// (ballerina / lang.query:0.0 .0 : Type [] | error)$streamElement $_9 = toArray();
// if ($streamElement $_9 is ballerina / lang.query:0.0 .0 : QueryErrorTypes ) $streamElement $_9 = getQueryErrorRootCause()