import boto3
import os
from botocore.exceptions import ClientError

class BedrockService:
    def __init__(self):
        self.bedrock = boto3.client(
            'bedrock-runtime',
            region_name=os.getenv("AWS_REGION", "us-east-1"),
            aws_access_key_id=os.getenv("AWS_ACCESS_KEY_ID"),
            aws_secret_access_key=os.getenv("AWS_SECRET_ACCESS_KEY")
        )
        self.model_id = os.getenv("AWS_BEDROCK_MODEL_ID", "anthropic.claude-v2")

    def chat(self, prompt: str) -> str:
        try:
            response = self.bedrock.invoke_model(
                modelId=self.model_id,
                contentType="application/json",
                accept="application/json",
                body=f'{{"prompt": "{prompt}", "max_tokens_to_sample": 256}}'
            )
            result = response['body'].read().decode('utf-8')
            return result
        except ClientError as e:
            print(f"Bedrock Error: {e}")
            raise

bedrock_service = BedrockService()
