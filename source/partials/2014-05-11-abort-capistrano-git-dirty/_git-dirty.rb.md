```ruby
before "deploy:update_code", 'git:dirty'

namespace :git do
  desc "Check current directory and raise if git status is dirty"
  task :dirty do
    run "cd #{current_path}; git status --porcelain" do|channel, stream, data|
      ignore = [ # Files to omit changes
        'D log/.gitkeep',
        'M db/schema.rb'
      ]
      diff = data.split("\n").reject{|m|
        ignore.include? m.strip
      }
      if diff.size > 0
        abort "Aborting: #{current_path} is dirty:\n #{ diff.join("\n") }"
      end
    end
  end
end
```
