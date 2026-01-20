# frozen_string_literal: true

module ::DiscoursePoisonFountain::Jobs
  class RegeneratePoison < ::Jobs::Scheduled
    every 1.months

    def execute(args)
      return unless SiteSetting.poison_fountain_enabled
      DiscoursePoisonFountain::FountainService.regenerate_ids
    end
  end
end
