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