Feature: Copy files to multiple targets

  In order to copy files to multiple locations when I change them
  As a developer
  I want to use guard-copy

  Scenario: Copy a file to two targets
    Given a directory named "target_one"
    And a directory named "target_two"
    And I have run guard with this Guardfile:
      """
      guard :copy, :from => 'source', :to => ['target_one', 'target_two']
      """
    When I create a file named "source/foo"
    Then "source/foo" should be copied to "target_one/foo"
    And "source/foo" should be copied to "target_two/foo"
