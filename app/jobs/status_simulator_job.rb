class StatusSimulatorJob < ApplicationJob
  queue_as :default

  RECOVERY_AFTER_MINUTES = 6

  def perform
    ActiveRecord::Base.transaction do
      tick_all_statuses
      flip_random_down
      recover_stale_outages
      activate_planned_outages
    end
  end

  def self.schedule_next
    set(wait: 2.minutes).perform_later
  end

  private

  def tick_all_statuses
    StateStatus.update_all(
      "response_time_ms = GREATEST(50, response_time_ms + (FLOOR(RANDOM() * 31) - 15)::int),
       last_checked_at = NOW()"
    )
  end

  def flip_random_down
    up_ids = StateStatus.up.pluck(:id)
    return if up_ids.empty?

    count = [ 1, 2 ].sample
    target_ids = up_ids.sample(count)
    StateStatus.where(id: target_ids).update_all(status: "down", planned_outage_start: nil, planned_outage_end: nil, outage_reason: nil)
  end

  def recover_stale_outages
    cutoff = RECOVERY_AFTER_MINUTES.minutes.ago
    StateStatus.down
               .where("last_checked_at < ?", cutoff)
               .update_all(status: "up")
  end

  def activate_planned_outages
    now = Time.current

    # Mark as planned_outage when the window starts
    StateStatus.up
               .where("planned_outage_start <= ? AND planned_outage_end > ?", now, now)
               .update_all(status: "planned_outage")

    # Return to up when the window ends
    StateStatus.planned_outage
               .where("planned_outage_end <= ?", now)
               .where.not(planned_outage_start: nil)
               .update_all(status: "up", planned_outage_start: nil, planned_outage_end: nil, outage_reason: nil)
  end
end
