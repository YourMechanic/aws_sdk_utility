# frozen_string_literal: true

require 'aws-sdk'
require 'aws_sdk_utility'

# rubocop:disable Metrics/BlockLength

RSpec.describe AwsSdkUtility do
  let(:s3_bucket) { AwsSdkUtility.s3_bucket = 'test.yourmechanic.com' }
  before(:each) do
    AwsSdkUtility.s3_bucket = 'some_bucket'
    AwsSdkUtility.amazon_key = 'amazon_key'
    AwsSdkUtility.amazon_access_key = 'amazon_access_key'
    AwsSdkUtility.s3_endpoint = 's3.amazonaws.com'
    client = Aws::S3::Client.new(stub_responses: true)
  end

  it 'has a version number' do
    expect(AwsSdkUtility::VERSION).not_to be nil
  end

  describe '.amazon_key' do
    it 'returns a amazon_key set by amazon_key=' do
      AwsSdkUtility.amazon_key = 'some_key'
      expect(AwsSdkUtility.amazon_key).to be
    end
  end

  describe '.bucket' do
    it 'returns a bucket' do
      puts AwsSdkUtility.bucket
      expect(AwsSdkUtility.bucket).to be
    end
  end

  describe '.cdn' do
    it 'returns a AWS::CloudFront object' do
      AwsSdkUtility.amazon_key = 'some_key'
      AwsSdkUtility.amazon_access_key = 'some_key_val'
      expect(AwsSdkUtility.cdn).to be
    end
  end

  # write test store file on s3_store_file
  describe '.s3_store_file' do
    it 'returns a s3file url' do
      stub_request(:head, 'https://s3.amazonaws.com/some_bucket/test')
        .to_return(status: 200, body: '', headers: {})
      stub_request(:put, 'https://s3.amazonaws.com/some_bucket/test')
        .to_return(status: 200, body: '', headers: {})
      allow(AwsSdkUtility).to receive(:doomsday).and_return('Mon, 18 Jan 2038 00:00:00 PST -08:00')
      expect(AwsSdkUtility.s3_store_file('test', File.open('spec/fixtures/test_file.txt'))).to be
    end
  end

  describe '.s3_download_file' do
    it 'downloads a file form s3' do
      stub_request(:get, 'https://s3.amazonaws.com/some_bucket/test')
        .to_return(body: File.open('spec/fixtures/test_file.txt'))
      expect(AwsSdkUtility.s3_download_file('test', File.open('spec/fixtures/test_file.txt'))).to be nil
    end
  end

  describe '.s3_download_large_file' do
    it 'downloads a large file form s3' do
      stub_request(:get, 'https://s3.amazonaws.com/test.yourmechanic.com/test')
        .to_return(body: File.open('spec/fixtures/test_file.txt'))
      expect(AwsSdkUtility.s3_download_large_file('test',
                                                  File.open('spec/fixtures/test_file.txt'),
                                                  bucket: 'test.yourmechanic.com')).to be nil
    end
  end

  describe '.s3_copy' do
    it 'copies file from one bucket to another' do
      stub_request(:head, 'https://s3.amazonaws.com/some_bucket/test')
        .to_return(status: 200, body: '', headers: {})
      stub_request(:put, 'https://s3.amazonaws.com/some_bucket/test2')
        .to_return(status: 200, body: '', headers: {})
      expect(AwsSdkUtility.s3_copy('test', {}, 'test2', {})).to be
    end
  end

  describe '.s3_delete' do
    it 'returns a delete a s3 file' do
      stub_request(:head, 'https://s3.amazonaws.com/some_bucket/test')
        .to_return(status: 200, body: '', headers: {})
      stub_request(:delete, 'https://s3.amazonaws.com/some_bucket/test')
        .to_return(status: 200, body: '', headers: {})
      expect(AwsSdkUtility.s3_delete('test')).to be nil
    end
  end

  describe '.s3_get_object' do
    it 'returns a get a s3 object' do
      stub_request(:head, 'https://s3.amazonaws.com/some_bucket/test')
        .to_return(status: 200, body: '', headers: {})
      stub_request(:get, 'https://s3.amazonaws.com/some_bucket/test')
        .to_return(status: 200, body: 'hello', headers: {})

      expect(AwsSdkUtility.s3_get_object('test').read).to be 'hello'
    end
  end
end

# rubocop:enable Metrics/BlockLength
