class ApplicationRecord < ActiveRecord::Base
  require 'date'
  self.abstract_class = true
end
