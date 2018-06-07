# frozen_string_literal: true

# TODO: if queries are really the same, we can refactor this...
module QueryHelpers
  def query(db, command)
    case command.to_s
    when "insert"
      create_query_for(db)
    when "select"
      select_query_for(db)
    when "update"
      update_query_for(db)
    when "delete"
      delete_query_for(db)
    end
  end

  def create_query_for(db)
    case db.to_s
    when "mysql"
      mysql_client.query("INSERT INTO users (id) VALUES ('just_doing_me');")
    when "postgresql"
      postgresql_client.exec("INSERT INTO users(id) VALUES('just_doing_me');")
    end
  end

  def select_query_for(db)
    case db.to_s
    when "mysql"
      mysql_client.query("SELECT id, anonymized FROM users;")
    when "postgresql"
      postgresql_client.exec("SELECT id, anonymized FROM users;")
    end
  end

  def update_query_for(db)
    case db.to_s
    when "mysql"
      mysql_client.query("UPDATE users SET anonymized = true;")
    when "postgresql"
      postgresql_client.exec("UPDATE users SET anonymized = true;")
    end
  end

  def delete_query_for(db)
    case db.to_s
    when "mysql"
      mysql_client.query("DELETE FROM users;")
    when "postgresql"
      postgresql_client.exec("DELETE FROM users;")
    end
  end
end
