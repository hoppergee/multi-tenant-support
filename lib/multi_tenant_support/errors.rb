module MultiTenantSupport
  class Error < StandardError
  end

  class MissingTenantError < Error
  end

  class ImmutableTenantError < Error
  end

  class NilTenantError < Error
  end
end
