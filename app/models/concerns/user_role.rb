module TheRole
  module UserRole
    extend ActiveSupport::Concern

    include TheRole::Base

    included do
      belongs_to :user
      belongs_to :role
      validates :user_id, :uniqueness => {:scope => :role_id}
      validates_presence_of :user_id, :role_id
      after_save { |user_role| user_role.user.instance_variable_set(:@role_hash, nil) }
    end
  end
end