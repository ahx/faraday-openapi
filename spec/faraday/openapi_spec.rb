# frozen_string_literal: true

RSpec.describe Faraday::Openapi do
  describe '.register' do
    it 'adds an OAD' do
      described_class.register('spec/data/dice.yaml')
      expect(described_class[:default]['info']['title']).to eq 'Dice API'
    end

    it 'raises an error if :default was already registered' do
      described_class.register('spec/data/dice.yaml')
      expect { described_class.register('spec/data/dice.yaml') }.to raise_error described_class::AlreadyRegisteredError
    end

    it 'adds an OAD under a custom name' do
      described_class.register('spec/data/dice.yaml', as: :dice)
      expect(described_class[:dice]['info']['title']).to eq 'Dice API'
    end
  end

  describe '.[]' do
    it 'returns an error if nothing was registered' do
      expect { described_class[:default] }.to raise_error described_class::NotRegisteredError
    end

    it 'returns the registered OAD' do
      described_class.register('spec/data/dice.yaml')
      expect(described_class[:default]['info']['title']).to eq 'Dice API'
    end
  end
end
