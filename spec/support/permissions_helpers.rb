# frozen_string_literal: true

require "method_source"

module Permissions
  class Code
    def self.for(user, permissions = nil, database: "grantinee_test", &block)
      permissions = if permissions
                      if permissions.source.match(/lambda do/)
                        permissions.source.split(/do|end/)[1..-2].first
                      else
                        permissions.source.split(/{|}/)[1..-2].first
                      end
                    else
                      block.source.split("\n")[1..-2].join("\n")
                    end

      %(
        on "#{database}" do
          user :#{user} do
            #{permissions}
          end
        end
      )
    end
  end
end
