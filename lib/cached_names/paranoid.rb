module CachedNames
  module ParanoidMethods

    def names_with_deleted
      load_paranoid_cached_names unless @cached_names_loaded

      begin
        Rails.cache.read cache_key('names_with_deleted')
      rescue
        load_paranoid_cached_names
        Rails.cache.read cache_key('names_with_deleted')
      end
    end

    def names_group_with_deleted key
      load_paranoid_cached_names unless @cached_names_loaded

      begin
        Rails.cache.read group_cache_key(key, 'names_group_with_deleted')
      rescue
        load_paranoid_cached_names
        Rails.cache.read group_cache_key(key, 'names_group_with_deleted')
      end
    end

    def load_paranoid_cached_names
      begin
        @paranoid_cached_names_instances = with_deleted.all(:order => @cached_names_sort_field)

        load_names(@paranoid_cached_names_instances, 'names_with_deleted')
        load_grouped_names(@paranoid_cached_names_instances, 'names_group_with_deleted') if @cached_names_group_method

        @paranoid_cached_names_loaded = true
      rescue Exception => e
        Rails.logger.error e.message
        Rails.logger.error e.backtrace
        @paranoid_cached_names_loaded = false
      end
    end
  end
end
