Simple-Javascript-TestRunner
============================

A very simple JavaScript Test framework.  Written in CoffeeScript.


This project was made to test a simple client side web application.

I found many of the test frameworks available to be too complex and bloated for such a small, simple job.

Basic Use
---------

In order to use the framework, you only need to know about two classes.

*class* TestRunner
------------------------------------

This is a singleton class which is bound to the global window object. It has two methods you will need to use.

**Methods**
	* register(*class TestCase*)
		* Registers a TestCase class with the test runner
	* test()
		* Begins running all the tests in the registered classes.

*class* TestCase
------------------------------------

This is an abstract test case class which your test cases should extend.

Any methods of this class which start with "test_" will be run as a test by the TestRunner

**Methods**
	* setup()
		* Run before every test
	* teardown()
		* Run after every test
	* assertTrue(input)
		* Assert the input is true
	* assertFalse(input)
		* Assert the input is false
	* assertEqual(input1, input2)
		* Assert both inputs are equal - equal value *and* type
	* assertLength(array, length)
		* Assert the array length equals length
