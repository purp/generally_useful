module GenerallyUseful
  def get_available_environments
    Dir.new(File.join(::RAILS_ROOT, 'config', 'environments')).grep(/\.rb$/).map {|f| f.chomp('.rb')}
  end
  module_function :get_available_environments
  
  def get_available_environments_with_aliases
    envs = get_available_environments
    envs.each do |env|
      env_alias = get_alias_for_environment_name(env)
      envs << env_alias if env_alias
    end
    envs.sort
  end
  module_function :get_available_environments_with_aliases
  
  def get_alias_for_environment_name(env_name)
    # Do not EVER remove the alias for the 'test' environment or bad things will happen
    environment_name_aliases = {
      'production'  => 'prod',
      'development' => 'dev',
      'test'        => 'testing'
    }
    environment_name_aliases[env_name.to_s]
  end
  module_function :get_alias_for_environment_name
end