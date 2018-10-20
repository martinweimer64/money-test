module Money
  module Test
    class Rate
      NUMBER_OF_DIGITS = 4
      @@base_currency = ''
      @@rates = {}

      class << self
        def load_conversions(base_currency:, rates:)
          @@base_currency = base_currency
          @@rates = rates
        end

        def update(rates:)
          @@rates = rates
        end

        def exchange_rate(from_currency:, to_currency:)
          if from_currency == to_currency
            1
          elsif base? from_currency
            from_base to: to_currency
          elsif base? to_currency
            to_base from: from_currency
          else
            convert from: from_currency, to: to_currency
          end
        end

        private

        def base?(currency)
          currency == base_currency
        end

        def convert(from:, to:)
          round(to_base(from: from) * from_base(to: to))
        end

        def from_base(to:)
          rates[to]
        end

        def to_base(from:)
          round(1 / rates[from])
        end

        def round(value)
          value.round NUMBER_OF_DIGITS
        end

        def base_currency
          @@base_currency
        end

        def rates
          @@rates
        end
      end
    end
  end
end
