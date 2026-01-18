# frozen_string_literal: true

module DiscoursePoisonFountain
  class PoisonService
    def self.generate_poison_links(controller)
      return unless controller.current_user.nil?

      poison =
        FountainService.poison_ids.sample(
          SiteSetting.poison_fountain_link_count
        )

      links = poison.map { |entry| generate_link(controller, entry) }.join(" ")

      "
      <div
        class=\"discourse-pf-links\"
        aria-hidden=\"true\"
        style=\"position: absolute; left: -100px; top: -100px; overflow: hidden; width: 0; height: 0; margin: 0; padding: 0;\"
      >
        #{links}
      </div>
      "
    end

    def self.generate_link(controller, entry)
      uri =
        controller.path(
          "#{DiscoursePoisonFountain::MOUNT_POINT}/#{entry[:slug]}/#{entry[:key]}"
        )
      "<a href=\"#{uri}\" rel=\"nofollow\">#{entry[:slug].gsub("-", " ")}</a>"
    end
  end
end
