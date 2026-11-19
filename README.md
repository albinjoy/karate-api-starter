# Beginner Karate API Automation Starter

A small Java + Maven + Karate project with three readable Gherkin API scenarios and Karate's built-in HTML report.

## 1. What you'll need

- Java 17 or newer (this project targets Java 17; Java 21 also works)
- Maven 3.8 or newer
- IntelliJ IDEA
- Internet access to `https://jsonplaceholder.typicode.com` when running the tests

## 2. Project structure

```text
karate-api-starter/
├── pom.xml
├── README.md
└── src/
    └── test/
        ├── java/
        │   └── com/example/apiautomation/
        │       └── ApiTest.java
        └── resources/
            ├── karate-config.js
            └── features/
                └── posts.feature
```

The Java runner is deliberately tiny: Karate features do the API work, while Java/JUnit simply tells Maven where the tests are. The configuration and feature files are test resources, not production application code.

## 3. Add the Maven configuration

Create `pom.xml` at the project root:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<project xmlns="http://maven.apache.org/POM/4.0.0"
         xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 https://maven.apache.org/xsd/maven-4.0.0.xsd">
    <modelVersion>4.0.0</modelVersion>

    <groupId>com.example</groupId>
    <artifactId>karate-api-starter</artifactId>
    <version>1.0-SNAPSHOT</version>

    <properties>
        <maven.compiler.release>17</maven.compiler.release>
        <project.build.sourceEncoding>UTF-8</project.build.sourceEncoding>
        <karate.version>1.4.1</karate.version>
        <junit.version>5.11.4</junit.version>
    </properties>

    <dependencies>
        <dependency>
            <groupId>com.intuit.karate</groupId>
            <artifactId>karate-junit5</artifactId>
            <version>${karate.version}</version>
            <scope>test</scope>
        </dependency>
        <dependency>
            <groupId>org.junit.jupiter</groupId>
            <artifactId>junit-jupiter</artifactId>
            <version>${junit.version}</version>
            <scope>test</scope>
        </dependency>
    </dependencies>

    <build>
        <plugins>
            <plugin>
                <groupId>org.apache.maven.plugins</groupId>
                <artifactId>maven-compiler-plugin</artifactId>
                <version>3.13.0</version>
                <configuration>
                    <release>${maven.compiler.release}</release>
                </configuration>
            </plugin>
            <plugin>
                <groupId>org.apache.maven.plugins</groupId>
                <artifactId>maven-surefire-plugin</artifactId>
                <version>3.5.2</version>
                <configuration>
                    <useModulePath>false</useModulePath>
                </configuration>
            </plugin>
        </plugins>
    </build>
</project>
```

**Why it is needed:** Maven reads this file to download dependencies and run tests. `karate-junit5` connects Karate to JUnit 5. Surefire is Maven's test runner. Dependency versions are centralized in properties so they can be updated in one place.

## 4. Set the base API URL

Create `src/test/resources/karate-config.js`:

```javascript
function fn() {
  var config = {
    baseUrl: 'https://jsonplaceholder.typicode.com'
  };
  return config;
}
```

Karate calls `fn()` at test startup and makes the returned values available to features. `baseUrl` is the shared API root. Changing it here changes the host used by these scenarios.

## 5. Write the API scenarios

Create `src/test/resources/features/posts.feature`:

```gherkin
Feature: Basic post and user API checks

  Background:
    Given url baseUrl

  Scenario: Retrieve a post by its ID
    Given path 'posts', 1
    When method get
    Then status 200
    And match response.id == 1
    And match response.title == '#string'
    And match response.body == '#string'

  Scenario: Submit a new post
    Given path 'posts'
    And request { title: 'Karate starter', body: 'My first API test', userId: 1 }
    When method post
    Then status 201
    And match response contains { title: 'Karate starter', body: 'My first API test', userId: 1 }
    And match response.id == '#number'

  Scenario: Retrieve a user by ID
    Given path 'users', 1
    When method get
    Then status 200
    And match response.id == 1
    And match response.email == '#string'
    And match response.address.city == '#string'
```

**Gherkin and Karate in plain language:**

- `Feature` names the group of related tests.
- `Background` runs before every scenario. `Given url baseUrl` sets the common request root.
- `Scenario` is one test case with a readable name.
- `Given` sets up the request: `path` adds URL segments and `request` supplies a JSON body.
- `When method get` or `When method post` sends the HTTP request.
- `Then status 200` checks the HTTP status code.
- `And` adds another step without repeating `Given`, `When`, or `Then`.
- `match` checks response data. `response` is Karate's parsed response body; `response.id` and `response.address.city` read JSON fields.
- `'#string'` and `'#number'` are Karate match markers for values of those types.
- `contains` checks the listed fields without requiring the response to have only those fields.

For **GET**, the `path` identifies the resource and `method get` retrieves it; there is no request body here. For **POST**, `path` identifies the collection, `request` provides JSON to submit, and `method post` sends it. JSONPlaceholder is a public demonstration API: its POST returns a success-shaped response with an ID, but does not permanently save the post.

## 6. Add the Java/JUnit runner

Create `src/test/java/com/example/apiautomation/ApiTest.java`:

```java
package com.example.apiautomation;

import com.intuit.karate.junit5.Karate;

class ApiTest {

    @Karate.Test
    Karate apiScenarios() {
        return Karate.run("classpath:features");
    }
}
```

`@Karate.Test` marks the method as a Karate test that JUnit 5 can run. `Karate.run("classpath:features")` tells Karate to find and execute feature files under `src/test/resources/features`. No Java code is needed to build requests or parse responses.

## 7. Run it in IntelliJ IDEA or Maven

1. In IntelliJ IDEA, choose **File → Open** and select the folder containing `pom.xml`.
2. Accept the prompt to load the Maven project and wait for dependencies to download.
3. Open `ApiTest.java` and click the run icon beside the class or test method.
4. Or, from a terminal in the project root, run:

   ```shell
   mvn test
   ```

Maven compiles the small Java runner, JUnit discovers it, and Karate executes each scenario in the `.feature` file.

## 8. Open the HTML report

After a test run, open:

```text
target/karate-reports/karate-summary.html
```

In IntelliJ, you can right-click that file and choose **Open in Browser** (or open it in your default browser). The report summarizes scenarios, steps, and failures. Re-run `mvn test` to refresh it. The `target/` folder is generated output and does not need to be edited.

## How the pieces fit together

**Java** supplies the JUnit entry point. **Maven** manages libraries and invokes tests. **Karate** reads the feature, sends HTTP requests, parses JSON, checks assertions, and produces the HTML report. **Gherkin** is the readable Given/When/Then syntax used in the feature. **IntelliJ IDEA** is where you edit files, run the tests, and inspect results.
