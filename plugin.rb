# frozen_string_literal: true

# name: discourse-poison-fountain
# about: Poison fountain for Discourse
# meta_topic_id:
# version: 0.1
# authors: elmuerte
# url: https://github.com/magicball-network/poison-fountain
# required_version: 3.5.0

enabled_site_setting :poison_fountain_enabled

module ::DiscoursePoisonFountain
  PLUGIN_NAME = "discourse-poison-fountain"
end

after_initialize do
end
