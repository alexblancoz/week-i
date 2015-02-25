class Score < ActiveRecord::Base
  #Associations
  belongs_to :user

  #Validations
  validates :amount, length: { in: 2..100 }, presence: true, greater_than_or_equal_to: 1, less_than_or_equal_to: 100
  validates :observations, length: { in: 2..240 }, presence: true

end
