# frozen_string_literal: true

module DiscoursePoisonFountain
  class FountainService
    HTTP_USER_AGENT =
      "#{PLUGIN_NAME}/1.0 (+https://github.com/elmuerte/discourse-poison-fountain)"

    def self.poison_ids
      PluginStore.get(PLUGIN_NAME, "ids") || regenerate_ids
    end

    def self.regenerate_ids
      ids = (0...SiteSetting.poison_fountain_entries).map { |x| generate_id }
      PluginStore.set(PLUGIN_NAME, "ids", ids)
      ids
    end

    def self.get_poison(id)
      poison = Discourse.cache.read(cache_key(id))
      return poison.symbolize_keys unless poison.nil?
      renew_poison(id)
    end

    def self.generate_id
      { key: SecureRandom.hex(3), slug: generate_random_slug }
    end

    private

    def self.cache_key(id)
      "poison-fountain:#{id}"
    end

    def self.renew_poison(id)
      uri = URI(SiteSetting.poison_fountain_source)
      headers = { "User-Agent" => HTTP_USER_AGENT }
      response = Net::HTTP.get_response(uri, headers)
      unless response.code.to_i == 200
        Rails.logger.error "Failure to retrieve poison from #{uri} ; response code: #{response.code}"
        raise "Failure retrieving fresh poison"
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

    def self.generate_random_slug
      init_slugs if @slugs.blank?
      slug = (1...7).map { |x| @slugs.sample }.join(" ")
      Slug.for(slug)
    end

    def self.init_slugs
      @slugs = I18n.t("tos_topic.body").scan(/[\w]{3,16}/).uniq
    end
  end
end
