- In the twitter_data directory, run `get_tweet_ids.R`, this will periodically save `twitter_ids.RData` incase R crashes and ultimately saves `tweets.txt`

- Install twarc, following instructions at [https://github.com/DocNow/twarc](https://github.com/DocNow/twarc).

- In terminal, in the twitter_data directory, run `twarc hydrate tweets.txt > tweets.jsonl`. This gets data from tweet ids and puts it into `tweets.jsonl`. It will also log information to `twarc.log`.

- In terminal, in the twitter_data directory, run `python3 tweets_to_df.py`. This reads the jsonl file (only readable in python) and puts information into `sample_tweets.csv`.