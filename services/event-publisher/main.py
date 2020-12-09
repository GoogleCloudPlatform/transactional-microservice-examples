import os
import sys
import time

from flask import Flask

from google.cloud import datastore
from google.cloud import pubsub_v1


app = Flask(__name__)
ds_client = datastore.Client()


def error500():
    resp = {
        'message': 'Internal error occured.'
    }
    return resp, 500


@app.route('/')
def index():
    return 'Event Publisher service. '


@app.route('/api/v1/event/publish', methods=['GET'])
def publish_event():
    futures = {}
    def get_callback(future, result):
        def callback(future):
            event_id = result['event_id']
            try:
                future.result()
                result['published'] = True
                ds_client.put(result)
            except:
                print('Failed to publish an envent {}: {}'.format(event_id, future.exception()),
                        file=sys.stderr)
            finally:
                futures.pop(event_id)
        return callback

    query = ds_client.query(kind='Event')
    query.add_filter('published', '=', False)
    query.order = ['timestamp']
    for result in query.fetch():
        publisher = pubsub_v1.PublisherClient()
        topic_name = 'projects/{}/topics/{}'.format(
            os.getenv('PROJECT_ID'), result['topic'])
        event_id = result['event_id']
        event_type = result['type']
        body = result['body'].encode("utf-8")

        future = publisher.publish(topic_name, body,
                    event_id=event_id, event_type=event_type)
        futures[event_id] = future
        future.add_done_callback(get_callback(future, result))

    while futures:
        time.sleep(5)

    return 'Finished.', 200


if __name__ == "__main__":
    app.run(debug=True, host='0.0.0.0', port=int(os.environ.get('PORT', 8080)))
