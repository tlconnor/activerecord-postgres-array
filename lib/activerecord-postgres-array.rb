require 'rails'

class ActiveRecordPostgresArray < Rails::Railtie

  initializer 'activerecord-postgres-array' do
    ActiveSupport.on_load :active_record do
      require "activerecord-postgres-array/activerecord"
    end
  end
end

require "activerecord-postgres-array/string"
require "activerecord-postgres-array/array"