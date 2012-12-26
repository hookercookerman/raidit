module ActiveRecordRepo
  class IndexedRepo
    def initialize
      @id_counter = 0
      @records = []
    end

    def all
      copy_and_return @records
    end

    def find(id)
      find_one {|r| r.id == id }
    end

    def find_one(&block)
      copy_and_return @records.find(&block)
    end

    def find_all(&block)
      copy_and_return @records.select(&block)
    end

    ##
    # We make sure to always clone the object being returned
    # so that it's an exact copy but changing it doesn't change
    # the True Value stored in @records
    ##
    def copy_and_return(result_or_array)
      if result_or_array.nil?
        nil
      elsif result_or_array.is_a?(Array)
        result_or_array.map {|r| copy_and_return(r) }
      else
        result_or_array.clone
      end
    end

    ##
    # Save the record to the persistence store
    # Will return true on success, false if there
    # are any errors on the object.
    ##
    def save(obj)
      if obj.errors.empty?
        set_or_replace_record obj
        true
      else
        false
      end
    end

    def set_or_replace_record(obj)
      @records.delete_if {|record| record.id == obj.id }
      obj.id ||= (@id_counter += 1)

      # Dup to clean up any extra added pieces, like Errors
      @records << obj.dup
    end
  end

  class GuildRepo
    def find(id)
      convert_to_domain ActiveRecordRepo::Models::Guild.find(id), ::Guild
    end

    def save(domain_model)
      ar_model = convert_to_ar_model(domain_model)
      ar_model.save.tap do |success|
        domain_model.id = ar_model.id if success
      end
    end

    def find_by_name(name)
      convert_to_domain ActiveRecordRepo::Models::Guild.first_by_name(name), ::Guild
    end

    def search_by_name(query)
      convert_all_to_domain ActiveRecordRepo::Models::Guild.search_by_name(query), ::Guild
    end

    private

    def convert_to_domain(record, domain_class)
      domain_class.new record.attributes if record
    end

    def convert_all_to_domain(records, domain_class)
      domain_models = []

      records.find_each do |record|
        domain_models << convert_to_domain(record, domain_class)
      end

      domain_models
    end

    def convert_to_ar_model(domain_model)
      if domain_model.persisted?
        ActiveRecordRepo::Models::Guild.find(domain_model.id).tap do |ar_model|
          ar_model.name = domain_model.name
          ar_model.region = domain_model.region
          ar_model.server = domain_model.server
        end
      else
        ActiveRecordRepo::Models::Guild.new(
          :name => domain_model.name,
          :region => domain_model.region,
          :server => domain_model.server
        )
      end
    end

  end

  class UserRepo
    def find(id)
      convert_to_domain ActiveRecordRepo::Models::User.find(id), ::User
    end

    def save(domain_model)
      ar_model = convert_to_ar_model(domain_model)
      ar_model.save.tap do |success|
        domain_model.id = ar_model.id if success
      end
    end

    def find_by_login(login)
      convert_to_domain ActiveRecordRepo::Models::User.first_by_login(login), ::User
    end

    def find_by_login_token(type, token)
      convert_to_domain ActiveRecordRepo::Models::User.first_by_login_token(type, token), ::User
    end

    private

    def convert_to_domain(record, domain_class)
      domain_class.new record.attributes if record
    end

    def convert_to_ar_model(domain_model)
      if domain_model.persisted?
        ActiveRecordRepo::Models::User.find(domain_model.id).tap do |ar_model|
          ar_model.login = domain_model.login
          ar_model.email = domain_model.email
          ar_model.password_hash = domain_model.password_hash
          ar_model.login_tokens = domain_model.login_tokens
        end
      else
        ActiveRecordRepo::Models::User.new(
          :login => domain_model.login,
          :email => domain_model.email,
          :password_hash => domain_model.password_hash,
          :login_tokens => domain_model.login_tokens
        )
      end
    end
  end

  class CharacterRepo < IndexedRepo
    def find_by_user_and_id(user, id)
      find_one {|c|
        c.id == id &&
        c.user.id == user.id
      }
    end

    def find_all_for_user(user)
      find_all {|c| c.user == user }
    end

    def find_main_character(user, guild)
      find_one {|c|
        c.user == user &&
          c.guild == guild &&
          c.main?
      }
    end

    def find_all_in_guild(guild)
      find_all {|c| c.guild == guild }
    end

    def find_all_for_user_in_guild(user, guild)
      find_all { |char|
        char.user == user && char.guild == guild
      }
    end
  end

  class RaidRepo < IndexedRepo
    def find_raids_for_guild(guild)
      find_all {|r| r.owner == guild }
    end

    def find_raids_for_guild_and_day(guild, day)
      raids = find_raids_for_guild(guild)
      if day
        raids.select {|raid| raid.when == day }
      else
        raids
      end
    end
  end

  class SignupRepo < IndexedRepo
    def find_all_for_raid(raid)
      find_all {|s| s.raid == raid }
    end

    def find_all_for_user_and_raid(user, raid)
      find_all {|s|
        s.raid == raid && s.user == user
      }
    end

    def find_by_raid_and_id(raid, id)
      find_one {|s|
        s.id == id && s.raid == raid
      }
    end
  end

  class PermissionRepo < IndexedRepo
    def find_by_user_and_guild(user, guild)
      find_one {|perm|
        perm.user == user && perm.guild == guild
      }
    end
  end

  class CommentRepo < IndexedRepo
    def find_all_by_signup(signup)
      find_all {|c|
        c.signup == signup
      }
    end
  end
end
