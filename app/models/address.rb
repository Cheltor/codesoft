class Address < ApplicationRecord
    def prettyadd
        "#{streetnumb} #{streetdirn} #{streetname} #{streettype} #{premisezip}"
    end
end
