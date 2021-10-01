class UserNameUpdateJob < ApplicationJob
  queue_as :integration_tests

  def perform(user)
    user.update(name: user.name + " UPDATE")
  end
end