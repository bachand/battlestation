# frozen_string_literal: true

require_relative '../output'

module Battlestation

  # A wrapper around the logic for uploading files to S3.
  class S3Uploader

    # @param [File] source
    # @option options [required,String] :bucket_name
    # @option options [required,Aws:Credentials] :credentials
    # @option options [required,String] :region
    # @return [Boolean] Whether the upload was successful.
    def upload(source, options = {})
      raise ArgumentError unless source
      raise ArgumentError unless options[:bucket_name]
      raise ArgumentError unless options[:credentials]
      raise ArgumentError unless options[:region]

      bucket_name = options[:bucket_name]
      credentials = options[:credentials]
      region = options[:region]

      source_basename = File.basename(source.path)

      Aws.config.update(
        region: region,
        credentials: credentials,
      )

      s3 = Aws::S3::Resource.new(region: region)
      object = s3.bucket(bucket_name).object(source_basename)

      if object.exists?
        # TODO: this class should raise an Error instead of printing.
        message = "An object named '#{source_basename}' already exists in bucket '#{bucket_name}'"
        Output.put_error(message)
        return false
      end

      object.upload_file(source,
        server_side_encryption: 'aws:kms',
        storage_class: 'STANDARD_IA',
      )
    end
  end
end
