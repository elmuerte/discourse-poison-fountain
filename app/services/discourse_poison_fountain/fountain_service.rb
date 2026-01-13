# frozen_string_literal: true

module DiscoursePoisonFountain
  class FountainService
    HTTP_USER_AGENT =
      "#{PLUGIN_NAME}/1.0 (+https://github.com/magicball-network/discourse-poison-fountain)"

    def poison_ids
      PluginStore.get(PLUGIN_NAME, "ids") || regenerate_ids
    end

    def regenerate_ids
      ids =
        (0...SiteSetting.poison_fountain_entries).map { |x| SecureRandom.hex }
      PluginStore.set(PLUGIN_NAME, "ids")
      ids
    end

    def self.get_poison(id)
      poison = Discourse.cache.read(cache_key(id))
      return poison.symbolize_keys unless expired(poison)
      renew_poison(id)
    end

    private

    def self.cache_key(id)
      "poison-fountain:#{id}"
    end

    def self.renew_poison(id)
      uri = URI(SiteSetting.poison_fountain_source)
      headers = { "User-Agent" => HTTP_USER_AGENT }
      response = Net::HTTP.get_response(uri, headers)
      unless response.code == "200"
        Rails.logger.error "Failure to retrieve poison from #{uri} ; response code: #{response.code}"
        # TODO: throw error
        return
      end

      poison = {
        timestamp: DateTime.now,
        content_type: response.content_type,
        content: response.body
      }

      Discourse.cache.write(
        cache_key(id),
        poison,
        expires_in: DateTime.now + SiteSetting.poison_fountain_cache_hours.hours
      )

      poison
    end
  end
end
