module Has
  require "has/#{ ::Rails.version < '3.1' ? 'railtie' : 'engine'}"
  require 'has/has.rb'
end