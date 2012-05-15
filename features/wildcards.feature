Feature: Wildcard target directories

  In order to copy files to directories identified by wildcards
  As a developer
  I want to use guard-copy

  Scenario: Wildcard target
    Given a directory named "target_one"
    And a directory named "target_two"
    And I have run guard with this Guardfile:
      """
      guard :copy, :from => 'source', :to => 'target*'
      """
    When I create a file named "source/foo"
    Then "source/foo" should be copied to "target_one/foo"
    And "source/foo" should be copied to "target_two/foo"

  Scenario: Newest duplicate option
    Given a directory named "target_older" created in 1978
    And a directory named "target_newer" created in 2012
    And I have run guard with this Guardfile:
      """
      guard :copy, :from => 'source', :to => 'target*', :glob => :newest
      """
    When I create a file named "source/foo"
    Then "source/foo" should be copied to "target_newer/foo"
    And "source/foo" should not be copied to "target_older/foo"
