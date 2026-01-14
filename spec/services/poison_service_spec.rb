# frozen_string_literal: true

RSpec.describe DiscoursePoisonFountain::PoisonService do
  it "produces poison links" do
    SiteSetting.poison_fountain_link_count = 2
    controller = instance_double("ApplicationController", current_user: nil)
    allow(controller).to receive(:path) { |p| p }
    html = described_class.generate_poison_links(controller)
    expect(html).not_to be_nil
    expect(html.scan(%r{href="/dpf/[^/]+/[^/]+"}i).count).to eq(2)
  end

  it "does not produce poison links for authenticated users" do
    controller = instance_double("ApplicationController", current_user: double)
    html = described_class.generate_poison_links(controller)
    expect(html).to be_nil
  end
end
