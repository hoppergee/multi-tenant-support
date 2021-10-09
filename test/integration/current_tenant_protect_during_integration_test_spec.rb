require_relative "../spec_helper"

RSpec.describe "Current tenant protect during integration test", type: :request do

  before do
    host! "amazon.example.com"
    MultiTenantSupport::Current.tenant_account = accounts(:amazon)
  end

  it "get won't reset current tenant" do
    expect(MultiTenantSupport.current_tenant).to eq(accounts(:amazon))
    get users_path
    expect(response.status).to eq(200)
    expect(MultiTenantSupport.current_tenant).to eq(accounts(:amazon))
  end

  it "post won't reset current tenant" do
    expect(MultiTenantSupport.current_tenant).to eq(accounts(:amazon))
    post users_path
    assert_redirected_to users_path
    expect(MultiTenantSupport.current_tenant).to eq(accounts(:amazon))
  end

  it "patch won't reset current tenant" do
    expect(MultiTenantSupport.current_tenant).to eq(accounts(:amazon))
    patch user_path(id: 1)
    assert_redirected_to users_path
    expect(MultiTenantSupport.current_tenant).to eq(accounts(:amazon))
  end

  it "put won't reset current tenant" do
    expect(MultiTenantSupport.current_tenant).to eq(accounts(:amazon))
    put user_path(id: 1)
    expect(MultiTenantSupport.current_tenant).to eq(accounts(:amazon))
  end

  it "delete won't reset current tenant" do
    expect(MultiTenantSupport.current_tenant).to eq(accounts(:amazon))
    delete user_path(id: 1)
    expect(MultiTenantSupport.current_tenant).to eq(accounts(:amazon))
  end

end
