describe SimpleAspect do
  it 'has a version number' do
    expect(SimpleAspect::VERSION).not_to be nil
  end

  describe '.aspect_around' do
    subject(:aspect_around) do
      dummy_class.new(dependency).perform(first, second, &block)
    end

    let(:block) { proc { |dependency| dependency.from_block } }

    let(:dummy_class) do
      Struct.new(:dependency) do
        extend(SimpleAspect)

        aspect_around(:perform) do |*args, &orig|
          dependency.pre(*args)
          orig.call
          dependency.post(*args)
        end

        def perform(first, second)
          yield(dependency) if block_given?
          dependency.invoke(first, second)
        end
      end
    end

    let(:dependency) { double(:dependency) }
    let(:first) { 'first' }
    let(:second) { 'second' }
    let(:result) { 'a-result' }

    before do
      allow(dependency).to receive(:invoke).and_return(result)
      allow(dependency).to receive(:from_block)
      allow(dependency).to receive(:pre)
      allow(dependency).to receive(:post)
    end

    it { is_expected.to be(result) }

    it do
      expect(dependency).to receive(:invoke).with(first, second)

      aspect_around
    end

    it do
      expect(dependency).to receive(:from_block)

      aspect_around
    end

    it do
      expect(dependency).to receive(:pre).with(first, second)

      aspect_around
    end

    it do
      expect(dependency).to receive(:post).with(first, second)

      aspect_around
    end

    context 'when using a symbol instead of a block' do
      let(:dummy_class) do
        Struct.new(:dependency) do
          extend(SimpleAspect)

          aspect_around(:perform, :around_perform)

          def perform(first, second)
            yield(dependency) if block_given?
            dependency.invoke(first, second)
          end

          private

          def around_perform(*args)
            dependency.pre(*args)
            yield
            dependency.post(*args)
          end
        end
      end

      it { is_expected.to be(result) }

      it do
        expect(dependency).to receive(:invoke).with(first, second)

        aspect_around
      end

      it do
        expect(dependency).to receive(:from_block)

        aspect_around
      end

      it do
        expect(dependency).to receive(:pre).with(first, second)

        aspect_around
      end

      it do
        expect(dependency).to receive(:post).with(first, second)

        aspect_around
      end
    end
  end
end
