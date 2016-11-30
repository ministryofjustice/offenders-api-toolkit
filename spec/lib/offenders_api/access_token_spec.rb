require 'spec_helper'
require 'timecop'

RSpec.describe OffendersApi::AccessToken do
  let(:value) { '6e78cefe9fbc959631cce781ad546a5c28b1a04d57321d534c2140f769a9f7b6' }
  let(:type) { 'bearer' }
  let(:expires_in) { 7200 }
  let(:created_at) { 1480354390 }
  let(:options) {
    {
      'value'      => value,
      'type'       => type,
      'expires_in' => expires_in,
      'created_at' => created_at
    }
  }
  let(:now) { Time.now.utc }

  subject(:token) { described_class.new(options) }

  specify { expect(token.value).to eq(value) }
  specify { expect(token.type).to eq(type) }
  specify { expect(token.expires_in).to eq(expires_in) }
  specify { expect(token.created_at).to eq(Time.at(created_at)) }

  context 'when no access token value is specified' do
    let(:options) { super().tap { |h| h.delete('value') } }
    specify {
      expect { described_class.new(options) }
        .to raise_error(KeyError, /key not found: :value/)
    }
  end

  context 'when no token type is specified' do
    let(:options) { super().tap { |h| h.delete('type') } }
    specify { expect(token.type).to eq(nil) }
  end

  context 'when no expires in is specified' do
    let(:options) { super().tap { |h| h.delete('expires_in') } }
    specify { expect(token.expires_in).to eq(0) }
  end

  context 'when no created at is specified' do
    let(:options) { super().tap { |h| h.delete('created_at') } }
    specify {
      Timecop.freeze(now) do
        expect(token.created_at.to_i).to eq(now.to_i)
      end
    }
  end

  describe '#expired?' do
    context 'when access token has expired' do
      let(:created_at) { now - expires_in }
      specify { expect(token.expired?).to be_truthy }
    end

    context 'when access token has not expired yet' do
      let(:created_at) { now }
      specify { expect(token.expired?).to be_falsey }
    end
  end

  describe '#valid?' do
    context 'when access token has expired' do
      let(:created_at) { now - expires_in }
      specify { expect(token.valid?).to be_falsey }
    end

    context 'when access token has not expired yet' do
      let(:created_at) { now }
      specify { expect(token.valid?).to be_truthy }
    end
  end

  describe '#expired_at' do
    context 'when neither "created at" and "expires in" were not provided' do
      let(:options) {
        super().tap { |h|
          %w(created_at expires_in).each { |key| h.delete(key) }
        }
      }
      specify { expect(token.expires_at.to_i).to eq(now.to_i) }
    end

    context 'when "created at" was not provided' do
      let(:options) { super().tap { |h| h.delete('created_at') } }
      specify { expect(token.expires_at.to_i).to eq((now + expires_in).to_i) }
    end

    context 'when "expires in" was not provided' do
      let(:options) { super().tap { |h| h.delete('expires_in') } }
      specify { expect(token.expires_at.to_i).to eq(created_at.to_i) }
    end

    specify { expect(token.expires_at.to_i).to eq((created_at + expires_in).to_i) }
  end
end
