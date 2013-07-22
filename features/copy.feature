Feature: Copy files

  In order to copy files to another location when I change them
  As a developer
  I want to use guard-copy

  Scenario: Guardfile template
    When I run `guard init copy`
    Then the file "Guardfile" should contain:
      """
      # Any files created or modified in the 'source' directory
      # will be copied to the 'target' directory. Update the
      # guard as appropriate for your needs.

      guard :copy, :from => 'source', :to => 'target'
      """

  Scenario: Copy a new file
    Given a directory named "source"
    And a directory named "target"
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

  Scenario: Copy a file to two targets
    Given a directory named "source"
    And a directory named "target_one"
    And a directory named "target_two"
    And I have run guard with this Guardfile:
      """
      guard :copy, :from => 'source', :to => ['target_one', 'target_two']
      """
    When I create a file named "source/foo"
    Then "source/foo" should be copied to "target_one/foo"
    And "source/foo" should be copied to "target_two/foo"

  Scenario: Wildcard target
    Given a directory named "source"
    And a directory named "target_one"
    And a directory named "target_two"
    And I have run guard with this Guardfile:
      """
      guard :copy, :from => 'source', :to => 'target*'
      """
    When I create a file named "source/foo"
    Then "source/foo" should be copied to "target_one/foo"
    And "source/foo" should be copied to "target_two/foo"

  Scenario: Newest duplicate option
    Given a directory named "source"
    And a directory named "target_older" created in 1978
    And a directory named "target_newer" created in 2012
    And I have run guard with this Guardfile:
      """
      guard :copy, :from => 'source', :to => 'target*', :glob => :newest
      """
    When I create a file named "source/foo"
    Then "source/foo" should be copied to "target_newer/foo"
    And "source/foo" should not be copied to "target_older/foo"

  Scenario: Create target directory on demand
    Given a directory named "source/nes/ted/dir/ectory"
    And I have run guard with this Guardfile:
      """
      guard :copy, :from => 'source', :to => 'target', :mkpath => true
      """
    When I create a file named "source/nes/ted/dir/ectory/foo"
    Then "source/nes/ted/dir/ectory/foo" should be copied to "target/nes/ted/dir/ectory/foo"

  Scenario: Copy a file from the root directory
    Given a directory named "target"
    And I have run guard with this Guardfile:
      """
      guard :copy, :from => '.', :to => 'target'
      """
    When I create a file named "foo"
    Then "foo" should be copied to "target/foo"

