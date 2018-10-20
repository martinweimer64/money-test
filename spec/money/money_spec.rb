equire "spec_helper"

module Money
  module Test
    RSpec.describe Money do
      let(:first_currency) { 'EUR' }
      let(:second_currency) { 'USD' }
      let(:first_amount) { Faker::Number.decimal(2, 2).to_f }
      let(:second_amount) { Faker::Number.decimal(2, 2).to_f }
      let(:rate) { Faker::Number.decimal(1, 3).to_f }
      let(:first_object) { Money.new(first_amount, first_currency)}

      describe '#initialize' do
        let(:subject) { Money.new(first_amount, first_currency)}

        it 'sets amount' do
          expect(subject.instance_variable_get(:@amount)).to eq(first_amount)
        end

        it 'sets currency' do
          expect(subject.instance_variable_get(:@currency)).to eq(first_currency)
        end
      end

      describe '#inspect' do
        it 'returns amount and currency' do
          expect(Money.new(15, 'USD').inspect).to eq '15.00 USD'
        end

        it 'returns amount and currency' do
          expect(Money.new(21, 'EUR').inspect).to eq '21.00 EUR'
        end
      end

      describe '#convert_to' do
        let(:subject) { Money.new(first_amount, first_currency)}
        before :each do
          allow(subject).to receive(:exchange_rate).with(second_currency) { rate }
        end

        it 'creates new money object' do
          expect(subject.convert_to(second_currency).object_id).not_to eq subject.object_id
        end

        it 'changes amount' do
          expect(subject.convert_to(second_currency).amount).to eq(rate * first_amount)
        end

        it 'changes currency' do
          expect(subject.convert_to(second_currency).currency).to eq(second_currency)
        end
      end

      describe '#+' do

        context 'with same currency' do
          let(:second_object) { Money.new(second_amount, first_currency)}
          before :each do
            allow(second_object).to receive(:exchange_rate).with(first_currency) { 1 }
          end

          it 'sums value' do
            expect((first_object + second_object).amount).to eq(first_amount + second_amount)
          end

          it 'has first currency' do
            expect((first_object + second_object).currency).to eq(first_currency)
          end
        end

        context 'with different currency' do
          let(:second_object) { Money.new(second_amount, second_currency)}
          before :each do
            allow(second_object).to receive(:exchange_rate).with(first_currency) { rate }
          end

          it 'sums value' do
            expect((first_object + second_object).amount).to eq(first_amount + second_amount * rate)
          end

          it 'has first currency' do
            expect((first_object + second_object).currency).to eq(first_currency)
          end
        end
      end

      describe '#-' do
        context 'with same currency' do
          let(:second_object) { Money.new(second_amount, first_currency)}
          before :each do
            allow(second_object).to receive(:exchange_rate).with(first_currency) { 1 }
          end

          it 'sums value' do
            expect((first_object - second_object).amount).to eq(first_amount - second_amount)
          end

          it 'has first currency' do
            expect((first_object - second_object).currency).to eq(first_currency)
          end
        end

        context 'with different currency' do
          let(:second_object) { Money.new(second_amount, second_currency)}
          before :each do
            allow(second_object).to receive(:exchange_rate).with(first_currency) { rate }
          end

          it 'sums value' do
            expect((first_object - second_object).amount).to eq(first_amount - second_amount * rate)
          end

          it 'has first currency' do
            expect((first_object - second_object).currency).to eq(first_currency)
          end
        end
      end

      describe '#*' do
        let(:multiply) { Faker::Number.positive(0, 25)}

        it 'multiplies amount' do
          expect((first_object * multiply).amount).to eq(first_amount * multiply)
        end

        it 'keeps currency' do
          expect((first_object * multiply).currency).to eq(first_currency)
        end
      end

      describe '#/' do
        let(:divide) { Faker::Number.positive(0, 25)}

        it 'divides amount' do
          expect((first_object / divide).amount).to eq(first_amount / divide)
        end

        it 'keeps currency' do
          expect((first_object / divide).currency).to eq(first_currency)
        end
      end

      describe '#==' do
        context 'with same currency' do
          before :each do
            allow(second_object).to receive(:exchange_rate).with(first_currency) { 1 }
          end

          context 'with equal value' do
            let(:second_object) { Money.new(first_amount, first_currency) }
            it 'is equal' do
              expect(first_object == second_object).to be_truthy
            end
          end

          context 'with different value' do
            let(:second_object) { Money.new(second_amount, first_currency) }
            it 'is not equal' do
              expect(first_object == second_object).to be_falsey
            end
          end
        end

        context 'with different currency' do
          before :each do
            allow(second_object).to receive(:exchange_rate).with(first_currency) { rate }
          end

          context 'with equal exchange value' do
            let(:second_object) { Money.new(first_amount / rate, second_currency) }
            it 'is equal' do
              expect(first_object == second_object).to be_truthy
            end
          end

          context 'with equal value' do
            let(:second_object) { Money.new(first_amount, second_currency) }
            it 'is different' do
              expect(first_object == second_object).to be_falsey
            end
          end
        end
      end

      describe '#>' do
        context 'with same currency' do
          before :each do
            allow(second_object).to receive(:exchange_rate).with(first_currency) { 1 }
          end

          context 'bigger amount' do
            let(:second_object) { Money.new(first_amount - 1, first_currency) }
            it 'is true' do
              expect(first_object > second_object).to be_truthy
            end
          end

          context 'smaller amount' do
            let(:second_object) { Money.new(first_amount, first_currency) }
            it 'is false' do
              expect(first_object > second_object).to be_falsey
            end
          end
        end

        context 'with different currency' do
          context 'with smaller amount, but bigger exchange' do
            let(:second_object) { Money.new(first_amount * 2, second_currency) }
            it 'is true' do
              allow(second_object).to receive(:exchange_rate).with(first_currency) { 1/4 }
              expect(first_object > second_object).to be_truthy
            end
          end

          context 'bigger amount, but smaller exchange' do
            let(:second_object) { Money.new(first_amount / 2, second_currency) }
            it 'is false' do
              allow(second_object).to receive(:exchange_rate).with(first_currency) { 4 }
              expect(first_object > second_object).to be_falsey
            end
          end
        end
      end

      describe '#<' do
        context 'with same currency' do
          before :each do
            allow(second_object).to receive(:exchange_rate).with(first_currency) { 1 }
          end

          context 'smaller amount' do
            let(:second_object) { Money.new(first_amount + 1, first_currency) }
            it 'is true' do
              expect(first_object < second_object).to be_truthy
            end
          end

          context 'bigger amount' do
            let(:second_object) { Money.new(first_amount, first_currency) }
            it 'is false' do
              expect(first_object < second_object).to be_falsey
            end
          end
        end

        context 'with different currency' do
          context 'bigger amount, but smaller exchange' do
            let(:second_object) { Money.new(first_amount / 2, second_currency) }
            it 'is true' do
              allow(second_object).to receive(:exchange_rate).with(first_currency) { 4 }
              expect(first_object < second_object).to be_truthy
            end
          end

          context 'smaller amount, but bigger exchange' do
            let(:second_object) { Money.new(first_amount * 2, second_currency) }
            it 'is false' do
              allow(second_object).to receive(:exchange_rate).with(first_currency) { 1/3 }
              expect(first_object < second_object).to be_falsey
            end
          end
        end
      end
    end
  end
end
