module Pod
  class MasterSource < Source
    # For now, the MasterSource behaves exactly the same as any other Source.
    # In the future we may apply separate logic to the MasterSource that doesn't
    # depend on the file system.
    MASTER_REPO_NAME = 'master'.freeze
  end
end
