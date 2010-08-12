class OptionFor < Hash
  require 'yaml'

  def self.method_missing(method, *args)
    @@option_for ||= self.new
    @@option_for.send method, args
  end
  
  def initialize(*args)
    super
    self.replace(args.first || YAML.load(File.read(File.join(Rails.root, "config", "option_for.yml"))) )
    
  end
  
  def method_missing(method, *args)
    if has_key?(method.to_s)
      value = read_key(method.to_s)
      if value.is_a?(Hash)
        OptionFor.new value
      else
        puts ":::: #{value}"
        eval(value) rescue value
      end
    else
      begin
        super
      rescue NoMethodError => e
        raise ArgumentError, "OptionFor does not have a key named \"#{method}\"."
      end
    end
  end
  
  def read_key(item)
    read_user_key read_environment_key(self[item])
  end
  
  def read_environment_key(item)
    if item.is_a?(Hash)
      item[Rails.env] || item['default'] || item
    else
      item
    end
  end
  
  def read_user_key(item)
    if item.is_a?(Hash)
      item[ENV['USER'].downcase] || item[ENV['USER'].downcase] || item['default'] || item
    else
      item
    end
  end
  
end
