require 'test_helper'

class MultiTenantSupport::ModelConcernTest < ActiveSupport::TestCase

  test '.belongs_to_tenant' do
    assert_equal accounts(:beer_stark), users(:jack).account
    assert_equal accounts(:fisher_mante), users(:william).account
    assert_equal accounts(:kohler), users(:robin).account
  end

end
