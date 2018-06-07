# frozen_string_literal: true

require "method_source"

module Permissions
  class Code
    def self.for(user, database: "grantinee_test", &block)
      %(
        on "#{database}" do
          user :#{user} do
            #{block.source.split("\n")[1..-2].join("\n")}
          end
        end
      )
    end
  end
end
