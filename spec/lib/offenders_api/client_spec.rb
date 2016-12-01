require 'spec_helper'

RSpec.describe OffendersApi::Client do

  describe 'initialize' do
    shared_examples_for 'mandatory option missing' do
      it 'raises a KeyError' do
        expect{
          described_class.new(options)
        }.to raise_error(KeyError, /key not found: #{mandatory_option.inspect}/)
      end
    end

    context 'when the client id is not provided' do
      let(:mandatory_option) { :client_id }
      let(:options) {
        {
          client_secret: '6973263cb1a04a5ef495d2e6936d0f8275e00be5ea5426872f70526d7daaacea',
          base_url: 'https://prisoners-api.herokuapp.com'
        }
      }

      include_examples 'mandatory option missing'
    end

    context 'when the client secret is not provided' do
      let(:mandatory_option) { :client_secret }
      let(:options) {
        {
          client_id: '674e1e2d62b8c95b5aa096b5b4af2a3975463a4b0194ece247f52360505fe9ia0',
          base_url: 'https://prisoners-api.herokuapp.com'
        }
      }

      include_examples 'mandatory option missing'
    end

    context 'when the base URL is not provided' do
      let(:mandatory_option) { :base_url }
      let(:options) {
        {
          client_id: '674e1e2d62b8c95b5aa096b5b4af2a3975463a4b0194ece247f52360505fe9ia0',
          client_secret: '6973263cb1a04a5ef495d2e6936d0f8275e00be5ea5426872f70526d7daaacea'
        }
      }

      include_examples 'mandatory option missing'
    end

    context 'when all the mandatory options are provided' do
      let(:options) {
        {
          client_id: '674e1e2d62b8c95b5aa096b5b4af2a3975463a4b0194ece247f52360505fe9ia0',
          client_secret: '6973263cb1a04a5ef495d2e6936d0f8275e00be5ea5426872f70526d7daaacea',
          base_url: 'https://prisoners-api.herokuapp.com'
        }
      }

      it 'does not raise a KeyError' do
        expect {
          described_class.new(options)
        }.not_to raise_error
      end
    end
  end

  describe '#authorize' do
    let(:client_id) { '674e1e2d62b8c95b5aa096b5b4af2a3975463a4b0194ece247f52360505fe9a0' }
    let(:client_secret) { '6973263cb1a04a5ef495d2e6936d0f8275e00be5ea5426872f70526d7daaacea' }
    let(:base_url) { 'https://prisoners-api.herokuapp.com' }
    let(:options) {
      {
        client_id: client_id,
        client_secret: client_secret,
        base_url: base_url
      }
    }
    let(:authorization_uri) { "#{base_url}/oauth/token" }
    let(:authorization_query) {
      {
        client_id: client_id,
        client_secret: client_secret,
        grant_type: 'client_credentials'
      }
    }
    let(:headers) {
      {
        'Connection' => 'close',
        'Host' => 'prisoners-api.herokuapp.com',
        'User-Agent' => 'http.rb/2.1.0',
        'Accept' => 'application/json'
      }
    }

    subject(:client) { described_class.new(options) }

    let(:successful_body) {
      {
        access_token: '6e78cefe9fbc959631cce781ad546a5c28b1a04d57321d534c2140f769a9f7b6',
        token_type: 'bearer',
        expires_in: 7200,
        created_at: 1480354390
      }.to_json
    }
    let(:response_headers) {
      {
        'Content-Type' => 'application/json'
      }
    }
    let(:http_status) { 200 }

    before do
      stub_post(authorization_uri)
        .with(headers: headers, query: authorization_query)
        .to_return(body: successful_body, status: http_status)
    end

    it 'requests a new access token for the client' do
      client.authorize
      expect(a_post(authorization_uri).with(query: authorization_query)).to have_been_made
    end

    it 'sets an access token from the retrieved information' do
      client.authorize
      expect(client.access_token).to be_kind_of(OffendersApi::AccessToken)
    end

    context 'when the request is not successful' do
      let(:http_status) { 201 }

      it 'does not set an access token' do
        client.authorize
        expect(client.access_token).to eq(nil)
      end
    end
  end

  describe '#get' do
    let(:client_id) { '674e1e2d62b8c95b5aa096b5b4af2a3975463a4b0194ece247f52360505fe9a0' }
    let(:client_secret) { '6973263cb1a04a5ef495d2e6936d0f8275e00be5ea5426872f70526d7daaacea' }
    let(:base_url) { 'https://prisoners-api.herokuapp.com' }
    let(:options) {
      {
        client_id: client_id,
        client_secret: client_secret,
        base_url: base_url
      }
    }
    let(:authorization_uri) { "#{base_url}/oauth/token" }
    let(:authorization_query) {
      {
        client_id: client_id,
        client_secret: client_secret,
        grant_type: 'client_credentials'
      }
    }
    let(:headers) {
      {
        'Connection' => 'close',
        'Host' => 'prisoners-api.herokuapp.com',
        'User-Agent' => 'http.rb/2.1.0',
        'Accept' => 'application/json'
      }
    }
    let(:access_token) { '6e78cefe9fbc959631cce781ad546a5c28b1a04d57321d534c2140f769a9f7b6' }
    let(:token_type) { 'bearer' }
    let(:successful_body) {
      {
        access_token: access_token,
        token_type: token_type,
        expires_in: 7200,
        created_at: Time.now.utc.to_i
      }.to_json
    }
    let(:authorization_http_status) { 200 }
    let(:get_uri) { "#{base_url}/api/offenders/search" }
    let(:get_query) { { access_token: access_token } }
    let(:get_response_body) { {}.to_json }
    let(:get_response_status) { 200 }
    let(:get_response_headers) {
      {
        'Context-Type' => 'application/json'
      }
    }

    subject(:client) { described_class.new(options) }

    shared_examples_for 'GET request' do
      it 'performs the autenticated request' do
        client.get '/offenders/search'
        expect(a_get(get_uri).with(query: get_query)).to have_been_made
      end

      it 'returns the HTTP response' do
        response = client.get '/offenders/search'
        expect(response).to be_kind_of(HTTP::Response)
        expect(response.status).to eq(get_response_status)
        expect(response.body.to_s).to eq(get_response_body)
      end

      context 'when query params are provided' do
        let(:get_query) {
          {
            access_token: access_token,
            param1: 'foo',
            param2: 'bar'
          }
        }

        it 'performs the autenticated request with the provided params' do
          client.get '/offenders/search', params: { param1: 'foo', param2: 'bar' }
          expect(a_get(get_uri).with(query: get_query)).to have_been_made
        end
      end
    end

    before do
      stub_post(authorization_uri)
        .with(headers: headers, query: authorization_query)
        .to_return(body: successful_body, status: authorization_http_status)
      stub_get(get_uri)
        .with(headers: headers, query: get_query)
        .to_return(body: get_response_body, status: get_response_status, headers: get_response_headers)
    end

    context 'when the client is not yet authorized' do
      it 'requests a new access token for the client' do
        client.get '/offenders/search'
        expect(a_post(authorization_uri).with(query: authorization_query)).to have_been_made
      end

      context 'but the authorization request fails' do
        let(:authorization_http_status) { 401 }

        before do
          stub_post(authorization_uri)
            .with(headers: headers, query: authorization_query)
            .to_return(body: successful_body, status: authorization_http_status)
        end

        it 'does not request a new access token for the client' do
          client.get '/offenders/search'
          expect(a_post(authorization_uri).with(query: authorization_query)).to have_been_made
        end

        it 'does not perform the authenticated request' do
          client.get '/offenders/search'
          expect(a_get(get_uri).with(query: get_query)).not_to have_been_made
        end
      end

      include_examples 'GET request'
    end

    context 'when the client is already authorized' do
      let(:valid_access_token) { FactoryGirl.build(:access_token, :valid) }

      before do
        allow(client).to receive(:access_token).and_return(valid_access_token)
      end

      it 'does not request a new access token for the client' do
        client.get '/offenders/search'
        expect(a_post(authorization_uri).with(query: authorization_query)).to_not have_been_made
      end

      include_examples 'GET request'
    end
  end
end
