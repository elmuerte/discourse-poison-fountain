# frozen_string_literal: true

# name: discourse-poison-fountain
# about: Poison fountain for Discourse
# meta_topic_id:
# version: 0.1
# authors: elmuerte
# url: https://github.com/elmuerte/discourse-poison-fountain
# required_version: 3.5.0

enabled_site_setting :poison_fountain_enabled

module ::DiscoursePoisonFountain
  PLUGIN_NAME = "discourse-poison-fountain"
  MOUNT_POINT = "/dpf"
end

require_relative "lib/discourse_poison_fountain/engine"

after_initialize do
  on(:robots_info) do |robots_info|
    DiscoursePoisonFountain::RobotsTxtService.on_robots_info(robots_info)
  end

  register_html_builder("server:before-body-close") do |controller|
    return unless SiteSetting.poison_fountain_enabled
    DiscoursePoisonFountain::PoisonService.generate_poison_links(controller)
  end
end
