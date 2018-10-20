require "spec_helper"

module Money
  module Test
    RSpec.describe Rate do
      let(:base) { 'EUR' }
      let(:rates) do
        { 'USD' => 1.15,
          'BIT' => 0.00018

        }
      end

      describe '@load_rates' do
        it 'adds base currency' do
          Rate.load_conversions(base_currency: base, rates: rates)
          expect(Rate.class_variable_get(:@@base_currency)).to eq(base)
        end

        it 'adds rates' do
          Rate.load_conversions(base_currency: base, rates: rates)
          expect(Rate.class_variable_get(:@@rates)).to eq(rates)
        end
      end

      describe '@exchange_rate' do
        let(:currency) { 'USD' }
        before :each do
          allow(Rate).to receive(:base_currency) { base }
          allow(Rate).to receive(:rates) { rates }
        end

        it 'returns EUR/USD rate' do
          expect(Rate.exchange_rate(from_currency: base, to_currency: currency)). to eq(rates[currency])
        end

        it 'returns USD/EUR rate' do
          expect(Rate.exchange_rate(from_currency: currency, to_currency: base)). to eq(0.87719)
        end

        it 'returns USD/BIT rate' do
          expect(Rate.exchange_rate(from_currency: currency, to_currency: 'BIT')). to eq(0.00202)
        end

        it 'returns EUR/EUR rate' do
          expect(Rate.exchange_rate(from_currency: base, to_currency: base)). to eq(1)
        end
      end
    end
  end
end
