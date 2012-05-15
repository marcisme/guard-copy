Feature: Configure guard-copy

  In order to have a default configuration added to my Guardfile
  As a developer
  I want to initialize guard-copy

  Scenario: Guardfile template
    When I run `guard init copy`
    Then the file "Guardfile" should contain:
      """
      # Any files created or modified in the 'source' directory
      # will be copied to the 'target' directory. Update the
      # guard as appropriate for your needs.

      guard :copy, :from => 'source', :to => 'target'
      """
