require 'byebug'
require_relative '02_searchable'
require 'active_support/inflector'

# Phase IIIa
class AssocOptions
  attr_accessor(
    :foreign_key,
    :class_name,
    :primary_key
  )

  def model_class
    @class_name.constantize
  end

  def table_name
    @class_name.constantize.send(:table_name)
  end
end

class BelongsToOptions < AssocOptions
  def initialize(name, options = {})
    options[:primary_key] ||= :id
    options[:foreign_key] ||= "#{name}_id".to_sym
    options[:class_name] ||=  name.to_s.singularize.capitalize
    @foreign_key = options[:foreign_key]
    @primary_key = options[:primary_key]
    @class_name = options[:class_name]
    @options = options
  end
end

class HasManyOptions < AssocOptions
  def initialize(name, self_class_name, options = {})
    options[:primary_key] ||= :id
    options[:foreign_key] ||= "#{self_class_name.downcase}_id".to_sym
    options[:class_name] ||=  name.to_s.singularize.capitalize
    @foreign_key = options[:foreign_key]
    @primary_key = options[:primary_key]
    @class_name = options[:class_name]
    @options = options
  end
end

module Associatable
  # Phase IIIb
  def belongs_to(name, options = {})
    options = BelongsToOptions.new(name, options)
    assoc_options["#{name}".to_sym] = options

    define_method("#{name}") do
      primary_holder = self.send(options.primary_key)
      options.model_class.where(primary_holder => self.send(options.foreign_key)).first
    end
  end

  def has_many(name, options = {})
    options = HasManyOptions.new(name, self.to_s , options)
    assoc_options["#{name}".to_sym] = options

    define_method("#{name}") do
      primary_holder = self.send(options.primary_key)
      options.model_class.where(options.foreign_key => primary_holder)
    end
  end

  def assoc_options
    # Wait to implement this in Phase IVa. Modify `belongs_to`, too.
    @assocs ||= {}
  end
end

class SQLObject
  extend Associatable
  # Mixin Associatable here...
end
