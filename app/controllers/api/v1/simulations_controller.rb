module Api
  module V1
    class SimulationsController < ApplicationController
      def trigger
        StatusSimulatorJob.perform_later
        render json: { triggered: true }
      end
    end
  end
end
