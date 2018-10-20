module Money
  module Test
    class Money
      attr_reader :amount, :currency

      def initialize(amount, currency)
        @amount = amount
        @currency = currency
      end

      def inspect
        sprintf '%.2f %s', @amount, @currency
      end

      def convert_to(new_currency)
        Money.new exchange_amount(new_currency), new_currency
      end

      def +(other)
        Money.new amount + other.exchange_amount(currency), currency
      end

      def -(other)
        Money.new amount - other.exchange_amount(currency), currency
      end

      def *(multiply)
        Money.new amount * multiply, currency
      end

      def /(divide)
        Money.new amount / divide, currency
      end

      def ==(other)
        compare with: other, operator: :==
      end

      def >(other)
        compare with: other, operator: :>
      end

      def <(other)
        compare with: other, operator: :<
      end

      def exchange_amount(new_currency)
        @amount * exchange_rate(new_currency)
      end

      private

      def exchange_rate(new_currency)
        Rate.exchange_rate(from_currency: @currency, to_currency: new_currency)
      end

      def compare(operator:, with:)
        amount.send(operator, with.exchange_amount(currency))
      end
    end
  end
end