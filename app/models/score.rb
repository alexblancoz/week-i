class Score < ActiveRecord::Base

  #associations
  belongs_to :user
  belongs_to :group

  #validations
  validates :innovation_score, numericality: { only_integer: true, greater_than_or_equal_to: 1, less_than_or_equal_to: 5 }, presence: true
  validates :creativity_score, numericality: { only_integer: true, greater_than_or_equal_to: 1, less_than_or_equal_to: 5 }, presence: true
  validates :business_model_score, numericality: { only_integer: true, greater_than_or_equal_to: 1, less_than_or_equal_to: 5 }, presence: true
  validates :modeling_tools_score, numericality: { only_integer: true, greater_than_or_equal_to: 1, less_than_or_equal_to: 5 }, presence: true
  validates :functionality_score, numericality: { only_integer: true, greater_than_or_equal_to: 1, less_than_or_equal_to: 5 }, presence: true
  validates :observations, length: { in: 5..512 }, allow_nil: true
  validates :user_id, numericality: { only_integer: true }, uniqueness: { scope: :group_id }, presence: true
  validates :group_id, numericality: { only_integer: true }, presence: true

  #selects
  scope :base, ->{ select('scores.id, scores.innovation_score, scores.creativity_score, scores.functionality_score, scores.business_model_score, scores.modeling_tools_score') }
  scope :base_groups, ->{ select('groups.id AS group_id, groups.name AS group_name, groups.member_count AS group_member_count') }
  scope :base_users, ->{ select('users.name AS user_name, users.last_names AS user_last_names') }

  #joins
  scope :with_groups, ->(user_id){ joins('RIGHT JOIN groups ON groups.id = scores.group_id AND scores.user_id = ' + sanitize(user_id)) }
  scope :with_users, ->{ joins('INNER JOIN users ON users.id = groups.owner_id') }

  #wheres
  scope :filter_by_score, ->{ where('scores.id IS NOT NULL') }
  scope :filter_by_no_score, ->{ where('scores.id IS NULL') }

  #methods
  def score
    @score ||= self.innovation_score + self.creativity_score + self.business_model_score + self.modeling_tools_score + self.functionality_score unless self.innovation_score.nil?
  end

end
