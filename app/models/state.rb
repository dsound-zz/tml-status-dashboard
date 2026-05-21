class State < ApplicationRecord
  has_one :state_status, dependent: :destroy

  STATUSES = %w[up planned_outage down].freeze

  validates :name, :abbreviation, :department_name, presence: true
  validates :abbreviation, uniqueness: true, length: { is: 2 }
end
