Feature: Home
  Background:
    Given I had an admin account

  @javascript
  Scenario: Login to home page
    Given I am on login page
    When I log in with email "admin@zenoradio.com" and password "1234qwer"
    Then I wanna sleep "5" seconds
    And I should see "Sign in" button 


