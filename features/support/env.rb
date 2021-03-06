# IMPORTANT: This file is generated by cucumber-rails - edit at your own peril.
# It is recommended to regenerate this file in the future when you upgrade to a
# newer version of cucumber-rails. Consider adding your own code to a new file
# instead of editing this one. Cucumber will automatically load all features/**/*.rb
# files.

require 'cucumber/rails'
require 'timecop'
require 'capybara/poltergeist'

Capybara.register_driver :poltergeist do |app|
  Capybara::Poltergeist::Driver.new app, :inspector => true
end
Capybara.javascript_driver = :poltergeist

# Capybara defaults to XPath selectors rather than Webrat's default of CSS3. In
# order to ease the transition to Capybara we set the default here. If you'd
# prefer to use XPath just remove this line and adjust any selectors in your
# steps to use the XPath syntax.
Capybara.default_selector = :css

# By default, any exception happening in your Rails application will bubble up
# to Cucumber so that your scenario will fail. This is a different from how
# your application behaves in the production environment, where an error page will
# be rendered instead.
#
# Sometimes we want to override this default behaviour and allow Rails to rescue
# exceptions and display an error page (just like when the app is running in production).
# Typical scenarios where you want to do this is when you test your error pages.
# There are two ways to allow Rails to rescue exceptions:
#
# 1) Tag your scenario (or feature) with @allow-rescue
#
# 2) Set the value below to true. Beware that doing this globally is not
# recommended as it will mask a lot of errors for you!
#
ActionController::Base.allow_rescue = false

require 'bcrypt'
Kernel.silence_warnings { BCrypt::Engine::DEFAULT_COST = 1 }

if ENV["REAL_DB"]
  # Cucumber already hooks into database cleaner for us,
  # we just need to specify the strategy
  DatabaseCleaner.strategy = :transaction
end

Before do
  if ENV["REAL_DB"]
    reset_and_configure_real_db
  else
    reset_and_configure_in_memory
  end

  setup_base_data
end

def reset_and_configure_real_db
  Repository.reset!
  Repository.configure(
    "User"        => ActiveRecordRepo::UserRepo.new,
    "Guild"       => ActiveRecordRepo::GuildRepo.new,
    "Character"   => ActiveRecordRepo::CharacterRepo.new,
    "Raid"        => ActiveRecordRepo::RaidRepo.new,
    "Signup"      => ActiveRecordRepo::SignupRepo.new,
    "Permission"  => ActiveRecordRepo::PermissionRepo.new,
    "Comment"     => ActiveRecordRepo::CommentRepo.new
  )
end

def reset_and_configure_in_memory
  Repository.reset!
  Repository.configure(
    "User"        => InMemory::UserRepo.new,
    "Guild"       => InMemory::GuildRepo.new,
    "Character"   => InMemory::CharacterRepo.new,
    "Raid"        => InMemory::RaidRepo.new,
    "Signup"      => InMemory::SignupRepo.new,
    "Permission"  => InMemory::PermissionRepo.new,
    "Comment"     => InMemory::CommentRepo.new
  )
end

def setup_base_data
  Repository.for(User).save(
    User.new(:login => "raid_leader", :password => "password",
                           :email => "raid_leader@raidit.org")
  )

  Repository.for(User).save(
    User.new(:login => "raider", :password => "password",
             :email => "raider@raidit.org")
  )

  Repository.for(User).save(
    User.new(:login => "guild_leader", :password => "password",
             :email => "gm@raidit.org")
  )

  Repository.for(Guild).save(
    Guild.new(:name => "Exiled")
  )

  Repository.for(Guild).save(
    Guild.new(:name => "Mind Crush")
  )

  Repository.for(Permission).save(
    Permission.new(:user => Repository.for(User).find_by_login("raid_leader"),
                   :guild => Repository.for(Guild).find_by_name("Exiled"),
                    :permissions => Permission::RAID_LEADER)
  )

  Repository.for(Permission).save(
    Permission.new(:user => Repository.for(User).find_by_login("guild_leader"),
                   :guild => Repository.for(Guild).find_by_name("Exiled"),
                    :permissions => Permission::GUILD_LEADER)
  )
end

Before do
  Capybara.use_default_driver
end

Before("@javascript") do
  Capybara.current_driver = :poltergeist
end
