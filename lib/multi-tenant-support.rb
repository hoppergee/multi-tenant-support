require "multi_tenant_support/version"
require 'multi_tenant_support/railtie'
require "multi_tenant_support/errors"
require "multi_tenant_support/config/app"
require "multi_tenant_support/config/controller"
require "multi_tenant_support/config/model"
require "multi_tenant_support/config/console"
require "multi_tenant_support/current"
require "multi_tenant_support/find_tenant_account"
require "multi_tenant_support/concern/controller_concern"
require "multi_tenant_support/concern/model_concern"

module MultiTenantSupport

  module_function

  def configure(&block)
    instance_eval(&block)
  end

  def current_tenant
    Current.tenant_account
  end

  def current_tenant_id
    Current.tenant_account&.send(model.tenant_account_primary_key)
  end

  def set_current_tenant(tenant)
    Current.tenant_account = tenant
    Current.protection_state = PROTECTED
  end

  def under_tenant(tenant_account, &block)
    raise ArgumentError, "block is missing" if block.nil?

    Current.set(tenant_account: tenant_account, protection_state: PROTECTED) do
      yield
    end
  end

  def without_current_tenant(&block)
    raise ArgumentError, "block is missing" if block.nil?

    Current.set(tenant_account: nil) do
      yield
    end
  end

  def full_protected?
    current_tenant || Current.protection_state == PROTECTED
  end

  def allow_read_across_tenant?
    current_tenant.nil? && [PROTECTED_EXCEPT_READ, UNPROTECTED].include?(Current.protection_state)
  end

  def unprotected?
    current_tenant.nil? && Current.protection_state == UNPROTECTED
  end

  def turn_off_protection
    raise 'Cannot turn off protection, try wrap in without_current_tenant' if current_tenant

    if block_given?
      Current.set(protection_state: UNPROTECTED) do
        yield
      end
    else
      Current.protection_state = UNPROTECTED
    end
  end

  def allow_read_across_tenant
    raise 'Cannot read across tenant, try wrap in without_current_tenant' if current_tenant

    if block_given?
      Current.set(protection_state: PROTECTED_EXCEPT_READ) do
        yield
      end
    else
      Current.protection_state = PROTECTED_EXCEPT_READ
    end
  end

  def turn_on_full_protection
    if block_given?
      Current.set(protection_state: PROTECTED) do
        yield
      end
    else
      Current.protection_state = PROTECTED
    end
  end

end
