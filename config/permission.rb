# This call read the permission from the permission.yml file and created one permission has
class Permission

  class << self
    # This method read the permissions.yml file and created on hash.
    def get_permissions
      @@permissions ||= YAML.load_file('config/permissions.yml')
    end

    # If there is permission group like read, write or other then, this method will return the the prrmission
    def permission(controller, action)
      get_permissions[controller.to_s][action.to_s] rescue nil
    end
  end

end