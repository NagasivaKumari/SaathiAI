import pandas as pd
from prophet import Prophet
import boto3
import os
import json
from datetime import datetime, timedelta
from dotenv import load_dotenv

load_dotenv()

def predict_market_trends():
    """
    Simulates price prediction for SathiAI using the Prophet library.
    In a full production app, this would fetch real historical data from an API.
    For the hackathon, we demonstrate the predictive logic.
    """
    print("📈 SathiAI Predictive Intelligence: Generating Price Forecasts...")
    
    # Mock historical data for Wheat over the last 30 days
    today = datetime.now()
    dates = [today - timedelta(days=x) for x in range(30, 0, -1)]
    # Simulate a steady rise with some noise
    prices = [2100 + (i * 5) + (i % 3 * 10) for i in range(30)]
    
    df = pd.DataFrame({
        'ds': dates,
        'y': prices
    })
    
    # Initialize and fit the model
    model = Prophet(daily_seasonality=True)
    model.fit(df)
    
    # Create future dataframe for the next 7 days
    future = model.make_future_dataframe(periods=7)
    forecast = model.predict(future)
    
    # Get the latest prediction
    latest_prediction = forecast.iloc[-1]
    predicted_price = round(latest_prediction['yhat'], 2)
    current_avg = df['y'].iloc[-1]
    
    trend = "up" if predicted_price > current_avg else "down"
    
    print(f"✅ Prediction for next week: ₹{predicted_price}/quintal (Trend: {trend})")
    
    # Update DynamoDB with this "Intelligence"
    try:
        dynamodb = boto3.resource(
            'dynamodb',
            region_name=os.getenv("AWS_REGION", "us-east-1"),
            aws_access_key_id=os.getenv("AWS_ACCESS_KEY_ID"),
            aws_secret_access_key=os.getenv("AWS_SECRET_ACCESS_KEY")
        )
        table = dynamodb.Table(os.getenv("DYNAMO_MARKET_TABLE", "SathiAI_MarketData"))
        
        # Update Wheat with predictive advice
        table.update_item(
            Key={'id': 'm1'},
            UpdateExpression="SET advice = :a, trend = :t, predicted_price = :p",
            ExpressionAttributeValues={
                ':a': f"Prices likely to hit ₹{predicted_price} next week. Hold for 3 days! 🌾",
                ':t': trend,
                ':p': str(predicted_price)
            }
        )
        print("📊 DynamoDB updated with pro-active selling advice.")
        
    except Exception as e:
        print(f"❌ Could not update DynamoDB: {e}")

if __name__ == "__main__":
    predict_market_trends()
