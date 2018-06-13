# frozen_string_literal: true

require "method_source"
require "byebug"

# TODO: refactor this bs to use meta programming to call DSL using a "spec translator"
module Permissions
  class Code
    class << self
      def for(users, permissions = nil, database: "grantinee_test", &block)
        if permissions.is_a?(Array)
          unless users.count == permissions.count
            raise "number of permissioned users (#{users.count} doesn't match "\
                  "number of permissions (#{permissions.count}"
          end

          for_multiple(users, permissions, database, &block)
        elsif !users.is_a?(Array) && !permissions.is_a?(Array)
          for_single(users, permissions, database, &block)
        else
          raise "Both permissions and users have to be array, but "\
                "only #{users.is_a?(Array) ? 'users' : 'permissions'} is array"
        end
      end

      private

      def for_single(user, permissions, database, &block)
        permissions = parse_permissions(permissions, block)
        write_grantinee_format_single(database, user, permissions)
      end

      def write_grantinee_format_single(database, user, permissions)
        %(
          on "#{database}" do
            user :#{user} do
              #{permissions}
            end
          end
        )
      end

      def for_multiple(users, permissions, database, &block)
        permissions = permissions.map do |user_permissions|
          parse_permissions(user_permissions, block)
        end

        write_grantinee_format_multiple(database, users, permissions)
      end

      def write_grantinee_format_multiple(database, users, permissions)
        user_permissions = users.each_with_index.map do |user, index|
          %(
            user :#{user} do
              #{permissions[index]}
            end
          )
        end

        %(
          on "#{database}" do
            #{user_permissions.join("\n")}
          end
        )
      end

      def parse_permissions(permissions, block)
        if permissions
          if permissions.source =~ /lambda do/
            permissions.source.split(/do|end/)[1..-2].first
          else
            permissions.source.split(/{|}/)[1..-2].first
          end
        else
          block.source.split("\n")[1..-2].join("\n")
        end
      end
    end
  end
end
