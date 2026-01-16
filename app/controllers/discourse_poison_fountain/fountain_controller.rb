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
      id = FountainService.poison_ids.sample
      redirect_to_poison(id)
    end

    def show
      id = params[:id] || "#unknown"
      ids = FountainService.poison_ids
      unless ids.any? { |x| x[:key] == id }
        return redirect_to_poison(ids.sample)
      end
      poison = FountainService.get_poison(id)

      if request.head?
        head :ok, content_type: poison[:content_type]
      else
        render plain: poison[:content], content_type: poison[:content_type]
      end
    rescue StandardError => error
      Rails.logger.error("Failure serving poison: #{error}")
      head :not_found
    end

    private

    def redirect_to_poison(id)
      redirect_to path(
                    "#{DiscoursePoisonFountain::MOUNT_POINT}/#{id[:slug]}/#{id[:key]}"
                  )
    end
  end
end
