module TheRole
  module User

    # This module has comman tasks which is used in both module (HasOneRole and HasManyRoles)
    module UserTask

      module ClassMethods
        def with_role name
          ::Role.where(name: name).first.try :users
        end
      end

      # FALSE if object is nil
      # If object is a USER - check for youself
      # Check for owner field - :user_id
      # Check for owner _object_ if owner field is not :user_id
      def owner? obj
        return false unless obj
        return true if admin?

        section_name = obj.class.to_s.tableize
        return true if moderator?(section_name)

        # obj is User, simple way to define user_id
        return id == obj.id if obj.is_a?(self.class)

        # few ways to define user_id
        return id == obj.user_id if obj.respond_to? :user_id
        return id == obj[:user_id] if obj[:user_id]
        return id == obj[:user][:id] if obj[:user]
        false
      end
    end

    # This module used when user has one role
    module HasOneRole
      extend ActiveSupport::Concern

      include TheRole::Base
      include TheRole::User::UserTask

      included do
        has_one :user_role, class_name: :UserRole
        has_one :role, through: :user_role
        before_validation :set_default_role, on: :create
        after_save { |user| user.instance_variable_set(:@role_hash, nil) }
      end

      def role_hash;
        @role_hash ||= role.try(:to_hash) || {}
      end

      private

      def set_default_role
        unless role
          default_role = ::Role.find_by_name(TheRole.config.default_user_role)
          self.role = default_role if default_role
        end

        if self.class.count.zero? && TheRole.config.first_user_should_be_admin
          self.role = TheRole.create_admin_role!
        end
      end
    end

    # This module used when user has many role
    module HasManyRoles
      extend ActiveSupport::Concern

      include TheRole::Base
      include TheRole::User::UserTask

      included do
        has_many :user_roles, class_name: :UserRole
        has_many :roles, through: :user_roles
        before_validation :set_default_role, on: :create
        # after_save { |user| user.instance_variable_set(:@role_hash, nil) }
      end

      def role_hash
        @role_hash = {}
        roles.each{ |role| @role_hash.deep_merge!(role.role_hash) }
        return @role_hash
      end

      private

      def set_default_role
        unless roles.blank?
          default_role = ::Role.find_by_name(TheRole.config.default_user_role)
          self.roles = [default_role] if default_role
        end

        if self.class.count.zero? && TheRole.config.first_user_should_be_admin
          self.roles = [TheRole.create_admin_role!]
        end
      end
    end
  end
end