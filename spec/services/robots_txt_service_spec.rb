# frozen_string_literal: true

RSpec.describe DiscoursePoisonFountain::RobotsTxtService do
  before(:example) do
    SiteSetting.poison_fountain_enabled = true
    SiteSetting.poison_fountain_update_robots_txt = true
  end

  it "will deny access to the fountain" do
    robots_info = {
      agents: [
        { name: "foobar", disallow: ["/"] },
        { name: "Googlebot", disallow: %w[/admin/ /auth/] },
        { name: "*", disallow: %w[/admin/ /auth/] }
      ]
    }

    described_class.on_robots_info(robots_info)

    expect(robots_info[:agents]).to eq(
      [
        { name: "foobar", disallow: ["/"] },
        { name: "Googlebot", disallow: %w[/admin/ /auth/ /dpf/] },
        { name: "*", disallow: %w[/admin/ /auth/ /dpf/] }
      ]
    )
  end
end
