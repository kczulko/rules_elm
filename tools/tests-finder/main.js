
const fs = require('node:fs');

const args = process.argv.slice(2);
const fileToExamine = args[0];
const fileToCreate = args[1]

extractExposedPossiblyTests(
    fileToExamine,
    fs.createReadStream
).then((possiblyTests) => {
    fs.writeFile(fileToCreate, JSON.stringify(possiblyTests), err => {
        if (err) {
            console.log(err)
            process.exit(-1);
        }
    });
})
