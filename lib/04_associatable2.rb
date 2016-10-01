require_relative '03_associatable'

# Phase IV
module Associatable
  # Remember to go back to 04_associatable to write ::assoc_options

  def has_one_through(name, through_name, source_name)
    options = assoc_options

    define_method("#{name}") do
      primary_holder = self.send(options[through_name].primary_key)

      through = options[through_name].model_class.
      where(primary_holder => self.send(options[through_name].foreign_key))

      through.first.send("#{source_name}")
    end
  end
end
