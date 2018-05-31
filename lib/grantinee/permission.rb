class Grantinee::Permission
  KINDS = %i( usage select insert update )

  def initialize(kind, table, fields=nil)
    # ap [ "permission", kind, fields ]
    raise "Not implemented" unless KINDS.include? kind

    @table = table
    @kind = kind
    @fields = fields
  end

  def build_permission
    # ap [ "build_permission", @kind, @fields ]

    # MySQL

    permission = if @fields.nil? || @fields.empty?
      "GRANT #{@kind} ON {{DATABASE}}.#{@table} TO {{USER}}@{{HOST}};"
    else
      "GRANT #{@kind} (#{@fields.join(', ')}) ON {{DATABASE}}.#{@table} TO {{USER}}@{{HOST}};"
    end
    return permission
  end

end
