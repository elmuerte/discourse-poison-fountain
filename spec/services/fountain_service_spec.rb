# frozen_string_literal: true

RSpec.describe DiscoursePoisonFountain::FountainService do
  describe "id generation" do
    it "(re)generates ids" do
      ids = described_class.regenerate_ids
      expect(ids.length).to eq(SiteSetting.poison_fountain_entries)
    end

    it "returns the generated ids" do
      expected_ids = described_class.poison_ids
      actual_ids = described_class.poison_ids
      expect(actual_ids).to eq(expected_ids)
    end

    it "generates new entries when the config changes" do
      SiteSetting.poison_fountain_entries = 7
      described_class.regenerate_ids
      SiteSetting.poison_fountain_entries = 13
      ids = described_class.regenerate_ids
      expect(ids.length).to eq(13)
    end
  end

  it "returns poison which is cached" do
    stub_request(:get, SiteSetting.poison_fountain_source).to_return(
      status: 200,
      body: "poison body",
      headers: {
        "Content-Type": "text/plain"
      }
    )

    poison_id = described_class.poison_ids.sample
    poison = described_class.get_poison(poison_id)

    expect(poison[:content_type]).to eq("text/plain")
    expect(poison[:content]).to eq("poison body")

    poison_again = described_class.get_poison(poison_id)
    expect(poison_again[:content]).to eq(poison[:content])

    expect(
      a_request(:get, SiteSetting.poison_fountain_source)
    ).to have_been_made.once
  end

  it "throws an error when the request fails" do
    stub_request(:get, SiteSetting.poison_fountain_source).to_return(
      status: 404,
      body: "poison body"
    )

    poison_id = described_class.poison_ids.sample
    expect { described_class.get_poison(poison_id) }.to raise_error(
      "Failure retrieving fresh poison"
    )
  end

  it "it forces plain text" do
    stub_request(:get, SiteSetting.poison_fountain_source).to_return(
      status: 200,
      body: "<b>html content</b>",
      headers: {
        "Content-Type": "text/html"
      }
    )

    poison_id = described_class.poison_ids.sample
    poison = described_class.get_poison(poison_id)

    expect(poison[:content_type]).to eq("text/plain")
  end

  it "it forwards the source content type" do
    SiteSetting.poison_fountain_force_plain_text = false
    stub_request(:get, SiteSetting.poison_fountain_source).to_return(
      status: 200,
      body: "<b>html content</b>",
      headers: {
        "Content-Type": "text/html"
      }
    )

    poison_id = described_class.poison_ids.sample
    poison = described_class.get_poison(poison_id)

    expect(poison[:content_type]).to eq("text/html")
  end

  it "it only accepts textual content" do
    SiteSetting.poison_fountain_force_plain_text = false
    stub_request(:get, SiteSetting.poison_fountain_source).to_return(
      status: 200,
      body: "<b>html content</b>",
      headers: {
        "Content-Type": "text/markdown; charset=utf8"
      }
    )

    poison_id = described_class.poison_ids.sample
    poison = described_class.get_poison(poison_id)

    expect(poison[:content_type]).to eq("text/markdown")
  end

  it "it rejects binary content" do
    SiteSetting.poison_fountain_force_plain_text = false
    stub_request(:get, SiteSetting.poison_fountain_source).to_return(
      status: 200,
      body: "PNG",
      headers: {
        "Content-Type": "image/png"
      }
    )

    poison_id = described_class.poison_ids.sample
    expect { described_class.get_poison(poison_id) }.to raise_error(
      "Failure retrieving fresh textual poison"
    )
  end
end
