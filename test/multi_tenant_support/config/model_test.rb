require "test_helper"

class MultiTenantSupport::Config::ModelTest < ActiveSupport::TestCase

  setup do
    @model_config = MultiTenantSupport::Config::Model.new
  end

  test "#tenant_account_class_name and #tenant_account_class_name=" do
    assert_raise "tenant_account_class is missing" do
      @model_config.tenant_account_class_name
    end

    @model_config.tenant_account_class_name = 'Account'
    assert_equal 'Account', @model_config.tenant_account_class_name
  end

  test "#tenant_account_primary_key and #tenant_account_primary_key=" do
    assert_equal :id, @model_config.tenant_account_primary_key

    @model_config.tenant_account_primary_key = :uuid
    assert_equal :uuid, @model_config.tenant_account_primary_key
  end

  test "#default_foreign_key and #default_foreign_key=" do
    @model_config.tenant_account_class_name = 'Account'
    assert_equal :account_id, @model_config.default_foreign_key

    @model_config.default_foreign_key = :tenant_id
    assert_equal :tenant_id, @model_config.default_foreign_key

    @model_config.default_foreign_key = :tenant_account_id
    assert_equal :tenant_account_id, @model_config.default_foreign_key
  end

end
