require 'byebug'
require_relative 'db_connection'
require 'active_support/inflector'
# NB: the attr_accessor we wrote in phase 0 is NOT used in the rest
# of this project. It was only a warm up.

class SQLObject
  def self.columns
    return @columns if @columns
    @query_result = DBConnection.execute2(<<-SQL)
      SELECT *
      FROM #{table_name}
    SQL
    @columns = @query_result.first.map(&:to_sym)
  end

  def self.finalize!
    self.columns.each do |col|
      attr_accessor col #setter getter for all column names
      #setter and getters for column values stored in attributes
      define_method("#{col}") do
        attributes[col]
      end
      define_method("#{col}=") do |val|
        attributes[col] = val
      end
    end
  end

  def self.table_name=(table_name)
    @table_name = table_name
    attr_accessor :table_name
  end

  def self.table_name
    @table_name = "#{self.name.downcase}s"
  end

  def self.all
    all = DBConnection.execute(<<-SQL)
      SELECT *
      FROM #{table_name}
    SQL

    all.map{ |obj| self.new(obj) }
  end

  def self.parse_all(results)
    results.map{ |obj| self.new(obj) }
  end

  def self.find(id)
    obj = DBConnection.execute(<<-SQL, id)
      SELECT *
      FROM #{table_name}
      WHERE id = ?
    SQL
    return nil if obj.empty?
    self.new(obj.first)
  end

  def initialize(params = {})
    params.each do |var, val|
      raise Exception, "unknown attribute '#{var}'" unless self.class.columns.include?(var.to_sym)
      
      self.send("#{var}=", val)
    end
  end

  def attributes
    @attributes ||= {}
  end

  def attribute_values
    attributes.values
  end

  def insert

    sanitizer = attributes.values.map{ |v| "?" }.join(', ')
    columns = self.class.columns.drop(1).join(', ')
    DBConnection.execute(<<-SQL, *attributes.values)
      INSERT INTO
        #{self.class.table_name} (#{columns})
      VALUES
        (#{sanitizer})
    SQL

    self.id = DBConnection.last_insert_row_id
  end

  def update
    columns = self.class.columns.drop(1).
    map{ |col| "#{col} = ?" }.join(', ')
    vals = attributes.values.drop(1) + [id]

    DBConnection.execute(<<-SQL, *vals)
      UPDATE
        #{self.class.table_name}
      SET
        #{columns}
      WHERE
       id = ?
    SQL
  end

  def save
    id ? update : insert
  end
end
