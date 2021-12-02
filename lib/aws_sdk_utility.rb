# frozen_string_literal: true

require_relative 'aws_sdk_utility/version'
require 'aws-sdk'
require 'byebug'

# rubocop:disable Metrics/ModuleLength

# AwsSdkUtility
module AwsSdkUtility
  module_function

  def s3_bucket
    @s3_bucket
  end

  def s3_bucket=(value)
    @s3_bucket = value
  end

  def s3_image
    @s3_image
  end

  def s3_image=(value)
    @s3_image = value
  end

  def amazon_key
    @amazon_key
  end

  def amazon_key=(value)
    @amazon_key = value
  end

  def amazon_access_key
    @amazon_access_key
  end

  def amazon_access_key=(value)
    @amazon_access_key = value
  end

  # region
  def region
    @region
  end

  def region=(value)
    @region = value
  end

  def config
    AWS.config(access_key_id: AwsSdkUtility.amazon_key,
               secret_access_key: AwsSdkUtility.amazon_access_key,
               region: AwsSdkUtility.region)
    AWS.config(s3_endpoint: AwsSdkUtility.s3_endpoint)
  end

  def s3_endpoint
    @s3_endpoint
  end

  def s3_endpoint=(value)
    @s3_endpoint = value
  end

  def bucket(bucket = s3_bucket)
    config
    @bucket = AWS::S3.new.buckets[bucket]
  end

  def cdn
    @cloudfront = AWS::CloudFront.new(access_key_id: amazon_key,
                                      secret_access_key: amazon_access_key)
  end

  def create_invalidations(files, distribution_id)
    cdn.client.create_invalidation(distribution_id: distribution_id,
                                   invalidation_batch: {
                                     paths: {
                                       quantity: files.count,
                                       items: files
                                     },
                                     caller_reference: 'INVALIDATE_CF_' + DateTime.now.to_s
                                   }).data
  end

  def get_invalidation_update(invalidation, distribution_id)
    cdn.client.get_invalidation(distribution_id: distribution_id,
                                id: invalidation[:id]).data
  end

  def get_invalidation_status(invalidation, distribution_id)
    get_invalidation_update(invalidation, distribution_id)[:status]
  end

  def s3_copy(orig, orig_options, target, target_options)
    run_with_retry do
      obj = s3_get_object(orig, orig_options)
      obj.copy_to(target, target_options) if obj && obj.exists?
    end
  end

  def s3_store_file(name, file, opt = {})
    unless opt.include?(:content_type)
      opt[:content_type] = content_type(File.extname(file))
    end

    # Stream the content for storage
    File.open(file, 'rb') do |f|
      return s3_store(name, f, opt)
    end
  end

  def s3_store(name, content, opt = {})
    run_with_retry do
      obj = s3_get_object(name, opt)
      obj.write(content, opt)
      obj.exists? ? s3_get_object_url(name, opt) : nil
    end
  end

  def run_with_retry
    maxtry = 3
    ntry = 0
    begin
      return yield
    rescue AWS::S3::Errors::RequestTimeout
      ntry += 1
      if ntry > maxtry
        Bugsnag.notify($ERROR_INFO, extra: { http_body: $ERROR_INFO.http_body })
        raise
      end
      print "Error: #{$ERROR_INFO}, retrying\n"
      @bucket = nil # So that we create a new bucket
      retry
    end
  end

  def doomsday
    expiration = Time.zone.now + 20.years
    # TODO: ::Update after AWS changes this limit. Will likely be a while
    # since it depends on global transition to 64-bit systems
    #
    # AWS sets 01/20/2038 as an upper limit threshold on expiration date
    # due to https://en.wikipedia.org/wiki/Year_2038_problem
    aws_max_date = Time.zone.parse('2038-01-18')
    expiration = aws_max_date if expiration > aws_max_date
    expiration
  end

  def s3_get_object_url(name, opt = {})
    obj = s3_get_object(name, opt)
    return nil unless obj && obj.exists?
    secure = opt.include?(:secure) ? opt[:secure] : true
    obj.url_for(:read, secure: secure, expires: doomsday).to_s
  end

  def s3_delete(name)
    run_with_retry { s3_get_object(name).delete }
  end

  def s3_get_object(name, opt = {})
    bucket = opt.include?(:bucket) ? bucket(opt[:bucket]) : bucket()
    bucket.objects[name]
  end

  def s3_store_attachment(name, attachment)
    name += content_ext(attachment.content_type)
    s3_store(name, attachment.tempfile, content_type: attachment.content_type)
  end

  def s3_download_file(name, filename, opt = {})
    run_with_retry do
      data = s3_get_object(name, opt).read
      File.open(filename, 'wb') do |file|
        file.write(data)
      end
      nil
    end
  end

  def s3_download_large_file(name, filename, opt = {})
    run_with_retry do
      obj = s3_get_object(name, bucket: opt[:bucket])
      File.open(filename, 'wb') do |file|
        count = 0
        obj.read do |chunk|
          file.write(chunk)
          count += 1
          if count > 1000
            count = 0
            print '.'
          end
        end
      end
      nil
    end
  end

  CONTENT_TYPE_TO_EXT = {
    'audio/amr' => '.amr',
    'audio/acc' => '.mp4',
    'audio/mp4' => '.mp4',
    'audio/mpeg' => '.mp3',
    'audio/ogg' => '.ogg',
    'image/jpeg' => '.jpg',
    'image/png' => '.png',
    'image/gif' => '.gif',
    'text/plain' => '.txt',
    'text/rtf' => '.rtf',
    'application/zip' => '.zip',
    'application/pdf' => '.pdf',
    'application/msword' => '.doc'
  }.freeze

  def content_type(ext)
    CONTENT_TYPE_TO_EXT.each do |ct, cext|
      return ct if ext == cext
    end
  end

  def content_ext(content_type)
    CONTENT_TYPE_TO_EXT[content_type] || ''
  end
end

# rubocop:enable Metrics/ModuleLength
