# efficiencydemos

A set of DynamoDB demo scripts and sample data that illustrate the read and write cost of various data access patterns.

## Intro

Amazon DynamoDB is a powerful serverless database that offers virtually unlimited scale when used efficiently.
The table structure and access patterns you choose have a big impact on DynamoDB's efficiency, and ultimately the read and write consumption that you are billed for.
Knowing the best access patterns takes practice and experimentation.  
In these labs, you can run a series of DynamoDB data operations using the AWS Command Line Interface, 
and get immediate visibility into the cost and effectiveness of your calls.

## Pre-requisites

 * An AWS Account with administrator access
 * The [AWS CLI](https://aws.amazon.com/cli/) setup and configured
 * [Node.JS](https://nodejs.org/en/download/) for loading the sample data
 * A bash command-line environment such as Mac Terminal or Windows 10 bash shell
 * The [NoSQL Workbench for Amazon DynamoDB](https://docs.aws.amazon.com/amazondynamodb/latest/developerguide/workbench.html)
 
 *If you do not have an AWS account, you can run [DynamoDB Local](https://docs.aws.amazon.com/amazondynamodb/latest/developerguide/DynamoDBLocal.html) on your laptop instead.*
 
 
## Consumed Capacity

![Consumed Capacity](https://dynamodb-images.s3.amazonaws.com/img/consumed_grey.png)

A nice feature of calls to DynamoDB is that you can request a summary of the capacity consumed by your call.
Even if your call is only sending or receiving a small amount of data, it may be consuming a much larger amount of Read Capacity or Write Capacity.

Capacity is measured in Read Units and Write Units (sometimes called RCUs and WCUs).
Each read unit represents the size of data read, measured in 4 KB units. Each write unit represents the size of data written measured in 1 KB units.  Your actual consumption is rounded up to the nearest unit.

Data operations to DynamoDB have an optional "Return Consumed Capacity" parameter, where you can specify either TOTAL or INDEXES.   Specifying INDEXES will provide a total along with a breakdown of capacity consumed by indexes.

For reads, you will also see two counts returned, the Scanned Count and the Returned Count.
The Scanned Count is the total number of Items (rows) read by the DynamoDB engine, while the Returned Count is the number returned to the user.
 
 
## Scenario 1 - Shopping Cart

We are consultants who have been hired to build a shopping cart for an E-commerce website.
Each cart that is created has a unique ID, such as Cart1 or Cart2. Within each cart, one or many products can exist.  
Each product is identified via IDs such as Product100, Product200, etc.
A one-to-many pattern of cart to products is modeled in a DynamoDB table called **ShoppingCart**.

![Cart1](https://dynamodb-images.s3.amazonaws.com/img/cart1.png)

This table also contains other types of items, such as Customer details and Product details.
The Description attribute for many of these items is a large string of 20,000 bytes, representing a typical JSON document payload.

![Customer](https://dynamodb-images.s3.amazonaws.com/img/customer.png)

![Product100](https://dynamodb-images.s3.amazonaws.com/img/product100.png)


We will take a tour of the DynamoDB read and write operations using simple shell scripts that access this table.


### Setup Steps

1. Clone this repository to a folder on your laptop, or download to a working folder via the green button above.
1. From your command prompt, navigate to the cart folder: ```cd cart```
1. You may wish to run ```export PATH=$PATH:$(pwd)``` so that scripts in your current folder will be added to your path.
1. Verify the AWS CLI is setup and running by running ```aws sts get-caller-identity``` 
and ```aws dynamodb describe-limits```.  You should see no errors.
1. Verify your AWS CLI is pointing to default region **us-east-1** (N. Virginia) by running ```aws configure``` and pressing enter four times.  You may enter ```us-east-1``` on the third prompt if necessary.


#### Creating the ShoppingCart table
1. Run ```recreate.sh``` to create your table.  Please ignore the ResourceNotFoundException that appears the first time, as it attempts to delete the table should it already exist.
1. Run ```node load``` which will write the data to your new **ShoppingCart** table from the [CartData.csv](./cart/CartData.csv) file.

*If you don't have Node.JS, you may use the NoSQL Workbench to deploy this table using the provided [ShoppingCart.json](./cart/ShoppingCart.json) file.*

#### Return Consumed Capacity
1. Review the rest of the shell scripts in this [/cart](./cart/) folder.
1. Open the [scan.sh](./cart/scan.sh) script in your text editor.
1. Notice the final four lines.  We include the option ```--return-consumed-capacity 'TOTAL'``` to request additional information about the cost of our operation.

The AWS CLI offers it's own ```--query``` utility to do a final client-side format of the data returned by your DynamoDB API calls.
We have chosen to comment out the display of actual returned ```Items[*]``` array of data, instead focusing on three consumed capacity stats.
*Learn more about the AWS CLI data formatting options via the [CLI Documentation](https://docs.aws.amazon.com/cli/latest/userguide/cli-usage-output.html).*

### Shopping Cart Demo

This sequence of commands helps illustrate the pros and cons of various access patterns.
As you run each example, try and estimate the capacity you think will be consumed, before running each commmand. 


| Demo | Command |
| --- | --- |
| Scan | ```scan.sh``` |
| Scan with filter | ```scanfilter.sh Cart1``` |
| GetItem Eventual Consistency | ```get.sh Cart1 Product100``` |
| GetItem with projection expression | ```get.sh Cart1 Product100 Price``` |
| GetItem with Strong Consistency | ```get.sh Cart1 Product100 Price STRONG``` |
| BatchGetItem | ```batchget.sh``` |
| Query | ```query.sh Cart1``` |
| Query with Filter | ```queryfilter.sh Cart1 Orange``` |
| Query with Sort Key Expression | ```querysortkey.sh Cart1 Product400``` |
| Delete Item | ```delete.sh Cart1 Product400``` |
| Put Item | ```put.sh``` <br/> *writes new item Cart7 Product700* |
| UpdateItem | 1. ```update.sh Cart7 Product700 Price 22.33``` <br/> 2. ```update.sh Cart7 Product700 CustomerDescription MuchSmaller``` <br/> 3. ```update.sh Cart7 Product700 Price 44.55``` |
| Add New GSI (ProductName + Price) | ```addgsi.sh``` <br/> Wait a couple minutes for **GSI-ProductPrice** to be created. |
| UpdateItem GSI key attribute | ```update.sh Cart1 Product100 Price 12.34``` |
| UpdateItem non-GSI key attribute | ```update.sh Cart1 Product100 Qty 5``` |
| UpdateItem with cost and non-GSI attribute | ```update.sh Customer "John Stiles" Address "100 Main Street"``` |
| Scan a GSI (works the same as base table) | ```scangsi.sh GSI-ProductPrice``` |
| Query a GSI (works the same as base table) | ```querygsi.sh GSI-ProductPrice Turnip``` |
| Write to a GSI | *N/A <br/> you can only write to a base table!* |
| Get Item from GSI | *N/A <br/> you can only get-item from a base table!* |



## Scenario 2 - Report Management

![GSI: StatusDate-by-OwnerID](https://dynamodb-images.s3.amazonaws.com/img/reports_gsi.png)

This is a view of the Global Secondary Index: **StatusDate-by-OwnerID**

### Setup Steps
1. Import model [report_mgmt.json](./reportmgmt/report_mgmt.json) into NoSQL Workbench for Amazon DynamoDB.
2. Use NoSQL Workbench Visualizer to "commit" the model to your AWS account in *us-east-1*.

*This table is created with Provisioned Capacity mode, with 5 read and 5 write units.
You have 25 such units free across all your tables.  If you will be keeping the table around, 
consider switching into On-Demand mode from the Capacity tab in your DynamoDB console.  
See further pricing notes at the bottom.*

### Report Management Demo
1. cd into the [reportmgmt](./reportmgmt/) folder.
2. View the model and example data.
3. Run this script to update the status and date for one of the entries:
```
update_report_statusdate.sh 9D2B 9D2B#meta Pending#2019-10-05
```
   Note write throughput consumed - why did the secondary index consume 2 ?
   
3. Run this script to selectively Query the global secondary index retrieving
   matches for a particular OwnerID and Status, and return in sort Date order.
```
query_gsi_by_owner_status_sortdate.sh Paola Pending
```
Note sorted result set and read throughput consumption reported.

## Scenario 3 - Transactions
1. Navigate to the project's *tx* folder.
2. Import model [OnlineBank.json](./tx/OnlineBank.json) into NoSQL Workbench for Amazon DynamoDB.
3. Use NoSQL Workbench Visualizer to "commit" the model to your AWS account in *us-east-1*.

You now have two tables called *Accounts* and *Transactions*.

Scan the tables to look at the existing data - accounts with balances, and a transaction
recorded already.

### Transactions Demo
1.  Perform a transfer.  

 ```balance_transfer.sh c3e67497-fcb0-4881-8477-b0cbedab7240 transfer1-allowed```

This succeeds - all conditions are met.  Notice the consumed writes, and re-scan the tables to see the new and changed items.


2.  Attempt a transfer where the payer has insufficient funds.

```balance_transfer.sh 4510ba8a-518b-4701-88b5-3db78e618f71 transfer2-underfunded```

This fails - the condition is not met on the first action, which is to verify
adequate funding in the source account.  Writes are consumed anyway.

3.  Attempt the same transfer again using the same idempotency key.

```balance_transfer.sh 4510ba8a-518b-4701-88b5-3db78e618f71 transfer2-underfunded```

Because the prior attempt failed due to a condition exception, the idempotency
token is not tracked by DynamoDB.  We try again, get the same exception, and
we consume the same writes.

4.  Attempt a transaction that uses a *txid* that was used in the past

```balance_transfer.sh 7d622075-f2f1-4dd4-8aaf-fb29e87c2b9a transfer3-txidused```

Now we try to make a transfer with a **txid** which matches the one that was
already recorded some time ago - it was in our initial sample data.  This fails
because the third condition is not matched - that every new transaction must
have its own unique txid.  This consumes writes.  
The validation check against historical use of *txid* was part of our application business logic, 
and did not involve the idempotency token.  Idempotency tokens are only tracked for around 10 mins).


5.  Perform a successful transfer, while using an idempotency token.

```balance_transfer.sh e896d9e5-818c-43b2-a139-59fd63fbcd12 transfer4-allowed```

This is a successful transfer - see the writes consumed, balances updated
and new transaction recorded.  But what if our client never received the 200
response from DynamoDB saying the transaction was committed?  It must retry, which could
be a problem - the exception would be raised due to seeing an existing *txid*,
preventing a repeat transfer, but to the client it still seems like a fail.
No way to know if this is because of retry in the short term or if this is a
genuine *txid* clash from separate balance transfer requests.  This sounds messy.


6.  Repeat the transfer

```balance_transfer.sh e896d9e5-818c-43b2-a139-59fd63fbcd12 transfer4-allowed```

Thankfully, if we retry within 10 minutes, DynamoDB will return a successful
response code to the client, so it knows it actually succeeded. The
transfer is not actually made again; no updates are made to the account balances and
the transaction is not recorded again.  You'll notice that capacity was
consumed - but look carefully.  It is read units.  No writes were made,
but read units are consumed in checking and confirming that the transaction was
in fact already successfully committed.  This adds a great deal of resilience
and integrity.  Clients can retry and ascertain the exact status of any
transaction.


## Modeling Exercises
To practice modeling DynamoDB tables using the NoSQL Workbench, 
please try the design challenges at:
 
 * [amazon-dynamodb-labs.com](https://amazon-dynamodb-labs.com/scenarios.html)


## Next Steps
The Shopping Cart table you created has 17 items and a size of 282 KB.  It was created in **On Demand** capacity mode.
The Reports table is under 2 KB and was created in Provisioned Capacity mode with a default of 5 Write Units and 5 Read Units.
The [pricing page for DynamoDB](https://aws.amazon.com/dynamodb/pricing/) shows that you enjoy 25GB of free-tier storage for your tables.
On On Demand mode, you are billed one penny for each 40,000 read units or 8000 write units consumed.
In Provisioned Capacity mode, your first 25 Write Units and 25 Read Units are always free.
You can delete your tables if desired.


Please contribute to this code sample by issuing a Pull Request or creating an Issue.

Share your feedback at [@robmccauley](https://twitter.com/robmccauley)

