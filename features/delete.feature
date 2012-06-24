Feature: Delete files

  In order to delete files in another location when I delete them
  As a developer
  I want to use guard-copy's delete option

  Scenario: Copy a new file
    Given I create a file named "source/file"
    And I create a file named "target/file"
    And I have run guard with this Guardfile:
      """
      guard :copy, :from => 'source', :to => 'target', :delete => true
      """
    When I remove the file "source/file"
    Then "target/file" should not exist
