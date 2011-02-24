module CachedNames
  class Railtie < Rails::Railtie
    initializer "cached_names.initialize" do |app|
      if defined?(ActiveRecord)
        ActiveRecord::Base.send :extend, CachedNames
        if defined?(ActsAsParanoid)
          ActiveRecord::Base.send :extend, CachedNames::Paranoid
          CachedNames.paranoid_loaded = true
        end
      end
    end
  end
end
