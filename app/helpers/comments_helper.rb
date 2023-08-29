module CommentsHelper
  def unit_options(units)
    options = units.map { |unit| [unit.number, unit.id] }
    options << ["Building", nil] # Adding "Building" option
    options
  end
end
