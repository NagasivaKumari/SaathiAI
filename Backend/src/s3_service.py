import boto3
import os
from botocore.exceptions import ClientError

class S3Service:
    def __init__(self):
        self.s3 = boto3.client(
            's3',
            region_name=os.getenv("AWS_REGION", "us-east-1"),
            aws_access_key_id=os.getenv("AWS_ACCESS_KEY_ID"),
            aws_secret_access_key=os.getenv("AWS_SECRET_ACCESS_KEY")
        )
        self.bucket_name = os.getenv("AWS_S3_BUCKET", "sathiai-assets")

    def upload_file(self, file_name, object_name=None):
        if object_name is None:
            object_name = os.path.basename(file_name)
        try:
            self.s3.upload_file(file_name, self.bucket_name, object_name)
            return f"https://{self.bucket_name}.s3.amazonaws.com/{object_name}"
        except ClientError as e:
            print(f"S3 Upload Error: {e}")
            return None

# Global instance
s3_service = S3Service()
