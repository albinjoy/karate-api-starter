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
