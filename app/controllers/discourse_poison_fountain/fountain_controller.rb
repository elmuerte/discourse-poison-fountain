# frozen_string_literal: true

module DiscoursePoisonFountain
  class FountainController < ::ApplicationController
    requires_plugin PLUGIN_NAME
    layout false
    skip_before_action :check_xhr,
                       :redirect_to_login_if_required,
                       :redirect_to_profile_if_required,
                       :verify_authenticity_token

    def index
      # TODO redirect to random entry?
    end

    def show
      # if non-existing: redirect to random entry
      # optional: update entry if expired
      # serve content
    end
  end
end
