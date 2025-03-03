locals {
  lambdas = {
    generate_url = {
       name        = "easytransfer-generate-presigned-url"
       description = "Generates a Presigned URL for S3: PUT or GET."
       route       = "POST /api/presign"
			 extra_policy_statements = []
		}
    send_email = {
       name        = "easytransfer-send-upload-email"
       description = "Sends email with Download link for the uploaded file."
       route       = "POST /api/upload"
			 extra_policy_statements = []
		}
    get_metadata = {
       name        = "easytransfer-get-file-metadata"
       description = "Returns file metadata stored in DynamoDB"
       route       = "GET /api/download/{fileId}"
			 extra_policy_statements = []
		}
	}
}
