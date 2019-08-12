import untangle
import sys
from dateutil import parser
from junit_xml import TestSuite, TestCase

# Get time taken to execute test in seconds for JUnit report
def getTimeTaken(startTime, endTime):
    st = parser.parse(startTime)
    et = parser.parse(endTime)
    timedelta = et-st
    return timedelta.seconds


if len(sys.argv) == 1:
    o = untangle.parse('failure.xml')
    print("No argument received, using failure.xml")
else:
    print("Argument received, using SharpBaggerTestResults.xml")
    o = untangle.parse(
        'C:\\jenkins\\workspace\\SharpController\\Jenkins\\pyscripts\\SharpBaggerTestResults.xml')

JunitTestCases = []
exitCode = 0
for CodesysTestCases in o.TestReport.Details.Sequence.TestCase:
    codesysTCName = str(CodesysTestCases['Name'])
    newTC = TestCase("","")
    newTC.status = CodesysTestCases.Result['State']
    newTC.elapsed_sec = getTimeTaken(CodesysTestCases.Timing.StartTime.cdata, CodesysTestCases.Timing.EndTime.cdata)
    chunksByUnderscore = codesysTCName
    chunksByUnderscore = chunksByUnderscore.split("_")

    chunksByColon = codesysTCName
    chunksByColon = chunksByColon.split(":")
    if chunksByUnderscore[0] == "FB":
        newTC.classname = chunksByUnderscore[0] + "_" + chunksByUnderscore[1]
        newTC.name = chunksByColon[1].strip() + ":" + chunksByColon[2]
    else:
        newTC.name = chunksByUnderscore[0]
        newTC.classname = "Test Script"
    if CodesysTestCases.Result['State'] == 'Failed':
        newTC.add_failure_info(CodesysTestCases.Result.AdditionalInformation.cdata)
        exitCode = 1
    JunitTestCases.append(newTC)

ts = TestSuite("SharpBagger Test Suite", JunitTestCases)

with open('C:\\jenkins\\workspace\\SharpController\\reports\\junitreport.xml', 'w') as f:
    TestSuite.to_file(f, [ts], prettyprint=True)
if exitCode != 0:
    print("Failing build due to test failure")
sys.exit(exitCode)