module MultiTenantSupport
  class Error < StandardError
  end

  class MissingTenantError < Error
  end
end
