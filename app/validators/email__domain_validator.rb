class EmailDomainValidator < ActiveModel::EachValidator
    def validate_each(record, attribute, value)
      domain = value.split("@").last
      unless domain == "example.com"
        record.errors[attribute] << (options[:message] || "is not a valid domain")
      end
    end
  end
  