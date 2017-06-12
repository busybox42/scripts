#!/usr/bin/python

import imaplib

def read(username, password, sender_of_interest):
    # Login to INBOX
    imap = imaplib.IMAP4_SSL("imap.domain.tld", 993)
    imap.login(user@domain.tld, password)
    imap.select('INBOX')

    # Use search(), not status()
    status, response = imap.search(None, 'INBOX', '(UNSEEN)')
    unread_msg_nums = response[0].split()

    # Print the count of all unread messages
    print len(unread_msg_nums)

    # Print all unread messages from a certain sender of interest
    status, response = imap.search(None, '(UNSEEN)', '(FROM "%s")' % (sender_of_interest))
    unread_msg_nums = response[0].split()
    da = []
    for e_id in unread_msg_nums:
        _, response = imap.fetch(e_id, '(UID BODY[TEXT])')
        da.append(response[0][1])
    print da

    # Mark them as seen
    for e_id in unread_msg_nums:
        imap.store(e_id, '+FLAGS', '\Seen')
