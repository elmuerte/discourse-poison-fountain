# frozen_string_literal: true

module ::DiscoursePoisonFountain
  class Engine < ::Rails::Engine
    engine_name PLUGIN_NAME
    isolate_namespace DiscoursePoisonFountain
  end
end
