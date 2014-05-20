#!/usr/bin/env python
from kombu import Connection, Exchange, Queue
from pprint import pprint
import os


## manually set the domain
domain = 'maskedadmins.com'
nova_x = Exchange('nova', type='topic', durable=False)
info_q = Queue('notifications.info', exchange=nova_x, durable=False, 
               routing_key='notifications.info')

def process_msg(body, message):
    print '='*80
    if 'state' in body['payload']:
      if body['payload']['state'] == 'deleted':
        print 'event: %s' % body['event_type']
        print 'hostname: %s' % body['payload']['hostname']
        print 'state: %s' %  body['payload']['state']
        print 'on_node: %s' %  body['payload']['node']
        print 'deleted_at: %s' %  body['payload']['deleted_at']
        if os.system("puppet node status %s.%s" % (body['payload']['hostname'],domain)):
          if os.system("puppet node clean %s.%s" % (body['payload']['hostname'],domain)):
            print 'Removed from puppet!'
          else:
            print 'Could not remove from puppet!'
      else:
        print 'event: %s' % body['event_type']
        print 'ignoring event...'
      #pprint(body)
    else:
      print 'event: %s' % body['event_type']
      print 'ignoring event...'
    message.ack()

with Connection('amqp://guest:guest@10.55.2.155//') as conn:
    with conn.Consumer(info_q, callbacks=[process_msg]):
        while True:
            try:
                conn.drain_events()
            except KeyboardInterrupt:
                break
