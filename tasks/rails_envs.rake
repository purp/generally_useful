gu_libs = File.expand_path(File.join(File.dirname(__FILE__), '..', 'lib'))
$LOAD_PATH.unshift(gu_libs) if File.exist?(gu_libs)

require "generally_useful"

### Adapted from Err The Blog, http://errtheblog.com/post/33

GenerallyUseful.get_available_environments.each do |env|
  # Avoid stepping on the 'test' task
  name      = env.to_s == 'test' ? 'testing' : env
  env_alias = GenerallyUseful.get_alias_for_environment_name(env)
  comment   = "Runs the following task in the #{env.to_s} environment"
  
  desc comment
  task name do
    RAILS_ENV = ENV['RAILS_ENV'] = env
  end
  
  if env_alias && name != env_alias
    desc comment
    task env_alias => name
  end
end
