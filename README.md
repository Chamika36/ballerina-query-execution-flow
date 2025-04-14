## 1. Introduction

This task focuses on improving Ballerina query expressions by leveraging Java streams. Currently, Ballerina query expressions are translated (desugared) into a series of Ballerina objects that work together in a pipeline. However, with this improvement we aim to shift this to a Java stream-based implementation, providing a more efficient and streamlined approach.  
We need to explore how Java streams can replace these Ballerina objects. We need to consider the possibilities of using both Ballerina and Java.  
Here’s a simple Ballerina query expression that retrieves names from a list of people who are above the age of 20 (Complex scenarios may be considered later if time permits which involves different types of data like XML and JSON):

```ballerina
Person[] people = [ 
  { name: "Alice", age: 25 }, 
  { name: "Bob", age: 19 }, 
  { name: "Charlie", age: 30 } 
];
string[] names = from Person p in people 
                 where p.age > 20 
                 select p.name;
```
Currently, this expression is translated into Ballerina objects forming a processing pipeline. Which is a huge pipeline of heavy Ballerina objects. If you think from a Java perspective, This is a simple Java stream problem which can be easily done. As the first step, we can rewrite the exact Ballerina objects in Java object and see the performance and then work on translating them to pure Java streams.

## 2. What are Query Expressions?

Query expressions in Ballerina resemble SQL-like syntax and allow data manipulation across collections such as lists, mappings, tables, and streams. Each query expression starts with a `from` clause and ends with a `select` or `collect` clause.  
Example:

```ballerina
Person[] people = [ 
  { name: "Alice", age: 25 }, 
  { name: "Bob", age: 19 }, 
  { name: "Charlie", age: 30 } 
];
string[] names = from Person p in people 
                 where p.age > 20 
                 select p.name;
```

- More examples :  
[Query expressions - The Ballerina programming language](https://ballerina.io/learn/by-example/query-expressions/)
- Specification : [Ballerina Language Specification#QueryExpression](https://ballerina.io/spec/lang/2023R1/#section_6.21)

## 3. Issues with Ballerina Query Expressions

Despite their readability and declarative nature, Ballerina query expressions exhibit the following performance inefficiencies and issues:

- **Longer Execution Times**: Significantly slower than imperative alternatives (foreach loop).
- **Heavy Object Creation**: Each query is translated into multiple Ballerina objects.
- **Debugging Complexity**: Harder to trace through desugared transformations.

## 4. Proposed Solution

To mitigate these performance drawbacks, we transition to a Java Streams-based execution model. This approach processes Ballerina collections using Java's Stream API without relying on Ballerina objects and optimizing query execution.

## 5. Streams API
![unnamed](https://github.com/user-attachments/assets/e5ee1c57-5b81-46e4-a37d-bbae34d3f73d)

- **Creating Streams**: Streams can be created from various sources such as collections, arrays, or even directly from values.
- **Intermediate Operations**: Intermediate operations transform the elements of a stream. Common operations include `filter`, `map`, and `sorted`.
- **Terminal Operations**: Terminal operations produce a result or a side effect, such as `forEach`, `collect`, or `count`.

> [Java Streams: Unlocking Functional Data Processing Power](https://jignect.tech/java-streams-unleashing-the-power-of-functional-data-processing/)

```java
empCountStartWithS = employeesList.stream()
                                   .map(Employee::getName)
                                   .filter(s -> s.startsWith("S"))
                                   .count();
```

## 6. Architecture
![unnamed (2)](https://github.com/user-attachments/assets/b5a21ca9-3bf0-4f9a-86cd-4c85ccdd6749)


- **Complete Architecture Doc**: [[Architecture][Intern Project][Ballerina] Optimizing Ballerina Query Expressions](https://docs.google.com/document/d/11tKKB6WgL3EZMonl-APBKNgoOb5EyVfvVX6EhZ5ie3o/edit?usp=sharing)

### 6.1 Previous Ballerina Implementation

- `QueryDesugar` -> `Helpers.bal` -> `Types.bal`
- Example: https://docs.google.com/document/d/11tKKB6WgL3EZMonl-APBKNgoOb5EyVfvVX6EhZ5ie3o/edit?tab=t.0#bookmark=id.njqhqhl72vzt

### 6.2 New Java Streams Implementation

- The ballerina classes defined in the `types.bal`, will be replaced by the new java streams implementation.
- The helper functions in the `helpers.bal` will call the Java Streams classes defined in the runtime via FFI.
- **Query Desugar**: Continues to generate lambda functions.
- **Helpers.bal**: Invokes Java methods via FFI instead of creating Ballerina objects.
- **Java Stream Classes**: Implements key classes (e.g., `StreamPipeline`, `Frame`, `Clauses`) for optimized query execution.

## 7. Main Classes

### StreamPipeline Class

**Attributes**:

```java
private final Iterator<?> itr;
private Stream<Frame> stream;
private final List<PipelineStage> pipelineStages;
private final BTypedesc constraintType;
private final BTypedesc completionType;
private final boolean isLazyLoading;
private final Environment env;
```

**Stream Initialization**

```java
private Stream<Frame> initializeFrameStream(Environment env, Iterator<?> itr){
    return BallerinaIteratorUtils.toStream(env, itr);
}
```

**Adding Query Stages**

```java
public void addStage(PipelineStage stage) {
    this.pipelineStages.add(stage);
}
```

**Processing the Query Pipeline**

```java
public void execute() throws Exception {
    for (PipelineStage stage : pipelineStages) {
        stream = stage.process(stream);
    }
}
```

**Extracting the processed stream**  
After processing all stages, the stream needs to be collected into a Ballerina-compatible format. The `BallerinaCollectionUtils` utility handles this by converting the stream into arrays, maps, or XML, depending on the required output type: `toXML()`, `toArray`, `toMap`, `toTable`.

---

### Frame Class

Represents a frame that wraps elements as Ballerina record

```java
private BMap<BString, Object> frame;
```

---

### Query Clauses

```java
public class ...Clause implements PipelineStage {
    BFunctionPointer transform;

    Stream process(Stream strm){
        return strm
        .{operation}(
            transform(frame);
            other logics...
        );
    }
}
```

---

### Clause Mapping

| Ballerina Clause | Java Streams Operation              | Description                              |
|------------------|-------------------------------------|------------------------------------------|
| From             | `map()`                             | Transforms each element in the stream    |
| Select           | `map()`                             | Extracts and transforms specific fields  |
| Where            | `filter()`                          | Removes elements that do not match conditions |
| Let              | `map()`                             | Introduces new computed values           |
| Limit            | `limit()`                           | Restricts the number of iterations       |
| Order By         | `sorted()`                          | Performs optimized sorting               |
| Group By         | `collect(Collectors.groupingBy())`  | Groups elements by key                   |
| Collect          | `collect()`                         | Aggregates results into a final collection |
| Join             | `flatMap()`                         | Merges multiple streams                  |
| Do               | `forEach()`                         | Query actions                            |

---

### BallerinaIteratorUtils

This wraps the ballerina iterator extracted from the BCollection in a Java iterator. Then it enables the BCollection to be used as a Java stream.

```java
private static <T> Iterator<T> createJavaIterator(BIterator<?> ballerinaIterator) throws ErrorValue {
    return new Iterator<>() {
        @Override
        public boolean hasNext() {
            return ballerinaIterator.hasNext();
        }

        @Override
        public T next() {
            return (T) ballerinaIterator.next();
        }
    };
}
```

---

### BallerinaCollectionUtils

These are responsible for collecting the processed stream to the required ballerina collection type. This consists methods such as `createArray`, `createTable`, `createMap`. In those methods it uses a terminal operation to execute and collect the stream.

```java
public static Object createArray(StreamPipeline pipeline, BArray array) {
    Stream<Frame> strm = pipeline.getStream();
    try {
        Iterator<Frame> it = strm.iterator();
        while (it.hasNext()) {
            Frame frame = it.next();
            array.append(frame.getRecord().get(VALUE_ACCESS_FIELD));
        }
        return array;
    } catch (QueryException e) {
        return e.getError();
    }
}
