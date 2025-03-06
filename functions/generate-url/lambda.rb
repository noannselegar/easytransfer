require 'aws-sdk-s3'
require 'json'
require 'base64'

def handler(event:, context:)
  begin
    if event["isBase64Encoded"]
      body_decoded = Base64.decode64(event["body"])
    end
    body = JSON.parse(body_decoded)
    file_hash = body["file_hash"]
    file_name = body["file_name"]

    unless valid_sha256?(file_hash)
      return { statusCode: 400, body: JSON.generate({ error: 'Invalid SHA256 hash' }) }
    end

    s3 = Aws::S3::Client.new(region: ENV['AWS_REGION'])

    bucket_name = ENV['S3_BUCKET']
    object_key = generate_object_key(file_hash, file_name)

    presigned_url = Aws::S3::Presigner.new(client: s3).presigned_url(:put_object, 
      bucket: bucket_name, 
      key: object_key, 
      expires_in: 3600
    )

    { statusCode: 200, body: JSON.generate({ url: presigned_url }) }
  rescue => e
    { statusCode: 500, body: JSON.generate({ error: e.message }) }
  end
end

def valid_sha256?(hash)
  hash.match?(/\A[a-f0-9]{64}\z/)
end

def generate_object_key(hash, file_name)
  parts = hash.scan(/.{1,8}/) 
  (parts + [file_name]).join('/')
end
