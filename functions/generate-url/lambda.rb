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
      return { statusCode: 400, body: { error: 'Invalid SHA256 hash' }.to_s }
    end

    # We need these dummy credentials to speed up Class initialization.
    Aws.config.update(
      access_key_id:     'foo',
      secret_access_key: 'bar',
      region:            'us-east-1'
    )
    s3 = Aws::S3::Client.new

    bucket_name = ENV['S3_BUCKET']
    object_key = generate_object_key(file_hash, file_name)

    presigned_url = Aws::S3::Presigner.new(client: s3).presigned_url(:put_object, 
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

handler(event:{"version"=>"2.0", "routeKey"=>"POST /api/presign", "rawPath"=>"/api/presign", "rawQueryString"=>"", "headers"=>{"accept"=>"*/*", "content-length"=>"113", "content-type"=>"application/x-www-form-urlencoded", "host"=>"eicl5mtgle.execute-api.us-east-1.amazonaws.com", "user-agent"=>"curl/8.9.1", "x-amzn-trace-id"=>"Root=1-67ca1ede-5298a0107870d7c07f7ef0e8", "x-forwarded-for"=>"177.128.73.176", "x-forwarded-port"=>"443", "x-forwarded-proto"=>"https"}, "requestContext"=>{"accountId"=>"250546337490", "apiId"=>"eicl5mtgle", "domainName"=>"eicl5mtgle.execute-api.us-east-1.amazonaws.com", "domainPrefix"=>"eicl5mtgle", "http"=>{"method"=>"POST", "path"=>"/api/presign", "protocol"=>"HTTP/1.1", "sourceIp"=>"177.128.73.176", "userAgent"=>"curl/8.9.1"}, "requestId"=>"HBnC2iuMIAMEa7Q=", "routeKey"=>"POST /api/presign", "stage"=>"$default", "time"=>"06/Mar/2025:22:17:02 +0000", "timeEpoch"=>1741299422608}, "body"=>"eyJmaWxlX2hhc2giOiAiN2Y4M2IxNjU3ZmYxZmM1M2I5MmRjMTgxNDhhMWQ2NWRmYzJkNGIxZmEzZDY3NzI4NGFkZGQyMDAxMjZkOTA2OSIsICJmaWxlX25hbWUiOiAiaGVsbG9fd29ybGQudHh0In0=", "isBase64Encoded"=>true}, context:"")