class StateStatus < ApplicationRecord
  belongs_to :state

  validates :status, inclusion: { in: State::STATUSES }
  validates :state_id, uniqueness: true

  scope :down, -> { where(status: "down") }
  scope :planned_outage, -> { where(status: "planned_outage") }
  scope :up, -> { where(status: "up") }
end
