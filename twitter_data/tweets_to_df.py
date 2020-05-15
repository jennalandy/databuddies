import json
import pandas as pd

with open('tweets.jsonl', 'r') as json_file:
    json_list = list(json_file)

created_at = []
tweet_id = []
full_text = []
hashtags = []
for tweet in json_list: 
    obj = json.loads(tweet.replace("\n",''))
    created_at.append(obj.get('created_at'))
    tweet_id.append(obj.get('id'))
    full_text.append(obj.get('full_text'))
    hashtags.append(obj.get('entities').get('hashtags'))


df = pd.DataFrame(list(zip(created_at, tweet_id, full_text, hashtags)),
                 columns=["date", "tweet_id", "full_text", "hashtags"])

df["date"] = pd.to_datetime(df['date']).apply(lambda x: x.date)

df.to_csv('sample_tweets.csv', index=False)
