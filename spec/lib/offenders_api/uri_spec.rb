require 'spec_helper'

RSpec.describe OffendersApi::URI do
  let(:uri_str) { 'https://test.com' }

  subject(:uri) { described_class.new(uri_str) }

  describe '#to_s' do
    specify { expect(uri.to_s).to eq('https://test.com') }

    context 'and host needs to be normalized' do
      let(:uri_str) { 'https://test.com/' }
      specify { expect(uri.to_s).to eq('https://test.com') }
    end

    context 'when a path is provided' do
      let(:uri_str) { 'https://test.com/path1/path//' }
      specify { expect(uri.to_s).to eq('https://test.com/path1/path') }

      context 'and the path is not normalized' do
        let(:uri_str) { 'https://test.com//path1/path2/' }
        specify { expect(uri.to_s).to eq('https://test.com/path1/path2') }
      end
    end

    context 'when a query string is provided' do
      let(:uri_str) { 'https://test.com/path1/search?param1=foo&param2=bar' }
      specify { expect(uri.to_s).to eq('https://test.com/path1/search?param1=foo&param2=bar') }

      context 'and the path is not normalized' do
        let(:uri_str) { 'https://test.com//path1/search/?param1=foo&param2=bar' }
        specify { expect(uri.to_s).to eq('https://test.com/path1/search?param1=foo&param2=bar') }
      end
    end
  end
end
