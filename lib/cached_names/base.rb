module CachedNames

  @@paranoid_loaded ||= false
  def self.paranoid_loaded=(value)
    @@paranoid_loaded = value
  end
  def self.paranoid_loaded
    @@paranoid_loaded
  end

  def has_cached_names name_method = "value", options = {}
    @cached_names_name_method = name_method
    @cached_names_sort_field = options[:sorted_by] || @cached_names_name_method
    @cached_names_group_method = options[:grouped_by]
    @cached_names_cache_key_prefix = "cached_names_#{self}"
    @cached_names_loaded = false

    after_save { self.class.load_cached_names }
    after_destroy { self.class.load_cached_names }

    load_cached_names
    load_paranoid_cached_names if CachedNames.paranoid_loaded
  end

  def names
    load_cached_names unless @cached_names_loaded

    begin
      Rails.cache.read cache_key
    rescue
      load_cached_names
      Rails.cache.read cache_key
    end
  end

  def names_group key
    load_cached_names unless @cached_names_loaded

    begin
      Rails.cache.read group_cache_key(key)
    rescue
      load_cached_names
      Rails.cache.read group_cache_key(key)
    end
  end

  def load_cached_names
    begin
      @cached_names_instances = all(:order => @cached_names_sort_field)

      load_names(@cached_names_instances)
      load_grouped_names(@cached_names_instances) if @cached_names_group_method

      @cached_names_loaded = true
    rescue Exception => e
      Rails.logger.error e.message
      Rails.logger.error e.backtrace
      @cached_names_loaded = false
    end
  end

  private

  def load_names(cached_instances, cache_suffix = 'names')
    all_names = cached_instances.map {|i| [i.send(@cached_names_name_method), i.id] }

    Rails.cache.write cache_key(cache_suffix), all_names
  end

  def load_grouped_names(cached_instances, cache_suffix = 'names_group')
    groups = cached_instances.inject({}) do |groups, instance|
      value = instance.send(@cached_names_group_method)

      groups[value] ||= []
      groups[value] << [instance.send(@cached_names_name_method), instance.id]

      groups
    end

    # when the value is nil, this means it is universal to all groups
    universal_names = groups[nil] || []

    groups.each do |(key, names)|
      all_names = names + universal_names

      Rails.cache.write group_cache_key(key, cache_suffix), all_names
    end
  end

  def cache_key(cache_suffix = 'names')
    "#{@cached_names_cache_key_prefix}_#{cache_suffix}"
  end

  def group_cache_key(key, cache_suffix = 'names_group')
    "#{@cached_names_cache_key_prefix}_#{key}_#{cache_suffix}"
  end
end

