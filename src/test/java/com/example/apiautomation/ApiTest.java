package com.example.apiautomation;

import com.intuit.karate.junit5.Karate;

class ApiTest {

    @Karate.Test
    Karate apiScenarios() {
        return Karate.run("classpath:features");
    }
}
