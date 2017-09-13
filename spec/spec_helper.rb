$LOAD_PATH.unshift File.expand_path("../../lib", __FILE__)


require 'rubygems'
require 'rspec'
require 'active_model'
require 'action_dispatch'
require 'rspec/rails/extensions'

require 'excel_validator'

class TestModel
  include ActiveModel::Validations

  def initialize(attributes = {})
    @attributes = attributes
  end
  
  def read_attribute_for_validation(key)
    @attributes[key]
  end
end