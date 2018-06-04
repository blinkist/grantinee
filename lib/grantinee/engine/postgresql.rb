class Grantinee::Engine::Postgresql

  def initialize
    # TODO Here establish the connection
  end

  def revoke_permissions!(data)
    query = "REVOKE ALL PRIVILEGES FROM %{user};" % data
    ap query
  end

  def grant_permission(data)
    query = if data[:fields].empty?
      "GRANT %{kind} ON %{table} TO %{user};"
    else
      "GRANT %{kind}(%{fields}) ON %{table} TO %{user};"
    end % data
  end

end
