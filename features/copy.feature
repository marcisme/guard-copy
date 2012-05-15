Feature: Copy files

  In order to copy files to another location when I change them
  As a developer
  I want to use guard-copy

  Scenario: Single target startup message
    When I have run guard with this Guardfile:
      """
      guard :copy, :from => 'source', :to => 'target'
      """
    Then guard should report that "Guard::Copy will copy files from 'source' to 'target'"

  Scenario: Copy a new file
    Given a directory named "target"
    And I have run guard with this Guardfile:
      """
      guard :copy, :from => 'source', :to => 'target'
      """
    When I create a file named "source/foo"
    Then "source/foo" should be copied to "target/foo"

  Scenario: Copy an updated file
    Given a directory named "target"
    And an empty file named "source/foo"
    And I have run guard with this Guardfile:
      """
      guard :copy, :from => 'source', :to => 'target'
      """
    When I append to "source/foo" with "xyz"
    Then "source/foo" should be copied to "target/foo"

  Scenario: Non-existent target directory
    Given a directory named "target" should not exist
    And I have run guard with this Guardfile:
      """
      guard :copy, :from => 'source', :to => 'target'
      """
    When I create a file named "source/foo"
    Then guard should report that "'target' does not match any directories"

  Scenario: Target directory is a file
    Given an empty file named "target"
    And I have run guard with this Guardfile:
      """
      guard :copy, :from => 'source', :to => 'target'
      """
    When I create a file named "source/foo"
    Then guard should report that "'target' is not a directory"
