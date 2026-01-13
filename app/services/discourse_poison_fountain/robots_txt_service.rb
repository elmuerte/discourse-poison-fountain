# frozen_string_literal: true

module DiscoursePoisonFountain
  class RobotsTxtService
    def self.on_robots_info(robots_info)
      unless SiteSetting.poison_fountain_enabled &&
               SiteSetting.poison_fountain_update_robots_txt
        return
      end
      deny_all = "#{Discourse.base_path}/"
      deny_path = Discourse.base_path + MOUNT_POINT + "/"
      robots_info[:agents].each do |agent|
        next unless agent[:name] == "*" || agent[:name] == "Googlebot"
        next if agent[:disallow].include?(deny_all)
        agent[:disallow] << deny_path
      end
    end
  end
end
