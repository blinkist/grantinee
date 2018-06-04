class Grantinee::Engine::Mysql

  def initialize
    # TODO Here establish the connection
  end

  def revoke_permissions!(data)
    query = "REVOKE ALL PRIVILEGES, GRANT OPTION FROM %{user}" % data
    ap query
  end

  def grant_permission(data)
    query = if data[:fields].empty?
      "GRANT %{kind} ON %{database}.%{table} TO '%{user}'@'%{host}';"
    else
      "GRANT %{kind}(%{fields}) ON %{database}.%{table} TO '%{user}'@'%{host}';"
    end % data
  end

end
