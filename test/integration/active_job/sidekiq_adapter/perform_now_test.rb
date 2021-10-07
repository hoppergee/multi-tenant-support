require 'test_helper'

module TestActiveJob
  module SidekiqAdapter
    class PeroformNowTest < ActiveSupport::TestCase

      test 'update succes update user when tenant account match' do
        under_tenant(amazon) do
          UserNameUpdateJob.perform_now(bezos)

          assert_equal "Jeff Bezos UPDATE", bezos.reload.name
        end
      end

      test 'fail to update user when tenant account is missing' do
        under_tenant nil do
          assert_raise(MultiTenantSupport::MissingTenantError) do
            UserNameUpdateJob.perform_now(bezos)
          end
        end

        under_tenant(amazon) do
          assert_equal "Jeff Bezos", @bezos.reload.name # Does not change
        end
      end

      test 'fail to update user when tenant account is not match' do
        under_tenant(apple) do
          assert_raise(MultiTenantSupport::InvalidTenantAccess) do
            UserNameUpdateJob.perform_now(bezos)
          end
        end

        under_tenant(amazon) do
          assert_equal "Jeff Bezos", @bezos.reload.name # Does not change
        end
      end

    end
  end
end
