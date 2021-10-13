require 'test_helper'

module TestActiveJob
  module TestAdapter
    class PreconfiguredPerformNowTest < ActiveSupport::TestCase
      include ActiveJob::TestHelper

      setup do
        Rails.application.configure do
          config.active_job.queue_adapter = :test
        end
      end

      test 'update succes update user when tenant account match' do
        under_tenant(amazon) do
          assert_no_changes 'MultiTenantSupport.current_tenant' do
            UserNameUpdateJob.set(queue: :integration_tests).perform_now(bezos)
          end

          assert_equal "Jeff Bezos UPDATE", bezos.reload.name
        end
      end

      test 'fail to update user when tenant account is missing' do
        without_current_tenant do
          assert_no_changes 'MultiTenantSupport.current_tenant' do
            assert_raise MultiTenantSupport::MissingTenantError do
              UserNameUpdateJob.set(queue: :integration_tests).perform_now(bezos)
            end
          end
        end

        under_tenant(amazon) do
          assert_equal "Jeff Bezos", @bezos.reload.name # Does not change
        end
      end

      test 'fail to update user when tenant account is not match' do
        under_tenant(apple) do
          assert_no_changes 'MultiTenantSupport.current_tenant' do
            assert_raise MultiTenantSupport::InvalidTenantAccess do
              UserNameUpdateJob.set(queue: :integration_tests).perform_now(bezos)
            end
          end
        end

        under_tenant(amazon) do
          assert_equal "Jeff Bezos", @bezos.reload.name # Does not change
        end
      end

    end
  end
end