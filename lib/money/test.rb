require "money/test/version"
require "money/test/rate"
require "money/test/money"

module Money
  module Test
    class << self
      def conversion_rates(base_currency, rates)
        Rate.load_conversions base_currency: base_currency, rates: rates
      end
    end
  end
end
