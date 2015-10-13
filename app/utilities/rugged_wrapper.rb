require 'rugged'

module Hacienda

  class RuggedWrapperFactory

    def get_repo(repo_path)
      RuggedWrapper.new(repo_path)
    end

  end

  class RuggedWrapper

    include Rugged

    def initialize(repo_path)
      @repo_path = repo_path
    end

    def get_repo
      Repository.new(@repo_path)
    end

    def sha_for(item_path)
      get_repo.head.target.tree.path(item_path)[:oid]
    end

    def get_version_in_past(file_path, changes_in_the_past, repo = get_repo, walker = Rugged::Walker.new(repo))
      raise ArgumentError if changes_in_the_past < 0
      walker.push(repo.last_commit)

      last_blob = repo.blob_at(repo.last_commit.oid, file_path)
      current_blob_id = last_blob.oid

      walker.each do |commit|
        blob = repo.blob_at(commit.oid, file_path)
        blob_id = (blob ? blob.oid : 0)

        if current_blob_id != blob_id
          current_blob_id = blob_id
          last_blob = blob
          changes_in_the_past -= 1
        end
        break if (changes_in_the_past == 0)
        break unless last_blob
      end

      changes_in_the_past == 0 ? last_blob : nil
    end

  end

end
