Given /^I have run guard with this Guardfile:$/ do |guardfile_contents|
  start_guard(guardfile_contents)
end

When /^I create a file named "([^"]*)"$/ do |file_name|
  write_file(file_name, '23908afs3wja038wj3wff3wa')
end

Then /^"([^"]*)" should be copied to "([^"]*)"$/ do |from_path, to_path|
  verify_guard_behavior do
    File.should be_file(to_path)
    IO.read(to_path).should == IO.read(from_path)
  end
end

# This step should be used after the affirmative version to make sure guard
# has processed the file system changes.
Then /^"([^"]*)" should not be copied to "([^"]*)"$/ do |from_path, to_path|
  verify_guard_behavior(0) do
    File.should_not be_file(to_path)
  end
end

Then /^guard should report that "([^"]*)"$/ do |output|
  verify_guard_behavior do
    guard_output.should include(output)
  end
end

Then /^the file "([^"]*)" should contain:$/ do |file, partial_content|
  check_file_content(file, partial_content, true)
end

Given /^a directory named "([^"]*)" created in (\d+)$/ do |dir, year|
  create_dir(dir)
  in_current_dir do
    FileUtils.touch(dir, :mtime => Time.utc(year))
  end
end
