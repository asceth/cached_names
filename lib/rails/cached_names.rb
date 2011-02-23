module CachedNames
  class Railtie < Rails::Railtie
    initializer "cached_names.initialize" do |app|
      ActiveRecord::Base.send :extend, CachedNames if defined?(ActiveRecord)
    end
  end
end
