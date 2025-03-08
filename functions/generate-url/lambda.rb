require 'aws-sdk-s3'
require 'json'
require 'base64'

def handler(event:, context:)
  puts event
  begin
    if event["isBase64Encoded"]
      body_decoded = Base64.decode64(event["body"])
    end
    body = JSON.parse(body_decoded)
    method = event.dig("queryStringParameters", "method")
    file_hash = body["file_hash"]
    file_name = body["file_name"]

    unless valid_sha256?(file_hash)
      return { statusCode: 400, body: { error: 'Invalid SHA256 hash' }.to_s }
    end

    s3 = Aws::S3::Client.new

    bucket_name = ENV['S3_BUCKET']
    object_key = generate_object_key(file_hash, file_name)
    method_symbol = method == "put" || method == "PUT" ? :put_object : :get_object

    presigned_url = Aws::S3::Presigner.new(client: s3).presigned_url(method_symbol, 
      bucket: bucket_name, 
      key: object_key, 
      expires_in: 3600
    )
    
    { statusCode: 200, body: { url: presigned_url }.to_s }
  rescue => e
    puts e.message
    { statusCode: 500, body: { error: e.message }.to_s }
  end
end

def valid_sha256?(hash)
  hash.match?(/\A[a-f0-9]{64}\z/)
end

def generate_object_key(hash, file_name)
  parts = hash.scan(/.{1,8}/) 
  (parts + [file_name]).join('/')
end