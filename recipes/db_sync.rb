namespace :db do
  desc "Dump the production database to a file and get the file"
  task :dump_and_download, :roles => :db, :only => { :primary => true } do
    backup_time = Time.now.localtime.strftime('%Y%m%d.%H%M%S')
    backup_file = "/tmp/production_db.#{backup_time}.dmp"
    backup_zip_file = "#{backup_file}.gz"
    on_rollback { run "rm -f #{backup_file} #{backup_zip_file}" }
    run "cd #{current_path} && rake db:prod:dump DUMPFILE=#{backup_file} && gzip #{backup_file}"
    get backup_zip_file, ENV['DUMPFILE']
    run "rm #{backup_zip_file}"
  end
end
