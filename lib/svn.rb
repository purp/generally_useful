# Let's be clear. I hate establishing a lateral dependency on Capistrano,
# but (a) generally_useful already assumes you have and use it, and
# (b) Jamis has written the best abstracted classes for handling SCM tools;
# they're just a bit incomplete. So let's fix that.
require 'capistrano/recipes/deploy/scm/subversion'

module GenerallyUseful
  class SVN < Capistrano::Deploy::SCM::Subversion
    def info(revision = head)
      command = scm(:info, repository, authentication, "-r#{revision}")
      ### FIXME: This doesn't work the same as it does in Cap's version.
      result = yield(command)
      yaml = YAML.load(result)
      raise "tried to run `#{command}' and got unexpected result #{result.inspect}" unless Hash === yaml
      yaml
    end
    
    def repository_root_url
      info['Repository Root']
    end
    
    def repository_trunk_url
      repository_root_url + "/trunk"
    end
    
    ### FIXME: This should all refactor such that <plural_word>_root_url and
    ###   <word>_url(name) automatically work. Lambda fun and all that. 
    def branches_root_url
      repository_root_url + "/branches"
    end

    def tags_root_url
      repository_root_url + "/tags"
    end

    def branch_url(branch_name)
      branches_root_url + "/#{branch_name}"
    end

    def tag_url(tag_name)
      branches_root_url + "/#{tag_name}"
    end

    def copy(source, destination, revision, other_opts = "")
      scm :copy, verbose, authentication, "-r#{revision}", other_opts, source,  destination
    end
    
    def delete(target, other_opts = "")
      scm :delete, verbose, authentication, other_opts, target
    end
    
    def delete_and_copy(source, destination, revision, other_opts = "")
      delete(destination, other_opts)
      copy(source, destination, revision, other_opts)
    end
  end
end

