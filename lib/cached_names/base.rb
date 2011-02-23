module CachedNames

  def has_cached_names name_method = "value", options = {}
    @cached_names_name_method = name_method
    @cached_names_sort_field = options[:sorted_by] || @cached_names_name_method
    @cached_names_group_method = options[:grouped_by]
    @cached_names_cache_key_prefix = "cached_names_#{self}"
    @cached_names_loaded = false

    after_save { self.load_cached_names }
    after_destroy { self.load_cached_names }

    load_cached_names
  end

  def names
    load_cached_names unless @cached_names_loaded

    begin
      Rails.cache.read "#{@cached_names_cache_key_prefix}_names"
    rescue
      load_cached_names
      Rails.cache.read "#{@cached_names_cache_key_prefix}_names"
    end
  end

  def names_with_deleted
    load_cached_names unless @cached_names_loaded

    begin
      Rails.cache.read "#{@cached_names_cache_key_prefix}_names_with_deleted"
    rescue
      load_cached_names
      Rails.cache.read "#{@cached_names_cache_key_prefix}_names_with_deleted"
    end
  end

  def names_group key
    load_cached_names unless @cached_names_loaded

    begin
      Rails.cache.read "#{@cached_names_cache_key_prefix}_names_group_#{key}"
    rescue
      load_cached_names
      Rails.cache.read "#{@cached_names_cache_key_prefix}_names_group_#{key}"
    end
  end

  def names_group_with_deleted key
    load_cached_names unless @cached_names_loaded

    begin
      Rails.cache.read "#{@cached_names_cache_key_prefix}_names_group_#{key}_with_deleted"
    rescue
      load_cached_names
      Rails.cache.read "#{@cached_names_cache_key_prefix}_names_group_#{key}_with_deleted"
    end
  end

  def load_cached_names
    begin
      @cached_names_instances = all(:with_deleted => true, :order => @cached_names_sort_field)

      load_names
      load_grouped_names if @cached_names_group_method

      @cached_names_loaded = true
    rescue Exception => e
      Rails.logger.error e.message
      Rails.logger.error e.backtrace
      @cached_names_loaded = false
    end
  end

  private

  def load_names
    names = @cached_names_instances.map {|i| [i.deleted?, [i.send(@cached_names_name_method), i.id]] }
    all_names, non_deleted_names = partition_by_deleted names

    Rails.cache.write "#{@cached_names_cache_key_prefix}_names_with_deleted", all_names
    Rails.cache.write "#{@cached_names_cache_key_prefix}_names", non_deleted_names
  end

  def load_grouped_names
    groups = @cached_names_instances.inject({}) do |groups, instance|
      value = instance.send(@cached_names_group_method)

      groups[value] ||= []
      groups[value] << [instance.deleted?, [instance.send(@cached_names_name_method), instance.id]]

      groups
    end

    # when the value is nil, this means it is universal to all groups
    universal_names = groups[nil] || []

    groups.each do |(key, names)|
      all_names, non_deleted_names = partition_by_deleted(names + universal_names)

      Rails.cache.write "#{@cached_names_cache_key_prefix}_names_group_#{key}_with_deleted", all_names
      Rails.cache.write "#{@cached_names_cache_key_prefix}_names_group_#{key}", non_deleted_names
    end
  end

  def partition_by_deleted names
    all_names = names.map {|(deleted, name_id_pair)| name_id_pair }
    non_deleted_names = names.map {|(deleted, name_id_pair)| name_id_pair unless deleted }.compact

    [all_names, non_deleted_names]
  end
end

