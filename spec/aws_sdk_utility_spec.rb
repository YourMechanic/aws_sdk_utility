# frozen_string_literal: true

RSpec.describe AwsSdkUtility do
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
      expect(AwsSdkUtility.bucket('some_bucket_name')).to be
    end
  end

  describe '.cdn' do
    it 'returns a AWS::CloudFront object' do
      AwsSdkUtility.amazon_key = 'some_key'
      AwsSdkUtility.amazon_access_key = 'some_key_val'
      expect(AwsSdkUtility.cdn).to be
    end
  end
end
