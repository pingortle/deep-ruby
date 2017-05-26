describe Deep do
  subject { Object.new }

  before do
    subject.extend Deep
  end

  describe '#deep' do
    it 'should call the block' do
      expect { |block| subject.deep(&block) }.to yield_control
    end

    it 'should call the block with self' do
      subject.deep { |parameter| expect(parameter).to be subject }
    end

    context 'with an enumerable' do
      subject { (1..10) }
      let(:successive_args) { [subject, *subject] }

      shared_examples 'collections' do
        it 'should call the block with each element' do
          expect { |block| subject.deep(&block) }
            .to yield_successive_args *successive_args
        end

        it 'should always yield an unwrapped object' do
          subject.deep do |object|
            expect(object.class.ancestors).to_not include Deep
          end
        end
      end
      include_examples 'collections'

      context 'with nested enumerables' do
        subject { [super(), :a, :b, :c] }
        let(:successive_args) do
          [
            subject,
            subject[0],
            *subject[0],
            *subject[1..-1]
          ]
          end

        include_examples 'collections'

        context 'within a hash' do
          subject { { data: super() } }
          let(:successive_args) do
            [
              subject,
              [:data, subject[:data]],
              :data,
              subject[:data],
              subject[:data][0],
              *subject[:data][0],
              *subject[:data][1..-1]
            ]
          end

          include_examples 'collections'
        end
      end
    end
  end
end
