Feature: Custom watchers

  In order to have greater control over which files are copied
  As a developer using guard-copy
  I want to define custom watchers

  Scenario: Watcher including :from directory
    Given a directory named "source"
    And a directory named "target"
    And I have run guard with this Guardfile:
      """
      guard :copy, :from => 'source', :to => 'target' do
        watch(%r{^source/.+\.js$})
      end
      """
    When I create a file named "source/file.js"
    Then "source/file.js" should be copied to "target/file.js"

  Scenario: Watcher without :from directory
    Given a directory named "source"
    And a directory named "target"
    And I have run guard with this Guardfile:
      """
      guard :copy, :from => 'source', :to => 'target' do
        watch(%r{^.+\.js$})
      end
      """
    When I create a file named "source/file.js"
    Then "source/file.js" should be copied to "target/file.js"

  Scenario: Only matched files are copied
    Given a directory named "source"
    And a directory named "target"
    And I have run guard with this Guardfile:
      """
      guard :copy, :from => 'source', :to => 'target' do
        watch(%r{^.+\.js$})
      end
      """
    When I create a file named "source/file.html"
    And I create a file named "source/file.js"
    Then "source/file.js" should be copied to "target/file.js"
    And "source/file.html" should not be copied to "target/file.html"

  Scenario: Only files in :from directory are copied
    Given a directory named "source/from"
    And a directory named "source/other"
    And a directory named "target/from"
    And a directory named "target/other"
    And I have run guard with this Guardfile:
      """
      guard :copy, :from => 'source/from', :to => 'target/from' do
        watch(%r{^.+\.js$})
      end
      """
    When I create a file named "source/other/file.js"
    And I create a file named "source/from/file.js"
    Then "source/from/file.js" should be copied to "target/from/file.js"
    And "source/other/file.js" should not be copied to "target/other/file.js"
