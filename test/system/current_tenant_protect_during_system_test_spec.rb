require_relative '../spec_helper'

RSpec.describe "current tenant protect during system test", type: :system do

  before do
    driven_by :rack_test
    Capybara.app_host = "http://amazon.example.com"
    MultiTenantSupport::Current.tenant_account = accounts(:amazon)
  end

  it "visit won't reset current tenant" do
    expect(MultiTenantSupport.current_tenant).to eq(accounts(:amazon))

    expect{
      visit users_path
    }.not_to change{ MultiTenantSupport.current_tenant }

    expect(page).to have_content("Users#index")
    expect(page).to have_selector("#id", text: accounts(:amazon).id.to_s)
    expect(page).to have_selector("#name", text: "Amazon")
    expect(page).to have_selector("#domain", text: "amazon.com")
    expect(page).to have_selector("#subdomain", text: "amazon")
  end

  it "refresh won't reset current tenant" do
    visit users_path

    expect(MultiTenantSupport.current_tenant).to eq(accounts(:amazon))

    expect{
      refresh
    }.not_to change{ MultiTenantSupport.current_tenant }
  end

  it "click_on won't reset current tenant" do
    visit users_path

    expect(MultiTenantSupport.current_tenant).to eq(accounts(:amazon))

    expect{
      click_on "Show"
    }.not_to change{ MultiTenantSupport.current_tenant }

    expect(page).to have_content("User - Show")
  end

  it "Element#click won't reset current tenant" do
    visit users_path

    expect(MultiTenantSupport.current_tenant).to eq(accounts(:amazon))

    expect{
      find_link("Show").click
    }.not_to change{ MultiTenantSupport.current_tenant }

    expect(page).to have_content("User - Show")
  end

end