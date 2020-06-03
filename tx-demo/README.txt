Import the data model to workbench OnlineBank.json



Commit to DynamoDB in us-east-1.

Take a look at the existing data - accounts with balances, and a transaction
recorded already.



1.  balance_transfer.sh c3e67497-fcb0-4881-8477-b0cbedab7240 transfer1-allowed

This succeeds - all conditions are met.  Showed consumed writes, and view
updated/inserted records.


2.  balance_transfer.sh 4510ba8a-518b-4701-88b5-3db78e618f71 transfer2-underfunded

This fails - condition is not met on the first action, which is the verifying
adequate funding in the source account.  Writes are consumed anyway.


3.  balance_transfer.sh 4510ba8a-518b-4701-88b5-3db78e618f71 transfer2-underfunded

Because the prior attempt failed due to a condition exception, the idempotency
token is not tracked by DynamoDB.  We try again, get the same exception, and
we consume the same writes.


4.  balance_transfer.sh 7d622075-f2f1-4dd4-8aaf-fb29e87c2b9a transfer3-txidused

Now we try to make a transfer with a txid which matches the one that was
already recorded some time ago - was already in our sample data.  This fails
because the third condition is not matched - that every new transaction must
have its own unique txid.  This consumes writes - was not enforced by the
idempotency token (idempotency tokens are only tracked for around 10mins).


5.  balance_transfer.sh e896d9e5-818c-43b2-a139-59fd63fbcd12 transfer4-allowed

This is another successful transfer - see the writes consumed, balances updated
and new transaction recorded.  But what if our client never received the 200
response from DynamoDB saying the tx was committed?  It must retry, which could
be a problem - the exception would be raised due to seeing an existing txid,
preventing a repeat transfer, but to the client it still seems like a fail.
No way to know if this is because of retry in the short term or if this is a
genuine txid clash from separate balance transfer requests.  This sounds messy.


6.  balance_transfer.sh e896d9e5-818c-43b2-a139-59fd63fbcd12 transfer4-allowed

Thankfully, if we retry within 10mins, DynamoDB will return a successful
response code to the client, so it knows it actually succeeded - but the
transfer is not made again - no updates are made to the account balances and
the transaction is not recorded again.  You'll notice that capacity was
consumed - but look carefully.  It is read units.  No writes were made,
but read units are consumed in checking and confirming that the transaction was
in fact already successfully committed.  This adds a great deal of resilience
and integrity.  Clients can retry and ascertain the exact status of any
transaction.
