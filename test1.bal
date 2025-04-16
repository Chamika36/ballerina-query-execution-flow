import ballerina/io;
 
public function main() {
    int[] nums = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10];
 
    int[] numsTimes10 = from var i in nums
                        where i > 2
                        limit 3
                        order by i descending
                        select i * 10;

    io:println(numsTimes10);
}

// int[] $streamElement $_0 = <int[]>nums;
// handle $streamElement $_1 = createPipeline();
// handle $streamElement $_2 = createInputFunction();
//  addStreamFunction();

// handle $streamElement $_3 = createFilterFunction();
//  addStreamFunction();

// handle $streamElement $_4 = createLimitFunction();
//  addStreamFunction();

// handle $streamElement $_5 = createOrderByFunction();
//  addStreamFunction();

// handle $streamElement $_6 = createSelectFunction();
//  addStreamFunction();

// handle $streamElement $_7 = getStreamFromPipeline();

// (ballerina / lang.query:0.0 .0 : Type [] | error)$streamElement $_8 = toArray();

// if ($streamElement $_8 is ballerina / lang.query:0.0 .0 : QueryErrorTypes ) $streamElement $_8 = getQueryErrorRootCause()
