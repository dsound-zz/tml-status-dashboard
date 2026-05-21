module Api
  module V1
    class StatesController < ApplicationController
      def index
        states = State.includes(:state_status).order(:name)
        render json: StateBlueprint.render(states)
      end
    end
  end
end
