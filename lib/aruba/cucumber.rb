require 'aruba/api'

World(Aruba::Api)

Before do
  unset_ruby_env_vars
  FileUtils.rm_rf(current_dir)
end

Before('@puts') do
  @puts = true
end

Before('@announce-cmd') do
  @announce_cmd = true
end

Before('@announce-stdout') do
  @announce_stdout = true
end

Before('@announce-stderr') do
  @announce_stderr = true
end

Before('@announce-dir') do
  @announce_dir = true
end

Before('@announce-env') do
  @announce_env = true
end

Before('@announce') do
  @announce_stdout = true
  @announce_stderr = true
  @announce_cmd = true
  @announce_dir = true
  @announce_env = true
end

After do
  restore_env
end

Given /^I'm using a clean gemset "([^"]*)"$/ do |gemset|
  use_clean_gemset(gemset)
end

Given /^a directory named "([^"]*)"$/ do |dir_name|
  create_dir(dir_name)
end

Given /^a file named "([^"]*)" with:$/ do |file_name, file_content|
  create_file(file_name, file_content)
end

Given /^an empty file named "([^"]*)"$/ do |file_name|
  create_file(file_name, "")
end

When /^I write to "([^"]*)" with:$/ do |file_name, file_content|
  create_file(file_name, file_content, false)
end

When /^I overwrite "([^"]*)" with:$/ do |file_name, file_content|
  create_file(file_name, file_content, true)
end

When /^I append to "([^"]*)" with:$/ do |file_name, file_content|
  append_to_file(file_name, file_content)
end

When /^I cd to "([^"]*)"$/ do |dir|
  cd(dir)
end

When /^I run "(.*)"$/ do |cmd|
  run(unescape(cmd), false)
end

When /^I successfully run "(.*)"$/ do |cmd|
  run(unescape(cmd))
end

When /^I start an interactive session with "(.*)"$/ do |cmd|
  start_interactive(unescape(cmd))
end

When /^I type "([^"]*)" into the session$/ do |input|
  type_interactive(ensure_newline(input))
end

When /^I stop the session$/ do
  kill_interactive
end

Then /^the output should contain "([^"]*)"$/ do |partial_output|
  assert_partial_output(partial_output)
end

Then /^the output should not contain "([^"]*)"$/ do |partial_output|
  combined_output.should_not =~ compile_and_escape(partial_output)
end

Then /^the output should contain:$/ do |partial_output|
  combined_output.should =~ compile_and_escape(partial_output)
end

Then /^the output should not contain:$/ do |partial_output|
  combined_output.should_not =~ compile_and_escape(partial_output)
end

Then /^the output should contain exactly "([^"]*)"$/ do |exact_output|
  combined_output.should == unescape(exact_output)
end

Then /^the output should contain exactly:$/ do |exact_output|
  combined_output.should == exact_output
end

# "the output should match" allows regex in the partial_output, if
# you don't need regex, use "the output should contain" instead since
# that way, you don't have to escape regex characters that
# appear naturally in the output
Then /^the output should match \/([^\/]*)\/$/ do |partial_output|
  combined_output.should =~ /#{partial_output}/
end
 
Then /^the output should match:$/ do |partial_output|
  combined_output.should =~ /#{partial_output}/m
end

Then /^the exit status should be (\d+)$/ do |exit_status|
  @last_exit_status.should == exit_status.to_i
end

Then /^the exit status should not be (\d+)$/ do |exit_status|
  @last_exit_status.should_not == exit_status.to_i
end

Then /^it should (pass|fail) with:$/ do |pass_fail, partial_output|
  self.__send__("assert_#{pass_fail}ing_with", partial_output)
end

Then /^the stderr should contain "([^"]*)"$/ do |partial_output|
  @last_stderr.should =~ compile_and_escape(partial_output)
end

Then /^the stdout should contain "([^"]*)"$/ do |partial_output|
  @last_stdout.should =~ compile_and_escape(partial_output)
end

Then /^the stderr should not contain "([^"]*)"$/ do |partial_output|
  @last_stderr.should_not =~ compile_and_escape(partial_output)
end

Then /^the stdout should not contain "([^"]*)"$/ do |partial_output|
  @last_stdout.should_not =~ compile_and_escape(partial_output)
end

Then /^the following files should exist:$/ do |files|
  check_file_presence(files.raw.map{|file_row| file_row[0]}, true)
end

Then /^the following files should not exist:$/ do |files|
  check_file_presence(files.raw.map{|file_row| file_row[0]}, false)
end

Then /^the following directories should exist:$/ do |directories|
  check_directory_presence(directories.raw.map{|directory_row| directory_row[0]}, true)
end

Then /^the following directories should not exist:$/ do |directories|
  check_file_presence(directories.raw.map{|directory_row| directory_row[0]}, false)
end

Then /^the file "([^"]*)" should contain "([^"]*)"$/ do |file, partial_content|
  check_file_content(file, partial_content, true)
end

Then /^the file "([^"]*)" should not contain "([^"]*)"$/ do |file, partial_content|
  check_file_content(file, partial_content, false)
end

Then /^the session transcript should be:/ do |content|
  out = read_interactive
  out.should == content
end
