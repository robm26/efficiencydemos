## Ocean Surface Temperatures

This example is intended as a learning opportunity.  Given a scenario and
a set of access patterns, review the initial data model provided using the
NoSQL Workbench for Amazon DynamoDB.  Identify any problems in the model -
access patterns not covered, functional gaps, or sub-optimal efficiency.

### Pre-requisites
 * The [NoSQL Workbench for Amazon DynamoDB](https://docs.aws.amazon.com/amazondynamodb/latest/developerguide/workbench.html)
 * The [ocean_surface_temps.json](ocean_surface_temps.json) Workbench model file
 
### Scenario
A global community project has begun, with the goal of recording a history of
ocean surface temperatures from all over the world.  There will be many
participating organizations - oceanographic exploration companies, universities
and other research institutions.  A community defined standard design for the
measurement device has been shared, and organizations are free to iterate on
their own implementations. The project aims to provide standard tooling to
help participating organizations manage and maintain their devices, to store the
measurements, and to provide a web based UI for organizations to view and edit
data from their devices.

The project assigns a unique three digit (zero padded) numeric identifier for
each participating organization.  And the organization defines a unique (to
their org) 5 digit (zero padded) numeric identifier for each device.  If a
device is redeployed to a new location, it is assigned a new identifier.

For each device, the org can store the install coordinates, most recent service
date, hardware model/revision, active/inactive status, and an indicator
present only when the device is considered to be in fault - needing service.

The sensor devices generate a temperature (in Kelvin, with 2 decimal places)
once each minute, and deliver it to a Kinesis Data Stream along with the
assigned org id and device id.  In addition, if the device self assesses that
it is in fault, it adds an additional indicator attribute to the records sent
to the stream.  Workers read from the stream in batches, and write the records
to DynamoDB using BatchWriteItem.  Some organizations have over 1000 devices,
and the project overall has 7 thousand devices today - expecting to reach over
10 thousand when the project reaches peak scale.

Temperature readings should be kept for one year and then be deleted.

### Access Patterns

The access patterns we need to support are:

* CRUD organization information
* CRUD device information
* CRUD sensor reading
* Retrieve sorted time range of temperature records for a device
* Retrieve most recent 60 readings for a device
* Retrieve the first temperature reading on record for a device
* List all devices for an organization
* Find all faulty readings (daily ETL)
* List all devices and their metadata (weekly ETL)
* Find all faulty readings for a particular organization in the last 30 minutes
* Find all faulty readings for a particular device
* Find all devices with a service date more than 1 year in the past

### Tasks
We need to notify an organization contact when any of their devices change
fault status.  And any time a fault indicated temperature data point arrives,
the status of the device record should change to indicate the fault.

Some initial work has been made towards modeling for this use case in the
NoSQL Workbench for DynamoDB.  Download the exported model, import into the
tool, review the model and make any improvements you can think of.

---
back to [HOME](../README.md)