
TEST_PROJ_PATH="Tests/RZUtilsTests.xcodeproj"
TEST_WORKSPACE_PATH="Tests/RZUtilsTests.xcworkspace"
TEST_SCHEME="RZUtilsTests"

#
# Install
#

namespace :install do
  
  task :tools do
    # don't care if this fails on travis
    sh("brew update") rescue nil
    sh("brew upgrade xctool") rescue nil
    sh("gem install cocoapods --no-rdoc --no-ri --no-document --quiet") rescue nil
  end

  task :pods do
    sh("cd Tests && pod install")
  end
  
end

task :install do
  Rake::Task['install:tools'].invoke
  Rake::Task['install:pods'].invoke
end

#
# Test
#

task :test do
  sh("xctool -workspace '#{TEST_WORKSPACE_PATH}' -scheme '#{TEST_SCHEME}' -sdk iphonesimulator build test") rescue nil
  exit $?.exitstatus
end

#
# Analyze
#

task :analyze do
  sh("xctool -workspace '#{TEST_WORKSPACE_PATH}' -scheme '#{TEST_SCHEME}' -sdk iphonesimulator analyze -failOnWarnings") rescue nil
  exit $?.exitstatus
end

#
# Clean
#

namespace :clean do
  
  task :pods do
    sh("rm -f Tests/Podfile.lock")
    sh "rm -rf Tests/Pods"
    sh("rm -rf Tests/*.xcworkspace")
  end
  
  task :tests do
    sh("xctool -project '#{TEST_PROJ_PATH}' -scheme '#{TEST_SCHEME}' -sdk iphonesimulator clean") rescue nil
  end
    
end

task :clean do
  Rake::Task['clean:pods'].invoke
  Rake::Task['clean:tests'].invoke
end


#
# Utils
#

task :usage do
  puts "Usage:"
  puts "  rake install       -- install all dependencies (xctool, cocoapods)"
  puts "  rake install:pods  -- install cocoapods for tests"
  puts "  rake install:tools -- install build tool dependencies"
  puts "  rake test          -- run unit tests"
  puts "  rake clean         -- clean everything"
  puts "  rake clean:tests   -- clean the test project build artifacts"
  puts "  rake clean:pods    -- clean up cocoapods artifacts"
  puts "  rake usage         -- print this message"
end

#
# Default
#

task :default => 'usage'
