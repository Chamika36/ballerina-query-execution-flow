import ballerina/io;

public function main() returns error? {
    var orders = [
        {orderId: 1, itemName: "A", price: 23.4, quantity: 2},
        {orderId: 1, itemName: "B", price: 20.4, quantity: 1},
        {orderId: 2, itemName: "C", price: 21.5, quantity: 3},
        {orderId: 1, itemName: "D", price: 21.5, quantity: 3}
    ];

    var items = from var {orderId, itemName} in orders
        group by orderId
        select [itemName];

    io:println(items);
}

// 1 = {BLangSimpleVariableDef@5214} "handle $streamElement$_1 = createPipeline()"
// 2 = {BLangSimpleVariableDef@5215} "handle $streamElement$_2 = createInputFunction()"
// 3 = {BLangExpressionStmt@5216} "addStreamFunction()"
// 4 = {BLangSimpleVariableDef@5217} "handle $streamElement$_3 = createGroupByFunction()"
// 5 = {BLangExpressionStmt@5218} "addStreamFunction()"
// 6 = {BLangSimpleVariableDef@5219} "handle $streamElement$_4 = createSelectFunction()"
// 7 = {BLangExpressionStmt@5220} "addStreamFunction()"
// 8 = {BLangSimpleVariableDef@5221} "handle $streamElement$_5 = getStreamFromPipeline()"
// 9 = {BLangSimpleVariableDef@5222} "(ballerina/lang.query:0.0.0:Type[]|error) $streamElement$_6 = toArray()"
// 10 = {BLangIf@5223} "if ($streamElement$_6 is ballerina/lang.query:0.0.0:QueryErrorTypes) $streamElement$_6 = getQueryErrorRootCause()"