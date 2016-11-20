require_relative 'db_connection'
require_relative 'sql_object'

module Searchable
  def where(params)
    where_line = params.keys.map{ |key| "#{key}= ?"}.join('AND ')
    objects = DBConnection.execute(<<-SQL, *params.values)
      SELECT
        *
      FROM
        #{self.table_name}
      WHERE
        #{where_line}
    SQL

    objects.map{ |obj| self.new(obj) }
  end
end

class SQLObject
  extend Searchable
end
