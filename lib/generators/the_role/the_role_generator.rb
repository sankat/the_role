class TheRoleGenerator < Rails::Generators::NamedBase
  source_root File.expand_path('../templates', __FILE__)
  # argument :xname, type: :string, default: :xname

  def generate_controllers
    if gen_name == 'install'
      cp_config
      cp_models
    elsif gen_name == 'config'
      cp_config
    elsif gen_name == 'models'
      cp_models
    elsif gen_name == 'admin'
      create_admin_role
    elsif gen_name == 'many-to-many'
      cp_permissions
    else
      puts 'TheRole Generator - wrong Name'
      puts 'Try to use install'
    end
  end

  private

  def root_path; TheRole::Engine.root; end

  def gen_name
    name.to_s.downcase
  end

  def cp_models
    copy_file "#{root_path}/app/models/_templates_/role.rb", "app/models/role.rb"
    copy_file "#{root_path}/app/models/_templates_/user_role.rb", "app/models/user_role.rb"
  end

  def cp_config
    copy_file 'the_role.rb', 'config/initializers/the_role.rb'
  end

  def cp_permissions
    copy_file "#{root_path}/config/permissions.yml", "config/permissions.yml"
    copy_file "#{root_path}/config/permission.rb", "config/initializers/permission.rb"
  end

  def create_admin_role
    puts `clear`
    puts '~'*40
    puts 'TheRole'
    puts '~'*40

    unless Role.with_name(:admin)
      role = Role.create(
        name: :admin,
        title: "role for admin",
        description:"this user can do anything"
      )

      role.create_rule(:system, :administrator)
      role.rule_on(:system, :administrator)

      puts "Admin role created"
    else
      puts "Admin role exists"
    end

    puts "Now you can makes any user as Admin:"
    puts "> bin/rails c"
    puts "> User.first.update( role: Role.with_name(:admin) )"
    puts '~'*40
  end
end