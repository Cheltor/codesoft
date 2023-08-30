module CitationsHelper
  def unit_options(units)
    options = [["Building", nil]] # Adding "Building" option as the first element
    options += units.map { |unit| [unit.number, unit.id] }
    options
  end
end
