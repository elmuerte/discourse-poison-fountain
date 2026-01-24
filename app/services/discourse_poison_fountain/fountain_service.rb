# frozen_string_literal: true

module DiscoursePoisonFountain
  class FountainService
    HTTP_USER_AGENT =
      "#{PLUGIN_NAME}/1.0 (+https://github.com/elmuerte/discourse-poison-fountain)"

    def self.poison_ids
      ids = PluginStore.get(PLUGIN_NAME, "ids")
      return ids.map(&:symbolize_keys) if ids
      regenerate_ids
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

      unless SiteSetting.poison_fountain_textual_only &&
               textual?(response.content_type)
        Rails.logger.error "Did not receive textual content from #{uri} ; received content-type: #{response.content_type}"
        raise "Failure retrieving fresh textual poison"
      end

      if SiteSetting.poison_fountain_force_plain_text
        content_type = "text/plain"
      else
        content_type = response.content_type
      end

      poison = {
        timestamp: DateTime.now,
        content_type: content_type,
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

    TEXTUAL_MIME_TYPES = %w[
      application/json
      application/javascript
      application/rss+xml
      application/xhtml+xml
      application/xml
      application/xslt+xml
      application/x-javascript
      application/x-tex
      application/x-yaml
      application/yaml
    ]

    def self.textual?(content_type)
      return true if %r{text/.*}.match(content_type)
      mime_type = content_type.split(";")[0]
      TEXTUAL_MIME_TYPES.include?(mime_type)
    end
  end
end
