module ApplicationService
  extend ActiveSupport::Concern

  included do
    def self.call(*args, **kargs)
      new(*args, **kargs).call
    end
  end
end
