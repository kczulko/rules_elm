// This script is responsible for replacing 'check' function with some js code
// Copied from https://github.com/rtfeldman/node-test-runner/blob/eedf853fc9b45afd73a0db72decebdb856a69771/lib/Generate.js#L56-L74
// In case of any changes please remember to update this script acordingly

const fs = require('fs')

const testVariantDefinition =
  /^var\s+\$elm_explorations\$test\$Test\$Internal\$(?:ElmTestVariant__\w+|UnitTest|FuzzTest|Labeled|Skipped|Only|Batch)\s*=\s*(?:\w+\(\s*)?function\s*\([\w, ]*\)\s*\{\s*return *\{/gm;


const checkDefinition =
  /^(var\s+\$author\$project\$Test\$Runner\$Node\$check)\s*=\s*\$author\$project\$Test\$Runner\$Node\$checkHelperReplaceMe___;?$/m;


// Create a symbol, tag all `Test` constructors with it and make the `check`
// function look for it.
function addKernelTestChecking(content) {
  return (
    'var __elmTestSymbol = Symbol("elmTestSymbol");\n' +
    content
      .replace(testVariantDefinition, '$&__elmTestSymbol: __elmTestSymbol, ')
      .replace(
        checkDefinition,
        '$1 = value => value && value.__elmTestSymbol === __elmTestSymbol ? $elm$core$Maybe$Just(value) : $elm$core$Maybe$Nothing;'
      )
  );
}

const args = process.argv.slice(2);
const fileToAdjust = args[0];
const fileToCreate = args[1];

const fileToAdjustContent = fs.readFileSync(fileToAdjust).toString();

fs.writeFileSync(fileToCreate, addKernelTestChecking(fileToAdjustContent), err => {
    if (err) {
        console.log(err);
        process.exit(-1);
    }
})
