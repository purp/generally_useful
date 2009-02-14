gu_libs = File.expand_path(File.join(File.dirname(__FILE__), '..', 'lib'))
$LOAD_PATH.unshift(gu_libs) if File.exist?(gu_libs)

require "svn"
@svn = GenerallyUseful::SVN.new

namespace :svn do
  def svn_copy_from_workspace_url_to(dest_url)
    src_url = @svn.info['URL']
    src_rev = @svn.query_revision
    @svn.copy(src_url, dest_url, src_rev, ENV['SVN_OPTS'])
  end
  
  def svn_copy_from_workspace_url_overwriting(dest_url)
    @svn.remove(dest_url, ENV['SVN_OPTS'])
    svn_copy_from_workspace_url_to(dest_url)
  end
  
  def branch_dest_url
    raise "You must set either BRANCH_NAME or BRANCH_URL environment variable" unless ENV['BRANCH_NAME'] || ENV['BRANCH_URL']
    ENV['BRANCH_URL'] || @svn.branch_url(ENV['BRANCH_NAME'])
  end
  
  def tag_dest_url
    raise "You must set either TAG_NAME or TAG_URL environment variable" unless ENV['TAG_NAME'] || ENV['TAG_URL']
    ENV['TAG_URL'] || @svn.tag_url(ENV['TAG_NAME'])
  end
  
  desc "Branch this workspace's SVN URL and revision to the name given in BRANCH_NAME or BRANCH_URL. Pass additional options via SVN_OPTS."
  task :create_branch do
    svn_copy_from_workspace_url_to(branch_dest_url)
  end
  task :branch => :create_branch

  desc "For BRANCH_URL or BRANCH_NAME, delete the branch and recreate it from this workspace's URL and revision. Pass additional options via SVN_OPTS."
  task :delete_and_recreate_branch do
    svn_copy_from_workspace_url_overwriting(branch_dest_url)
  end
  task :rebranch => :delete_and_recreate_branch
  
  desc "Tag this workspace's SVN URL and revision to the name given in TAG_NAME or TAG_URL. Pass additional options via SVN_OPTS."
  task :create_tag do
    svn_copy_from_workspace_url_to(tag_dest_url)
  end
  task :tag => :create_tag
  
  desc "For TAG_URL or TAG_NAME, delete the branch and recreate it from this workspace's URL and revision. Pass additional options via SVN_OPTS."
  task :delete_and_recreate_tag do
    svn_copy_from_workspace_url_overwriting(tag_dest_url)
  end
  task :retag => :delete_and_recreate_tag
end