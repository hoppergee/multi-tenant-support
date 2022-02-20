module MultiTenantSupport
  module Asserts

    def multi_attempt_assert(failure_message)
      attempt = 0
      success = false

      loop do
        sleep 0.5

        success = yield 

        attempt += 1
        break if success
        break if attempt >= 4
      end

      assert success, failure_message
    end

    def wait_until(interval = 0.5, max_attempt = 4)
      attempt = 0
      success = false

      loop do
        sleep interval

        success = yield 

        attempt += 1
        break if success
        break if attempt >= max_attempt
      end
    end

  end
end