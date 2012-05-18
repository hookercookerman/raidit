module InMemory
  class GuildRepo

    def initialize
      @guilds = []
    end

    def find(id)
      @guilds.find {|g| g.id == id }
    end

    def find_by_name(name)
      @guilds.find {|g| g.name == name }
    end

    def save(guild)
      @guilds << guild
    end
  end

  class UserRepo
    def initialize
      @users = []
    end

    def save(user)
      @users << user
    end

    def find_by_login_token(type, token)
      @users.find {|u| u.login_token(type) == token }
    end

    def all
      @users
    end
  end

  class CharacterRepo
    def initialize
      @characters = []
    end

    def save(character)
      @characters << character
    end

    def find_all_for_user(user)
      @characters.select {|c| c.user == user }
    end
  end

  class RaidRepo
    def initialize
      @raids = []
    end

    def save(raid)
      @raids << raid
    end

    def all
      @raids
    end
  end

  class SignupRepo
    def initialize
      @signups = []
    end

    def save(signup)
      @signups << signup
    end

    def all
      @signups
    end
  end

  class PermissionRepo
    def initialize
      @perms = []
    end

    def find_by_user_and_guild(user, guild)
      @perms.find {|perm|
        perm.user == user && perm.guild == guild
      }
    end

    def save(perm)
      @perms << perm
    end
  end
end