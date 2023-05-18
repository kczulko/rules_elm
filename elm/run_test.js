var failures = 0
var todos = []

function handleResults(response) {
    for (var key in response.results) {
        result = response.results[key]
        if (result !== null) {
            if (typeof result.todo !== "undefined") {
                todos.push(result);
            } else {
                failures++;
                console.log(result)
            }
        }
    }
}

var app = require(process.argv[2]).Elm.RulesElmMainTestsExecutor.init({
    flags: 0,
})

app.ports.send.subscribe(function(msg) {
    response = JSON.parse(msg)
    switch (response.type) {
        case "BEGIN":
            console.log(response.message)
            break
        case "ERROR":
            throw new Error(response.message)
        case "FINISHED":
            handleResults(response)
            app.ports.receive.send({
                "type": "SUMMARY",
                "duration": 0,
                "failures": failures,
                "todos": todos,
            })
            break
        case "RESULTS":
            handleResults(response)
            break
        case "SUMMARY":
            console.log(response.message)
            process.exit(response.exitCode)
        default:
            console.log(response)
            throw new Error(
                "Unrecognized message from worker:" + response.type
            )
    }
})

app.ports.receive.send({
    "type": "TEST",
    "index": -1,
})
