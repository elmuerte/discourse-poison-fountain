# frozen_string_literal: true

DiscoursePoisonFountain::Engine.routes.draw do
  get "/" => "fountain#index"
  get "/:id" => "fountain#show"
end

Discourse::Application.routes.draw do
  mount ::DiscoursePoisonFountain::Engine,
        at: ::DiscoursePoisonFountain::MOUNT_POINT
end
