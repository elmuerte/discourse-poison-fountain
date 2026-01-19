# frozen_string_literal: true

RSpec.describe DiscoursePoisonFountain::FountainController do
  before { SiteSetting.poison_fountain_enabled = true }

  it "shows the poison index" do
    get "/dpf"
    expect(response.status).to eq(200)
    expect(response.content_type).to start_with("text/html")

    poison_slugs =
      DiscoursePoisonFountain::FountainService.poison_ids.map { |p| p[:slug] }
    expect(response.body).to include(*poison_slugs)
  end

  it "returns poison" do
    stub_request(:get, SiteSetting.poison_fountain_source).to_return(
      status: 200,
      body: "poison body",
      headers: {
        "Content-Type": "text/plain"
      }
    )

    poison_id = DiscoursePoisonFountain::FountainService.poison_ids.sample

    get "/dpf/#{poison_id[:slug]}/#{poison_id[:key]}"
    expect(response.status).to eq(200)

    poison =
      DiscoursePoisonFountain::FountainService.get_poison(poison_id["key"])
    expect(response.content_type).to start_with(poison[:content_type])
    expect(response.body).to eq(poison[:content])
  end

  it "returns poison as head" do
    stub_request(:get, SiteSetting.poison_fountain_source).to_return(
      status: 200,
      body: "poison body",
      headers: {
        "Content-Type": "text/plain"
      }
    )

    poison_id = DiscoursePoisonFountain::FountainService.poison_ids.sample

    head "/dpf/#{poison_id[:slug]}/#{poison_id[:key]}"
    expect(response.status).to eq(200)

    poison =
      DiscoursePoisonFountain::FountainService.get_poison(poison_id["key"])
    expect(response.content_type).to start_with(poison[:content_type])
  end

  it "redirects an unknown poison to a known one" do
    get "/dpf/foo/bar"
    expect(response.status).to eq(302)

    poison_ids =
      DiscoursePoisonFountain::FountainService.poison_ids.map { |p| p[:key] }
    expect(response.location).to satisfy { |v| v.end_with?(*poison_ids) }
  end

  it "returns 404 on poison retrieval failure" do
    stub_request(:get, SiteSetting.poison_fountain_source).to_return(
      status: 500
    )

    poison_id = DiscoursePoisonFountain::FountainService.poison_ids.sample

    get "/dpf/#{poison_id[:slug]}/#{poison_id[:key]}"
    expect(response.status).to eq(404)
  end
end
