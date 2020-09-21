//


const AWS = require('aws-sdk');
AWS.config.region = process.env.AWS_REGION || 'us-east-1';

// AWS.config.endpoint = 'http://localhost:8000';

const fs = require('fs');

const DYNAMODB_TABLE = 'ShoppingCart';
const DATA_FILE      = 'CartData.csv';

console.log('Loading file: ' + DATA_FILE + ' into table: ' + DYNAMODB_TABLE );
console.log();

const docClient = new AWS.DynamoDB.DocumentClient();

let Item = {}; // this obj will be filled with key-value pairs from the data file


fs.readFile(DATA_FILE, 'utf8', function(err, rawData) {
    let newLineSignal = '\n';

    if(rawData.search('\r\n') > 0) {
        newLineSignal = '\r\n';
    }
    const fileLines = rawData.split(newLineSignal);

    if(fileLines.length < 2) {
        console.log('The CSV file ' + DATA_FILE + ' should have column headers on line 1 and data starting on line 2');

    } else {

        const attrNamesQuoted = fileLines[0].match(/(".*?"|[^",\s]+)(?=\s*,|\s*$)/g);

        let attrNames = [];
        for(let a=0; a < attrNamesQuoted.length; a++) {
            // console.log(attrNamesQuoted[a]);

            attrNames.push(stripQuotes(attrNamesQuoted[a]));
        }

        const linesToProcess = fileLines.length;
        // const linesToProcess = 3;

        for(let i = 1; i < linesToProcess; i++) {
            Item = {};

            // const attrData = fileLines[i]
            //     .replace(/,,/g, ',null,')
            //     .match(/(".*?"|[^",]+)(?=\s*,|\s*$)/g);

            const attrData = fileLines[i].split(/,(?=(?:(?:[^"]*"){2})*[^"]*$)/);

            // console.log();
            // console.log( fileLines[i]);
            // console.log( attrData);

            if(attrData) {
                for(let j = 0; j < attrData.length; j++) {

                    let attr = stripQuotes(attrData[j]);

                    // console.log(attr + ' ' + typeof attr);
                    if(attr.length > 0) {

                        if(!isNaN(attr)) {
                            attr = attr * 1; // convert to number
                            Item[attrNames[j]] = attr;

                        } else {

                            if(attr.charAt(0) === '{' && attr.charAt(attr.length-1) === '}') {
                                // JSON object within string
                                const obj = JSON.parse(attr.replace(/""/g,'"'));
                                console.log('\n^^^^ obj: ' + obj);

                                Item[attrNames[j]] = obj;

                            } else {
                                Item[attrNames[j]] = attr;
                            }
                        }

                    }


                }
                // console.log(JSON.stringify(Item));

                const paramsPut = {
                    TableName: DYNAMODB_TABLE,
                    Item: Item
                };

                console.log('\n***** paramsPut');
                console.log(paramsPut);
                console.log();

                docClient.put(paramsPut, function (err, data) {
                    if (err) {
                        console.error("Unable to put item. Error JSON:", JSON.stringify(err, null, 2));
                        return 'error';

                    } else {
                        console.log("UpdateItem succeeded:", JSON.stringify(paramsPut.Item, null, 2));

                    }
                });

            }
        }
    }
});

function stripQuotes(str) {
    return str.replace(/^"(.*)"$/, '$1'); // strip quotes
}


