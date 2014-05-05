'''
Author: Ze'ev Gilovitz
Description: A very simple testing framework
  Useful for very small projects when direct access to the browser DOM is required.
'''

class TestController

  constructor: ->
    @registeredTests = []
    @pass = 0
    @fail = 0
    @messages = []

  register: (testCase) ->
    @registeredTests.push(testCase)

  test: ->
    tests = @build()
    @run(tests)
    @results()

    @pass = 0
    @fail = 0
    @messages = []

  build: ->
    @info("Collecting registered tests cases.")

    tests = []

    for testCase in @registeredTests
      for attributeName of testCase.prototype
        if attributeName.slice(0, 5) == "test_"
          @info("Test #{attributeName} is registered")
          tests.push([testCase, attributeName])

    return tests


  run: (tests) ->
    @info("========================")
    @info("Running collected tests.")
    @info("========================")


    for test in tests
      cls = test[0]
      attributeName = test[1]


      # Create a new instance for every test
      # We want them to have state...
      # But we don't want state to leak between tests
      obj = new cls()
      @info(attributeName)
      obj.setup()

      testLogs = []
      silencedLogger = (message) ->
        testLogs.push(message)

      logger = console.log
      console.log = silencedLogger

      try

        # We don't really want our tests to output logging
        # temporarily disable logging which isn't from the TestRunner

        obj[attributeName]()

        # Reinstate the logger
        console.log = logger
        
        @infoGood("OK")
        @pass++
      catch e
        # Try to reinstate the logger
        console.log = logger

        # If this is not a TestCaseException then
        # Throw it again, don't know how to handle it
        if (e not instanceof TestCaseException)
          obj.teardown()
          throw e



        # Immediately Print FAIL
        # Push a detailed message onto a queue of messages
        @infoBad("FAIL") 
        @messages.push(new TestCaseMessage(obj, attributeName, testLogs, e))
        @fail++


      # Always teardown
      obj.teardown()

  results: () ->
    @info("========================")
    @info("       Results")

    for message in @messages
      text = "
        Test #{message.testCase} in
        #{message.testClass.constructor.name} Failed
      "

      @infoBad(text)
      @info(message.exception)

      for log in  message.testLogs
        @info(log)

    if @pass > 0
      @infoGood("Pass: #{@pass}")

    if @fail > 0
      @infoBad("Fail: #{@fail}")


  info: (message) ->
    console.log(message)

  debug: (message) ->
    console.log(message)

  infoBad: (message) ->
    console.log("%c #{message}", 'color: red')

  infoGood: (message) ->
    console.log("%c #{message}", 'color: green')


class TestCase

  setup: ->
    return

  teardown: ->
    return

  assertTrue: (input1) ->
    try
      @assertEqual(input1, true)
    catch e
      e.type = "NotTrue"
      throw e

  assertFalse: (input1) ->
    try
      @assertEqual(input1, false)
    catch e
      e.type = "NotFalse"
      throw e

  assertEqual: (input1, input2) ->
    if input1 == input2
      return
    else
      message = "#{input1} != #{input2}"
      throw new TestCaseException("NotEqual", message)

  assertLength: (array, length) ->
    if array.length == length
      return
    else
      message = "Array length is not #{length}\n"
      message += "#{array.length} != #{length}"
      throw new TestCaseException("LengthNotEqual", message)


class TestCaseMessage
  constructor: (@testClass, @testCase, @testLogs, @exception) ->
    return


class TestCaseException extends Error
  constructor: (@type, @message) ->
    @error = new super()
    super
    return


window.TestRunner = TestRunner = new TestController()
window.TestCase = TestCase = TestCase

module.exports.TestRunner = TestRunner
module.exports.TestCase = TestCase