gu_libs = File.expand_path(File.join(File.dirname(__FILE__), '..', 'lib'))
$LOAD_PATH.unshift(gu_libs) if File.exist?(gu_libs)

require "generally_useful"

### Based on Err The Blog, http://errtheblog.com/post/33 ... and then I added a lot of bugs. =]

# Use symbols for commands to avoid name collision with db config options
namespace :db do
  @db_options = {
    :recycle => %w(db:drop db:create db:migrate),
    :sync    => %w(db:set_dumpfile db:dump_remote_production db:load),
    :reload  => %w(db:set_dumpfile db:load),
    'mysql' => {
      :console   => 'mysql',
      :create    => 'mysqladmin create',
      :drop      => 'mysqladmin --force drop',
      :dump      => 'mysqldump --add-drop-table --result-file ${DUMPFILE}',
      :list      => 'echo "show databases" | mysql',
      :load      => 'gzcat ${DUMPFILE} | mysql',
      'username' => '-u %s',
      'password' => '-p%s',
      'host'     => '-h %s',
      'port'     => '-P %s',
      'socket'   => '-S %s',
      'database' => '%s'
    }
  }
  
  @commands = {
    :console => "Launch local database console",
    :create  => "Create local database",
    :drop    => "Drop local database",
    :dump    => "Dump local database",
    :list    => "List all databases being served",
    :load    => "Load local database from DUMPFILE",
    :recycle => "Drop, create, and migrate local database",
    :sync    => "Dump remote production database into the local database"
  }
  
  @commands.each do |name, comment|
    unless Rake::Task.task_defined?(['db', name.to_s].join(':'))
      comment = comment.chomp('.').rstrip
      desc comment + " for current environment."
      if @db_options[name]
        task name => @db_options[name]
      else
        task name => :environment do
          print "Connecting to #{RAILS_ENV} database ... "
          command = assemble_db_command(name, YAML.load(open(File.join(RAILS_ROOT, 'config', 'database.yml')))[RAILS_ENV])
          system command if command && command != ''
        end
      end
    end
    
    GenerallyUseful.get_available_environments.each do |env|
      env_alias = GenerallyUseful.get_alias_for_environment_name(env)

      # avoid making the 'test' task a prerequisite
      env_prereq = (env == 'test') ? env_alias : env
      unless Rake::Task.task_defined?(['db', env, name.to_s].join(':'))
        namespace env do
          desc comment + " for #{env.to_s} environment."
          task name => [env_prereq, "db:#{name.to_s}"]
        end
      end
      if env_alias
        unless Rake::Task.task_defined?(['db', env_alias, name.to_s].join(':'))
          namespace env_alias do
            desc comment + " for #{env.to_s} environment."
            task name => [env_prereq, "db:#{name.to_s}"]
          end
        end
      end  
    end
  end

  def assemble_db_command(command, config)
    if options = @db_options[config['adapter']].clone
      if options[command.to_sym]
        puts "using #{config['adapter']} adapter."
        command  = options.delete(command.to_sym) + ' '
        command << options.map {|opt, fmt| fmt % config[opt] if config[opt]}.join(' ')
      else
        puts "ERROR: unknown command #{command.to_s} ... teach me how to do that one!"
        nil
      end
    else
      puts "ERROR: unknown database adapter '#{adapter}' ... teach me how to do that one!"
      nil
    end
  end
  
  ### version task by Doug Alcorn (http://blog.lathi.net/) and ncryptic (http://www.ncryptic.com/)
  ###   as lifted from http://blog.jayfields.com/2006/11/rails-get-schemainfo-version-number.html
  desc "Returns the current schema version"
  task :version => :environment do
    begin
      puts "Current version: " + ActiveRecord::Migrator.current_version.to_s
    rescue
      puts "Current version: 0 (database not yet migrated)"
    end
  end

  task :set_dumpfile do
    ENV['DUMPFILE'] = 'db/production_db.dmp.gz' unless ENV['DUMPFILE']
  end  

  desc "Get the database dump from production"
  task :dump_remote_production => :environment do
    `cap production db:dump_and_download`
  end
end
